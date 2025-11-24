// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'level_functions.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(LevelingStateNotifier)
const levelingStateProvider = LevelingStateNotifierProvider._();

final class LevelingStateNotifierProvider
    extends $NotifierProvider<LevelingStateNotifier, LevelingState> {
  const LevelingStateNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'levelingStateProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$levelingStateNotifierHash();

  @$internal
  @override
  LevelingStateNotifier create() => LevelingStateNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LevelingState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LevelingState>(value),
    );
  }
}

String _$levelingStateNotifierHash() =>
    r'6a01a146ee975e34c6a38efdfc7badcefddb83f0';

abstract class _$LevelingStateNotifier extends $Notifier<LevelingState> {
  LevelingState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<LevelingState, LevelingState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<LevelingState, LevelingState>,
              LevelingState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
