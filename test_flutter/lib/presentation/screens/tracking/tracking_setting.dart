import 'package:flutter/material.dart';
import 'package:test_flutter/core/theme.dart';
import 'package:test_flutter/core/route.dart';
import 'package:test_flutter/presentation/widgets/layouts.dart';
import 'package:test_flutter/presentation/widgets/app_bars.dart';
import 'package:test_flutter/presentation/widgets/toggles_chips.dart';
import 'package:test_flutter/dummy_data/goal_data.dart';

/// トラッキング設定画面（新デザインシステム版）
class TrackingSettingScreenNew extends StatefulWidget {
  const TrackingSettingScreenNew({super.key});

  @override
  State<TrackingSettingScreenNew> createState() => _TrackingSettingScreenNewState();
}

class _TrackingSettingScreenNewState extends State<TrackingSettingScreenNew> {
  // 各カテゴリーに対応する目標の選択
  String? selectedStudyGoal;
  String? selectedPcGoal;
  String? selectedSmartphoneGoal;

  // 設定の状態
  bool isPowerSavingMode = false;
  bool isCameraVisible = true;

  @override
  void initState() {
    super.initState();
    // デフォルトで最初の目標を選択
    final studyGoals = dummyGoals.where((g) => g.category == 'study').toList();
    final pcGoals = dummyGoals.where((g) => g.category == 'pc').toList();
    final smartphoneGoals = dummyGoals.where((g) => g.category == 'smartphone').toList();
    
    if (studyGoals.isNotEmpty) selectedStudyGoal = studyGoals[0].id;
    if (pcGoals.isNotEmpty) selectedPcGoal = pcGoals[0].id;
    if (smartphoneGoals.isNotEmpty) selectedSmartphoneGoal = smartphoneGoals[0].id;
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: AppColors.black,
      appBar: AppBarWithBack(title: 'Tracking Settings'),
      body: SafeContent(
        child: ScrollableContent(
          child: SpacedColumn(
            spacing: AppSpacing.lg,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 目標選択セクション
              _buildGoalSelectionSection(),

              SizedBox(height: AppSpacing.md),

              // 設定セクション
              _buildSettingsSection(),

              SizedBox(height: AppSpacing.xl),

              // スタートボタン
              _buildStartButton(context),
            ],
          ),
        ),
      ),
    );
  }

  /// 目標選択セクション
  Widget _buildGoalSelectionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Goal Selection',
          style: AppTextStyles.h2,
        ),
        SizedBox(height: AppSpacing.sm),
        Text(
          'Select which goal to track for each detected activity',
          style: AppTextStyles.body2.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: AppSpacing.md),

        // 勉強の目標選択
        _buildGoalSelector(
          title: 'Study',
          icon: Icons.menu_book,
          color: AppColors.green,
          selectedGoalId: selectedStudyGoal,
          goals: dummyGoals.where((g) => g.category == 'study').toList(),
          onGoalSelected: (goalId) {
            setState(() {
              selectedStudyGoal = goalId;
            });
          },
        ),

        SizedBox(height: AppSpacing.md),

        // パソコンの目標選択
        _buildGoalSelector(
          title: 'PC Work',
          icon: Icons.computer,
          color: AppColors.blue,
          selectedGoalId: selectedPcGoal,
          goals: dummyGoals.where((g) => g.category == 'pc').toList(),
          onGoalSelected: (goalId) {
            setState(() {
              selectedPcGoal = goalId;
            });
          },
        ),

        SizedBox(height: AppSpacing.md),

        // スマホの目標選択
        _buildGoalSelector(
          title: 'Smartphone',
          icon: Icons.smartphone,
          color: AppColors.orange,
          selectedGoalId: selectedSmartphoneGoal,
          goals: dummyGoals.where((g) => g.category == 'smartphone').toList(),
          onGoalSelected: (goalId) {
            setState(() {
              selectedSmartphoneGoal = goalId;
            });
          },
        ),
      ],
    );
  }

  /// 目標選択ウィジェット
  Widget _buildGoalSelector({
    required String title,
    required IconData icon,
    required Color color,
    required String? selectedGoalId,
    required List<DummyGoal> goals,
    required ValueChanged<String?> onGoalSelected,
  }) {
    if (goals.isEmpty) {
      return Container(
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.lightblackgray.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppRadius.large),
          border: Border.all(
            color: AppColors.lightblackgray.withValues(alpha: 0.4),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.lightblackgray.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                '$title: No goals available',
                style: AppTextStyles.body1.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.lightblackgray.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(
          color: color.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              SizedBox(width: AppSpacing.sm),
              Text(
                title,
                style: AppTextStyles.body1.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          ...goals.map((goal) {
            final isSelected = selectedGoalId == goal.id;
            return Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.xs),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                  onTap: () => onGoalSelected(goal.id),
                  child: Container(
                    padding: EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? color.withValues(alpha: 0.2)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(AppRadius.medium),
                      border: Border.all(
                        color: isSelected
                            ? color
                            : AppColors.lightblackgray.withValues(alpha: 0.3),
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isSelected
                              ? Icons.radio_button_checked
                              : Icons.radio_button_unchecked,
                          color: isSelected ? color : AppColors.textSecondary,
                          size: 20,
                        ),
                        SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                goal.title,
                                style: AppTextStyles.body2.copyWith(
                                  color: isSelected
                                      ? AppColors.white
                                      : AppColors.textSecondary,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                              ),
                              Text(
                                '${goal.targetHours}h / ${goal.period}',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  /// 設定セクション
  Widget _buildSettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Settings',
          style: AppTextStyles.h2,
        ),
        SizedBox(height: AppSpacing.sm),

        // 省電力モード
        _buildSettingSwitch(
          title: 'Power Saving Mode',
          description: 'Reduce battery consumption during tracking',
          icon: Icons.battery_saver,
          iconColor: AppColors.green,
          value: isPowerSavingMode,
          onChanged: (value) {
            setState(() {
              isPowerSavingMode = value;
            });
          },
        ),

        SizedBox(height: AppSpacing.md),

        // カメラ表示
        _buildSettingSwitch(
          title: 'Show Camera',
          description: 'Display camera preview during tracking',
          icon: Icons.videocam,
          iconColor: AppColors.blue,
          value: isCameraVisible,
          onChanged: (value) {
            setState(() {
              isCameraVisible = value;
            });
          },
        ),
      ],
    );
  }

  /// 設定スイッチウィジェット
  Widget _buildSettingSwitch({
    required String title,
    required String description,
    required IconData icon,
    required Color iconColor,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.lightblackgray.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(
          color: iconColor.withValues(alpha: 0.35),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: value
                  ? iconColor.withValues(alpha: 0.2)
                  : AppColors.lightblackgray.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: value ? iconColor : AppColors.textSecondary,
              size: 24,
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.body1.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: AppSpacing.xs),
                Text(
                  description,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          AppToggleSwitch(
            value: value,
            onChanged: onChanged,
            activeColor: iconColor,
          ),
        ],
      ),
    );
  }

  /// スタートボタン
  Widget _buildStartButton(BuildContext context) {
    final borderRadius = BorderRadius.circular(AppRadius.large);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: borderRadius,
        onTap: () {
          Navigator.pushNamed(context, AppRoutes.trackingNew);
        },
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: AppColors.lightblackgray.withValues(alpha: 0.1),
            borderRadius: borderRadius,
            border: Border.all(
              color: AppColors.blue.withValues(alpha: 0.4),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(26),
                  gradient: const LinearGradient(
                    colors: [
                      AppColors.blue,
                      AppColors.purple,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: AppColors.white,
                  size: 28,
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Text(
                'Start Tracking',
                style: AppTextStyles.h3.copyWith(
                  color: AppColors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
