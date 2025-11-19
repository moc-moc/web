// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'total_functions.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 累計データ機能用の関数群
///
/// Riverpod Generatorを使用して累計データ機能に特化した実装を提供します。
///
/// **提供機能**:
/// - 累計データ管理Provider（Notifier）
/// - 同期ヘルパー関数
/// - ローカル読み込みヘルパー関数
// ===== Providers (Riverpod Generator) =====
/// 累計データを管理するNotifier
///
/// Riverpod Generatorを使用してTotalDataモデルを管理します。
///
/// **使用方法**:
/// ```dart
/// final totalData = ref.watch(totalDataNotifierProvider);
/// ref.read(totalDataNotifierProvider.notifier).updateTotal(newData);
/// ```

@ProviderFor(TotalDataNotifier)
const totalDataProvider = TotalDataNotifierProvider._();

/// 累計データ機能用の関数群
///
/// Riverpod Generatorを使用して累計データ機能に特化した実装を提供します。
///
/// **提供機能**:
/// - 累計データ管理Provider（Notifier）
/// - 同期ヘルパー関数
/// - ローカル読み込みヘルパー関数
// ===== Providers (Riverpod Generator) =====
/// 累計データを管理するNotifier
///
/// Riverpod Generatorを使用してTotalDataモデルを管理します。
///
/// **使用方法**:
/// ```dart
/// final totalData = ref.watch(totalDataNotifierProvider);
/// ref.read(totalDataNotifierProvider.notifier).updateTotal(newData);
/// ```
final class TotalDataNotifierProvider
    extends $NotifierProvider<TotalDataNotifier, TotalData> {
  /// 累計データ機能用の関数群
  ///
  /// Riverpod Generatorを使用して累計データ機能に特化した実装を提供します。
  ///
  /// **提供機能**:
  /// - 累計データ管理Provider（Notifier）
  /// - 同期ヘルパー関数
  /// - ローカル読み込みヘルパー関数
  // ===== Providers (Riverpod Generator) =====
  /// 累計データを管理するNotifier
  ///
  /// Riverpod Generatorを使用してTotalDataモデルを管理します。
  ///
  /// **使用方法**:
  /// ```dart
  /// final totalData = ref.watch(totalDataNotifierProvider);
  /// ref.read(totalDataNotifierProvider.notifier).updateTotal(newData);
  /// ```
  const TotalDataNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'totalDataProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$totalDataNotifierHash();

  @$internal
  @override
  TotalDataNotifier create() => TotalDataNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TotalData value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TotalData>(value),
    );
  }
}

String _$totalDataNotifierHash() => r'22432f11d531061c46725fbcefe3b0c14a1f42be';

/// 累計データ機能用の関数群
///
/// Riverpod Generatorを使用して累計データ機能に特化した実装を提供します。
///
/// **提供機能**:
/// - 累計データ管理Provider（Notifier）
/// - 同期ヘルパー関数
/// - ローカル読み込みヘルパー関数
// ===== Providers (Riverpod Generator) =====
/// 累計データを管理するNotifier
///
/// Riverpod Generatorを使用してTotalDataモデルを管理します。
///
/// **使用方法**:
/// ```dart
/// final totalData = ref.watch(totalDataNotifierProvider);
/// ref.read(totalDataNotifierProvider.notifier).updateTotal(newData);
/// ```

abstract class _$TotalDataNotifier extends $Notifier<TotalData> {
  TotalData build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<TotalData, TotalData>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<TotalData, TotalData>,
              TotalData,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
