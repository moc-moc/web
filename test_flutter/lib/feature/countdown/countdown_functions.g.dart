// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'countdown_functions.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// カウントダウン機能用の関数群
///
/// Riverpod Generatorを使用してカウントダウン機能に特化した実装を提供します。
///
/// **提供機能**:
/// - カウントダウンリスト管理Provider（Notifier）
/// - アプリ起動時刻管理Provider
/// - カウントダウン追加ヘルパー関数
/// - UIフィードバック
// ===== Providers (Riverpod Generator) =====
/// カウントダウンリストを管理するNotifier
///
/// Riverpod Generatorを使用してCountdownモデルのリストを管理します。
///
/// **使用方法**:
/// ```dart
/// final countdowns = ref.watch(countdownsListProvider);
/// ref.read(countdownsListProvider.notifier).addCountdown(countdown);
/// ```

@ProviderFor(CountdownsList)
const countdownsListProvider = CountdownsListProvider._();

/// カウントダウン機能用の関数群
///
/// Riverpod Generatorを使用してカウントダウン機能に特化した実装を提供します。
///
/// **提供機能**:
/// - カウントダウンリスト管理Provider（Notifier）
/// - アプリ起動時刻管理Provider
/// - カウントダウン追加ヘルパー関数
/// - UIフィードバック
// ===== Providers (Riverpod Generator) =====
/// カウントダウンリストを管理するNotifier
///
/// Riverpod Generatorを使用してCountdownモデルのリストを管理します。
///
/// **使用方法**:
/// ```dart
/// final countdowns = ref.watch(countdownsListProvider);
/// ref.read(countdownsListProvider.notifier).addCountdown(countdown);
/// ```
final class CountdownsListProvider
    extends $NotifierProvider<CountdownsList, List<Countdown>> {
  /// カウントダウン機能用の関数群
  ///
  /// Riverpod Generatorを使用してカウントダウン機能に特化した実装を提供します。
  ///
  /// **提供機能**:
  /// - カウントダウンリスト管理Provider（Notifier）
  /// - アプリ起動時刻管理Provider
  /// - カウントダウン追加ヘルパー関数
  /// - UIフィードバック
  // ===== Providers (Riverpod Generator) =====
  /// カウントダウンリストを管理するNotifier
  ///
  /// Riverpod Generatorを使用してCountdownモデルのリストを管理します。
  ///
  /// **使用方法**:
  /// ```dart
  /// final countdowns = ref.watch(countdownsListProvider);
  /// ref.read(countdownsListProvider.notifier).addCountdown(countdown);
  /// ```
  const CountdownsListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'countdownsListProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$countdownsListHash();

  @$internal
  @override
  CountdownsList create() => CountdownsList();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Countdown> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Countdown>>(value),
    );
  }
}

String _$countdownsListHash() => r'ba72ae5d2f57ce3b34fa16fa4fceea769c37c106';

/// カウントダウン機能用の関数群
///
/// Riverpod Generatorを使用してカウントダウン機能に特化した実装を提供します。
///
/// **提供機能**:
/// - カウントダウンリスト管理Provider（Notifier）
/// - アプリ起動時刻管理Provider
/// - カウントダウン追加ヘルパー関数
/// - UIフィードバック
// ===== Providers (Riverpod Generator) =====
/// カウントダウンリストを管理するNotifier
///
/// Riverpod Generatorを使用してCountdownモデルのリストを管理します。
///
/// **使用方法**:
/// ```dart
/// final countdowns = ref.watch(countdownsListProvider);
/// ref.read(countdownsListProvider.notifier).addCountdown(countdown);
/// ```

abstract class _$CountdownsList extends $Notifier<List<Countdown>> {
  List<Countdown> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<List<Countdown>, List<Countdown>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<Countdown>, List<Countdown>>,
              List<Countdown>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// アプリ起動時刻を記録するProvider
///
/// アプリが起動した日時を保持します。
/// 各種時間計算や統計情報で使用されます。
///
/// **使用方法**:
/// ```dart
/// final startTime = ref.watch(appStartTimeProvider);
/// ```

@ProviderFor(appStartTime)
const appStartTimeProvider = AppStartTimeProvider._();

/// アプリ起動時刻を記録するProvider
///
/// アプリが起動した日時を保持します。
/// 各種時間計算や統計情報で使用されます。
///
/// **使用方法**:
/// ```dart
/// final startTime = ref.watch(appStartTimeProvider);
/// ```

final class AppStartTimeProvider
    extends $FunctionalProvider<DateTime, DateTime, DateTime>
    with $Provider<DateTime> {
  /// アプリ起動時刻を記録するProvider
  ///
  /// アプリが起動した日時を保持します。
  /// 各種時間計算や統計情報で使用されます。
  ///
  /// **使用方法**:
  /// ```dart
  /// final startTime = ref.watch(appStartTimeProvider);
  /// ```
  const AppStartTimeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appStartTimeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appStartTimeHash();

  @$internal
  @override
  $ProviderElement<DateTime> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DateTime create(Ref ref) {
    return appStartTime(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DateTime value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DateTime>(value),
    );
  }
}

String _$appStartTimeHash() => r'389410612d3955ae221eeebc8e51df5e8fa180bb';
