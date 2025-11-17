/// プラットフォーム別のTensorFlow Lite検出サービス
/// 
/// 条件付きインポートを使用してWeb版とモバイル版を切り替え
export 'tflite_detection_service_stub.dart'
    if (dart.library.io) 'tflite_detection_service_mobile.dart';

