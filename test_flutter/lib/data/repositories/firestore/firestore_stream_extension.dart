import 'dart:async';

/// Stream拡張: mergeWith
extension FirestoreStreamExtension<T> on Stream<T> {
  Stream<T> mergeWith(List<Stream<T>> others) {
    final controller = StreamController<T>.broadcast();
    final subscriptions = <StreamSubscription<T>>[];

    void addStream(Stream<T> stream) {
      subscriptions.add(stream.listen(
        (data) => controller.add(data),
        onError: (error) => controller.addError(error),
      ));
    }

    addStream(this);
    for (final stream in others) {
      addStream(stream);
    }

    controller.onCancel = () {
      for (final sub in subscriptions) {
        sub.cancel();
      }
    };

    return controller.stream;
  }
}

