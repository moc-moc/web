import 'package:flutter/material.dart';
import 'package:test_flutter/core/theme.dart';
import 'package:test_flutter/core/route.dart';
import 'package:test_flutter/presentation/widgets/buttons.dart';

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
            padding: EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: SingleChildScrollView(child: content)),

                SizedBox(height: AppSpacing.xl),

                // SNSシェアボタン
                if (showShareButton) ...[
                  OutlineButton(
                    text: 'Share',
                    icon: Icons.share,
                    size: ButtonSize.large,
                    borderColor: AppColors.textPrimary.withValues(alpha: 0.5),
                    onPressed: () {
                      // 将来実装: SNS共有機能
                    },
                  ),
                  SizedBox(height: AppSpacing.md),
                ],

                // OKボタン
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.textPrimary,
                    borderRadius: BorderRadius.circular(AppRadius.medium),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap:
                          onOkPressed ??
                          () {
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              AppRoutes.home,
                              (route) => false,
                            );
                          },
                      borderRadius: BorderRadius.circular(AppRadius.medium),
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
