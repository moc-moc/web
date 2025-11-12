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
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(AppRadius.medium),
      ),
      child: scrollable
          ? SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: _buildTabRow(),
            )
          : _buildTabRow(),
    );
  }

  Widget _buildTabRow() {
    return Row(
      mainAxisSize: scrollable ? MainAxisSize.min : MainAxisSize.max,
      children: List.generate(tabs.length, (index) {
        final isSelected = index == selectedIndex;
        return Expanded(
          flex: scrollable ? 0 : 1,
          child: _TabItem(
            label: tabs[index],
            isSelected: isSelected,
            onTap: () => onTabSelected(index),
          ),
        );
      }),
    );
  }
}

class _TabItem extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabItem({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? AppColors.blue : Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadius.medium),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Center(
            child: Text(
              label,
              style: AppTextStyles.body2.copyWith(
                color: AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              ),
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

  const PeriodTabBar({
    super.key,
    required this.selectedIndex,
    required this.onPeriodSelected,
  });

  static const List<String> periods = ['Day', 'Week', 'Month', 'Year'];

  @override
  Widget build(BuildContext context) {
    return AppTabBar(
      tabs: periods,
      selectedIndex: selectedIndex,
      onTabSelected: onPeriodSelected,
      scrollable: true,
    );
  }
}
