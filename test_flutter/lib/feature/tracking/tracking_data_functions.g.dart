// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tracking_data_functions.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// トラッキングセッションのリストを管理するNotifier

@ProviderFor(TrackingSessionsNotifier)
const trackingSessionsProvider = TrackingSessionsNotifierProvider._();

/// トラッキングセッションのリストを管理するNotifier
final class TrackingSessionsNotifierProvider
    extends $NotifierProvider<TrackingSessionsNotifier, List<TrackingSession>> {
  /// トラッキングセッションのリストを管理するNotifier
  const TrackingSessionsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'trackingSessionsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$trackingSessionsNotifierHash();

  @$internal
  @override
  TrackingSessionsNotifier create() => TrackingSessionsNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<TrackingSession> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<TrackingSession>>(value),
    );
  }
}

String _$trackingSessionsNotifierHash() =>
    r'a778dabb98c59dbbe1d0fdfe701c1fcf4f969397';

/// トラッキングセッションのリストを管理するNotifier

abstract class _$TrackingSessionsNotifier
    extends $Notifier<List<TrackingSession>> {
  List<TrackingSession> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<List<TrackingSession>, List<TrackingSession>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<TrackingSession>, List<TrackingSession>>,
              List<TrackingSession>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
