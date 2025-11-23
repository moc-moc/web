// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'goal_memo_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 目標メモを管理するNotifier
///
/// 目標メモ（自分を鼓舞するためのメモ）を管理します。
///
/// **使用方法**:
/// ```dart
/// final memo = ref.watch(goalMemoProvider);
/// ref.read(goalMemoProvider.notifier).updateMemo(newMemo);
/// ```

@ProviderFor(GoalMemoNotifier)
const goalMemoProvider = GoalMemoNotifierProvider._();

/// 目標メモを管理するNotifier
///
/// 目標メモ（自分を鼓舞するためのメモ）を管理します。
///
/// **使用方法**:
/// ```dart
/// final memo = ref.watch(goalMemoProvider);
/// ref.read(goalMemoProvider.notifier).updateMemo(newMemo);
/// ```
final class GoalMemoNotifierProvider
    extends $NotifierProvider<GoalMemoNotifier, GoalMemo> {
  /// 目標メモを管理するNotifier
  ///
  /// 目標メモ（自分を鼓舞するためのメモ）を管理します。
  ///
  /// **使用方法**:
  /// ```dart
  /// final memo = ref.watch(goalMemoProvider);
  /// ref.read(goalMemoProvider.notifier).updateMemo(newMemo);
  /// ```
  const GoalMemoNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'goalMemoProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$goalMemoNotifierHash();

  @$internal
  @override
  GoalMemoNotifier create() => GoalMemoNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GoalMemo value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GoalMemo>(value),
    );
  }
}

String _$goalMemoNotifierHash() => r'9f0e3f983d694a6a017a96d337f26154c3b0c7bb';

/// 目標メモを管理するNotifier
///
/// 目標メモ（自分を鼓舞するためのメモ）を管理します。
///
/// **使用方法**:
/// ```dart
/// final memo = ref.watch(goalMemoProvider);
/// ref.read(goalMemoProvider.notifier).updateMemo(newMemo);
/// ```

abstract class _$GoalMemoNotifier extends $Notifier<GoalMemo> {
  GoalMemo build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<GoalMemo, GoalMemo>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<GoalMemo, GoalMemo>,
              GoalMemo,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
