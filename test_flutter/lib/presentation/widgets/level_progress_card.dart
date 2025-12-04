import 'package:flutter/material.dart';
import 'package:test_flutter/core/theme.dart';
import 'package:test_flutter/feature/leveling/level_formula.dart';
import 'package:test_flutter/feature/leveling/level_model.dart';
import 'package:test_flutter/feature/leveling/level_visuals.dart';
import 'package:test_flutter/presentation/widgets/level_badge.dart';
import 'package:test_flutter/presentation/widgets/progress_bars.dart';
import 'package:test_flutter/presentation/widgets/stats_display.dart';

class LevelProgressCard extends StatelessWidget {
  const LevelProgressCard({
    super.key,
    required this.state,
    this.additionalPersonSeconds = 0,
    this.showCountdown = true,
  });

  final LevelingState state;
  final int additionalPersonSeconds;
  final bool showCountdown;

  @override
  Widget build(BuildContext context) {
    final totalSeconds =
        (state.personSeconds + additionalPersonSeconds).clamp(0, 1 << 31).toInt();
    final computation = LevelFormula.computeLevel(totalSeconds);
    final visuals = LevelRankVisuals.resolveForLevel(computation.level);
    final percentage = computation.progressToNextLevel.clamp(0.0, 1.0);
    final hours = (totalSeconds / 3600).toStringAsFixed(1);
    final nextReset = state.nextResetAt;
    final remainingSeconds =
        (computation.requiredSecondsForNextLevel - totalSeconds).clamp(0, 1 << 31);
    final remainingHours = (remainingSeconds / 3600).toStringAsFixed(1);

    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(
          color: visuals.badgeColor.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: visuals.badgeColor.withValues(alpha: 0.2),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              LevelBadge(
                tier: computation.rank,
                level: computation.level,
                size: 64,
                showGlow: true,
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Monthly Level',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      'Lv ${computation.level} • ${visuals.label}',
                      style: AppTextStyles.h3.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '$hours h human focus',
                      style: AppTextStyles.body2.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          LinearProgressBar(
            percentage: percentage,
            height: 12,
            progressColor: visuals.badgeColor,
            backgroundColor: AppColors.blackgray,
            barBackgroundColor: AppColors.disabledGray,
            showFlowAnimation: true,
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            'Next level in $remainingHours h',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          if (showCountdown && nextReset.isAfter(DateTime.now())) ...[
            SizedBox(height: AppSpacing.md),
            RealtimeCountdownDisplay(
              eventName: 'Next reset',
              targetDate: nextReset,
              accentColor: visuals.badgeColor,
              borderColor: visuals.badgeColor.withValues(alpha: 0.4),
              backgroundColor: AppColors.blackgray,
            ),
          ],
        ],
      ),
    );
  }
}


