import 'package:flutter/material.dart';
import 'package:test_flutter/core/theme.dart';
import 'package:test_flutter/core/route.dart';
import 'package:test_flutter/presentation/widgets/input_fields.dart';
import 'package:test_flutter/presentation/widgets/layouts.dart';
import 'package:test_flutter/presentation/widgets/app_bars.dart';
import 'package:test_flutter/presentation/widgets/cards.dart';
import 'package:test_flutter/presentation/widgets/toggles_chips.dart';
import 'package:test_flutter/presentation/widgets/navigation/navigation_helper.dart';

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
    NavigationHelper.push(context, AppRoutes.initialGoal);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: AppColors.black,
      appBar: AppBarWithBack(
        title: 'Setup Profile',
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
    return FormSection(
      title: 'Birthdate',
      backgroundColor: AppColors.black,
      borderColor: AppColors.blue,
      borderWidth: 3.0,
      child: AppDatePicker(
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
    );
  }

  Widget _buildGenderSection() {
    return FormSection(
      title: 'Gender',
      backgroundColor: AppColors.black,
      borderColor: AppColors.green,
      borderWidth: 3.0,
      child: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: _genderOptions.map((gender) {
          final isSelected = _selectedGender == gender;
          return SelectableButton(
            label: gender,
            isSelected: isSelected,
            onTap: () {
              setState(() {
                _selectedGender = isSelected ? null : gender;
              });
            },
            selectedColor: AppColors.blue,
            showCheckmark: true,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPurposeSection() {
    return FormSection(
      title: 'Purpose of Use',
      backgroundColor: AppColors.black,
      borderColor: AppColors.orange,
      borderWidth: 3.0,
      subtitleText: 'Select all that apply',
      child: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: _purposeOptions.map((purpose) {
          final isSelected = _selectedPurposes.contains(purpose);
          return SelectableButton(
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
            selectedColor: AppColors.blue,
            showCheckmark: true,
          );
        }).toList(),
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
}
