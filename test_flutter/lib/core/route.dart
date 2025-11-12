import 'package:flutter/material.dart';
import 'package:test_flutter/presentation/screens/Goal/setgoal.dart';
import 'package:test_flutter/presentation/screens/Goal/settinggoal.dart';
import 'package:test_flutter/presentation/widgets/navigation.dart';
import 'package:test_flutter/core/route_generator.dart';
import 'package:test_flutter/presentation/screens/tracking/tracking.dart';
import 'package:test_flutter/presentation/screens/tracking/tracking_setting.dart';
import 'package:test_flutter/presentation/screens/tracking/tracking_finished.dart';
import 'package:test_flutter/presentation/screens/setting/settings_screen.dart';
import 'package:test_flutter/presentation/screens/setting/account_settings_screen.dart';
import 'package:test_flutter/presentation/screens/setting/notification_settings_screen.dart';
import 'package:test_flutter/presentation/screens/setting/display_settings_screen.dart';
import 'package:test_flutter/presentation/screens/setting/time_settings_screen.dart';
import 'package:test_flutter/presentation/screens/auth/signup_login_screen.dart';
import 'package:test_flutter/presentation/screens/auth/initial_setup_screen.dart';
import 'package:test_flutter/presentation/screens/auth/initial_goal_screen.dart';
import 'package:test_flutter/presentation/screens/home/home_screen_new.dart';
import 'package:test_flutter/presentation/screens/tracking/tracking_setting_new.dart';
import 'package:test_flutter/presentation/screens/tracking/tracking_new.dart';
import 'package:test_flutter/presentation/screens/tracking/tracking_finished_new.dart';
import 'package:test_flutter/presentation/screens/goal/goal_new.dart';
import 'package:test_flutter/presentation/screens/report/report_new.dart';
import 'package:test_flutter/presentation/screens/setting/settings_screen_new.dart';
import 'package:test_flutter/presentation/screens/setting/account_settings_new.dart';
import 'package:test_flutter/presentation/screens/setting/notification_settings_new.dart';
import 'package:test_flutter/presentation/screens/setting/display_settings_new.dart';
import 'package:test_flutter/presentation/screens/setting/subscription_new.dart';
import 'package:test_flutter/presentation/screens/setting/event_preview_new.dart';
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

  // Tracking Routes (New)
  static const String trackingSettingNew = '/tracking-setting-new';
  static const String trackingNew = '/tracking-new';
  static const String trackingFinishedNew = '/tracking-finished-new';
  static const String setgoal = '/setgoal';
  static const String settinggoal = '/settinggoal';
  static const String setcountdown = '/setcountdown';
  static const String achivedgoal = '/achivedgoal';
  static const String consecutiveDays = '/consecutiveDays';
  static const String finishedCountdown = '/finishedCountdown';
  static const String finishedGoalTerm = '/finishedGoalTerm';
  static const String focusTotalTime = '/focusTotalTime';
  static const String setCountdown = '/setCountdown';
  static const String setGoal = '/setGoal';
  static const String setEvent = '/setEvent';
  static const String profile = '/profile';
  static const String profileedit = '/profileedit';
  static const String subscription = '/subscription';
  static const String firstsetting = '/firstsetting';
  static const String notification = '/notification';
  static const String tracking = '/tracking';
  static const String trackingsetting = '/trackingsetting';
  static const String trackingfinished = '/trackingfinished';
  static const String resettime = '/resettime';
  static const String settings = '/settings';
  static const String accountSettings = '/accountSettings';
  static const String accountSettingsNew = '/account-settings-new';
  static const String notificationSettings = '/notificationSettings';
  static const String notificationSettingsNew = '/notification-settings-new';
  static const String displaySettings = '/displaySettings';
  static const String displaySettingsNew = '/display-settings-new';
  static const String timeSettings = '/timeSettings';

  // Settings Routes (New)
  static const String settingsNew = '/settings-new';
  static const String subscriptionNew = '/subscription-new';
  static const String eventPreviewNew = '/event-preview-new';

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
  /// home、report、goalはBottomNavigationBarScreenを使用
  static final Map<String, Widget Function()> _routeMap = {
    // Auth Routes
    AppRoutes.signupLogin: () => const SignupLoginScreen(),
    AppRoutes.initialSetup: () => const InitialSetupScreen(),
    AppRoutes.initialGoal: () => const InitialGoalScreen(),

    // Main Routes
    AppRoutes.home: () => const BottomNavigationBarScreen(initialIndex: 0),
    AppRoutes.homeNew: () => const HomeScreenNew(), // 新デザインシステム版
    AppRoutes.report: () => const BottomNavigationBarScreen(initialIndex: 2),
    AppRoutes.reportNew: () => const ReportScreenNew(), // 新デザインシステム版
    AppRoutes.goal: () => const BottomNavigationBarScreen(initialIndex: 1),
    AppRoutes.goalNew: () => const GoalScreenNew(), // 新デザインシステム版
    // Tracking Routes (New)
    AppRoutes.trackingSettingNew: () => const TrackingSettingScreenNew(),
    AppRoutes.trackingNew: () => const TrackingScreenNew(),
    AppRoutes.trackingFinishedNew: () => const TrackingFinishedScreenNew(),
    AppRoutes.setgoal: () => const GoalSetGoal(),
    AppRoutes.settinggoal: () => const SettingGoal(),
    AppRoutes.tracking: () => const TrackingScreen(),
    AppRoutes.trackingsetting: () => const TrackingSettingScreen(),
    AppRoutes.trackingfinished: () => const TrackingFinishedScreen(),
    AppRoutes.settings: () => const SettingsScreen(),
    AppRoutes.accountSettings: () => const AccountSettingsScreen(),
    AppRoutes.accountSettingsNew: () => const AccountSettingsScreenNew(),
    AppRoutes.notificationSettings: () => const NotificationSettingsScreen(),
    AppRoutes.notificationSettingsNew: () =>
        const NotificationSettingsScreenNew(),
    AppRoutes.displaySettings: () => const DisplaySettingsScreen(),
    AppRoutes.displaySettingsNew: () => const DisplaySettingsScreenNew(),
    AppRoutes.timeSettings: () => const TimeSettingsScreen(),

    // Settings Routes (New)
    AppRoutes.settingsNew: () => const SettingsScreenNew(),
    AppRoutes.subscriptionNew: () => const SubscriptionScreenNew(),
    AppRoutes.eventPreviewNew: () => const EventPreviewScreenNew(),

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
