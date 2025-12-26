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

    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          height: constraints.maxHeight,
          padding: EdgeInsets.all(AppSpacing.xs),
          decoration: BoxDecoration(
            color: AppColors.black,
            borderRadius: BorderRadius.circular(AppRadius.medium),
            border: Border.all(
              color: visuals.badgeColor.withValues(alpha: 0.3),
            ),
            boxShadow: [
              BoxShadow(
                color: visuals.badgeColor.withValues(alpha: 0.2),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  LevelBadge(
                    tier: computation.rank,
                    level: computation.level,
                    size: 28,
                    showGlow: true,
                  ),
                  SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Lv ${computation.level} • ${visuals.label}',
                          style: AppTextStyles.body1.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(height: 1),
                        Text(
                          '$hours h human focus',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4),
              LinearProgressBar(
                percentage: percentage,
                height: 8,
                progressColor: visuals.badgeColor,
                backgroundColor: AppColors.blackgray,
                barBackgroundColor: AppColors.disabledGray,
                showFlowAnimation: true,
              ),
              if (showCountdown && nextReset.isAfter(DateTime.now())) ...[
                SizedBox(height: AppSpacing.xs),
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
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: visuals.badgeColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppRadius.small),
                border: Border.all(
                  color: visuals.badgeColor.withValues(alpha: 0.6),
                  width: 1,
                ),
              ),
              child: Text(
                'Next in $remainingHours h',
                style: AppTextStyles.caption.copyWith(
                  color: visuals.badgeColor,
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
        ),
      );
      },
    );
  }
}


