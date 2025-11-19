import 'package:flutter/material.dart';
import 'package:test_flutter/core/theme.dart';

/// アプリ共通タブバー
class AppTabBar extends StatelessWidget {
  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;
  final bool scrollable;

  const AppTabBar({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onTabSelected,
    this.scrollable = false,
  });

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(30);

    Widget content = _buildTabRow();

    if (scrollable) {
      content = SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: content,
      );
    }

    return ClipRRect(
      borderRadius: borderRadius,
      child: Container(
        height: 48,
        color: AppColors.blackgray,
        child: content,
      ),
    );
  }

  Widget _buildTabRow() {
    return Row(
      mainAxisSize: scrollable ? MainAxisSize.min : MainAxisSize.max,
      children: List.generate(tabs.length, (index) {
        final isSelected = index == selectedIndex;
        final tab = _TabItem(
          label: tabs[index],
          isSelected: isSelected,
          onTap: () => onTabSelected(index),
          isScrollable: scrollable,
        );
        if (scrollable) {
          return ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 110),
            child: tab,
          );
        } else {
          return Expanded(child: tab);
        }
      }),
    );
  }
}

class _TabItem extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isScrollable;

  const _TabItem({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.isScrollable,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          height: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: isScrollable ? AppSpacing.lg : AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.blue
                : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTextStyles.body2.copyWith(
              color: isSelected ? AppColors.white : AppColors.textPrimary,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

/// レポート画面用の期間タブバー
class PeriodTabBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onPeriodSelected;
  final bool scrollable;

  const PeriodTabBar({
    super.key,
    required this.selectedIndex,
    required this.onPeriodSelected,
    this.scrollable = true,
  });

  static const List<String> periods = ['Day', 'Week', 'Month', 'Year'];

  @override
  Widget build(BuildContext context) {
    return AppTabBar(
      tabs: periods,
      selectedIndex: selectedIndex,
      onTabSelected: onPeriodSelected,
      scrollable: scrollable,
    );
  }
}

/// 2つのタブを切り替えるスイッチャー（Sign Up / Log In用）
class TabSwitcher extends StatelessWidget {
  final String firstTab;
  final String secondTab;
  final bool isFirstSelected;
  final ValueChanged<bool> onTabChanged;

  const TabSwitcher({
    super.key,
    required this.firstTab,
    required this.secondTab,
    required this.isFirstSelected,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
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
        children: [
          Expanded(
            child: _TabSwitcherItem(
              text: firstTab,
              isSelected: isFirstSelected,
              onTap: () => onTabChanged(true),
            ),
          ),
          Expanded(
            child: _TabSwitcherItem(
              text: secondTab,
              isSelected: !isFirstSelected,
              onTap: () => onTabChanged(false),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabSwitcherItem extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabSwitcherItem({
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(
            vertical: AppSpacing.sm,
            horizontal: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.blue.withValues(alpha: 0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isSelected ? AppColors.blue : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: AppTextStyles.body2.copyWith(
              color: isSelected
                  ? AppColors.blue
                  : AppColors.textSecondary,
              fontWeight: isSelected
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}

/// 複数のタブを切り替えるスイッチャー（3つ以上に対応）
class MultiTabSwitcher extends StatelessWidget {
  final Map<String, String> tabs; // key: 値, value: 表示ラベル
  final String selectedKey;
  final ValueChanged<String> onTabChanged;
  final Color? selectedColor;

  const MultiTabSwitcher({
    super.key,
    required this.tabs,
    required this.selectedKey,
    required this.onTabChanged,
    this.selectedColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveSelectedColor = selectedColor ?? AppColors.orange;

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
        children: tabs.entries.map((entry) {
          final isSelected = selectedKey == entry.key;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: () => onTabChanged(entry.key),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.symmetric(
                      vertical: AppSpacing.sm,
                      horizontal: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? effectiveSelectedColor.withValues(alpha: 0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isSelected
                            ? effectiveSelectedColor
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
                              ? effectiveSelectedColor
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
}
