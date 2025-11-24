import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:test_flutter/core/theme.dart';
import 'package:test_flutter/data/services/tutorial_service.dart';

/// チュートリアル画面（オンボーディング）
class TutorialScreen extends StatefulWidget {
  const TutorialScreen({super.key});

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // チュートリアルの各ページのデータ
  final List<TutorialPageData> _pages = [
    TutorialPageData(
      title: 'Focus Trackerへようこそ',
      description: 'AI検出技術を使って、あなたの学習・作業時間を自動的にトラッキングします。',
      icon: Icons.rocket_launch,
      iconColor: AppColors.blue,
    ),
    TutorialPageData(
      title: 'トラッキング機能',
      description: 'カメラで机の上の物体（本、PC、スマホなど）を検出し、自動的に時間を計測します。',
      icon: Icons.camera_alt,
      iconColor: AppColors.purple,
    ),
    TutorialPageData(
      title: '目標設定',
      description: 'Study、PC、Smartphoneごとに目標を設定し、進捗を確認できます。',
      icon: Icons.flag,
      iconColor: AppColors.green,
    ),
    TutorialPageData(
      title: '統計とレポート',
      description: '累計時間や連続日数（Streak）を確認し、あなたの成長を可視化します。',
      icon: Icons.bar_chart,
      iconColor: AppColors.orange,
    ),
    TutorialPageData(
      title: 'フレンド機能',
      description: '友達の投稿を見て、お互いに励まし合いながら目標達成を目指しましょう。',
      icon: Icons.people,
      iconColor: AppColors.yellow,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  Future<void> _completeTutorial() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    await TutorialService.markTutorialAsCompleted(userId: uid);
    
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/');
    }
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeTutorial();
    }
  }

  void _skipTutorial() {
    _completeTutorial();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: SafeArea(
        child: Column(
          children: [
            // スキップボタン
            if (_currentPage < _pages.length - 1)
              Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: Align(
                  alignment: Alignment.topRight,
                  child: TextButton(
                    onPressed: _skipTutorial,
                    child: Text(
                      'スキップ',
                      style: AppTextStyles.body2.copyWith(
                        color: AppColors.gray,
                      ),
                    ),
                  ),
                ),
              ),

            // ページビュー
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _buildPage(_pages[index]);
                },
              ),
            ),

            // ページインジケーター
            _buildPageIndicator(),

            SizedBox(height: AppSpacing.lg),

            // 次へ/開始ボタン
            _buildNavigationButton(),

            SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(TutorialPageData pageData) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // アイコン
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: pageData.iconColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: pageData.iconColor.withValues(alpha: 0.4),
                width: 2,
              ),
            ),
            child: Icon(
              pageData.icon,
              size: 60,
              color: pageData.iconColor,
            ),
          ),

          SizedBox(height: AppSpacing.xl),

          // タイトル
          Text(
            pageData.title,
            style: AppTextStyles.h1.copyWith(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: AppSpacing.md),

          // 説明
          Text(
            pageData.description,
            style: AppTextStyles.body1.copyWith(
              color: AppColors.textSecondary,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _pages.length,
        (index) => _buildIndicatorDot(index == _currentPage),
      ),
    );
  }

  Widget _buildIndicatorDot(bool isActive) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? AppColors.blue : AppColors.gray.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildNavigationButton() {
    final isLastPage = _currentPage == _pages.length - 1;
    
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _nextPage,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.blue,
            foregroundColor: AppColors.white,
            padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.large),
            ),
            elevation: 0,
          ),
          child: Text(
            isLastPage ? '始める' : '次へ',
            style: AppTextStyles.h3.copyWith(
              color: AppColors.white,
            ),
          ),
        ),
      ),
    );
  }
}

/// チュートリアルページのデータモデル
class TutorialPageData {
  final String title;
  final String description;
  final IconData icon;
  final Color iconColor;

  TutorialPageData({
    required this.title,
    required this.description,
    required this.icon,
    required this.iconColor,
  });
}

