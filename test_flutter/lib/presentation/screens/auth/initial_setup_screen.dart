import 'package:flutter/material.dart';
import 'package:test_flutter/core/theme.dart';
import 'package:test_flutter/core/route.dart';
import 'package:test_flutter/presentation/widgets/input_fields.dart';
import 'package:test_flutter/presentation/widgets/layouts.dart';
import 'package:test_flutter/presentation/widgets/app_bars.dart';

/// 初期設定画面
class InitialSetupScreen extends StatefulWidget {
  const InitialSetupScreen({super.key});

  @override
  State<InitialSetupScreen> createState() => _InitialSetupScreenState();
}

class _InitialSetupScreenState extends State<InitialSetupScreen> {
  DateTime? _selectedDate;
  String? _selectedGender;
  final Set<String> _selectedPurposes = {};

  final List<String> _genderOptions = [
    'Male',
    'Female',
    'Other',
    'Prefer not to say',
  ];
  final List<String> _purposeOptions = [
    'Study',
    'Qualification',
    'Work',
    'Time Management',
    'Hobby',
    'Other',
  ];

  void _handleNext() {
    // ダミー: 次の画面へ遷移
    Navigator.pushNamed(context, AppRoutes.initialGoal);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: AppColors.black,
      appBar: AppBarWithBack(
        title: 'Setup Profile',
        onBack: () => Navigator.pop(context),
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
                _buildBirthdateSection(),
                SizedBox(height: AppSpacing.xl),
                _buildGenderSection(),
                SizedBox(height: AppSpacing.xl),
                _buildPurposeSection(),
                SizedBox(height: AppSpacing.xxl),
                _buildNextButton(),
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
        Text('Tell us about yourself', style: AppTextStyles.h2),
        SizedBox(height: AppSpacing.sm),
        Text(
          'This helps us personalize your experience',
          style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildBirthdateSection() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(
          color: AppColors.blue,
          width: 3.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Birthdate',
            style: AppTextStyles.body1.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.white,
            ),
          ),
          SizedBox(height: AppSpacing.md),
          AppDatePicker(
            placeholder: 'Select your birthdate',
            selectedDate: _selectedDate,
            onDateSelected: (date) {
              setState(() {
                _selectedDate = date;
              });
            },
            firstDate: DateTime(1900),
            lastDate: DateTime.now(),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderSection() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(
          color: AppColors.green,
          width: 3.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gender',
            style: AppTextStyles.body1.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.white,
            ),
          ),
          SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: _genderOptions.map((gender) {
              final isSelected = _selectedGender == gender;
              return _buildCustomChip(
                label: gender,
                isSelected: isSelected,
                onTap: () {
                  setState(() {
                    _selectedGender = isSelected ? null : gender;
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPurposeSection() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(
          color: AppColors.orange,
          width: 3.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Purpose of Use',
            style: AppTextStyles.body1.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.white,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            'Select all that apply',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: _purposeOptions.map((purpose) {
              final isSelected = _selectedPurposes.contains(purpose);
              return _buildCustomChip(
                label: purpose,
                isSelected: isSelected,
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedPurposes.remove(purpose);
                    } else {
                      _selectedPurposes.add(purpose);
                    }
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildNextButton() {
    return Container(
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
          onTap: _handleNext,
          borderRadius: BorderRadius.circular(AppRadius.large),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Next',
                  style: AppTextStyles.body1.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0,
                  ),
                ),
                SizedBox(width: AppSpacing.sm),
                Icon(
                  Icons.arrow_forward,
                  color: AppColors.white,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.blue.withValues(alpha: 0.15)
                : AppColors.black,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isSelected
                  ? AppColors.blue
                  : AppColors.gray.withValues(alpha: 0.35),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: AppTextStyles.body2.copyWith(
                  color: isSelected
                      ? AppColors.blue
                      : AppColors.textSecondary,
                  fontWeight: isSelected
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
              if (isSelected) ...[
                SizedBox(width: AppSpacing.xs),
                Icon(
                  Icons.check,
                  size: 16,
                  color: AppColors.blue,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
