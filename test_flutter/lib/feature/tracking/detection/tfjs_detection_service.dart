/// プラットフォーム別のTensorFlow.js検出サービス
/// 
/// 条件付きインポートを使用してWeb版とモバイル版を切り替え
export 'tfjs_detection_service_stub.dart'
    if (dart.library.html) 'tfjs_detection_service_web.dart';

