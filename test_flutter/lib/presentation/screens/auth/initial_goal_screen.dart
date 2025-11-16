import 'package:flutter/material.dart';
import 'package:test_flutter/core/theme.dart';
import 'package:test_flutter/core/route.dart';
import 'package:test_flutter/presentation/widgets/buttons.dart';
import 'package:test_flutter/presentation/widgets/layouts.dart';
import 'package:test_flutter/presentation/widgets/app_bars.dart';
import 'package:test_flutter/presentation/widgets/navigation/navigation_helper.dart';
import 'package:test_flutter/presentation/screens/auth/initial_goal_form.dart';

/// 初期目標設定画面
class InitialGoalScreen extends StatefulWidget {
  const InitialGoalScreen({super.key});

  @override
  State<InitialGoalScreen> createState() => _InitialGoalScreenState();
}

class _InitialGoalScreenState extends State<InitialGoalScreen> {
  String _selectedCategory = 'study';
  String _selectedPeriod = 'weekly';
  String? _selectedComparison; // 'above' or 'below'
  final _titleController = TextEditingController();
  final _targetHoursController = TextEditingController(text: '10');


  @override
  void dispose() {
    _titleController.dispose();
    _targetHoursController.dispose();
    super.dispose();
  }

  void _handleGetStarted() {
    // ダミー: ホーム画面へ遷移
    NavigationHelper.pushAndRemoveUntil(context, AppRoutes.home);
  }

  void _handleSkip() {
    // ダミー: 目標設定をスキップしてホーム画面へ
    NavigationHelper.pushAndRemoveUntil(context, AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: AppColors.black,
      appBar: AppBarWithBack(
        title: 'Set Your Goals',
        onBack: () => NavigationHelper.pop(context),
      ),
      body: SafeArea(
        child: ScrollableContent(
          padding: EdgeInsets.all(AppSpacing.md),
          child: ConstrainedContent(
            maxWidth: 600,
            child: SpacedColumn(
              spacing: AppSpacing.xl,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(),
                SizedBox(height: AppSpacing.lg),
                InitialGoalForm(
                  selectedCategory: _selectedCategory,
                  selectedPeriod: _selectedPeriod,
                  selectedComparison: _selectedComparison,
                  titleController: _titleController,
                  targetHoursController: _targetHoursController,
                  onCategoryChanged: (key) {
                    setState(() {
                      _selectedCategory = key;
                    });
                  },
                  onPeriodChanged: (key) {
                    setState(() {
                      _selectedPeriod = key;
                    });
                  },
                  onComparisonChanged: (value) {
                    setState(() {
                      _selectedComparison = value;
                    });
                  },
                ),
                SizedBox(height: AppSpacing.xxl),
                _buildButtons(),
                SizedBox(height: AppSpacing.md),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Set Your First Goal!', style: AppTextStyles.h2),
        SizedBox(height: AppSpacing.sm),
        Text(
          'Goals help you stay motivated and track your progress',
          style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }



  Widget _buildButtons() {
    return SpacedColumn(
      spacing: AppSpacing.md,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: 56.0,
          decoration: BoxDecoration(
            color: AppColors.blue.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(AppRadius.large),
            border: Border.all(
              color: AppColors.blue,
              width: 1.5,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _handleGetStarted,
              borderRadius: BorderRadius.circular(AppRadius.large),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check,
                      color: AppColors.white,
                      size: 20,
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Text(
                      'Get Started',
                      style: AppTextStyles.body1.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        AppTextButton(
          text: 'Skip for now',
          onPressed: _handleSkip,
          size: ButtonSize.large,
          textColor: AppColors.textSecondary,
        ),
      ],
    );
  }
}
