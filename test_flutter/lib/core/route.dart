import 'package:flutter/material.dart';
import 'package:test_flutter/core/route_generator.dart';
import 'package:test_flutter/presentation/screens/auth/signup_login_screen.dart';
import 'package:test_flutter/presentation/screens/auth/initial_setup_screen.dart';
import 'package:test_flutter/presentation/screens/auth/initial_goal_screen.dart';
import 'package:test_flutter/presentation/screens/home/home_screen.dart';
import 'package:test_flutter/presentation/screens/tracking/tracking_setting.dart';
import 'package:test_flutter/presentation/screens/tracking/tracking.dart';
import 'package:test_flutter/presentation/screens/tracking/tracking_finished.dart';
import 'package:test_flutter/presentation/screens/goal/goal.dart';
import 'package:test_flutter/presentation/screens/report/report.dart';
import 'package:test_flutter/presentation/screens/friend/friend.dart';
import 'package:test_flutter/presentation/screens/setting/settings_screen.dart';
import 'package:test_flutter/presentation/screens/setting/account_settings.dart';
import 'package:test_flutter/presentation/screens/setting/notification_settings.dart';
import 'package:test_flutter/presentation/screens/setting/display_settings.dart';
import 'package:test_flutter/presentation/screens/setting/subscription.dart';
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

class AppRoutes {
  // Auth Routes
  static const String signupLogin = '/signup-login';
  static const String initialSetup = '/initial-setup';
  static const String initialGoal = '/initial-goal';

  // Main Routes
  static const String home = '/';
  static const String homeNew = '/home-new'; // 新デザインシステム版
  static const String report = '/report';
  static const String reportNew = '/report-new'; // 新デザインシステム版
  static const String goal = '/goal';
  static const String goalNew = '/goal-new'; // 新デザインシステム版
  static const String friend = '/friend';
  static const String friendNew = '/friend-new'; // 新デザインシステム版
  static const String friendList = '/friend-list'; // フレンドリスト画面

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
  static const String contactUsNew = '/contact-us-new';
  static const String eventPreviewNew = '/event-preview-new';
  static const String colorPreview = '/color-preview';
  static const String widgetCatalog = '/widget-catalog';

  // Event Routes (New)
  static const String goalAchievedEvent = '/goal-achieved-event';
  static const String goalSetEvent = '/goal-set-event';
  static const String goalPeriodEndedEvent = '/goal-period-ended-event';
  static const String streakMilestoneEvent = '/streak-milestone-event';
  static const String totalHoursMilestoneEvent = '/total-hours-milestone-event';
  static const String countdownEndedEvent = '/countdown-ended-event';
  static const String countdownSetEvent = '/countdown-set-event';
}

class RouteGenerator {
  /// ルート名とウィジェットのマッピング
  /// 各主要画面は自身でボトムナビゲーションを保持
  static final Map<String, Widget Function()> _routeMap = {
    // Auth Routes
    AppRoutes.signupLogin: () => const SignupLoginScreen(),
    AppRoutes.initialSetup: () => const InitialSetupScreen(),
    AppRoutes.initialGoal: () => const InitialGoalScreen(),

    // Main Routes
    AppRoutes.home: () => const HomeScreenNew(),
    AppRoutes.homeNew: () => const HomeScreenNew(), // 新デザインシステム版
    AppRoutes.report: () => const ReportScreenNew(),
    AppRoutes.reportNew: () => const ReportScreenNew(), // 新デザインシステム版
    AppRoutes.goal: () => const GoalScreenNew(),
    AppRoutes.goalNew: () => const GoalScreenNew(), // 新デザインシステム版
    AppRoutes.friend: () => const FriendScreenNew(),
    AppRoutes.friendNew: () => const FriendScreenNew(), // 新デザインシステム版
    AppRoutes.friendList: () => const FriendListScreenNew(), // フレンドリスト画面
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
    AppRoutes.contactUsNew: () => const ContactUsScreenNew(),
    AppRoutes.eventPreviewNew: () => const EventPreviewScreenNew(),
    AppRoutes.colorPreview: () => const ColorPreviewScreen(),
    AppRoutes.widgetCatalog: () => const WidgetCatalogScreen(),

    // Event Routes (New)
    AppRoutes.goalAchievedEvent: () => const GoalAchievedEventScreen(),
    AppRoutes.goalSetEvent: () => const GoalSetEventScreen(),
    AppRoutes.goalPeriodEndedEvent: () => const GoalPeriodEndedEventScreen(),
    AppRoutes.streakMilestoneEvent: () => const StreakMilestoneEventScreen(),
    AppRoutes.totalHoursMilestoneEvent: () =>
        const TotalHoursMilestoneEventScreen(),
    AppRoutes.countdownEndedEvent: () => const CountdownEndedEventScreen(),
    AppRoutes.countdownSetEvent: () => const CountdownSetEventScreen(),
  };

  /// ルート生成メイン関数
  /// CoreMkの汎用関数を利用してルートを生成
  static Route<dynamic> generateRoute(RouteSettings settings) {
    return RouteMk.generateRoute(settings: settings, routeMap: _routeMap);
  }
}
