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
  });

  final LevelRankTier tier;
  final String label;
  final List<Color> gradient;
  final IconData icon;
  final Color accentColor;
  final Color badgeColor;

  static LevelRankVisuals resolve(LevelRankTier tier) {
    switch (tier) {
      case LevelRankTier.diamond:
        return LevelRankVisuals(
          tier: tier,
          label: 'Diamond',
          gradient: const [Color(0xFF83A4FF), Color(0xFFB6FBFF)],
          icon: Icons.auto_awesome,
          accentColor: AppColors.white,
          badgeColor: const Color(0xFFBCE0FF),
        );
      case LevelRankTier.platinum:
        return LevelRankVisuals(
          tier: tier,
          label: 'Platinum',
          gradient: const [Color(0xFFB5B5D8), Color(0xFFE3E3F1)],
          icon: Icons.workspace_premium,
          accentColor: AppColors.white,
          badgeColor: const Color(0xFFC9C9E8),
        );
      case LevelRankTier.gold:
        return LevelRankVisuals(
          tier: tier,
          label: 'Gold',
          gradient: const [Color(0xFFFFC371), Color(0xFFFFA751)],
          icon: Icons.emoji_events,
          accentColor: AppColors.white,
          badgeColor: const Color(0xFFFFD27D),
        );
      case LevelRankTier.silver:
        return LevelRankVisuals(
          tier: tier,
          label: 'Silver',
          gradient: const [Color(0xFFBBD2C5), Color(0xFF536976)],
          icon: Icons.military_tech,
          accentColor: AppColors.white,
          badgeColor: const Color(0xFFCBD6DA),
        );
      case LevelRankTier.bronze:
        return LevelRankVisuals(
          tier: tier,
          label: 'Bronze',
          gradient: const [Color(0xFFD1913C), Color(0xFFFFC857)],
          icon: Icons.local_fire_department,
          accentColor: AppColors.white,
          badgeColor: const Color(0xFFF0B775),
        );
      case LevelRankTier.apprentice:
        return LevelRankVisuals(
          tier: tier,
          label: 'Apprentice',
          gradient: const [Color(0xFF3A1C71), Color(0xFFD76D77)],
          icon: Icons.star_border,
          accentColor: AppColors.white,
          badgeColor: const Color(0xFFD76D77),
        );
    }
  }
}


