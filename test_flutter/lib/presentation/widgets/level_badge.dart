import 'package:flutter/material.dart';
import 'package:test_flutter/core/theme.dart';
import 'package:test_flutter/feature/leveling/level_model.dart';
import 'package:test_flutter/feature/leveling/level_visuals.dart';

class LevelBadge extends StatelessWidget {
  const LevelBadge({
    super.key,
    required this.tier,
    required this.level,
    this.size = 72,
    this.showGlow = false,
  });

  final LevelRankTier tier;
  final int level;
  final double size;
  final bool showGlow;

  @override
  Widget build(BuildContext context) {
    // レベルに応じたスタイルを取得
    final style = LevelRankVisuals.resolveForLevel(level);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: style.gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: showGlow
            ? [
                BoxShadow(
                  color: style.badgeColor.withValues(alpha: 0.7 * style.glowIntensity),
                  blurRadius: 18 * style.glowIntensity,
                  spreadRadius: 2 * style.glowIntensity,
                ),
              ]
            : [],
      ),
      child: Container(
        margin: EdgeInsets.all(size * 0.08),
        decoration: BoxDecoration(
          color: AppColors.black.withValues(alpha: 0.35),
          shape: BoxShape.circle,
          border: Border.all(
            color: style.badgeColor.withValues(alpha: 0.6),
            width: style.borderWidth,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              style.icon,
              color: style.accentColor,
              size: size * 0.35,
            ),
            Text(
              level.toString(),
              style: AppTextStyles.body1.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
                fontSize: size * 0.25,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


