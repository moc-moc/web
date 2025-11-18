import 'dart:async';
import 'package:test_flutter/feature/tracking/detection/detection_result.dart';
import 'package:test_flutter/feature/tracking/detection/stabilized_measurement.dart';

/// 計測安定化システム
/// 
/// 検出結果の誤差を吸収し、実際の作業時間に近づけるための補正を行う
class MeasurementStabilizer {
  // ========== 設定パラメータ ==========
  
  /// 履歴管理用のウィンドウサイズ（通常モード）
  final int windowSizeNormal;
  
  /// 履歴管理用のウィンドウサイズ（省電力モード）
  final int windowSizePowerSaving;
  
  /// 状態遷移に必要な連続回数
  final int transitionThreshold;
  
  /// フォールバック期間（通常モード）
  final Duration fallbackDurationNormal;
  
  /// フォールバック期間（省電力モード）
  final Duration fallbackDurationPowerSaving;
  
  // ========== 内部状態 ==========
  
  /// 検出履歴（時系列）
  final List<DetectionResult> _history = [];
  
  /// 現在の安定状態
  DetectionCategory? _currentStableState;
  
  /// 同じカテゴリが連続で検出された回数
  int _consecutiveCount = 0;
  
  /// 連続検出中のカテゴリ
  DetectionCategory? _consecutiveCategory;
  
  /// 最後に確定した状態
  DetectionCategory? _lastConfirmedState;
  
  /// 最後に確定した状態の時刻
  DateTime? _lastConfirmedStateTime;
  
  /// フォールバック開始時刻
  DateTime? _fallbackStartTime;
  
  /// 省電力モードかどうか
  bool _isPowerSavingMode = false;
  
  /// ストリームコントローラー
  final StreamController<StabilizedMeasurement> _stabilizedController =
      StreamController<StabilizedMeasurement>.broadcast();

  /// 安定化された結果のストリーム
  Stream<StabilizedMeasurement> get stabilizedStream =>
      _stabilizedController.stream;

  MeasurementStabilizer({
    this.windowSizeNormal = 5,
    this.windowSizePowerSaving = 3,
    this.transitionThreshold = 2,
    this.fallbackDurationNormal = const Duration(seconds: 30),
    this.fallbackDurationPowerSaving = const Duration(seconds: 60),
  });

  /// 省電力モードの設定
  void setPowerSavingMode(bool enabled) {
    _isPowerSavingMode = enabled;
    // 履歴をクリアして再計算
    _clearHistory();
  }

  /// 検出結果を処理して安定化
  void processDetection(DetectionResult result) {
    final now = DateTime.now();
    
    // 履歴に追加
    _history.add(result);
    
    // ウィンドウサイズを超えたら古い履歴を削除
    final windowSize = _isPowerSavingMode 
        ? windowSizePowerSaving 
        : windowSizeNormal;
    if (_history.length > windowSize) {
      _history.removeAt(0);
    }
    
    // 安定化処理を実行
    final stabilized = _stabilize(result, now);
    
    if (stabilized != null && !_stabilizedController.isClosed) {
      _stabilizedController.add(stabilized);
    }
  }

  /// 安定化処理のメインロジック
  StabilizedMeasurement? _stabilize(DetectionResult result, DateTime now) {
    // Phase 1: フォールバックメカニズム
    if (result.category == DetectionCategory.nothingDetected) {
      return _handleFallback(result, now);
    }
    
    // 検出成功時はフォールバックをリセット
    _fallbackStartTime = null;
    
    // Phase 1: 状態遷移の慣性
    final transitionResult = _handleStateTransition(result, now);
    if (transitionResult != null) {
      return transitionResult;
    }
    
    // すべての補正を通過したら、そのまま確定
    return _confirmState(result, now, isCorrected: false);
  }

  /// Phase 1: フォールバックメカニズム
  /// 検出失敗時、前の状態を一定期間保持
  StabilizedMeasurement? _handleFallback(
    DetectionResult result,
    DateTime now,
  ) {
    // 最後に確定した状態がある場合
    if (_lastConfirmedState != null && _lastConfirmedStateTime != null) {
      final fallbackDuration = _isPowerSavingMode
          ? fallbackDurationPowerSaving
          : fallbackDurationNormal;
      
      final timeSinceLastConfirmed = now.difference(_lastConfirmedStateTime!);
      
      // フォールバック期間内であれば、前の状態を継続
      if (timeSinceLastConfirmed < fallbackDuration) {
        if (_fallbackStartTime == null) {
          _fallbackStartTime = now;
        }
        
        return StabilizedMeasurement(
          category: _lastConfirmedState,
          originalResult: result,
          timestamp: now,
          confidence: result.confidence,
          isConfirmed: true,
          isCorrected: true,
          correctionReason: 'フォールバック: 検出失敗時の状態保持',
        );
      }
    }
    
    // フォールバック期間を超えた場合は、検出なしとして扱う
    return _confirmState(result, now, isCorrected: false);
  }

  /// Phase 1: 状態遷移の慣性
  /// 状態を変えるには連続でM回同じ結果が必要
  StabilizedMeasurement? _handleStateTransition(
    DetectionResult result,
    DateTime now,
  ) {
    final category = result.category;
    
    if (category == null) {
      return null;
    }
    
    // 連続検出のカウント
    if (_consecutiveCategory == category) {
      _consecutiveCount++;
    } else {
      _consecutiveCategory = category;
      _consecutiveCount = 1;
    }
    
    // 現在の安定状態と同じカテゴリの場合、即座に確定
    if (_currentStableState == category) {
      return _confirmState(result, now, isCorrected: false);
    }
    
    // 遷移閾値に達した場合、状態を変更
    if (_consecutiveCount >= transitionThreshold) {
      return _confirmStateTransition(result, now);
    }
    
    // 遷移閾値に達していない場合、前の状態を継続
    if (_currentStableState != null) {
      return StabilizedMeasurement(
        category: _currentStableState,
        originalResult: result,
        timestamp: now,
        confidence: result.confidence,
        isConfirmed: false,
        isCorrected: true,
        correctionReason: '状態遷移の慣性: 連続検出不足（${_consecutiveCount}/${transitionThreshold}回）',
      );
    }
    
    return null;
  }


  /// 状態を確定する
  StabilizedMeasurement _confirmState(
    DetectionResult result,
    DateTime now, {
    required bool isCorrected,
    String? correctionReason,
  }) {
    final category = result.category;
    
    // 状態が変わった場合、開始時刻を更新
    if (_currentStableState != category) {
      _currentStableState = category;
      _lastConfirmedState = category;
      _lastConfirmedStateTime = now;
      _consecutiveCount = 0;
      _consecutiveCategory = null;
    }
    
    return StabilizedMeasurement(
      category: category,
      originalResult: result,
      timestamp: now,
      confidence: result.confidence,
      isConfirmed: true,
      isCorrected: isCorrected,
      correctionReason: correctionReason,
    );
  }

  /// 状態遷移を確定する
  StabilizedMeasurement _confirmStateTransition(
    DetectionResult result,
    DateTime now,
  ) {
    return _confirmState(
      result,
      now,
      isCorrected: true,
      correctionReason: '状態遷移確定: 連続${_consecutiveCount}回検出',
    );
  }

  /// 履歴をクリア
  void _clearHistory() {
    _history.clear();
    _consecutiveCount = 0;
    _consecutiveCategory = null;
    _fallbackStartTime = null;
  }

  /// リソースを解放
  void dispose() {
    _clearHistory();
    _stabilizedController.close();
  }
}

