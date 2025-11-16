import 'package:flutter/material.dart';
import 'package:test_flutter/core/theme.dart';
import 'package:test_flutter/presentation/widgets/cards.dart';
import 'package:test_flutter/presentation/widgets/toggles_chips.dart';
import 'package:test_flutter/presentation/widgets/tab_bars.dart';
import 'package:test_flutter/presentation/widgets/layouts.dart';

/// 初期目標設定フォームウィジェット
class InitialGoalForm extends StatefulWidget {
  final String selectedCategory;
  final String selectedPeriod;
  final String? selectedComparison;
  final TextEditingController titleController;
  final TextEditingController targetHoursController;
  final ValueChanged<String> onCategoryChanged;
  final ValueChanged<String> onPeriodChanged;
  final ValueChanged<String?> onComparisonChanged;

  const InitialGoalForm({
    super.key,
    required this.selectedCategory,
    required this.selectedPeriod,
    required this.selectedComparison,
    required this.titleController,
    required this.targetHoursController,
    required this.onCategoryChanged,
    required this.onPeriodChanged,
    required this.onComparisonChanged,
  });

  @override
  State<InitialGoalForm> createState() => _InitialGoalFormState();
}

class _InitialGoalFormState extends State<InitialGoalForm> {
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
  Widget build(BuildContext context) {
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
    return FormSection(
      title: 'Title',
      child: TextField(
        controller: widget.titleController,
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
    );
  }

  Widget _buildCategorySection() {
    return FormSection(
      title: 'Category',
      child: _buildCategoryGrid(),
    );
  }

  Widget _buildTargetHoursSection() {
    return FormSection(
      title: 'Target Hours',
      child: TextField(
        controller: widget.targetHoursController,
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
    );
  }

  Widget _buildPeriodSection() {
    return FormSection(
      title: 'Goal Period',
      child: MultiTabSwitcher(
        tabs: _periods,
        selectedKey: widget.selectedPeriod,
        onTabChanged: widget.onPeriodChanged,
        selectedColor: AppColors.orange,
      ),
    );
  }

  Widget _buildComparisonSection() {
    return FormSection(
      title: 'Comparison',
      child: Row(
        children: [
          Expanded(
            child: SelectableButton(
              label: '以上',
              isSelected: widget.selectedComparison == 'above',
              onTap: () {
                widget.onComparisonChanged(
                  widget.selectedComparison == 'above' ? null : 'above',
                );
              },
              selectedColor: AppColors.purple,
            ),
          ),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: SelectableButton(
              label: '以下',
              isSelected: widget.selectedComparison == 'below',
              onTap: () {
                widget.onComparisonChanged(
                  widget.selectedComparison == 'below' ? null : 'below',
                );
              },
              selectedColor: AppColors.purple,
            ),
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
        final isSelected = widget.selectedCategory == entry.key;
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

    return CategoryCard(
      label: label,
      icon: icon,
      color: color,
      isSelected: isSelected,
      onTap: () => widget.onCategoryChanged(key),
      subtitle: key == 'work' ? 'study+pc' : null,
    );
  }
}

