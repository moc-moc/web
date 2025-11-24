import 'package:flutter/material.dart';
import 'package:test_flutter/core/theme.dart';
import 'package:test_flutter/core/route.dart';
import 'package:test_flutter/presentation/widgets/navigation/navigation_helper.dart';

/// イベント画面の共通ベース
class EventScreenBase extends StatelessWidget {
  final List<Color> gradientColors;
  final Widget content;
  final String? okButtonText;
  final VoidCallback? onOkPressed;
  final bool showShareButton;

  const EventScreenBase({
    super.key,
    required this.gradientColors,
    required this.content,
    this.okButtonText,
    this.onOkPressed,
    this.showShareButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final availableWidth = constraints.maxWidth.isFinite
                          ? constraints.maxWidth
                          : 520.0;
                      final maxContentWidth = availableWidth > 520
                          ? 520.0
                          : availableWidth;
                      return Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.center,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: maxContentWidth,
                            ),
                            child: content,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                SizedBox(height: AppSpacing.sm),

                // SNSシェアボタン
                if (showShareButton) ...[
                  Row(
                    children: [
                      Expanded(
                        child: _ShareButton(
                          icon: Icons.share,
                          label: 'Share',
                          textColor: Colors.white,
                          iconColor: Colors.white,
                          onTap: () {
                            // 将来実装: SNS共有機能
                          },
                        ),
                      ),
                      SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: _ShareButton(
                          icon: Icons.group,
                          label: 'Friend Share',
                          textColor: Colors.white,
                          iconColor: Colors.white,
                          onTap: () {
                            NavigationHelper.push(context, AppRoutes.friend);
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.md),
                ],

                // OKボタン
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.textPrimary,
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap:
                          onOkPressed ??
                          () {
                            NavigationHelper.pushAndRemoveUntil(
                              context,
                              AppRoutes.home,
                            );
                          },
                      borderRadius: BorderRadius.circular(30.0),
                      child: SizedBox(
                        height: 56,
                        child: Center(
                          child: Text(
                            okButtonText ?? 'OK',
                            style: AppTextStyles.h3.copyWith(
                              color: gradientColors[0],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
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

class _ShareButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color textColor;
  final Color iconColor;
  final VoidCallback onTap;

  const _ShareButton({
    required this.icon,
    required this.label,
    required this.textColor,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: textColor.withValues(alpha: 0.5), width: 2),
        borderRadius: BorderRadius.circular(30.0),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(30.0),
          child: SizedBox(
            height: 56,
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: iconColor, size: 18),
                  SizedBox(width: AppSpacing.sm),
                  Text(
                    label,
                    style: AppTextStyles.h3.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
