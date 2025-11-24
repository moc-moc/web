import 'package:flutter/material.dart';
import 'package:test_flutter/core/theme.dart';
import 'package:test_flutter/feature/leveling/level_model.dart';
import 'package:test_flutter/feature/leveling/level_visuals.dart';
import 'package:test_flutter/presentation/screens/event/event_screen_base.dart';
import 'package:test_flutter/presentation/widgets/event_content_builder.dart';

class LevelUpEventScreen extends StatefulWidget {
  const LevelUpEventScreen({super.key});

  @override
  State<LevelUpEventScreen> createState() => _LevelUpEventScreenState();
}

class _LevelUpEventScreenState extends State<LevelUpEventScreen> {
  int _level = 0;
  double _exactLevel = 0;
  double _progress = 0;
  int _personSeconds = 0;
  LevelRankTier _rank = LevelRankTier.apprentice;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arguments = ModalRoute.of(context)?.settings.arguments;
    if (arguments is Map<String, dynamic>) {
      setState(() {
        _level = (arguments['level'] as num?)?.round() ?? 0;
        _exactLevel = (arguments['exactLevel'] as num?)?.toDouble() ?? _level.toDouble();
        _progress = (arguments['progress'] as num?)?.toDouble() ?? 0;
        _personSeconds = (arguments['personSeconds'] as num?)?.round() ?? 0;
        final rankName = arguments['rank'] as String?;
        _rank = LevelRankTier.values.firstWhere(
          (tier) => tier.name == rankName,
          orElse: () => LevelRankTier.apprentice,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = LevelRankVisuals.resolve(_rank);
    final hours = (_personSeconds / 3600).toStringAsFixed(1);
    final percent = ((_progress.clamp(0.0, 1.0)) * 100).toStringAsFixed(1);

    return EventScreenBase(
      gradientColors: style.gradient,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(style.icon, size: 72, color: style.accentColor),
          SizedBox(height: AppSpacing.sm),
          Text(
            'Level Up!',
            style: AppTextStyles.h1.copyWith(
              fontSize: 34,
              color: AppColors.white,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            'Rank unlocked: ${style.label}',
            style: AppTextStyles.body1.copyWith(color: AppColors.white),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.lg),
          EventContentBuilder.buildProgressRing(
            percentage: (_exactLevel / 100).clamp(0.0, 1.0),
            value: 'Lv $_level',
            label: 'Current Level',
            size: 260,
            backgroundColor: style.badgeColor.withValues(alpha: 0.15),
            progressColor: style.badgeColor,
          ),
          SizedBox(height: AppSpacing.lg),
          Container(
            padding: EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.black.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(AppRadius.large),
              border: Border.all(color: style.badgeColor.withValues(alpha: 0.5)),
              boxShadow: [
                BoxShadow(
                  color: style.badgeColor.withValues(alpha: 0.3),
                  blurRadius: 24,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                EventContentBuilder.buildDetailRow(
                  'Exact Level',
                  _exactLevel.toStringAsFixed(2),
                ),
                EventContentBuilder.buildDetailRow(
                  'Next Level Progress',
                  '$percent%',
                ),
                EventContentBuilder.buildDetailRow(
                  'Human Focused Time',
                  '$hours h',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
