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

class AppRoutes {
  static const String home = '/';
  static const String report = '/report';
  static const String goal = '/goal';
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
  static const String notificationSettings = '/notificationSettings';
  static const String displaySettings = '/displaySettings';
  static const String timeSettings = '/timeSettings';
}

class RouteGenerator {
  /// ルート名とウィジェットのマッピング
  /// home、report、goalはBottomNavigationBarScreenを使用
  static final Map<String, Widget Function()> _routeMap = {
    AppRoutes.home: () => const BottomNavigationBarScreen(initialIndex: 0),
    AppRoutes.report: () => const BottomNavigationBarScreen(initialIndex: 2),
    AppRoutes.goal: () => const BottomNavigationBarScreen(initialIndex: 1),
    AppRoutes.setgoal: () => const GoalSetGoal(),
    AppRoutes.settinggoal: () => const SettingGoal(),
    AppRoutes.tracking: () => const TrackingScreen(),
    AppRoutes.trackingsetting: () => const TrackingSettingScreen(),
    AppRoutes.trackingfinished: () => const TrackingFinishedScreen(),
    AppRoutes.settings: () => const SettingsScreen(),
    AppRoutes.accountSettings: () => const AccountSettingsScreen(),
    AppRoutes.notificationSettings: () => const NotificationSettingsScreen(),
    AppRoutes.displaySettings: () => const DisplaySettingsScreen(),
    AppRoutes.timeSettings: () => const TimeSettingsScreen(),
  };

  /// ルート生成メイン関数
  /// CoreMkの汎用関数を利用してルートを生成
  static Route<dynamic> generateRoute(RouteSettings settings) {
    return RouteMk.generateRoute(
      settings: settings,
      routeMap: _routeMap,
    );
  }
}