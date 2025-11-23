import 'package:flutter/material.dart';
import 'package:test_flutter/core/theme.dart';
import 'package:test_flutter/presentation/widgets/toggles_chips.dart';

/// イベント画面の共通コンテンツ生成ヘルパー
class EventContentBuilder {
  /// アイコン + タイトル + メッセージのコンテンツを生成
  static Widget buildIconContent({
    required IconData icon,
    required String title,
    required String message,
    double iconSize = 120,
    double titleFontSize = 40,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: iconSize, color: AppColors.textPrimary),
        SizedBox(height: AppSpacing.md),
        Text(
          title,
          style: AppTextStyles.h1.copyWith(fontSize: titleFontSize),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: AppSpacing.sm),
        Text(
          message,
          style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.normal),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// 大きな数字 + ラベル + タイトル + メッセージのコンテンツを生成
  static Widget buildNumberContent({
    required String number,
    required String label,
    required String title,
    required String message,
    double numberFontSize = 120,
    double titleFontSize = 36,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          number,
          style: TextStyle(
            fontSize: numberFontSize,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            height: 1.0,
          ),
        ),
        SizedBox(height: AppSpacing.xs),
        Text(
          label,
          style: AppTextStyles.h3,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: AppSpacing.sm),
        Text(
          title,
          style: AppTextStyles.h2.copyWith(fontSize: titleFontSize),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: AppSpacing.xs),
        Text(
          message,
          style: AppTextStyles.body2,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// 次マイルストーン表示カードを生成
  static Widget buildMilestoneCard({
    required String nextMilestoneText,
    IconData? icon,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.textPrimary.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppRadius.medium),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, color: AppColors.textPrimary, size: 18),
            SizedBox(width: AppSpacing.xs),
          ],
          Flexible(
            child: Text(
              nextMilestoneText,
              style: AppTextStyles.body2.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  /// 達成率表示カードを生成
  static Widget buildAchievementCard({
    required String goalName,
    required double achievedHours,
    required double targetHours,
    String? period,
  }) {
    final percentage = (achievedHours / targetHours * 100).toStringAsFixed(0);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.textPrimary.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppRadius.medium),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.timer, color: AppColors.textPrimary, size: 18),
              SizedBox(width: AppSpacing.xs),
              Text(
                '${achievedHours.toStringAsFixed(1)}h / ${targetHours.toStringAsFixed(1)}h',
                style: AppTextStyles.h3,
                textAlign: TextAlign.center,
              ),
            ],
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            'Achieved $percentage%',
            style: AppTextStyles.body2.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// イベント名表示カードを生成
  static Widget buildEventNameCard({
    required String eventName,
    double fontSize = 32,
    Widget? additionalContent,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.textPrimary.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppRadius.medium),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            eventName,
            style: AppTextStyles.h2.copyWith(fontSize: fontSize),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (additionalContent != null) ...[
            SizedBox(height: AppSpacing.sm),
            additionalContent,
          ],
        ],
      ),
    );
  }

  /// 詳細情報行を生成
  static Widget buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.body1.copyWith(
              color: AppColors.textPrimary.withValues(alpha: 0.7),
            ),
          ),
          Text(
            value,
            style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  /// チップ（タグ）を生成
  static Widget buildChip({
    required String label,
    Color? backgroundColor,
    Color? textColor,
  }) {
    return AppChip(
      label: label,
      backgroundColor: backgroundColor ?? AppColors.textPrimary.withValues(alpha: 0.2),
      textColor: textColor ?? AppColors.textPrimary,
    );
  }
}

