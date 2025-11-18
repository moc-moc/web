// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'goal_functions.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 目標機能用の関数群
///
/// Riverpod Generatorを使用して目標機能に特化した実装を提供します。
///
// ===== Providers (Riverpod Generator) =====
/// 目標リストを管理するNotifier
///
/// Riverpod Generatorを使用してGoalモデルのリストを管理します。

@ProviderFor(GoalsList)
const goalsListProvider = GoalsListProvider._();

/// 目標機能用の関数群
///
/// Riverpod Generatorを使用して目標機能に特化した実装を提供します。
///
// ===== Providers (Riverpod Generator) =====
/// 目標リストを管理するNotifier
///
/// Riverpod Generatorを使用してGoalモデルのリストを管理します。
final class GoalsListProvider extends $NotifierProvider<GoalsList, List<Goal>> {
  /// 目標機能用の関数群
  ///
  /// Riverpod Generatorを使用して目標機能に特化した実装を提供します。
  ///
  // ===== Providers (Riverpod Generator) =====
  /// 目標リストを管理するNotifier
  ///
  /// Riverpod Generatorを使用してGoalモデルのリストを管理します。
  const GoalsListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'goalsListProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$goalsListHash();

  @$internal
  @override
  GoalsList create() => GoalsList();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Goal> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Goal>>(value),
    );
  }
}

String _$goalsListHash() => r'380791173361b9aa016cb75368ac765776635c41';

/// 目標機能用の関数群
///
/// Riverpod Generatorを使用して目標機能に特化した実装を提供します。
///
// ===== Providers (Riverpod Generator) =====
/// 目標リストを管理するNotifier
///
/// Riverpod Generatorを使用してGoalモデルのリストを管理します。

abstract class _$GoalsList extends $Notifier<List<Goal>> {
  List<Goal> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<List<Goal>, List<Goal>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<Goal>, List<Goal>>,
              List<Goal>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
