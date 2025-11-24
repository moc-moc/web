import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:test_flutter/core/theme.dart';
import 'package:test_flutter/feature/auth/auth_controller.dart';
import 'package:test_flutter/presentation/widgets/buttons.dart';
import 'package:test_flutter/presentation/widgets/layouts.dart';

class EmailVerificationScreen extends ConsumerStatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  ConsumerState<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState
    extends ConsumerState<EmailVerificationScreen> {
  bool _isRefreshing = false;
  bool _isResending = false;

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      if (!mounted) return;
      if (next.status == AuthStatus.authenticated &&
          previous?.status != AuthStatus.authenticated) {
        Navigator.of(context).pop(true);
      }
      if (next.status == AuthStatus.signedOut &&
          previous?.status != AuthStatus.signedOut) {
        Navigator.of(context).pop(false);
      }
    });

    final authState = ref.watch(authControllerProvider);
    final email = authState.firebaseUser?.email ?? '';

    return AppScaffold(
      backgroundColor: AppColors.black,
      body: SafeArea(
        child: ScrollableContent(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: ConstrainedContent(
            maxWidth: 420,
            child: SpacedColumn(
              spacing: AppSpacing.lg,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: AppSpacing.xxl),
                Icon(Icons.mark_email_read, size: 80, color: AppColors.blue),
                Text(
                  'メール認証が必要です',
                  style: AppTextStyles.h1.copyWith(fontSize: 28),
                  textAlign: TextAlign.center,
                ),
                Text(
                  '$email に確認メールを送りました。メール内のリンクを開いたら、下の「認証済みを確認」を押してください。',
                  style: AppTextStyles.body1,
                ),
                Container(
                  padding: EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.blackgray,
                    borderRadius: BorderRadius.circular(AppRadius.large),
                  ),
                  child: SpacedColumn(
                    spacing: AppSpacing.sm,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      _ChecklistItem(text: '迷惑メールフォルダも確認する'),
                      _ChecklistItem(text: '受信できない場合は再送信'),
                      _ChecklistItem(text: 'リンクは一定時間で期限切れになります'),
                    ],
                  ),
                ),
                PrimaryButton(
                  text: '認証済みを確認',
                  onPressed: () {
                    if (_isRefreshing) return;
                    _handleRefresh();
                  },
                  size: ButtonSize.large,
                  isLoading: _isRefreshing,
                ),
                SecondaryButton(
                  text: _isResending ? '再送信中...' : '確認メールを再送',
                  onPressed: () {
                    if (_isResending) return;
                    _handleResend();
                  },
                  size: ButtonSize.large,
                ),
                TextButton(
                  onPressed: () async {
                    await ref.read(authControllerProvider.notifier).signOut();
                    if (mounted) Navigator.of(context).pop(false);
                  },
                  child: Text(
                    'ログアウトに戻る',
                    style: AppTextStyles.body2.copyWith(color: AppColors.gray),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleRefresh() async {
    setState(() => _isRefreshing = true);
    try {
      await ref
          .read(authControllerProvider.notifier)
          .refreshEmailVerification();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('認証状態の更新に失敗しました: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isRefreshing = false);
      }
    }
  }

  Future<void> _handleResend() async {
    setState(() => _isResending = true);
    await ref.read(authControllerProvider.notifier).resendVerificationEmail();
    if (mounted) {
      setState(() => _isResending = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('確認メールを再送しました')),
      );
    }
  }
}

class _ChecklistItem extends StatelessWidget {
  const _ChecklistItem({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.check_circle, color: AppColors.blue, size: 20),
        SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }
}

