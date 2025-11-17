/// プラットフォーム別のONNX Runtime検出サービス
/// 
/// 条件付きインポートを使用してWeb版とモバイル版を切り替え
export 'onnx_detection_service_stub.dart'
    if (dart.library.html) 'onnx_detection_service_web.dart'
    if (dart.library.io) 'onnx_detection_service_mobile.dart';
