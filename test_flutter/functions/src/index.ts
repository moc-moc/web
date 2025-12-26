import * as admin from "firebase-admin";
import * as functions from "firebase-functions/v1";
import Stripe from "stripe";

admin.initializeApp();

const db = admin.firestore();

const stripeSecret = process.env.STRIPE_SECRET_KEY;
const stripeWebhookSecret = process.env.STRIPE_WEBHOOK_SECRET;

const stripe = stripeSecret ?
  new Stripe(stripeSecret, {apiVersion: "2024-06-20"}) :
  null;

type SubscriptionPayload = {
  planType: string;
  planId?: string | null;
  nextBillingAt?: FirebaseFirestore.Timestamp | null;
  trialEndAt?: FirebaseFirestore.Timestamp | null;
  trialStartAt?: FirebaseFirestore.Timestamp | null;
  isLifetime: boolean;
  promoLabel?: string | null;
  stripeCustomerId?: string | null;
  stripeSubscriptionId?: string | null;
};

export const createStripeCheckoutSession = functions.https.onCall(
  async (data, context) => {
    if (!stripe) {
      throw new functions.https.HttpsError(
        "failed-precondition",
        "Stripe is not configured.",
      );
    }

    const uid = context.auth?.uid;
    if (!uid) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "Authentication required.",
      );
    }

    const planId = data.planId as string | undefined;
    const currency = (data.currency as string | undefined)?.toUpperCase();
    const successUrl = data.successUrl as string | undefined;
    const cancelUrl = data.cancelUrl as string | undefined;
    if (!planId || !currency || !successUrl || !cancelUrl) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "planId, currency, successUrl, cancelUrl are required.",
      );
    }

    const userRef = db.collection("users").doc(uid);
    const [planSnap, userSnap] = await Promise.all([
      db.collection("plans").doc(planId).get(),
      userRef.get(),
    ]);
    if (!planSnap.exists) {
      throw new functions.https.HttpsError("not-found", "Plan not found.");
    }
    const planData = planSnap.data() ?? {};
    const userData = userSnap.data() ?? {};
    const existingCustomerId =
      userData.subscription?.stripeCustomerId ?? undefined;
    const priceInfo =
      planData.prices?.[currency] ?? planData.prices?.[currency.toLowerCase()];
    if (!priceInfo || typeof priceInfo.amount !== "number") {
      throw new functions.https.HttpsError(
        "failed-precondition",
        "Price is not configured for this currency.",
      );
    }
    // priceIdの優先順位: 1. 各通貨ごとのpriceId, 2. ルートレベルのpriceId
    const priceId = typeof priceInfo.priceId === "string" ?
      priceInfo.priceId.trim() :
      (typeof planData.priceId === "string" ?
        planData.priceId.trim() :
        undefined);
    const interval = planData.interval ?? "monthly";
    const mode = interval === "lifetime" ? "payment" : "subscription";

    const lineItem:
    Stripe.Checkout.SessionCreateParams.LineItem = priceId ?
      {
        price: priceId,
        quantity: 1,
      } :
      buildDynamicLineItem({
        planData,
        planId,
        currency,
        interval,
        priceInfo,
      });

    const session = await stripe.checkout.sessions.create({
      mode,
      success_url: successUrl,
      cancel_url: cancelUrl,
      customer: existingCustomerId,
      client_reference_id: uid,
      allow_promotion_codes: true,
      metadata: {
        planId,
        userId: uid,
      },
      line_items: [lineItem],
      subscription_data:
        mode === "subscription" && planData.trialDays ?
          {
            trial_period_days: planData.trialDays,
            metadata: {
              planId,
              userId: uid,
            },
          } :
          undefined,
    });

    return {
      sessionId: session.id,
      checkoutUrl: session.url,
    };
  },
);

export const stripeWebhook = functions.https.onRequest(async (req, res) => {
  if (req.method !== "POST") {
    res.status(405).send("Method Not Allowed");
    return;
  }
  if (!stripe) {
    res.status(200).send("Stripe not configured");
    return;
  }

  let event: Stripe.Event;
  try {
    if (stripeWebhookSecret) {
      const signature = req.headers["stripe-signature"] as string;
      event = stripe.webhooks.constructEvent(
        req.rawBody,
        signature,
        stripeWebhookSecret,
      );
    } else {
      event = req.body;
    }
  } catch (err) {
    functions.logger.error("Stripe webhook verification failed", err);
    res.status(400).send(`Webhook Error: ${(err as Error).message}`);
    return;
  }

  try {
    switch (event.type) {
    case "checkout.session.completed":
      await handleCheckoutCompleted(
        event.data.object as Stripe.Checkout.Session);
      break;
    case "invoice.paid":
      await handleInvoicePaid(event.data.object as Stripe.Invoice);
      break;
    case "customer.subscription.deleted":
      await handleSubscriptionCanceled(
          event.data.object as Stripe.Subscription,
      );
      break;
    default:
      functions.logger.info(`Unhandled Stripe event: ${event.type}`);
    }
    res.status(200).send({received: true});
  } catch (err) {
    functions.logger.error("Stripe webhook handler failed", err);
    res.status(500).send("Internal Server Error");
  }
});

export const verifyAppleReceipt = functions.https.onCall(
  async (data, context) => {
    const uid = context.auth?.uid;
    if (!uid) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "Authentication required.",
      );
    }
    const planId = data.planId as string | undefined;
    const receipt = data.receipt as string | undefined;
    if (!planId || !receipt) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "planId and receipt are required.",
      );
    }

    functions.logger.info("Received Apple receipt", {uid, planId});
    const planData = await fetchPlan(planId);
    if (!planData) {
      throw new functions.https.HttpsError("not-found", "Plan not found.");
    }

    // TODO: App Store Server APIでreceiptを検証
    await writeUserSubscription(uid, planData, {
      planType: planData.interval ?? "monthly",
      planId,
      trialEndAt: null,
      trialStartAt: null,
      nextBillingAt: null,
      isLifetime: planData.interval === "lifetime",
    });

    return {success: true};
  },
);

export const verifyGooglePlayReceipt = functions.https.onCall(
  async (data, context) => {
    const uid = context.auth?.uid;
    if (!uid) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "Authentication required.",
      );
    }
    const planId = data.planId as string | undefined;
    const purchaseToken = data.purchaseToken as string | undefined;
    if (!planId || !purchaseToken) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "planId and purchaseToken are required.",
      );
    }

    const planData = await fetchPlan(planId);
    if (!planData) {
      throw new functions.https.HttpsError("not-found", "Plan not found.");
    }

    functions.logger.info("Received Google Play purchase token", {
      uid,
      planId,
    });

    // TODO: Google Play Developer APIでpurchaseTokenを検証
    await writeUserSubscription(uid, planData, {
      planType: planData.interval ?? "monthly",
      planId,
      trialEndAt: null,
      trialStartAt: null,
      nextBillingAt: null,
      isLifetime: planData.interval === "lifetime",
    });

    return {success: true};
  },
);

export const createStripePortalSession = functions.https.onCall(
  async (data, context) => {
    if (!stripe) {
      throw new functions.https.HttpsError(
        "failed-precondition",
        "Stripe is not configured.",
      );
    }
    const uid = context.auth?.uid;
    if (!uid) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "Authentication required.",
      );
    }
    const returnUrl = data.returnUrl as string | undefined;
    if (!returnUrl) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "returnUrl is required.",
      );
    }
    const userSnap = await db.collection("users").doc(uid).get();
    const customerId = userSnap.data()?.subscription?.stripeCustomerId;
    if (!customerId) {
      throw new functions.https.HttpsError(
        "failed-precondition",
        "Stripe customer is not linked to this account.",
      );
    }
    const portalSession = await stripe.billingPortal.sessions.create({
      customer: customerId,
      return_url: returnUrl,
    });
    return {url: portalSession.url};
  },
);

export const syncSubscriptionStatus = functions.https.onCall(
  async (data, context) => {
    const uid = context.auth?.uid;
    if (!uid) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "Authentication required.",
      );
    }
    const userSnap = await db.collection("users").doc(uid).get();
    if (!userSnap.exists) {
      throw new functions.https.HttpsError("not-found", "User not found.");
    }
    const subscription = userSnap.data()?.subscription;
    if (!subscription) {
      return {status: "no-subscription"};
    }
    if (subscription.isLifetime) {
      return {status: "lifetime"};
    }
    if (subscription.stripeSubscriptionId && stripe) {
      const planId =
        subscription.planId ||
        (subscription.metadata && subscription.metadata.planId);
      if (!planId) {
        return {status: "missing-plan"};
      }
      const planData = await fetchPlan(planId);
      if (!planData) {
        return {status: "missing-plan"};
      }
      const stripeSubscription = await stripe.subscriptions.retrieve(
        subscription.stripeSubscriptionId,
      );
      await upsertFromStripeSubscription(
        uid,
        planId,
        planData,
        stripeSubscription,
      );
      return {status: "updated"};
    }
    return {status: "noop"};
  },
);

export const scheduledSubscriptionAudit = functions.pubsub
  .schedule("every 24 hours")
  .timeZone("Asia/Tokyo")
  .onRun(async () => {
    const now = admin.firestore.Timestamp.now();
    const snapshot = await db
      .collection("users")
      .where("subscription.isLifetime", "==", false)
      .where("subscription.nextBillingAt", "<=", now)
      .get();

    await Promise.all(
      snapshot.docs.map((doc) =>
        writeUserSubscription(doc.id, null, {
          planType: "free",
          planId: null,
          nextBillingAt: null,
          trialEndAt: null,
          trialStartAt: null,
          isLifetime: false,
          stripeSubscriptionId: null,
        }),
      ),
    );
    if (!snapshot.empty) {
      functions.logger.info(`Expired ${snapshot.size} subscriptions.`);
    }
    return null;
  });

/**
 * Parameters for building a dynamic line item when no priceId is supplied.
 */
type DynamicLineItemParams = {
  planData: FirebaseFirestore.DocumentData;
  planId: string;
  currency: string;
  interval: string;
  priceInfo: Record<string, unknown>;
};

/**
 * Converts a Firestore Timestamp to a JavaScript Date.
 * @param {unknown} value - The value to convert.
 * @return {Date | null} The converted Date or null.
 */
function timestampToDate(value: unknown): Date | null {
  if (!value) return null;
  if (value instanceof admin.firestore.Timestamp) {
    return value.toDate();
  }
  if (value instanceof Date) {
    return value;
  }
  // Handle Firestore Timestamp-like objects
  if (typeof value === "object" && value !== null) {
    const ts = value as {seconds?: number; nanoseconds?: number};
    if (typeof ts.seconds === "number") {
      return new Date(ts.seconds * 1000 + (ts.nanoseconds ?? 0) / 1000000);
    }
  }
  return null;
}

/**
 * Checks if a promotional period is currently active.
 * @param {FirebaseFirestore.DocumentData} promo - The promo data.
 * @return {boolean} True if the promo is active.
 */
function isPromoActive(
  promo: FirebaseFirestore.DocumentData | undefined,
): boolean {
  if (!promo) return false;
  const now = new Date();
  const startsAt = timestampToDate(promo.startsAt);
  const endsAt = timestampToDate(promo.endsAt);
  const hasStarted = !startsAt || now >= startsAt;
  const notEnded = !endsAt || now <= endsAt;
  return hasStarted && notEnded;
}

/**
 * Builds a line item using dynamic price_data for legacy plans.
 * @param {DynamicLineItemParams} params - Data required to build the item.
 * @return {{price_data: Stripe.Checkout.SessionCreateParams.LineItemPriceData,
 *   quantity: number}} Checkout line item definition.
 */
function buildDynamicLineItem(
  params: DynamicLineItemParams,
): Stripe.Checkout.SessionCreateParams.LineItem {
  const {planData, planId, currency, interval, priceInfo} = params;
  const baseAmount = priceInfo.amount as number;
  const promo = planData.promo;
  const promoActive = isPromoActive(promo);
  const currencyUpper = currency.toUpperCase();

  let unitAmount = baseAmount;

  // 優先順位1: 期間限定の初回限定固定価格（最優先）
  if (promoActive && promo?.introductoryFixedPrices) {
    const introFixedPrice =
      promo.introductoryFixedPrices[currencyUpper] ??
      promo.introductoryFixedPrices[currency.toLowerCase()];
    if (
      typeof introFixedPrice === "number" &&
      introFixedPrice > 0 &&
      introFixedPrice < baseAmount
    ) {
      unitAmount = introFixedPrice;
    }
  } else if (promoActive && promo?.fixedPrices) {
    // 優先順位2: 期間限定の固定価格
    const fixedPrice =
      promo.fixedPrices[currencyUpper] ??
      promo.fixedPrices[currency.toLowerCase()];
    if (
      typeof fixedPrice === "number" &&
      fixedPrice > 0 &&
      fixedPrice < baseAmount
    ) {
      unitAmount = fixedPrice;
    }
  } else if (promoActive && promo?.discountRate) {
    // 優先順位3: 期間限定の割引率
    const promoRate =
      typeof promo.discountRate === "number" ? promo.discountRate : 0;
    if (promoRate > 0 && promoRate < 1) {
      unitAmount = Math.round(baseAmount * (1 - promoRate));
    }
  } else {
    // 優先順位4: 通常の初回割引価格
    const introAmount = priceInfo.introductoryAmount as number | undefined;
    if (introAmount && introAmount > 0 && introAmount < baseAmount) {
      unitAmount = introAmount;
    }
  }

  const recurring:
  Stripe.Checkout.SessionCreateParams.LineItem.PriceData
    .Recurring | undefined =
    interval !== "lifetime" ?
      {
        interval: resolveStripeInterval(interval),
      } :
      undefined;

  // product_dataには既存のProduct IDを設定できないため、nameのみ設定
  // price_dataを使う場合は、動的に新しいProductが作成されます
  const productData:
    Stripe.Checkout.SessionCreateParams.LineItem.PriceData.ProductData =
    {
      name: planData.displayName ?? planId,
    };

  return {
    price_data: {
      currency: currency.toLowerCase(),
      unit_amount: unitAmount,
      product_data: productData,
      recurring,
    },
    quantity: 1,
  } as Stripe.Checkout.SessionCreateParams.LineItem;
}

/**
 * Handles checkout session completion event from Stripe.
 * @param {Stripe.Checkout.Session} session - The checkout session object.
 */
async function handleCheckoutCompleted(session: Stripe.Checkout.Session) {
  const userId = session.metadata?.userId;
  const planId = session.metadata?.planId;
  if (!userId || !planId) return;
  const planData = await fetchPlan(planId);
  if (!planData) return;
  const customerId =
    typeof session.customer === "string" ?
      session.customer :
      (session.customer as Stripe.Customer | null)?.id ?? null;

  if (session.mode === "payment") {
    await writeUserSubscription(userId, planData, {
      planType: planData.interval ?? "lifetime",
      planId,
      isLifetime: true,
      nextBillingAt: null,
      trialEndAt: null,
      trialStartAt: null,
      stripeCustomerId: customerId,
      stripeSubscriptionId: null,
    });
    return;
  }

  if (session.subscription && stripe) {
    const subscription = await stripe.subscriptions.retrieve(
      session.subscription as string,
    );
    await upsertFromStripeSubscription(
      userId,
      planId,
      planData,
      subscription,
      customerId,
    );
  }
}

/**
 * Handles invoice paid event from Stripe.
 * @param {Stripe.Invoice} invoice - The invoice object.
 */
async function handleInvoicePaid(invoice: Stripe.Invoice) {
  if (!invoice.subscription || !stripe) return;
  const subscription = await stripe.subscriptions.retrieve(
    invoice.subscription as string,
  );
  const userId = (subscription.metadata as Record<string, string> | null)
    ?.userId;
  const planId = (subscription.metadata as Record<string, string> | null)
    ?.planId;
  if (!userId || !planId) return;
  const planData = await fetchPlan(planId);
  if (!planData) return;
  await upsertFromStripeSubscription(userId, planId, planData, subscription);
}

/**
 * Handles subscription canceled event from Stripe.
 * @param {Stripe.Subscription} subscription - The subscription object.
 */
async function handleSubscriptionCanceled(subscription: Stripe.Subscription) {
  const userId = (subscription.metadata as Record<string, string> | null)
    ?.userId;
  if (!userId) return;
  await writeUserSubscription(userId, null, {
    planType: "free",
    planId: null,
    nextBillingAt: null,
    trialEndAt: null,
    trialStartAt: null,
    isLifetime: false,
    stripeSubscriptionId: null,
  });
}

/**
 * Fetches plan data from Firestore.
 * @param {string} planId - The plan ID.
 * @return {Promise<FirebaseFirestore.DocumentData | undefined>} Plan data.
 */
async function fetchPlan(planId: string) {
  const snap = await db.collection("plans").doc(planId).get();
  return snap.data();
}

/**
 * Upserts user subscription from Stripe subscription data.
 * @param {string} userId - The user ID.
 * @param {string} planId - The plan ID.
 * @param {FirebaseFirestore.DocumentData} planData - The plan data.
 * @param {Stripe.Subscription} subscription - The Stripe subscription object.
 * @param {string | null} customerId - Optional customer ID.
 */
async function upsertFromStripeSubscription(
  userId: string,
  planId: string,
  planData: FirebaseFirestore.DocumentData,
  subscription: Stripe.Subscription,
  customerId?: string | null,
) {
  const nextBillingAt = subscription.current_period_end ?
    admin.firestore.Timestamp.fromMillis(
      subscription.current_period_end * 1000) :
    null;
  const trialEnd = subscription.trial_end ?
    admin.firestore.Timestamp.fromMillis(subscription.trial_end * 1000) :
    null;
  const trialStart = subscription.trial_start ?
    admin.firestore.Timestamp.fromMillis(
      subscription.trial_start * 1000,
    ) :
    null;

  await writeUserSubscription(userId, planData, {
    planType: planData.interval ?? "monthly",
    planId,
    nextBillingAt,
    trialEndAt: trialEnd,
    trialStartAt: trialStart,
    isLifetime: planData.interval === "lifetime",
    stripeCustomerId:
      customerId ??
      (typeof subscription.customer === "string" ?
        subscription.customer :
        (subscription.customer as Stripe.Customer | null)?.id ?? null),
    stripeSubscriptionId: subscription.id,
  });
}

/**
 * Writes user subscription data to Firestore.
 * @param {string} userId - The user ID.
 * @param {FirebaseFirestore.DocumentData | null} planData - The plan data.
 * @param {SubscriptionPayload} payload - The subscription payload.
 */
async function writeUserSubscription(
  userId: string,
  planData: FirebaseFirestore.DocumentData | null,
  payload: SubscriptionPayload,
) {
  const userRef = db.collection("users").doc(userId);
  const currentData = (await userRef.get()).data() ?? {};
  const currentSubscription = currentData.subscription ?? {};

  const subscription = {
    ...currentSubscription,
    planType: payload.planType,
    planId: payload.planId ?? currentSubscription.planId ?? null,
    nextBillingAt: payload.nextBillingAt ?? null,
    trialEndAt: payload.trialEndAt ?? null,
    trialStartAt: payload.trialStartAt ?? null,
    isLifetime: payload.isLifetime,
    promoLabel: payload.promoLabel ?? planData?.promo?.label ?? null,
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  };

  if (payload.stripeCustomerId !== undefined) {
    subscription.stripeCustomerId = payload.stripeCustomerId;
  }
  if (payload.stripeSubscriptionId !== undefined) {
    subscription.stripeSubscriptionId = payload.stripeSubscriptionId;
  }

  await userRef.set(
    {
      subscription,
      planType: subscription.planType,
      nextBillingAt: subscription.nextBillingAt,
    },
    {merge: true},
  );
}

/**
 * Resolves Stripe interval from plan interval.
 * @param {string} interval - The plan interval.
 * @return {string} Stripe interval.
 */
function resolveStripeInterval(
  interval: string,
): Stripe.Price.Recurring.Interval {
  switch (interval) {
  case "weekly":
    return "week";
  case "yearly":
    return "year";
  case "monthly":
  default:
    return "month";
  }
}
