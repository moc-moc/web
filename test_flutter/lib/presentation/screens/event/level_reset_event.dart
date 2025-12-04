import 'package:flutter/material.dart';
import 'package:test_flutter/core/theme.dart';
import 'package:test_flutter/feature/leveling/level_visuals.dart';
import 'package:test_flutter/presentation/screens/event/event_screen_base.dart';
import 'package:test_flutter/presentation/widgets/event_content_builder.dart';

class LevelResetEventScreen extends StatefulWidget {
  const LevelResetEventScreen({super.key});

  @override
  State<LevelResetEventScreen> createState() => _LevelResetEventScreenState();
}

class _LevelResetEventScreenState extends State<LevelResetEventScreen> {
  int _previousLevel = 0;
  int _personSeconds = 0;
  String _periodId = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arguments = ModalRoute.of(context)?.settings.arguments;
    if (arguments is Map<String, dynamic>) {
      setState(() {
        _previousLevel = (arguments['previousLevel'] as num?)?.round() ?? 0;
        _personSeconds = (arguments['personSeconds'] as num?)?.round() ?? 0;
        _periodId = arguments['periodId'] as String? ?? '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = LevelRankVisuals.resolveForLevel(_previousLevel);
    final hours = (_personSeconds / 3600).toStringAsFixed(1);

    return EventScreenBase(
      gradientColors: style.gradient,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.restart_alt, size: 72, color: style.accentColor),
          SizedBox(height: AppSpacing.sm),
          Text(
            'New Month, Fresh Level',
            style: AppTextStyles.h1.copyWith(
              fontSize: 30,
              color: AppColors.white,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            'Last month (${_periodId.isEmpty ? 'previous' : _periodId}) achievements have been saved.',
            style: AppTextStyles.body1.copyWith(color: AppColors.white),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.lg),
          EventContentBuilder.buildNumberContent(
            number: 'Lv $_previousLevel',
            label: style.label,
            title: 'Total Human Focused Time',
            message: '$hours h',
          ),
        ],
      ),
    );
  }
}


