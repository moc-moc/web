import 'package:flutter/material.dart';
import 'package:test_flutter/core/theme.dart';
import 'package:test_flutter/presentation/screens/home/home_screen.dart';
import 'package:test_flutter/presentation/screens/goal/goal.dart';
import 'package:test_flutter/presentation/screens/report/report.dart';
import 'package:test_flutter/presentation/screens/setting/settings_screen.dart';

// ========================================
// 新しいデザインシステムに基づくナビゲーション
// ========================================

/// ナビゲーションアイテム
class NavigationItem {
  final IconData icon;
  final String label;
  final Widget screen;
  final Color? activeColor;

  const NavigationItem({
    required this.icon,
    required this.label,
    required this.screen,
    this.activeColor,
  });
}

/// アプリのボトムナビゲーションバー
class AppBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<NavigationItem> items;

  const AppBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  /// デフォルトの4項目ナビゲーション（Home, Goal, Report, Settings）
  static List<NavigationItem> get defaultItems => [
    const NavigationItem(
      icon: Icons.home,
      label: 'Home',
      screen: HomeScreenNew(),
      activeColor: AppColors.blue,
    ),
    const NavigationItem(
      icon: Icons.flag,
      label: 'Goal',
      screen: GoalScreenNew(),
      activeColor: AppColors.orange,
    ),
    const NavigationItem(
      icon: Icons.assessment,
      label: 'Report',
      screen: ReportScreenNew(),
      activeColor: AppColors.green,
    ),
    const NavigationItem(
      icon: Icons.settings,
      label: 'Settings',
      screen: SettingsScreenNew(),
      activeColor: AppColors.purple,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.md,
          0,
          AppSpacing.md,
          AppSpacing.xs,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.black,
            borderRadius: BorderRadius.circular(26),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(items.length, (index) {
              final item = items[index];
              final isSelected = index == currentIndex;
              return Expanded(
                child: _NavigationBarItem(
                  icon: item.icon,
                  label: item.label,
                  isSelected: isSelected,
                  activeColor: item.activeColor,
                  onTap: () => onTap(index),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavigationBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final Color? activeColor;
  final VoidCallback onTap;

  const _NavigationBarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.large),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            padding: EdgeInsets.symmetric(
              vertical: AppSpacing.xs,
              horizontal: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? (activeColor ?? AppColors.blue).withValues(alpha: 0.15)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isSelected
                    ? (activeColor ?? AppColors.blue)
                    : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: isSelected
                      ? (activeColor ?? AppColors.blue)
                      : AppColors.textSecondary,
                  size: 22,
                ),
                SizedBox(height: AppSpacing.xs),
                Text(
                  label,
                  style: AppTextStyles.caption.copyWith(
                    color: isSelected
                        ? (activeColor ?? AppColors.blue)
                        : AppColors.textSecondary,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// ボトムナビゲーションバー付きの画面コンテナ
class AppNavigationScreen extends StatefulWidget {
  final int initialIndex;
  final List<NavigationItem>? items;

  const AppNavigationScreen({super.key, this.initialIndex = 0, this.items});

  @override
  State<AppNavigationScreen> createState() => _AppNavigationScreenState();
}

class _AppNavigationScreenState extends State<AppNavigationScreen> {
  late int _currentIndex;
  late List<NavigationItem> _items;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _items = widget.items ?? AppBottomNavigationBar.defaultItems;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: _items[_currentIndex].screen,
      bottomNavigationBar: AppBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: _items,
      ),
    );
  }
}

// ========================================
// 既存のナビゲーション（互換性のために保持）
// ========================================

/// ボトムナビゲーションバー（旧バージョン）
class BottomNavigationBarScreen extends StatefulWidget {
  final int initialIndex;

  const BottomNavigationBarScreen({super.key, this.initialIndex = 0});

  @override
  State<BottomNavigationBarScreen> createState() =>
      _BottomNavigationBarScreenState();
}

class _BottomNavigationBarScreenState extends State<BottomNavigationBarScreen> {
  late int _currentIndex;

  final List<Widget> _screens = [
    const HomeScreenNew(),
    const GoalScreenNew(),
    const ReportScreenNew(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.home, color: AppColors.blue),
                SizedBox(height: 2),
                Text('Home', style: TextStyle(color: AppColors.blue)),
              ],
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.flag, color: AppColors.green),
                SizedBox(height: 2),
                Text('Goal', style: TextStyle(color: AppColors.green)),
              ],
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.assessment, color: AppColors.red),
                SizedBox(height: 2),
                Text('Report', style: TextStyle(color: AppColors.red)),
              ],
            ),
            label: '',
          ),
        ],
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
