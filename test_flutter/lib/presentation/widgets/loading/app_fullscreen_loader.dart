import 'package:flutter/material.dart';
import 'package:test_flutter/core/theme.dart';

/// アプリ全体で使い回す全画面ローディングビュー
class AppFullScreenLoader extends StatefulWidget {
  const AppFullScreenLoader({
    super.key,
    this.message,
  });

  /// ローディング中に表示する任意メッセージ
  final String? message;

  @override
  State<AppFullScreenLoader> createState() => _AppFullScreenLoaderState();
}

class _AppFullScreenLoaderState extends State<AppFullScreenLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  );

  late final Animation<double> _scaleAnimation = Tween<double>(
    begin: 0.0,
    end: 1.0,
  ).animate(
    CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ),
  );

  @override
  void initState() {
    super.initState();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.blue,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.blue.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.timer_outlined,
                  size: 64,
                  color: AppColors.white,
                ),
              ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(
              color: AppColors.blue,
              strokeWidth: 3,
            ),
            if (widget.message != null) ...[
              const SizedBox(height: 24),
              Text(
                widget.message!,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

