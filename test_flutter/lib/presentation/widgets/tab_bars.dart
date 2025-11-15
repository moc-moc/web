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
