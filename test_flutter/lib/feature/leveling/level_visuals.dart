import 'package:flutter/material.dart';
import 'package:test_flutter/core/theme.dart';
import 'package:test_flutter/feature/leveling/level_model.dart';

class LevelRankVisuals {
  const LevelRankVisuals({
    required this.tier,
    required this.label,
    required this.gradient,
    required this.icon,
    required this.accentColor,
    required this.badgeColor,
    required this.borderWidth,
    required this.glowIntensity,
  });

  final LevelRankTier tier;
  final String label;
  final List<Color> gradient;
  final IconData icon;
  final Color accentColor;
  final Color badgeColor;
  final double borderWidth;
  final double glowIntensity;

  /// レベルに応じた色を計算（緑→青→紫→赤→オレンジ→黄色→金→白→シルバー→黒）
  static LevelRankVisuals resolveForLevel(int level) {
    // レベル範囲に応じた色を決定
    Color primaryColor;
    Color secondaryColor;
    Color badgeColor;
    IconData icon;
    String label;
    double borderWidth;
    double glowIntensity;

    if (level >= 91) {
      // レベル91-100: 黒
      primaryColor = const Color(0xFF1A1A1A);
      secondaryColor = const Color(0xFF2A2A2A);
      badgeColor = const Color(0xFF3A3A3A);
      icon = Icons.diamond;
      label = 'Master';
      borderWidth = 3.0;
      glowIntensity = 1.0;
    } else if (level >= 81) {
      // レベル81-90: シルバー
      primaryColor = const Color(0xFFC0C0C0);
      secondaryColor = const Color(0xFFE8E8E8);
      badgeColor = const Color(0xFFD0D0D0);
      icon = Icons.workspace_premium;
      label = 'Elite';
      borderWidth = 2.5;
      glowIntensity = 0.9;
    } else if (level >= 71) {
      // レベル71-80: 白
      primaryColor = const Color(0xFFFFFFFF);
      secondaryColor = const Color(0xFFF5F5F5);
      badgeColor = const Color(0xFFE8E8E8);
      icon = Icons.stars;
      label = 'Legend';
      borderWidth = 2.5;
      glowIntensity = 0.85;
    } else if (level >= 61) {
      // レベル61-70: 金
      primaryColor = const Color(0xFFFFD700);
      secondaryColor = const Color(0xFFFFF8DC);
      badgeColor = const Color(0xFFFFE55C);
      icon = Icons.emoji_events;
      label = 'Champion';
      borderWidth = 2.0;
      glowIntensity = 0.8;
    } else if (level >= 51) {
      // レベル51-60: 黄色
      primaryColor = AppColors.yellow;
      secondaryColor = const Color(0xFFFFF59D);
      badgeColor = const Color(0xFFFFEB3B);
      icon = Icons.star;
      label = 'Expert';
      borderWidth = 2.0;
      glowIntensity = 0.7;
    } else if (level >= 41) {
      // レベル41-50: オレンジ
      primaryColor = AppColors.orange;
      secondaryColor = const Color(0xFFFFB74D);
      badgeColor = const Color(0xFFFF9800);
      icon = Icons.local_fire_department;
      label = 'Advanced';
      borderWidth = 1.5;
      glowIntensity = 0.6;
    } else if (level >= 31) {
      // レベル31-40: 赤
      primaryColor = AppColors.red;
      secondaryColor = const Color(0xFFFF6B6B);
      badgeColor = const Color(0xFFFF5252);
      icon = Icons.whatshot;
      label = 'Skilled';
      borderWidth = 1.5;
      glowIntensity = 0.5;
    } else if (level >= 21) {
      // レベル21-30: 紫
      primaryColor = AppColors.purple;
      secondaryColor = const Color(0xFFBA68C8);
      badgeColor = const Color(0xFF9C27B0);
      icon = Icons.auto_awesome;
      label = 'Intermediate';
      borderWidth = 1.0;
      glowIntensity = 0.4;
    } else if (level >= 11) {
      // レベル11-20: 青
      primaryColor = AppColors.blue;
      secondaryColor = const Color(0xFF64B5F6);
      badgeColor = const Color(0xFF2196F3);
      icon = Icons.trending_up;
      label = 'Novice';
      borderWidth = 1.0;
      glowIntensity = 0.3;
    } else {
      // レベル0-10: 緑
      primaryColor = AppColors.green;
      secondaryColor = const Color(0xFF81C784);
      badgeColor = const Color(0xFF4CAF50);
      icon = Icons.star_border;
      label = 'Beginner';
      borderWidth = 1.0;
      glowIntensity = 0.2;
    }

    return LevelRankVisuals(
      tier: _tierForLevel(level),
      label: label,
      gradient: [primaryColor, secondaryColor],
      icon: icon,
      accentColor: AppColors.white,
      badgeColor: badgeColor,
      borderWidth: borderWidth,
      glowIntensity: glowIntensity,
    );
  }

  static LevelRankTier _tierForLevel(int level) {
    if (level >= 85) return LevelRankTier.diamond;
    if (level >= 70) return LevelRankTier.platinum;
    if (level >= 55) return LevelRankTier.gold;
    if (level >= 40) return LevelRankTier.silver;
    if (level >= 20) return LevelRankTier.bronze;
    return LevelRankTier.apprentice;
  }

  static LevelRankVisuals resolve(LevelRankTier tier) {
    // 後方互換性のため、tierベースの解決も提供
    switch (tier) {
      case LevelRankTier.diamond:
        return LevelRankVisuals(
          tier: tier,
          label: 'Diamond',
          gradient: const [Color(0xFF83A4FF), Color(0xFFB6FBFF)],
          icon: Icons.auto_awesome,
          accentColor: AppColors.white,
          badgeColor: const Color(0xFFBCE0FF),
          borderWidth: 3.0,
          glowIntensity: 1.0,
        );
      case LevelRankTier.platinum:
        return LevelRankVisuals(
          tier: tier,
          label: 'Platinum',
          gradient: const [Color(0xFFB5B5D8), Color(0xFFE3E3F1)],
          icon: Icons.workspace_premium,
          accentColor: AppColors.white,
          badgeColor: const Color(0xFFC9C9E8),
          borderWidth: 2.5,
          glowIntensity: 0.9,
        );
      case LevelRankTier.gold:
        return LevelRankVisuals(
          tier: tier,
          label: 'Gold',
          gradient: const [Color(0xFFFFC371), Color(0xFFFFA751)],
          icon: Icons.emoji_events,
          accentColor: AppColors.white,
          badgeColor: const Color(0xFFFFD27D),
          borderWidth: 2.0,
          glowIntensity: 0.8,
        );
      case LevelRankTier.silver:
        return LevelRankVisuals(
          tier: tier,
          label: 'Silver',
          gradient: const [Color(0xFFBBD2C5), Color(0xFF536976)],
          icon: Icons.military_tech,
          accentColor: AppColors.white,
          badgeColor: const Color(0xFFCBD6DA),
          borderWidth: 1.5,
          glowIntensity: 0.6,
        );
      case LevelRankTier.bronze:
        return LevelRankVisuals(
          tier: tier,
          label: 'Bronze',
          gradient: const [Color(0xFFD1913C), Color(0xFFFFC857)],
          icon: Icons.local_fire_department,
          accentColor: AppColors.white,
          badgeColor: const Color(0xFFF0B775),
          borderWidth: 1.5,
          glowIntensity: 0.5,
        );
      case LevelRankTier.apprentice:
        return LevelRankVisuals(
          tier: tier,
          label: 'Apprentice',
          gradient: const [Color(0xFF3A1C71), Color(0xFFD76D77)],
          icon: Icons.star_border,
          accentColor: AppColors.white,
          badgeColor: const Color(0xFFD76D77),
          borderWidth: 1.0,
          glowIntensity: 0.2,
        );
    }
  }
}


