// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'streak_functions.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 連続継続日数機能用の関数群
///
/// Riverpod Generatorを使用して連続継続日数機能に特化した実装を提供します。
///
/// **提供機能**:
/// - 連続継続日数データ管理Provider（Notifier）
/// - トラッキングヘルパー関数
/// - 同期ヘルパー関数
/// - UIフィードバック
// ===== Providers (Riverpod Generator) =====
/// 連続継続日数データを管理するNotifier
///
/// Riverpod Generatorを使用してStreakDataモデルを管理します。
///
/// **使用方法**:
/// ```dart
/// final streakData = ref.watch(streakDataNotifierProvider);
/// ref.read(streakDataNotifierProvider.notifier).updateStreak(newData);
/// ```

@ProviderFor(StreakDataNotifier)
const streakDataProvider = StreakDataNotifierProvider._();

/// 連続継続日数機能用の関数群
///
/// Riverpod Generatorを使用して連続継続日数機能に特化した実装を提供します。
///
/// **提供機能**:
/// - 連続継続日数データ管理Provider（Notifier）
/// - トラッキングヘルパー関数
/// - 同期ヘルパー関数
/// - UIフィードバック
// ===== Providers (Riverpod Generator) =====
/// 連続継続日数データを管理するNotifier
///
/// Riverpod Generatorを使用してStreakDataモデルを管理します。
///
/// **使用方法**:
/// ```dart
/// final streakData = ref.watch(streakDataNotifierProvider);
/// ref.read(streakDataNotifierProvider.notifier).updateStreak(newData);
/// ```
final class StreakDataNotifierProvider
    extends $NotifierProvider<StreakDataNotifier, StreakData> {
  /// 連続継続日数機能用の関数群
  ///
  /// Riverpod Generatorを使用して連続継続日数機能に特化した実装を提供します。
  ///
  /// **提供機能**:
  /// - 連続継続日数データ管理Provider（Notifier）
  /// - トラッキングヘルパー関数
  /// - 同期ヘルパー関数
  /// - UIフィードバック
  // ===== Providers (Riverpod Generator) =====
  /// 連続継続日数データを管理するNotifier
  ///
  /// Riverpod Generatorを使用してStreakDataモデルを管理します。
  ///
  /// **使用方法**:
  /// ```dart
  /// final streakData = ref.watch(streakDataNotifierProvider);
  /// ref.read(streakDataNotifierProvider.notifier).updateStreak(newData);
  /// ```
  const StreakDataNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'streakDataProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$streakDataNotifierHash();

  @$internal
  @override
  StreakDataNotifier create() => StreakDataNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StreakData value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StreakData>(value),
    );
  }
}

String _$streakDataNotifierHash() =>
    r'1e3699a8ed235f3264d6378107c2b629f2988588';

/// 連続継続日数機能用の関数群
///
/// Riverpod Generatorを使用して連続継続日数機能に特化した実装を提供します。
///
/// **提供機能**:
/// - 連続継続日数データ管理Provider（Notifier）
/// - トラッキングヘルパー関数
/// - 同期ヘルパー関数
/// - UIフィードバック
// ===== Providers (Riverpod Generator) =====
/// 連続継続日数データを管理するNotifier
///
/// Riverpod Generatorを使用してStreakDataモデルを管理します。
///
/// **使用方法**:
/// ```dart
/// final streakData = ref.watch(streakDataNotifierProvider);
/// ref.read(streakDataNotifierProvider.notifier).updateStreak(newData);
/// ```

abstract class _$StreakDataNotifier extends $Notifier<StreakData> {
  StreakData build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<StreakData, StreakData>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<StreakData, StreakData>,
              StreakData,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
