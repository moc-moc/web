import 'package:flutter/foundation.dart';
import 'package:riverpod/riverpod.dart';

@immutable
class DataRefreshState {
  final int homeToken;
  final int goalToken;
  final int reportToken;
  final int settingsToken;
  final int homeAckToken;
  final int goalAckToken;
  final int reportAckToken;
  final int settingsAckToken;

  const DataRefreshState({
    this.homeToken = 0,
    this.goalToken = 0,
    this.reportToken = 0,
    this.settingsToken = 0,
    this.homeAckToken = 0,
    this.goalAckToken = 0,
    this.reportAckToken = 0,
    this.settingsAckToken = 0,
  });

  DataRefreshState copyWith({
    int? homeToken,
    int? goalToken,
    int? reportToken,
    int? settingsToken,
    int? homeAckToken,
    int? goalAckToken,
    int? reportAckToken,
    int? settingsAckToken,
  }) {
    return DataRefreshState(
      homeToken: homeToken ?? this.homeToken,
      goalToken: goalToken ?? this.goalToken,
      reportToken: reportToken ?? this.reportToken,
      settingsToken: settingsToken ?? this.settingsToken,
      homeAckToken: homeAckToken ?? this.homeAckToken,
      goalAckToken: goalAckToken ?? this.goalAckToken,
      reportAckToken: reportAckToken ?? this.reportAckToken,
      settingsAckToken: settingsAckToken ?? this.settingsAckToken,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DataRefreshState &&
        other.homeToken == homeToken &&
        other.goalToken == goalToken &&
        other.reportToken == reportToken &&
        other.settingsToken == settingsToken &&
        other.homeAckToken == homeAckToken &&
        other.goalAckToken == goalAckToken &&
        other.reportAckToken == reportAckToken &&
        other.settingsAckToken == settingsAckToken;
  }

  @override
  int get hashCode => Object.hash(
        homeToken,
        goalToken,
        reportToken,
        settingsToken,
        homeAckToken,
        goalAckToken,
        reportAckToken,
        settingsAckToken,
      );
}

final dataRefreshProvider =
    NotifierProvider<DataRefreshController, DataRefreshState>(
  DataRefreshController.new,
);

void triggerAppLaunch(dynamic ref) {
  ref.read(dataRefreshProvider.notifier).triggerAppLaunch();
}

void triggerTrackingCompleted(dynamic ref) {
  ref.read(dataRefreshProvider.notifier).triggerTrackingCompleted();
}

void triggerGoalChanged(dynamic ref) {
  ref.read(dataRefreshProvider.notifier).triggerGoalChanged();
}

void triggerCountdownChanged(dynamic ref) {
  ref.read(dataRefreshProvider.notifier).triggerCountdownChanged();
}

void markHomeHandled(dynamic ref, int token) {
  ref.read(dataRefreshProvider.notifier).markHomeHandled(token);
}

void markGoalHandled(dynamic ref, int token) {
  ref.read(dataRefreshProvider.notifier).markGoalHandled(token);
}

void markReportHandled(dynamic ref, int token) {
  ref.read(dataRefreshProvider.notifier).markReportHandled(token);
}

void markSettingsHandled(dynamic ref, int token) {
  ref.read(dataRefreshProvider.notifier).markSettingsHandled(token);
}

class DataRefreshController extends Notifier<DataRefreshState> {
  @override
  DataRefreshState build() => const DataRefreshState();

  void triggerAppLaunch() {
    _update(home: true, goal: true, report: true, settings: true);
  }

  void triggerTrackingCompleted() {
    _update(home: true, goal: true, report: true);
  }

  void triggerGoalChanged() {
    _update(home: true, goal: true);
  }

  void triggerCountdownChanged() {
    _update(home: true, goal: true);
  }

  void markHomeHandled(int token) {
    if (token <= state.homeAckToken) return;
    state = state.copyWith(homeAckToken: token);
  }

  void markGoalHandled(int token) {
    if (token <= state.goalAckToken) return;
    state = state.copyWith(goalAckToken: token);
  }

  void markReportHandled(int token) {
    if (token <= state.reportAckToken) return;
    state = state.copyWith(reportAckToken: token);
  }

  void markSettingsHandled(int token) {
    if (token <= state.settingsAckToken) return;
    state = state.copyWith(settingsAckToken: token);
  }

  void _update({
    bool home = false,
    bool goal = false,
    bool report = false,
    bool settings = false,
  }) {
    state = state.copyWith(
      homeToken: home ? state.homeToken + 1 : state.homeToken,
      goalToken: goal ? state.goalToken + 1 : state.goalToken,
      reportToken: report ? state.reportToken + 1 : state.reportToken,
      settingsToken:
          settings ? state.settingsToken + 1 : state.settingsToken,
    );
  }
}

