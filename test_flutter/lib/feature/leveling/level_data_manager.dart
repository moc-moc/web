import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:test_flutter/data/repositories/base/base_data_manager.dart';
import 'package:test_flutter/feature/leveling/level_model.dart';

class LevelingDataManager extends BaseDataManager<LevelingState> {
  static const _docId = 'current_level';

  @override
  String getCollectionPath(String userId) => 'users/$userId/leveling';

  @override
  LevelingState convertFromFirestore(Map<String, dynamic> data) {
    DateTime timestampToDate(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      return DateTime.now();
    }

    return LevelingState(
      id: data['id'] as String? ?? _docId,
      periodId: data['periodId'] as String? ?? '',
      level: (data['level'] as num?)?.round() ?? 0,
      exactLevel: (data['exactLevel'] as num?)?.toDouble() ?? 0,
      progressToNextLevel:
          (data['progressToNextLevel'] as num?)?.toDouble() ?? 0,
      personSeconds: data['personSeconds'] as int? ?? 0,
      requiredSecondsForNextLevel:
          (data['requiredSecondsForNextLevel'] as num?)?.round() ?? 0,
      rank: _rankFromString(data['rank'] as String?),
      periodStart: timestampToDate(data['periodStart']),
      periodEnd: timestampToDate(data['periodEnd']),
      nextResetAt: timestampToDate(data['nextResetAt']),
      lastUpdated: timestampToDate(data['lastUpdated']),
    );
  }

  @override
  Map<String, dynamic> convertToFirestore(LevelingState item) {
    return {
      'id': item.id,
      'periodId': item.periodId,
      'level': item.level,
      'exactLevel': item.exactLevel,
      'progressToNextLevel': item.progressToNextLevel,
      'personSeconds': item.personSeconds,
      'requiredSecondsForNextLevel': item.requiredSecondsForNextLevel,
      'rank': item.rank.name,
      'periodStart': Timestamp.fromDate(item.periodStart),
      'periodEnd': Timestamp.fromDate(item.periodEnd),
      'nextResetAt': Timestamp.fromDate(item.nextResetAt),
      'lastUpdated': Timestamp.fromDate(item.lastUpdated),
    };
  }

  @override
  LevelingState convertFromJson(Map<String, dynamic> json) =>
      LevelingState.fromJson(json);

  @override
  Map<String, dynamic> convertToJson(LevelingState item) => item.toJson();

  @override
  String get storageKey => 'leveling_state';

  @override
  String get idField => 'id';

  LevelRankTier _rankFromString(String? value) {
    if (value == null) return LevelRankTier.apprentice;
    return LevelRankTier.values.firstWhere(
      (tier) => tier.name == value,
      orElse: () => LevelRankTier.apprentice,
    );
  }

  Future<LevelingState> getOrCreateCurrentState(DateTime now) async {
    try {
      final existing = await _getCurrentLevelWithAuth();
      if (existing != null) {
        return existing;
      }
    } catch (e) {
      debugPrint('⚠️ [LevelingDataManager] 取得エラー: $e');
    }

    final created = LevelingState.initial(now: now, id: _docId);
    await saveCurrentLevel(created);
    return created;
  }

  Future<LevelingState?> _getCurrentLevelWithAuth() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return await getLocalById(_docId);
    try {
      final doc = await manager.getById(userId, _docId);
      if (doc != null) {
        await manager.updateLocal(doc);
        return doc;
      }
    } catch (e) {
      debugPrint('⚠️ [LevelingDataManager] Firestore取得失敗: $e');
    }
    return await getLocalById(_docId);
  }

  Future<LevelingState?> getLocalCurrentLevel() async =>
      await getLocalById(_docId);

  Future<void> saveCurrentLevel(LevelingState state) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      await manager.saveWithRetry(userId, state);
    }
    await manager.updateLocal(state);
  }
}


