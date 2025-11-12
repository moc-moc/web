import 'package:flutter/material.dart';
import 'package:test_flutter/core/theme.dart';
import 'package:test_flutter/presentation/screens/Home/homescreen.dart';
import 'package:test_flutter/presentation/screens/Goal/goal.dart';
import 'package:test_flutter/presentation/screens/Report/report.dart';

// ========================================
// 新しいデザインシステムに基づくナビゲーション
// ========================================

/// ナビゲーションアイテム
class NavigationItem {
  final IconData icon;
  final String label;
  final Widget screen;

  const NavigationItem({
    required this.icon,
    required this.label,
    required this.screen,
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

  /// デフォルトの3項目ナビゲーション（Home, Goal, Report）
  static List<NavigationItem> get defaultItems => [
    const NavigationItem(icon: Icons.home, label: 'Home', screen: HomeScreen()),
    const NavigationItem(icon: Icons.flag, label: 'Goal', screen: Goal()),
    const NavigationItem(
      icon: Icons.assessment,
      label: 'Report',
      screen: Report(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 64,
          padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (index) {
              final item = items[index];
              final isSelected = index == currentIndex;
              return _NavigationBarItem(
                icon: item.icon,
                label: item.label,
                isSelected: isSelected,
                onTap: () => onTap(index),
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
  final VoidCallback onTap;

  const _NavigationBarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.medium),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? AppColors.blue : AppColors.textSecondary,
                size: 24,
              ),
              SizedBox(height: AppSpacing.xs),
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: isSelected ? AppColors.blue : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
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
    const HomeScreen(),
    const Goal(),
    const Report(),
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
