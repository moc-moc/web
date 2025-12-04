import 'package:flutter/material.dart';
import 'package:test_flutter/core/route_generator.dart';
import 'package:test_flutter/presentation/screens/auth/signup_login_screen.dart';
import 'package:test_flutter/presentation/screens/auth/initial_setup_screen.dart';
import 'package:test_flutter/presentation/screens/auth/initial_goal_screen.dart';
import 'package:test_flutter/presentation/screens/auth/email_verification_screen.dart';
import 'package:test_flutter/presentation/screens/home/home_screen.dart';
import 'package:test_flutter/presentation/screens/tracking/tracking_setting.dart';
import 'package:test_flutter/presentation/screens/tracking/tracking.dart';
import 'package:test_flutter/presentation/screens/tracking/tracking_finished.dart';
import 'package:test_flutter/presentation/screens/goal/goal.dart';
import 'package:test_flutter/presentation/screens/report/report.dart';
import 'package:test_flutter/presentation/screens/setting/settings_screen.dart';
import 'package:test_flutter/presentation/screens/setting/account_settings.dart';
import 'package:test_flutter/presentation/screens/setting/notification_settings.dart';
import 'package:test_flutter/presentation/screens/setting/display_settings.dart';
import 'package:test_flutter/presentation/screens/setting/subscription.dart';
import 'package:test_flutter/presentation/screens/setting/subscription_admin.dart';
import 'package:test_flutter/presentation/screens/setting/contact_us.dart';
import 'package:test_flutter/presentation/screens/setting/event_preview.dart';
import 'package:test_flutter/presentation/screens/setting/widget_catalog_screen.dart';
import 'package:test_flutter/presentation/screens/setting/color_preview_screen.dart';
import 'package:test_flutter/presentation/screens/event/goal_achieved_event.dart';
import 'package:test_flutter/presentation/screens/event/goal_set_event.dart';
import 'package:test_flutter/presentation/screens/event/goal_period_ended_event.dart';
import 'package:test_flutter/presentation/screens/event/streak_milestone_event.dart';
import 'package:test_flutter/presentation/screens/event/total_hours_milestone_event.dart';
import 'package:test_flutter/presentation/screens/event/countdown_ended_event.dart';
import 'package:test_flutter/presentation/screens/event/countdown_set_event.dart';
import 'package:test_flutter/presentation/screens/event/level_up_event.dart';
import 'package:test_flutter/presentation/screens/event/level_reset_event.dart';
import 'package:test_flutter/presentation/screens/friend/friend.dart';
import 'package:test_flutter/presentation/screens/friend/friend_list.dart';
import 'package:test_flutter/presentation/screens/friend/friend_leaderboard.dart';
import 'package:test_flutter/presentation/screens/tutorial/tutorial_screen.dart';

class AppRoutes {
  // Tutorial Route
  static const String tutorial = '/tutorial';

  // Auth Routes
  static const String signupLogin = '/signup-login';
  static const String initialSetup = '/initial-setup';
  static const String initialGoal = '/initial-goal';
  static const String emailVerification = '/email-verification';

  // Main Routes
  static const String home = '/';
  static const String homeNew = '/home-new'; // 新デザインシステム版
  static const String report = '/report';
  static const String reportNew = '/report-new'; // 新デザインシステム版
  static const String goal = '/goal';
  static const String goalNew = '/goal-new'; // 新デザインシステム版

  // Tracking Routes (New)
  static const String trackingSettingNew = '/tracking-setting-new';
  static const String trackingNew = '/tracking-new';
  static const String trackingFinishedNew = '/tracking-finished-new';
  // Settings Routes
  static const String settings = '/settings';
  static const String settingsNew = '/settings-new';
  static const String accountSettingsNew = '/account-settings-new';
  static const String notificationSettingsNew = '/notification-settings-new';
  static const String displaySettingsNew = '/display-settings-new';
  static const String subscriptionNew = '/subscription-new';
  static const String subscriptionAdmin = '/subscription-admin';
  static const String contactUsNew = '/contact-us-new';
  static const String eventPreviewNew = '/event-preview-new';
  static const String colorPreview = '/color-preview';
  static const String widgetCatalog = '/widget-catalog';
  static const String friend = '/friend';
  static const String friendList = '/friend-list';
  static const String friendLeaderboard = '/friend-leaderboard';
  // Event Routes (New)
  static const String goalAchievedEvent = '/goal-achieved-event';
  static const String goalSetEvent = '/goal-set-event';
  static const String goalPeriodEndedEvent = '/goal-period-ended-event';
  static const String streakMilestoneEvent = '/streak-milestone-event';
  static const String totalHoursMilestoneEvent = '/total-hours-milestone-event';
  static const String countdownEndedEvent = '/countdown-ended-event';
  static const String countdownSetEvent = '/countdown-set-event';
  static const String levelUpEvent = '/level-up-event';
  static const String levelResetEvent = '/level-reset-event';
}

class RouteGenerator {
  /// ルート名とウィジェットのマッピング
  /// 各主要画面は自身でボトムナビゲーションを保持
  static final Map<String, Widget Function()> _routeMap = {
    // Tutorial Route
    AppRoutes.tutorial: () => const TutorialScreen(),

    // Auth Routes
    AppRoutes.signupLogin: () => const SignupLoginScreen(),
    AppRoutes.initialSetup: () => const InitialSetupScreen(),
    AppRoutes.initialGoal: () => const InitialGoalScreen(),
    AppRoutes.emailVerification: () => const EmailVerificationScreen(),

    // Main Routes
    AppRoutes.home: () => const HomeScreenNew(),
    AppRoutes.homeNew: () => const HomeScreenNew(), // 新デザインシステム版
    AppRoutes.report: () => const ReportScreenNew(),
    AppRoutes.reportNew: () => const ReportScreenNew(), // 新デザインシステム版
    AppRoutes.goal: () => const GoalScreenNew(),
    AppRoutes.goalNew: () => const GoalScreenNew(), // 新デザインシステム版
    // Tracking Routes (New)
    AppRoutes.trackingSettingNew: () => const TrackingSettingScreenNew(),
    AppRoutes.trackingNew: () => const TrackingScreenNew(),
    AppRoutes.trackingFinishedNew: () => const TrackingFinishedScreenNew(),

    // Settings Routes
    AppRoutes.settings: () => const SettingsScreenNew(),
    AppRoutes.accountSettingsNew: () => const AccountSettingsScreenNew(),
    AppRoutes.notificationSettingsNew: () =>
        const NotificationSettingsScreenNew(),
    AppRoutes.displaySettingsNew: () => const DisplaySettingsScreenNew(),

    // Settings Routes (New)
    AppRoutes.settingsNew: () => const SettingsScreenNew(),
    AppRoutes.subscriptionNew: () => const SubscriptionScreenNew(),
    AppRoutes.subscriptionAdmin: () => const SubscriptionAdminScreen(),
    AppRoutes.contactUsNew: () => const ContactUsScreenNew(),
    AppRoutes.eventPreviewNew: () => const EventPreviewScreenNew(),
    AppRoutes.colorPreview: () => const ColorPreviewScreen(),
    AppRoutes.widgetCatalog: () => const WidgetCatalogScreen(),
    AppRoutes.friend: () => const FriendScreenNew(),
    AppRoutes.friendList: () => const FriendListScreenNew(),
    AppRoutes.friendLeaderboard: () => const FriendLeaderboardScreen(),
    // Event Routes (New)
    AppRoutes.goalAchievedEvent: () => const GoalAchievedEventScreen(),
    AppRoutes.goalSetEvent: () => const GoalSetEventScreen(),
    AppRoutes.goalPeriodEndedEvent: () => const GoalPeriodEndedEventScreen(),
    AppRoutes.streakMilestoneEvent: () => const StreakMilestoneEventScreen(),
    AppRoutes.totalHoursMilestoneEvent: () =>
        const TotalHoursMilestoneEventScreen(),
    AppRoutes.countdownEndedEvent: () => const CountdownEndedEventScreen(),
    AppRoutes.countdownSetEvent: () => const CountdownSetEventScreen(),
    AppRoutes.levelUpEvent: () => const LevelUpEventScreen(),
    AppRoutes.levelResetEvent: () => const LevelResetEventScreen(),
  };

  /// MaterialAppのroutesプロパティへ渡すためのWidgetBuilderマップ
  static Map<String, WidgetBuilder> get materialRouteBuilders {
    return {
      for (final entry in _routeMap.entries) entry.key: (_) => entry.value(),
    };
  }

  /// ルート生成メイン関数
  /// CoreMkの汎用関数を利用してルートを生成
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // CountdownSetEventScreenの場合は引数を処理
    if (settings.name == AppRoutes.countdownSetEvent) {
      final arguments = settings.arguments;
      if (arguments is Map<String, dynamic>) {
        final eventName = arguments['eventName'] as String?;
        final remainingDays = arguments['remainingDays'] as int?;
        return RouteMk.createMaterialPageRoute(
          widget: CountdownSetEventScreen(
            eventName: eventName,
            remainingDays: remainingDays,
          ),
          settings: settings,
        );
      }
    }

    // GoalPeriodEndedEventScreenの場合は引数を処理
    if (settings.name == AppRoutes.goalPeriodEndedEvent) {
      final arguments = settings.arguments;
      if (arguments is Map<String, dynamic>) {
        final goalName = arguments['goalName'] as String?;
        final targetHours = arguments['targetHours'] as double?;
        final achievedHours = arguments['achievedHours'] as double?;
        final progress = arguments['progress'] as double?;
        final consecutiveDays = arguments['consecutiveDays'] as int?;
        final period = arguments['period'] as String?;
        final goalId = arguments['goalId'] as String?;
        return RouteMk.createMaterialPageRoute(
          widget: GoalPeriodEndedEventScreen(
            goalName: goalName,
            targetHours: targetHours,
            achievedHours: achievedHours,
            progress: progress,
            consecutiveDays: consecutiveDays,
            period: period,
            goalId: goalId,
          ),
          settings: settings,
        );
      }
    }

    // GoalSetEventScreenの場合は引数を処理
    if (settings.name == AppRoutes.goalSetEvent) {
      final arguments = settings.arguments;
      if (arguments is Map<String, dynamic>) {
        final goalTitle = arguments['goalTitle'] as String?;
        final targetTime = arguments['targetTime'] as int?;
        final consecutiveDays = arguments['consecutiveDays'] as int?;
        final durationDays = arguments['durationDays'] as int?;
        final consecutivePeriodAchievements =
            arguments['consecutivePeriodAchievements'] as int?;
        final detectionItem = arguments['detectionItem'] as String?;
        return RouteMk.createMaterialPageRoute(
          widget: GoalSetEventScreen(
            goalTitle: goalTitle,
            targetTime: targetTime,
            consecutiveDays: consecutiveDays,
            durationDays: durationDays,
            consecutivePeriodAchievements: consecutivePeriodAchievements,
            detectionItem: detectionItem,
          ),
          settings: settings,
        );
      }
    }

    // StreakMilestoneEventScreenの場合は引数を処理
    if (settings.name == AppRoutes.streakMilestoneEvent) {
      final arguments = settings.arguments;
      if (arguments is Map<String, dynamic>) {
        final days = arguments['days'] as int?;
        final nextMilestone = arguments['nextMilestone'] as int?;
        return RouteMk.createMaterialPageRoute(
          widget: StreakMilestoneEventScreen(
            days: days,
            nextMilestone: nextMilestone,
          ),
          settings: settings,
        );
      }
    }
    // ルートマップからルートを生成
    final route = RouteMk.generateRoute(
      settings: settings,
      routeMap: _routeMap,
    );

    // ルートが見つからない場合（404エラーページが返された場合）の処理
    // これは通常発生しないはずですが、念のためログを出力
    if (route.settings.name == settings.name &&
        route.settings.name != null &&
        !_routeMap.containsKey(route.settings.name)) {
      debugPrint('⚠️ [RouteGenerator] ルートが見つかりませんでした: ${route.settings.name}');
      debugPrint('   - 登録されているルート: ${_routeMap.keys.join(", ")}');
    }

    return route;
  }
}
