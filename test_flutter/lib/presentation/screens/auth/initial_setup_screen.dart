import 'package:flutter/material.dart';
import 'package:test_flutter/core/theme.dart';
import 'package:test_flutter/core/route.dart';
import 'package:test_flutter/presentation/widgets/buttons.dart';
import 'package:test_flutter/presentation/widgets/input_fields.dart';
import 'package:test_flutter/presentation/widgets/layouts.dart';
import 'package:test_flutter/presentation/widgets/app_bars.dart';
import 'package:test_flutter/presentation/widgets/toggles_chips.dart';

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
      appBar: AppBarWithBack(
        title: 'Setup Profile',
        onBack: () => Navigator.pop(context),
      ),
      body: ScrollableContent(
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Birthdate',
          style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.w600),
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
    );
  }

  Widget _buildGenderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gender',
          style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.w600),
        ),
        SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: _genderOptions.map((gender) {
            final isSelected = _selectedGender == gender;
            return AppFilterChip(
              label: gender,
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedGender = selected ? gender : null;
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPurposeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Purpose of Use',
          style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.w600),
        ),
        SizedBox(height: AppSpacing.sm),
        Text('Select all that apply', style: AppTextStyles.caption),
        SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: _purposeOptions.map((purpose) {
            final isSelected = _selectedPurposes.contains(purpose);
            return AppFilterChip(
              label: purpose,
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedPurposes.add(purpose);
                  } else {
                    _selectedPurposes.remove(purpose);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildNextButton() {
    return PrimaryButton(
      text: 'Next',
      onPressed: _handleNext,
      size: ButtonSize.large,
      icon: Icons.arrow_forward,
    );
  }
}
