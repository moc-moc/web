import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:test_flutter/core/theme.dart';
import 'package:test_flutter/core/route.dart';
import 'package:test_flutter/presentation/widgets/layouts.dart';
import 'package:test_flutter/presentation/widgets/app_bars.dart';
import 'package:test_flutter/presentation/widgets/toggles_chips.dart';
import 'package:test_flutter/presentation/widgets/navigation/navigation_helper.dart';
import 'package:test_flutter/feature/goals/goal_functions.dart';
import 'package:test_flutter/feature/goals/goal_model.dart';
import 'package:test_flutter/feature/setting/tracking_settings_notifier.dart';

/// トラッキング設定画面（新デザインシステム版）
class TrackingSettingScreenNew extends ConsumerStatefulWidget {
  const TrackingSettingScreenNew({super.key});

  @override
  ConsumerState<TrackingSettingScreenNew> createState() => _TrackingSettingScreenNewState();
}

class _TrackingSettingScreenNewState extends ConsumerState<TrackingSettingScreenNew> {
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
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadSettings();
  }

  /// 設定を読み込む
  Future<void> _loadSettings() async {
    // トラッキング設定を読み込む
    await loadTrackingSettingsWithBackgroundRefreshHelper(ref);
    
    final settings = ref.read(trackingSettingsProvider);
    final goals = ref.read(goalsListProvider);
    
    // 各カテゴリーの目標を取得
    final studyGoals = goals.where((g) => g.detectionItem == DetectionItem.book).toList();
    final pcGoals = goals.where((g) => g.detectionItem == DetectionItem.pc).toList();
    final smartphoneGoals = goals.where((g) => g.detectionItem == DetectionItem.smartphone).toList();
    
    String? newSelectedStudyGoal;
    String? newSelectedPcGoal;
    String? newSelectedSmartphoneGoal;
    bool needsUpdate = false;
    
    // Study目標の選択を確認・更新
    if (settings.selectedStudyGoalId != null) {
      final exists = studyGoals.any((g) => g.id == settings.selectedStudyGoalId);
      if (exists) {
        newSelectedStudyGoal = settings.selectedStudyGoalId;
      } else if (studyGoals.isNotEmpty) {
        // 選択された目標が存在しない場合、最初の目標を自動選択
        newSelectedStudyGoal = studyGoals[0].id;
        needsUpdate = true;
      } else {
        newSelectedStudyGoal = null;
        needsUpdate = true;
      }
    } else if (studyGoals.isNotEmpty) {
      // 設定がなく、目標が存在する場合は最初の目標を自動選択
      newSelectedStudyGoal = studyGoals[0].id;
      needsUpdate = true;
    }
    
    // PC目標の選択を確認・更新
    if (settings.selectedPcGoalId != null) {
      final exists = pcGoals.any((g) => g.id == settings.selectedPcGoalId);
      if (exists) {
        newSelectedPcGoal = settings.selectedPcGoalId;
      } else if (pcGoals.isNotEmpty) {
        // 選択された目標が存在しない場合、最初の目標を自動選択
        newSelectedPcGoal = pcGoals[0].id;
        needsUpdate = true;
      } else {
        newSelectedPcGoal = null;
        needsUpdate = true;
      }
    } else if (pcGoals.isNotEmpty) {
      // 設定がなく、目標が存在する場合は最初の目標を自動選択
      newSelectedPcGoal = pcGoals[0].id;
      needsUpdate = true;
    }
    
    // Smartphone目標の選択を確認・更新
    if (settings.selectedSmartphoneGoalId != null) {
      final exists = smartphoneGoals.any((g) => g.id == settings.selectedSmartphoneGoalId);
      if (exists) {
        newSelectedSmartphoneGoal = settings.selectedSmartphoneGoalId;
      } else if (smartphoneGoals.isNotEmpty) {
        // 選択された目標が存在しない場合、最初の目標を自動選択
        newSelectedSmartphoneGoal = smartphoneGoals[0].id;
        needsUpdate = true;
      } else {
        newSelectedSmartphoneGoal = null;
        needsUpdate = true;
      }
    } else if (smartphoneGoals.isNotEmpty) {
      // 設定がなく、目標が存在する場合は最初の目標を自動選択
      newSelectedSmartphoneGoal = smartphoneGoals[0].id;
      needsUpdate = true;
    }
    
    setState(() {
      selectedStudyGoal = newSelectedStudyGoal;
      selectedPcGoal = newSelectedPcGoal;
      selectedSmartphoneGoal = newSelectedSmartphoneGoal;
      
      // 設定の状態を読み込む
      isPowerSavingMode = settings.isPowerSavingMode;
      isCameraVisible = settings.isCameraOn;
    });
    
    // 自動選択された場合は保存
    if (needsUpdate) {
      await _saveSettings();
    }
  }

  /// 設定を保存する
  Future<void> _saveSettings() async {
    final currentSettings = ref.read(trackingSettingsProvider);
    final updatedSettings = currentSettings.copyWith(
      selectedStudyGoalId: selectedStudyGoal,
      selectedPcGoalId: selectedPcGoal,
      selectedSmartphoneGoalId: selectedSmartphoneGoal,
      isPowerSavingMode: isPowerSavingMode,
      isCameraOn: isCameraVisible,
    );
    
    await saveTrackingSettingsHelper(ref, updatedSettings);
  }

  @override
  Widget build(BuildContext context) {
    final goals = ref.watch(goalsListProvider);
    
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
              _buildGoalSelectionSection(goals),

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
  Widget _buildGoalSelectionSection(List<Goal> goals) {
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
          goals: goals.where((g) => g.detectionItem == DetectionItem.book).toList(),
          onGoalSelected: (goalId) async {
            setState(() {
              selectedStudyGoal = goalId;
            });
            await _saveSettings();
          },
        ),

        SizedBox(height: AppSpacing.md),

        // パソコンの目標選択
        _buildGoalSelector(
          title: 'PC Work',
          icon: Icons.computer,
          color: AppColors.blue,
          selectedGoalId: selectedPcGoal,
          goals: goals.where((g) => g.detectionItem == DetectionItem.pc).toList(),
          onGoalSelected: (goalId) async {
            setState(() {
              selectedPcGoal = goalId;
            });
            await _saveSettings();
          },
        ),

        SizedBox(height: AppSpacing.md),

        // スマホの目標選択
        _buildGoalSelector(
          title: 'Smartphone',
          icon: Icons.smartphone,
          color: AppColors.orange,
          selectedGoalId: selectedSmartphoneGoal,
          goals: goals.where((g) => g.detectionItem == DetectionItem.smartphone).toList(),
          onGoalSelected: (goalId) async {
            setState(() {
              selectedSmartphoneGoal = goalId;
            });
            await _saveSettings();
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
    required List<Goal> goals,
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
                                '${(goal.targetTime / 60).toStringAsFixed(1)}h / ${goal.durationDays} days',
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
          onChanged: (value) async {
            setState(() {
              isPowerSavingMode = value;
            });
            await _saveSettings();
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
          onChanged: (value) async {
            setState(() {
              isCameraVisible = value;
            });
            await _saveSettings();
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
          NavigationHelper.push(context, AppRoutes.trackingNew);
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
