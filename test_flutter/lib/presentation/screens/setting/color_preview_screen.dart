import 'package:flutter/material.dart';
import 'package:test_flutter/core/theme.dart';

class ColorPreviewScreen extends StatelessWidget {
  const ColorPreviewScreen({super.key});

  static const List<_ColorInfo> _colors = [
    _ColorInfo('Blue', AppColors.blue),
    _ColorInfo('Purple', AppColors.purple),
    _ColorInfo('Green', AppColors.green),
    _ColorInfo('Yellow', AppColors.yellow),
    _ColorInfo('Orange', AppColors.orange),
    _ColorInfo('Red', AppColors.red),
    _ColorInfo('Black Gray', AppColors.blackgray),
    _ColorInfo('Black', AppColors.black),
    _ColorInfo('White', AppColors.white),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        title: const Text('ダークカラーパレット確認'),
        backgroundColor: AppColors.black,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(AppSpacing.lg),
        itemCount: _colors.length,
        itemBuilder: (context, index) {
          final colorInfo = _colors[index];
          return _ColorPreviewCard(
            base: colorInfo,
            palette: _colors,
          );
        },
      ),
    );
  }
}

class _ColorPreviewCard extends StatelessWidget {
  final _ColorInfo base;
  final List<_ColorInfo> palette;

  const _ColorPreviewCard({
    required this.base,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    final otherColors = palette.where((c) => c != base).toList();
    return Card(
      color: AppColors.blackgray,
      margin: EdgeInsets.only(bottom: AppSpacing.lg),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.large),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              base.name,
              style: AppTextStyles.h2,
            ),
            SizedBox(height: AppSpacing.xs),
            Text(
              _hexString(base.color),
              style: AppTextStyles.body2.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: AppSpacing.md),
            _ColorSurface(color: base.color),
            SizedBox(height: AppSpacing.lg),
            Text(
              '背景 ${base.name} 上でのテキスト',
              style: AppTextStyles.body1,
            ),
            SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: otherColors
                  .map(
                    (color) => _ColorCombinationTile(
                      background: base,
                      foreground: color,
                      mode: _CombinationMode.foreground,
                    ),
                  )
                  .toList(),
            ),
            SizedBox(height: AppSpacing.lg),
            Text(
              '${base.name} をテキストカラーに使う背景',
              style: AppTextStyles.body1,
            ),
            SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: otherColors
                  .map(
                    (color) => _ColorCombinationTile(
                      background: color,
                      foreground: base,
                      mode: _CombinationMode.background,
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _ColorSurface extends StatelessWidget {
  final Color color;

  const _ColorSurface({required this.color});

  @override
  Widget build(BuildContext context) {
    final infoTextColor =
        color.computeLuminance() > 0.5 ? AppColors.black : AppColors.white;
    return Container(
      height: 140,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(
          color: AppColors.white.withValues(alpha: 0.1),
        ),
      ),
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Aa 見出し',
            style: AppTextStyles.h2.copyWith(color: infoTextColor),
          ),
          Text(
            '本文テキスト例 — Body',
            style: AppTextStyles.body1.copyWith(color: infoTextColor),
          ),
          Text(
            'キャプション text',
            style: AppTextStyles.caption.copyWith(color: infoTextColor),
          ),
        ],
      ),
    );
  }
}

enum _CombinationMode { foreground, background }

class _ColorCombinationTile extends StatelessWidget {
  final _ColorInfo background;
  final _ColorInfo foreground;
  final _CombinationMode mode;

  const _ColorCombinationTile({
    required this.background,
    required this.foreground,
    required this.mode,
  });

  @override
  Widget build(BuildContext context) {
    final labelColor = background.color.computeLuminance() > 0.5
        ? AppColors.black
        : AppColors.white;
    return Container(
      width: 150,
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: background.color,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(color: AppColors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Aa',
            style: AppTextStyles.h3.copyWith(color: foreground.color),
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            mode == _CombinationMode.foreground
                ? foreground.name
                : background.name,
            style: AppTextStyles.body2.copyWith(color: labelColor),
          ),
          Text(
            _hexString(foreground.color),
            style: AppTextStyles.caption.copyWith(
              color: labelColor.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

class _ColorInfo {
  final String name;
  final Color color;

  const _ColorInfo(this.name, this.color);

  @override
  bool operator ==(Object other) {
    return other is _ColorInfo && color.value == other.color.value;
  }

  @override
  int get hashCode => color.value.hashCode;
}

String _hexString(Color color) {
  return '#${color.value.toRadixString(16).padLeft(8, '0').toUpperCase()}';
}

