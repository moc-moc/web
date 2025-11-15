import 'package:flutter/material.dart';
import 'package:test_flutter/core/theme.dart';
import 'package:test_flutter/core/route.dart';
import 'package:test_flutter/presentation/widgets/buttons.dart';
import 'package:test_flutter/presentation/widgets/layouts.dart';
import 'package:test_flutter/presentation/widgets/app_bars.dart';

/// 初期目標設定画面
class InitialGoalScreen extends StatefulWidget {
  const InitialGoalScreen({super.key});

  @override
  State<InitialGoalScreen> createState() => _InitialGoalScreenState();
}

class _InitialGoalScreenState extends State<InitialGoalScreen> {
  String _selectedCategory = 'study';
  String _selectedPeriod = 'weekly';
  String? _selectedComparison; // 'above' or 'below'
  final _titleController = TextEditingController();
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
    _titleController.dispose();
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
      backgroundColor: AppColors.black,
      appBar: AppBarWithBack(
        title: 'Set Your Goals',
        onBack: () => Navigator.pop(context),
      ),
      body: SafeArea(
        child: ScrollableContent(
          padding: EdgeInsets.all(AppSpacing.md),
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
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(
          color: AppColors.gray.withValues(alpha: 0.35),
          width: 1.5,
        ),
      ),
      child: SpacedColumn(
        spacing: AppSpacing.xl,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTitleSection(),
          _buildCategorySection(),
          _buildTargetHoursSection(),
          _buildPeriodSection(),
          _buildComparisonSection(),
        ],
      ),
    );
  }

  Widget _buildTitleSection() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.blackgray,
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(
          color: AppColors.gray.withValues(alpha: 0.35),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Title',
            style: AppTextStyles.body1.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.white,
            ),
          ),
          SizedBox(height: AppSpacing.md),
          TextField(
            controller: _titleController,
            style: AppTextStyles.body1.copyWith(color: AppColors.white),
            decoration: InputDecoration(
              hintText: 'Enter goal title',
              hintStyle: AppTextStyles.body1.copyWith(
                color: AppColors.textDisabled,
              ),
              filled: true,
              fillColor: AppColors.black,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.medium),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.medium),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.medium),
                borderSide: BorderSide(color: AppColors.gray, width: 2),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.blackgray,
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(
          color: AppColors.gray.withValues(alpha: 0.35),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Category',
            style: AppTextStyles.body1.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.white,
            ),
          ),
          SizedBox(height: AppSpacing.md),
          _buildCategoryGrid(),
        ],
      ),
    );
  }

  Widget _buildTargetHoursSection() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.blackgray,
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(
          color: AppColors.gray.withValues(alpha: 0.35),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Target Hours',
            style: AppTextStyles.body1.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.white,
            ),
          ),
          SizedBox(height: AppSpacing.md),
          TextField(
            controller: _targetHoursController,
            keyboardType: TextInputType.number,
            style: AppTextStyles.body1.copyWith(color: AppColors.white),
            decoration: InputDecoration(
              hintText: '10',
              hintStyle: AppTextStyles.body1.copyWith(
                color: AppColors.textDisabled,
              ),
              suffixIcon: Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: Text(
                  'hours',
                  style: AppTextStyles.body2.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              filled: true,
              fillColor: AppColors.black,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.medium),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.medium),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.medium),
                borderSide: BorderSide(color: AppColors.gray, width: 2),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSection() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.blackgray,
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(
          color: AppColors.gray.withValues(alpha: 0.35),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Goal Period',
            style: AppTextStyles.body1.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.white,
            ),
          ),
          SizedBox(height: AppSpacing.md),
          _buildPeriodSelection(),
        ],
      ),
    );
  }

  Widget _buildComparisonSection() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.blackgray,
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(
          color: AppColors.gray.withValues(alpha: 0.35),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Comparison',
            style: AppTextStyles.body1.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.white,
            ),
          ),
          SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _buildComparisonButton('above', '以上'),
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _buildComparisonButton('below', '以下'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonButton(String value, String label) {
    final isSelected = _selectedComparison == value;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () {
          setState(() {
            _selectedComparison = isSelected ? null : value;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(
            vertical: AppSpacing.sm,
            horizontal: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.purple.withValues(alpha: 0.15)
                : AppColors.black,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isSelected
                  ? AppColors.purple
                  : AppColors.gray.withValues(alpha: 0.35),
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: AppTextStyles.body2.copyWith(
                color: isSelected
                    ? AppColors.purple
                    : AppColors.textSecondary,
                fontWeight: isSelected
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
          ),
        ),
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
        color = AppColors.green;
        break;
      case 'pc':
        icon = Icons.computer;
        color = AppColors.blue;
        break;
      case 'smartphone':
        icon = Icons.smartphone;
        color = AppColors.orange;
        break;
      case 'work':
        icon = Icons.work;
        color = AppColors.purple;
        break;
      default:
        icon = Icons.category;
        color = AppColors.blackgray;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: isSelected
            ? color.withValues(alpha: 0.2)
            : AppColors.black,
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(
          color: isSelected
              ? color
              : AppColors.gray.withValues(alpha: 0.35),
          width: isSelected ? 1.5 : 1,
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
          borderRadius: BorderRadius.circular(AppRadius.large),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
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
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
                if (key == 'work') ...[
                  SizedBox(height: AppSpacing.xs),
                  Text(
                    'study+pc',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.gray,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodSelection() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.gray.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: _periods.entries.map((entry) {
          final isSelected = _selectedPeriod == entry.key;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: () {
                    setState(() {
                      _selectedPeriod = entry.key;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.symmetric(
                      vertical: AppSpacing.sm,
                      horizontal: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.orange.withValues(alpha: 0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.orange
                            : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        entry.value,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.body2.copyWith(
                          color: isSelected
                              ? AppColors.orange
                              : AppColors.textSecondary,
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
      ),
    );
  }

  Widget _buildButtons() {
    return SpacedColumn(
      spacing: AppSpacing.md,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: 56.0,
          decoration: BoxDecoration(
            color: AppColors.blue.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(AppRadius.large),
            border: Border.all(
              color: AppColors.blue,
              width: 1.5,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _handleGetStarted,
              borderRadius: BorderRadius.circular(AppRadius.large),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check,
                      color: AppColors.white,
                      size: 20,
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Text(
                      'Get Started',
                      style: AppTextStyles.body1.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
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
