import 'dart:typed_data';
import 'package:test_flutter/feature/tracking/detection/detection_result.dart';

/// 検出サービスの抽象クラス
/// 
/// AI検出機能を提供するサービスの基底クラス
/// 具体的な実装（TensorFlow Lite、MediaPipeなど）はこのクラスを継承
abstract class DetectionService {
  /// モデルの初期化
  /// 
  /// 検出モデルを読み込み、初期化します
  /// 
  /// **戻り値**: 初期化成功時true、失敗時false
  Future<bool> initialize();

  /// 現在の省電力モード（対応しているサービスのみ有効）
  bool? get currentPowerSavingMode => null;

  /// 初期化前に省電力モード設定を伝達
  /// 
  /// デフォルトでは何もしない（ONNXなど必要な実装で上書き）
  void applyInitialPowerSavingMode(bool powerSavingMode) {}

  /// モデルを事前読み込み（プリフェッチ）する
  /// 
  /// デフォルト実装は何もしない。対応サービスのみ上書きする。
  Future<void> prefetchModel({required bool powerSavingMode}) async {}

  /// 画像から物体を検出
  /// 
  /// **パラメータ**:
  /// - `imageBytes`: 検出対象の画像データ
  /// 
  /// **戻り値**: 検出結果のリスト（複数の物体が検出される可能性がある）
  Future<List<DetectionResult>> detect(Uint8List imageBytes);

  /// 検出モデルのリソースを解放
  /// 
  /// メモリリークを防ぐため、使用後は必ず呼び出す
  Future<void> dispose();

  /// モデルを切り替える
  /// 
  /// 省電力モードに応じて異なるモデルを読み込む
  /// 
  /// **パラメータ**:
  /// - `powerSavingMode`: trueの場合は高精度モデル（yolo11l）、falseの場合はバランスモデル（yolo11m）
  /// 
  /// **戻り値**: 切り替え成功時true、失敗時false
  Future<bool> switchModel({required bool powerSavingMode});
}

