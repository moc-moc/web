import 'package:flutter/material.dart';
import 'package:test_flutter/core/theme.dart';

/// カード
class CustomCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;

  const CustomCard({
    super.key,
    required this.child,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        color: AppColors.blackgray,
        margin: EdgeInsets.zero,
        child: child,
      ),
    );
  }
}

/// 時間入力カード（トラッキング用）
/// 
/// カテゴリごとに時間（分単位）を入力するカードです。
class TimeInputCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color iconColor;
  final TextEditingController controller;

  const TimeInputCard({
    super.key,
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: iconColor,
              radius: 24,
              child: Icon(
                icon,
                color: AppColors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(
              width: 80,
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  suffixText: '分',
                  suffixStyle: const TextStyle(
                    color: AppColors.gray,
                    fontSize: 14,
                  ),
                  filled: true,
                  fillColor: AppColors.black.withValues(alpha: 0.3),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 累計データ表示カード
/// 
/// 総ログイン日数と総作業時間を横並びで表示します。
class TotalStatsCard extends StatelessWidget {
  final int totalLoginDays;
  final String totalWorkTime;

  const TotalStatsCard({
    super.key,
    required this.totalLoginDays,
    required this.totalWorkTime,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: CustomCard(
              height: 120,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      color: AppColors.blue,
                      size: 28,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '$totalLoginDays日',
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      '総ログイン',
                      style: TextStyle(
                        color: AppColors.gray,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: CustomCard(
              height: 120,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.timer,
                      color: AppColors.green,
                      size: 28,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      totalWorkTime,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      '総作業時間',
                      style: TextStyle(
                        color: AppColors.gray,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
