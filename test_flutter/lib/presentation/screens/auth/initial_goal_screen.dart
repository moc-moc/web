import 'package:flutter/material.dart';
import 'package:test_flutter/core/theme.dart';
import 'package:test_flutter/core/route.dart';
import 'package:test_flutter/presentation/widgets/buttons.dart';
import 'package:test_flutter/presentation/widgets/input_fields.dart';
import 'package:test_flutter/presentation/widgets/layouts.dart';
import 'package:test_flutter/presentation/widgets/app_bars.dart';
import 'package:test_flutter/presentation/widgets/cards.dart';

/// 初期目標設定画面
class InitialGoalScreen extends StatefulWidget {
  const InitialGoalScreen({super.key});

  @override
  State<InitialGoalScreen> createState() => _InitialGoalScreenState();
}

class _InitialGoalScreenState extends State<InitialGoalScreen> {
  String _selectedCategory = 'study';
  String _selectedPeriod = 'weekly';
  final _targetHoursController = TextEditingController(text: '10');

  final Map<String, String> _categories = {
    'study': 'Study',
    'pc': 'Computer Work',
    'smartphone': 'Smartphone',
    'work': 'Work',
  };

  final Map<String, String> _periods = {
    'daily': 'Daily',
    'weekly': 'Weekly',
    'monthly': 'Monthly',
  };

  @override
  void dispose() {
    _targetHoursController.dispose();
    super.dispose();
  }

  void _handleGetStarted() {
    // ダミー: ホーム画面へ遷移
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.home,
      (route) => false,
    );
  }

  void _handleSkip() {
    // ダミー: 目標設定をスキップしてホーム画面へ
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.home,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBarWithBack(
        title: 'Set Your Goals',
        onBack: () => Navigator.pop(context),
      ),
      body: ScrollableContent(
        child: ConstrainedContent(
          maxWidth: 600,
          child: SpacedColumn(
            spacing: AppSpacing.xl,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              SizedBox(height: AppSpacing.lg),
              _buildGoalForm(),
              SizedBox(height: AppSpacing.xxl),
              _buildButtons(),
              SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Set Your First Goal!', style: AppTextStyles.h2),
        SizedBox(height: AppSpacing.sm),
        Text(
          'Goals help you stay motivated and track your progress',
          style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildGoalForm() {
    return StandardCard(
      child: SpacedColumn(
        spacing: AppSpacing.lg,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Category Selection
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'What do you want to track?',
                style: AppTextStyles.body1.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: AppSpacing.md),
              _buildCategoryGrid(),
            ],
          ),
          // Period Selection
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Goal Period',
                style: AppTextStyles.body1.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: AppSpacing.md),
              _buildPeriodSelection(),
            ],
          ),
          // Target Hours
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Target Hours',
                style: AppTextStyles.body1.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _targetHoursController,
                keyboardType: TextInputType.number,
                placeholder: '10',
                suffixIcon: Padding(
                  padding: EdgeInsets.all(AppSpacing.md),
                  child: Text(
                    'hours',
                    style: AppTextStyles.body2.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryGrid() {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      mainAxisSpacing: AppSpacing.sm,
      crossAxisSpacing: AppSpacing.sm,
      childAspectRatio: 2.5,
      physics: const NeverScrollableScrollPhysics(),
      children: _categories.entries.map((entry) {
        final isSelected = _selectedCategory == entry.key;
        return _buildCategoryCard(entry.key, entry.value, isSelected);
      }).toList(),
    );
  }

  Widget _buildCategoryCard(String key, String label, bool isSelected) {
    IconData icon;
    Color color;

    switch (key) {
      case 'study':
        icon = Icons.menu_book;
        color = AppChartColors.study;
        break;
      case 'pc':
        icon = Icons.computer;
        color = AppChartColors.pc;
        break;
      case 'smartphone':
        icon = Icons.smartphone;
        color = AppChartColors.smartphone;
        break;
      case 'work':
        icon = Icons.work;
        color = AppColors.purple;
        break;
      default:
        icon = Icons.category;
        color = AppColors.gray;
    }

    return Container(
      decoration: BoxDecoration(
        color: isSelected
            ? color.withValues(alpha: 0.2)
            : AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(
          color: isSelected ? color : AppColors.backgroundSecondary,
          width: 2,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedCategory = key;
            });
          },
          borderRadius: BorderRadius.circular(AppRadius.medium),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? color : AppColors.textSecondary,
                size: 20,
              ),
              SizedBox(width: AppSpacing.sm),
              Text(
                label,
                style: AppTextStyles.body2.copyWith(
                  color: isSelected
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodSelection() {
    return Row(
      children: _periods.entries.map((entry) {
        final isSelected = _selectedPeriod == entry.key;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: entry.key != _periods.keys.last ? AppSpacing.sm : 0,
            ),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.blue
                    : AppColors.backgroundSecondary,
                borderRadius: BorderRadius.circular(AppRadius.medium),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedPeriod = entry.key;
                    });
                  },
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                  child: Center(
                    child: Text(
                      entry.value,
                      style: AppTextStyles.body2.copyWith(
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildButtons() {
    return SpacedColumn(
      spacing: AppSpacing.md,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PrimaryButton(
          text: 'Get Started',
          onPressed: _handleGetStarted,
          size: ButtonSize.large,
          icon: Icons.check,
        ),
        AppTextButton(
          text: 'Skip for now',
          onPressed: _handleSkip,
          size: ButtonSize.large,
          textColor: AppColors.textSecondary,
        ),
      ],
    );
  }
}
