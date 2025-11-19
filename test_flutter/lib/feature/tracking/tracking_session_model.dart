import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'tracking_session_model.freezed.dart';
part 'tracking_session_model.g.dart';

/// 検出期間（時系列データ）
/// 
/// 何時何分何秒から何時何分何秒まで何が検出されたかを記録
@freezed
abstract class DetectionPeriod with _$DetectionPeriod {
  const factory DetectionPeriod({
    /// 検出開始時刻
    required DateTime startTime,
    
    /// 検出終了時刻
    required DateTime endTime,
    
    /// 検出されたカテゴリ
    required String category,
    
    /// 信頼度
    required double confidence,
  }) = _DetectionPeriod;

  /// プライベートコンストラクタ（getter用）
  const DetectionPeriod._();

  /// JSONからDetectionPeriodを生成
  factory DetectionPeriod.fromJson(Map<String, dynamic> json) =>
      _$DetectionPeriodFromJson(json);

  /// FirestoreデータからDetectionPeriodを生成
  factory DetectionPeriod.fromFirestore(Map<String, dynamic> data) {
    return DetectionPeriod(
      startTime: (data['startTime'] as Timestamp).toDate(),
      endTime: (data['endTime'] as Timestamp).toDate(),
      category: data['category'] as String,
      confidence: (data['confidence'] as num).toDouble(),
    );
  }

  /// Firestore形式に変換
  Map<String, dynamic> toFirestore() {
    return {
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'category': category,
      'confidence': confidence,
    };
  }
}

/// トラッキングセッションモデル
/// 
/// 1回のトラッキングセッションのデータを管理します。
/// Freezedを使用してイミュータブルなモデルを実現しています。
@freezed
abstract class TrackingSession with _$TrackingSession {
  /// TrackingSessionモデルのコンストラクタ
  const factory TrackingSession({
    /// セッションID（自動生成）
    required String id,
    
    /// セッション開始時刻
    required DateTime startTime,
    
    /// セッション終了時刻
    required DateTime endTime,
    
    /// カテゴリ別の時間（秒単位）
    required Map<String, int> categorySeconds,
    
    /// 検出期間のリスト（時系列データ）
    @Default([]) List<DetectionPeriod> detectionPeriods,
    
    /// 最終更新日時
    required DateTime lastModified,
  }) = _TrackingSession;

  /// プライベートコンストラクタ（getter用）
  const TrackingSession._();

  /// JSONからTrackingSessionモデルを生成
  factory TrackingSession.fromJson(Map<String, dynamic> json) =>
      _$TrackingSessionFromJson(json);

  /// FirestoreデータからTrackingSessionモデルを生成
  factory TrackingSession.fromFirestore(Map<String, dynamic> data) {
    // 後方互換性: categoryMinutesもcategorySecondsも受け入れる
    final categoryData = data['categorySeconds'] ?? data['categoryMinutes'];
    return TrackingSession(
      id: data['id'] as String,
      startTime: (data['startTime'] as Timestamp).toDate(),
      endTime: (data['endTime'] as Timestamp).toDate(),
      categorySeconds: Map<String, int>.from(categoryData as Map),
      detectionPeriods: (data['detectionPeriods'] as List<dynamic>?)
              ?.map((e) => DetectionPeriod.fromFirestore(e as Map<String, dynamic>))
              .toList() ??
          [],
      lastModified: (data['lastModified'] as Timestamp).toDate(),
    );
  }

  /// Firestore形式に変換
  /// 
  /// [excludeDetectionPeriods]がtrueの場合、detectionPeriodsを除外します。
  /// これによりFirestoreのデータ量を削減できます。
  /// 時系列データは統計データ（DailyStatistics等）に集計済みです。
  Map<String, dynamic> toFirestore({bool excludeDetectionPeriods = false}) {
    final data = {
      'id': id,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'categorySeconds': categorySeconds,
      'lastModified': Timestamp.fromDate(lastModified),
    };
    
    // detectionPeriodsはオプションで除外可能（データ量削減のため）
    if (!excludeDetectionPeriods) {
      data['detectionPeriods'] = detectionPeriods.map((e) => e.toFirestore()).toList();
    }
    
    return data;
  }

  /// カテゴリ別の時間を時間単位で取得（categorySecondsは秒単位）
  double getStudyHours() => (categorySeconds['study'] ?? 0) / 3600.0;
  double getPcHours() => (categorySeconds['pc'] ?? 0) / 3600.0;
  double getSmartphoneHours() => (categorySeconds['smartphone'] ?? 0) / 3600.0;
  double getPersonOnlyHours() => (categorySeconds['personOnly'] ?? 0) / 3600.0;
  
  /// detectionPeriodsからcategorySecondsを再計算して検証
  /// 不整合がある場合は修正されたMapを返す
  Map<String, int> recalculateCategorySeconds() {
    final calculated = <String, int>{
      'study': 0,
      'pc': 0,
      'smartphone': 0,
      'personOnly': 0,
    };
    
    for (final period in detectionPeriods) {
      final duration = period.endTime.difference(period.startTime).inSeconds;
      final category = period.category;
      
      // nothingDetectedは除外
      if (category == 'nothingDetected') {
        continue;
      }
      
      // 有効なカテゴリの場合のみ加算
      if (calculated.containsKey(category)) {
        calculated[category] = (calculated[category] ?? 0) + duration;
      }
    }
    
    return calculated;
  }
  
  /// データの整合性をチェック
  /// 戻り値: (isValid, issues)
  (bool isValid, List<String> issues) validateData() {
    final issues = <String>[];
    
    // 1. detectionPeriodsの連続性チェック
    if (detectionPeriods.isNotEmpty) {
      DateTime? lastEndTime;
      for (var i = 0; i < detectionPeriods.length; i++) {
        final period = detectionPeriods[i];
        
        // 開始時刻と終了時刻の順序チェック
        if (period.startTime.isAfter(period.endTime)) {
          issues.add('検出期間[$i]: 開始時刻が終了時刻より後です');
        }
        
        // 空白期間のチェック
        if (lastEndTime != null && period.startTime != lastEndTime) {
          final gapSeconds = period.startTime.difference(lastEndTime).inSeconds;
          issues.add('検出期間[$i]: 前の期間との間に$gapSeconds秒の空白があります');
        }
        
        lastEndTime = period.endTime;
      }
      
      // セッション終了時刻との整合性チェック
      if (lastEndTime != null && lastEndTime != endTime) {
        final gapSeconds = endTime.difference(lastEndTime).inSeconds;
        issues.add('最後の検出期間とセッション終了時刻に$gapSeconds秒の差があります');
      }
    }
    
    // 2. categorySecondsとdetectionPeriodsの整合性チェック
    final recalculated = recalculateCategorySeconds();
    for (final entry in categorySeconds.entries) {
      final calculated = recalculated[entry.key] ?? 0;
      final stored = entry.value;
      if ((calculated - stored).abs() > 1) { // 1秒の誤差は許容
        issues.add('カテゴリ[${entry.key}]: 保存値($stored秒)と計算値($calculated秒)が不一致です');
      }
    }
    
    // 3. セッション全体時間とカテゴリ別時間の合計のチェック
    final totalCategorySeconds = categorySeconds.values.fold(0, (sum, val) => sum + val);
    final sessionTotalSeconds = duration.inSeconds;
    
    // nothingDetected期間を考慮
    final nothingDetectedSeconds = detectionPeriods
        .where((p) => p.category == 'nothingDetected')
        .fold(0, (sum, p) => sum + p.endTime.difference(p.startTime).inSeconds);
    
    final expectedTotal = totalCategorySeconds + nothingDetectedSeconds;
    if ((sessionTotalSeconds - expectedTotal).abs() > 1) {
      issues.add('セッション全体時間($sessionTotalSeconds秒)とカテゴリ別時間の合計($expectedTotal秒)が不一致です');
    }
    
    return (issues.isEmpty, issues);
  }
  
  /// 合計時間（時間単位）
  double get totalHours => (endTime.difference(startTime).inSeconds) / 3600.0;
  
  /// セッションの継続時間
  Duration get duration => endTime.difference(startTime);
}

