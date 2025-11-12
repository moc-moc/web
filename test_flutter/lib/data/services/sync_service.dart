
/// 同期ロジックの汎用的な基本関数
/// 
/// データの同期、マージ、差分検出に関する基本的な操作を提供する関数群
/// カウントダウンなどの具体的なビジネスロジックは含まない
class SyncMk {
  /// データをマージ（Firestore優先）
  /// 
  /// ローカルデータとリモートデータをマージする
  /// マージルール:
  /// 1. リモート（Firestore）データが存在する場合: 常にリモートを採用
  /// 2. リモートに存在しない場合のみ: ローカルデータを使用
  /// 3. これにより、Firestoreが常に信頼できる情報源となる
  static List<Map<String, dynamic>> mergeData(
    List<Map<String, dynamic>> localData,
    List<Map<String, dynamic>> remoteData,
    String idField,
    String lastModifiedField,
  ) {
    final Map<String, Map<String, dynamic>> merged = {};
    
    // ローカルデータを追加
    for (final item in localData) {
      final id = item[idField] as String?;
      if (id != null) {
        merged[id] = Map<String, dynamic>.from(item);
      }
    }
    
    // リモートデータでマージ（Firestore優先）
    for (final remoteItem in remoteData) {
      final id = remoteItem[idField] as String?;
      if (id == null) continue;
      
      // リモートデータが存在する場合は常に採用（Firestore優先）
      merged[id] = Map<String, dynamic>.from(remoteItem);
    }
    
    return merged.values.toList();
  }
  
  /// 差分を検出
  /// 
  /// 2つのデータリスト間の差分を検出する
  /// 戻り値: {'added': [...], 'modified': [...], 'deleted': [...]}
  static Map<String, List<Map<String, dynamic>>> detectDifferences(
    List<Map<String, dynamic>> oldData,
    List<Map<String, dynamic>> newData,
    String idField,
  ) {
    final Map<String, Map<String, dynamic>> oldMap = {};
    final Map<String, Map<String, dynamic>> newMap = {};
    
    // マップに変換
    for (final item in oldData) {
      final id = item[idField] as String?;
      if (id != null) {
        oldMap[id] = item;
      }
    }
    
    for (final item in newData) {
      final id = item[idField] as String?;
      if (id != null) {
        newMap[id] = item;
      }
    }
    
    final List<Map<String, dynamic>> added = [];
    final List<Map<String, dynamic>> modified = [];
    final List<Map<String, dynamic>> deleted = [];
    
    // 新規追加と変更を検出
    for (final entry in newMap.entries) {
      final id = entry.key;
      final newItem = entry.value;
      final oldItem = oldMap[id];
      
      if (oldItem == null) {
        // 新規追加
        added.add(newItem);
      } else if (!_isEqual(oldItem, newItem)) {
        // 変更
        modified.add(newItem);
      }
    }
    
    // 削除を検出
    for (final entry in oldMap.entries) {
      final id = entry.key;
      if (!newMap.containsKey(id)) {
        deleted.add(entry.value);
      }
    }
    
    return {
      'added': added,
      'modified': modified,
      'deleted': deleted,
    };
  }
  
  /// タイムスタンプを比較
  /// 
  /// 2つのタイムスタンプを比較し、どちらが新しいかを判定する
  /// 戻り値: 1 (firstが新しい), -1 (secondが新しい), 0 (同じ)
  static int compareTimestamps(
    dynamic first,
    dynamic second,
  ) {
    final firstDate = _parseDateTime(first);
    final secondDate = _parseDateTime(second);
    
    if (firstDate == null && secondDate == null) return 0;
    if (firstDate == null) return -1;
    if (secondDate == null) return 1;
    
    if (firstDate.isAfter(secondDate)) return 1;
    if (firstDate.isBefore(secondDate)) return -1;
    return 0;
  }
  
  /// 指定時刻以降の変更をフィルタ
  /// 
  /// 指定された時刻以降に変更されたデータのみをフィルタリングする
  static List<Map<String, dynamic>> filterModifiedSince(
    List<Map<String, dynamic>> data,
    DateTime since,
    String lastModifiedField,
  ) {
    return data.where((item) {
      final lastModified = _parseDateTime(item[lastModifiedField]);
      if (lastModified == null) return false;
      return lastModified.isAfter(since);
    }).toList();
  }
  
  /// データの同期状態を確認
  /// 
  /// ローカルとリモートの最終同期時刻を比較し、同期が必要かどうかを判定する
  static bool needsSync(
    DateTime? localLastSync,
    DateTime? remoteLastSync,
  ) {
    if (localLastSync == null || remoteLastSync == null) return true;
    return remoteLastSync.isAfter(localLastSync);
  }
  
  /// 同期時刻を更新
  /// 
  /// 現在時刻で同期時刻を更新する
  static DateTime updateSyncTime() {
    return DateTime.now();
  }
  
  /// データの整合性をチェック
  /// 
  /// データリストの整合性をチェックし、不正なデータを検出する
  /// 戻り値: 不正なデータのリスト
  static List<Map<String, dynamic>> validateData(
    List<Map<String, dynamic>> data,
    List<String> requiredFields,
  ) {
    final List<Map<String, dynamic>> invalidData = [];
    
    for (final item in data) {
      bool isValid = true;
      
      // 必須フィールドの存在チェック
      for (final field in requiredFields) {
        if (!item.containsKey(field) || item[field] == null) {
          isValid = false;
          break;
        }
      }
      
      if (!isValid) {
        invalidData.add(item);
      }
    }
    
    return invalidData;
  }
  
  /// データをソート
  /// 
  /// 指定されたフィールドでデータをソートする
  static List<Map<String, dynamic>> sortData(
    List<Map<String, dynamic>> data,
    String sortField,
    {bool ascending = true}
  ) {
    final sortedData = List<Map<String, dynamic>>.from(data);
    
    sortedData.sort((a, b) {
      final aValue = a[sortField];
      final bValue = b[sortField];
      
      if (aValue == null && bValue == null) return 0;
      if (aValue == null) return ascending ? 1 : -1;
      if (bValue == null) return ascending ? -1 : 1;
      
      if (aValue is DateTime && bValue is DateTime) {
        return ascending 
            ? aValue.compareTo(bValue)
            : bValue.compareTo(aValue);
      }
      
      if (aValue is String && bValue is String) {
        return ascending 
            ? aValue.compareTo(bValue)
            : bValue.compareTo(aValue);
      }
      
      if (aValue is num && bValue is num) {
        return ascending 
            ? aValue.compareTo(bValue)
            : bValue.compareTo(aValue);
      }
      
      return 0;
    });
    
    return sortedData;
  }
  
  /// 重複データを除去
  /// 
  /// 指定されたフィールドで重複を検出し、重複データを除去する
  static List<Map<String, dynamic>> removeDuplicates(
    List<Map<String, dynamic>> data,
    String uniqueField,
  ) {
    final Set<String> seen = {};
    final List<Map<String, dynamic>> uniqueData = [];
    
    for (final item in data) {
      final uniqueValue = item[uniqueField] as String?;
      if (uniqueValue != null && !seen.contains(uniqueValue)) {
        seen.add(uniqueValue);
        uniqueData.add(item);
      }
    }
    
    return uniqueData;
  }
  
  /// データをページ分割
  /// 
  /// データを指定されたページサイズで分割する
  static List<List<Map<String, dynamic>>> paginateData(
    List<Map<String, dynamic>> data,
    int pageSize,
  ) {
    final List<List<Map<String, dynamic>>> pages = [];
    
    for (int i = 0; i < data.length; i += pageSize) {
      final end = (i + pageSize < data.length) ? i + pageSize : data.length;
      pages.add(data.sublist(i, end));
    }
    
    return pages;
  }
  
  /// ヘルパー関数: DateTimeを解析
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
  
  /// ヘルパー関数: 2つのMapが等しいかチェック
  static bool _isEqual(Map<String, dynamic> a, Map<String, dynamic> b) {
    if (a.length != b.length) return false;
    
    for (final entry in a.entries) {
      final key = entry.key;
      final value = entry.value;
      
      if (!b.containsKey(key)) return false;
      if (value != b[key]) return false;
    }
    
    return true;
  }

  /// Firestoreデータリストを変換可能な形式に変換
  /// 
  /// FirestoreのTimestampオブジェクトを含むデータを、
  /// JSONエンコード可能な形式（DateTime → ISO8601文字列）に変換します。
  /// 
  /// データ形式を自動判定:
  /// - Firestore形式（Timestamp含む）: fromFirestore() → toJson()で変換
  /// - JSON形式（文字列のみ）: そのまま使用（既に変換済み）
  /// 
  /// **パラメータ**:
  /// - `dataList`: データリスト（Firestore形式またはJSON形式）
  /// - `fromFirestore`: FirestoreデータをモデルTに変換する関数
  /// - `toJson`: モデルTをJSON形式に変換する関数
  /// - `fromJson`: JSON形式をモデルTに変換する関数（形式判定用）
  /// 
  /// **戻り値**: JSONエンコード可能なデータリスト
  /// 
  /// **使用例**:
  /// ```dart
  /// final jsonList = SyncMk.convertToJsonFormat<Countdown>(
  ///   mixedDataList,
  ///   fromFirestore: (data) => Countdown.fromFirestore(data),
  ///   toJson: (item) => item.toJson(),
  ///   fromJson: (json) => Countdown.fromJson(json),
  /// );
  /// ```
  static List<Map<String, dynamic>> convertToJsonFormat<T>(
    List<Map<String, dynamic>> dataList,
    T Function(Map<String, dynamic>) fromFirestore,
    Map<String, dynamic> Function(T) toJson,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final jsonList = <Map<String, dynamic>>[];
    
    for (final data in dataList) {
      try {
        // データ形式を判定: Timestamp型のフィールドがあるかチェック
        final isFirestoreFormat = _isFirestoreFormat(data);
        
        if (isFirestoreFormat) {
          // Firestore形式（Timestamp含む）→ モデル → JSON形式
          final item = fromFirestore(data);
          final jsonData = toJson(item);
          jsonList.add(jsonData);
        } else {
          // 既にJSON形式 → 検証のためモデル化してから再JSON化
          try {
            final item = fromJson(data);
            final jsonData = toJson(item);
            jsonList.add(jsonData);
          } catch (e) {
            // fromJsonでエラーの場合はそのまま追加
            jsonList.add(data);
          }
        }
      } catch (e) {
        // エラーが発生したアイテムはスキップ（ログなし）
      }
    }
    
    return jsonList;
  }

  /// データがFirestore形式かJSON形式かを判定
  /// 
  /// Timestamp型のフィールドが含まれている場合はFirestore形式と判定
  static bool _isFirestoreFormat(Map<String, dynamic> data) {
    for (final value in data.values) {
      // Timestampクラスの型チェック
      if (value.runtimeType.toString().contains('Timestamp')) {
        return true;
      }
    }
    return false;
  }
}
