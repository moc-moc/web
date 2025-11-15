import 'package:flutter/material.dart';
import 'package:test_flutter/core/theme.dart';
import 'package:test_flutter/presentation/widgets/layouts.dart';
import 'package:test_flutter/presentation/widgets/app_bars.dart';

/// お問い合わせ画面（新デザインシステム版）
class ContactUsScreenNew extends StatefulWidget {
  const ContactUsScreenNew({super.key});

  @override
  State<ContactUsScreenNew> createState() => _ContactUsScreenNewState();
}

class _ContactUsScreenNewState extends State<ContactUsScreenNew> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      // ダミー: フォーム送信処理
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Thank you for your message. We will get back to you soon.'),
          backgroundColor: AppColors.blue,
        ),
      );
      // フォームをクリア
      _nameController.clear();
      _emailController.clear();
      _subjectController.clear();
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: AppColors.black,
      appBar: AppBarWithBack(title: 'Contact Us'),
      body: SafeArea(
        child: ScrollableContent(
          padding: EdgeInsets.all(AppSpacing.md),
          child: SpacedColumn(
            spacing: AppSpacing.lg,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ヘッダーセクション
              _buildHeaderSection(),

              // お問い合わせフォーム
              _buildContactForm(),

              SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(color: AppColors.blue.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: AppColors.blue.withValues(alpha: 0.25),
            blurRadius: 18,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.support_agent,
            size: 64,
            color: AppColors.blue,
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            'We\'re Here to Help',
            style: AppTextStyles.h2.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            'Have a question or need assistance? Send us a message and we\'ll get back to you as soon as possible.',
            style: AppTextStyles.body2.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildContactForm() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(color: AppColors.gray.withValues(alpha: 0.3)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Send us a Message',
              style: AppTextStyles.h3.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: AppSpacing.md),

            // 名前フィールド
            _buildTextField(
              controller: _nameController,
              label: 'Name',
              icon: Icons.person,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
            ),

            SizedBox(height: AppSpacing.md),

            // メールフィールド
            _buildTextField(
              controller: _emailController,
              label: 'Email',
              icon: Icons.email,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                if (!value.contains('@')) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),

            SizedBox(height: AppSpacing.md),

            // 件名フィールド
            _buildTextField(
              controller: _subjectController,
              label: 'Subject',
              icon: Icons.subject,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a subject';
                }
                return null;
              },
            ),

            SizedBox(height: AppSpacing.md),

            // メッセージフィールド
            _buildTextField(
              controller: _messageController,
              label: 'Message',
              icon: Icons.message,
              maxLines: 6,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your message';
                }
                if (value.length < 10) {
                  return 'Message must be at least 10 characters';
                }
                return null;
              },
            ),

            SizedBox(height: AppSpacing.lg),

            // 送信ボタン
            Container(
              decoration: BoxDecoration(
                color: AppColors.blue,
                borderRadius: BorderRadius.circular(AppRadius.large),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _handleSubmit,
                  borderRadius: BorderRadius.circular(AppRadius.large),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                      vertical: AppSpacing.md,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.send, color: AppColors.white, size: 20),
                        SizedBox(width: AppSpacing.sm),
                        Text(
                          'Send Message',
                          style: AppTextStyles.body1.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(color: AppColors.gray.withValues(alpha: 0.35)),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
        style: AppTextStyles.body1,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: AppTextStyles.body2.copyWith(
            color: AppColors.textSecondary,
          ),
          prefixIcon: Icon(icon, color: AppColors.blue),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(AppSpacing.md),
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
        ),
        cursorColor: AppColors.blue,
      ),
    );
  }

}

