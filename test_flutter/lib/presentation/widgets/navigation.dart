import 'package:flutter/material.dart';
import 'package:test_flutter/core/theme.dart';
import 'package:test_flutter/presentation/screens/Home/homescreen.dart';
import 'package:test_flutter/presentation/screens/Goal/goal.dart';
import 'package:test_flutter/presentation/screens/Report/report.dart';

/// ボトムナビゲーションバー
class BottomNavigationBarScreen extends StatefulWidget {
  final int initialIndex;
  
  const BottomNavigationBarScreen({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<BottomNavigationBarScreen> createState() => _BottomNavigationBarScreenState();
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

