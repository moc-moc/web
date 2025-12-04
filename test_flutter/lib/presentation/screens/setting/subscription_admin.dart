import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:test_flutter/core/theme.dart';
import 'package:test_flutter/presentation/widgets/app_bars.dart';
import 'package:test_flutter/presentation/widgets/layouts.dart';
import 'package:test_flutter/data/models/subscription_status.dart';
import 'package:test_flutter/feature/auth/auth_controller.dart';

class SubscriptionAdminScreen extends ConsumerStatefulWidget {
  const SubscriptionAdminScreen({super.key});

  @override
  ConsumerState<SubscriptionAdminScreen> createState() =>
      _SubscriptionAdminScreenState();
}

class _SubscriptionAdminScreenState
    extends ConsumerState<SubscriptionAdminScreen> {
  final TextEditingController _uidController = TextEditingController();
  SubscriptionPlanType _selectedPlanType = SubscriptionPlanType.free;
  DateTime? _trialStartAt;
  DateTime? _trialEndAt;
  DateTime? _nextBillingAt;
  bool _isLifetime = false;
  String? _promoLabel;
  bool _loading = false;
  String? _statusMessage;

  @override
  void dispose() {
    _uidController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isAdmin = authState.profile?.isAdmin ?? false;
    final currentUid = authState.firebaseUser?.uid ?? '';
    if (_uidController.text.isEmpty && currentUid.isNotEmpty) {
      _uidController.text = currentUid;
    }

    return AppScaffold(
      appBar: AppBarWithBack(title: 'Subscription Admin'),
      body: SafeArea(
        child: ScrollableContent(
          padding: EdgeInsets.all(AppSpacing.md),
          child: isAdmin
              ? _buildForm(context)
              : _buildNoAccessMessage(),
        ),
      ),
    );
  }

  Widget _buildNoAccessMessage() {
    return Center(
      child: Container(
        padding: EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.blackgray,
          borderRadius: BorderRadius.circular(AppRadius.large),
          border: Border.all(color: AppColors.gray.withValues(alpha: 0.3)),
        ),
        child: Text(
          '管理者専用の画面です。',
          style: AppTextStyles.body1.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _uidController,
          decoration: const InputDecoration(
            labelText: 'User UID',
            hintText: '対象ユーザーのUIDを入力',
          ),
        ),
        SizedBox(height: AppSpacing.md),
        _buildPlanSelector(),
        SizedBox(height: AppSpacing.md),
        SwitchListTile(
          value: _isLifetime,
          title: const Text('Lifetime purchase'),
          subtitle: const Text('買い切りフラグ'),
          activeThumbColor: AppColors.blue,
          onChanged: (value) {
            setState(() => _isLifetime = value);
          },
        ),
        SizedBox(height: AppSpacing.md),
        _buildDateField(
          context,
          label: 'Trial Start',
          date: _trialStartAt,
          onPick: () => _pickDate(context, (date) {
            setState(() => _trialStartAt = date);
          }),
          onClear: () => setState(() => _trialStartAt = null),
        ),
        SizedBox(height: AppSpacing.sm),
        _buildDateField(
          context,
          label: 'Trial End',
          date: _trialEndAt,
          onPick: () => _pickDate(context, (date) {
            setState(() => _trialEndAt = date);
          }),
          onClear: () => setState(() => _trialEndAt = null),
        ),
        SizedBox(height: AppSpacing.sm),
        _buildDateField(
          context,
          label: 'Next Billing',
          date: _nextBillingAt,
          onPick: () => _pickDate(context, (date) {
            setState(() => _nextBillingAt = date);
          }),
          onClear: () => setState(() => _nextBillingAt = null),
        ),
        SizedBox(height: AppSpacing.md),
        TextField(
          decoration: const InputDecoration(
            labelText: 'Promo Label',
            hintText: '任意（例: 初月980円）',
          ),
          onChanged: (value) {
            setState(() => _promoLabel = value.isEmpty ? null : value);
          },
        ),
        SizedBox(height: AppSpacing.lg),
        if (_statusMessage != null)
          Padding(
            padding: EdgeInsets.only(bottom: AppSpacing.sm),
            child: Text(
              _statusMessage!,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        _buildActionButtons(context),
      ],
    );
  }

  Widget _buildPlanSelector() {
    return InputDecorator(
      decoration: const InputDecoration(
        labelText: 'Plan Type',
        border: OutlineInputBorder(),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<SubscriptionPlanType>(
          value: _selectedPlanType,
          items: SubscriptionPlanType.values
              .map(
                (type) => DropdownMenuItem(
                  value: type,
                  child: Text(type.name),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() => _selectedPlanType = value);
            }
          },
        ),
      ),
    );
  }

  Widget _buildDateField(
    BuildContext context, {
    required String label,
    required DateTime? date,
    required VoidCallback onPick,
    required VoidCallback onClear,
  }) {
    final display = date != null
        ? '${date.year}/${date.month}/${date.day}'
        : '--';
    return Row(
      children: [
        Expanded(
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(label),
            subtitle: Text(display),
            trailing: IconButton(
              icon: const Icon(Icons.date_range),
              color: AppColors.blue,
              onPressed: onPick,
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.clear),
          color: AppColors.textSecondary,
          onPressed: date == null ? null : onClear,
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _loading ? null : _loadUser,
            child: _loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('ユーザー読み込み'),
          ),
        ),
        SizedBox(width: AppSpacing.md),
        Expanded(
          child: ElevatedButton(
            onPressed: _loading ? null : _saveChanges,
            child: const Text('保存'),
          ),
        ),
      ],
    );
  }

  Future<void> _pickDate(
    BuildContext context,
    ValueChanged<DateTime> onSelected,
  ) async {
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );
    if (selected != null) {
      onSelected(DateTime(selected.year, selected.month, selected.day));
    }
  }

  Future<void> _loadUser() async {
    final uid = _uidController.text.trim();
    if (uid.isEmpty) {
      setState(() {
        _statusMessage = 'UIDを入力してください';
      });
      return;
    }
    setState(() {
      _loading = true;
      _statusMessage = null;
    });
    try {
      final repository = ref.read(userRepositoryProvider);
      final user = await repository.fetchUser(uid);
      if (!mounted) return;
      if (user == null) {
        setState(() {
          _loading = false;
          _statusMessage = 'ユーザーが見つかりません';
        });
        return;
      }
      final status = user.subscription;
      setState(() {
        _selectedPlanType = status.planType;
        _trialStartAt = status.trialStartAt;
        _trialEndAt = status.trialEndAt;
        _nextBillingAt = status.nextBillingAt;
        _isLifetime = status.isLifetime;
        _promoLabel = status.promoLabel;
        _loading = false;
        _statusMessage = '最新の状態を読み込みました';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _statusMessage = '読み込みエラー: $e';
      });
    }
  }

  Future<void> _saveChanges() async {
    final uid = _uidController.text.trim();
    if (uid.isEmpty) {
      setState(() {
        _statusMessage = 'UIDを入力してください';
      });
      return;
    }
    setState(() {
      _loading = true;
      _statusMessage = null;
    });
    final repository = ref.read(userRepositoryProvider);
    final status = SubscriptionStatus(
      planType: _selectedPlanType,
      trialStartAt: _trialStartAt,
      trialEndAt: _trialEndAt,
      nextBillingAt: _nextBillingAt,
      isLifetime: _isLifetime,
      promoLabel: _promoLabel,
    );
    try {
      await repository.updateSubscriptionStatus(uid, status);
      if (!mounted) return;
      setState(() {
        _loading = false;
        _statusMessage = '保存しました';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _statusMessage = '保存エラー: $e';
      });
    }
  }
}

