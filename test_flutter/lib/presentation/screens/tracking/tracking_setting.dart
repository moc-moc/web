import 'package:flutter/material.dart';
import 'package:test_flutter/core/theme.dart';
import 'package:test_flutter/core/route.dart';
import 'package:test_flutter/presentation/widgets/buttons.dart';

/// Tracking Setting画面
/// トラッキング開始前の設定画面
class TrackingSettingScreen extends StatelessWidget {
  const TrackingSettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text('Tracking Setting'),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.blackgray,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Tracking Setting画面',
              style: TextStyle(
                color: AppColors.blackgray,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            // popAndPushNamedでtracking画面へ遷移
            CustomPopAndPushButton(
              text: 'Start',
              routeName: AppRoutes.tracking,
              color: AppColors.green,
            ),
          ],
        ),
      ),
    );
  }
}

