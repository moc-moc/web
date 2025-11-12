import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:test_flutter/core/theme.dart';
import 'package:test_flutter/presentation/widgets/buttons.dart';
import 'package:test_flutter/presentation/widgets/cards.dart';
import 'package:test_flutter/feature/countdown/countdown_functions.dart';

class GoalSetGoal extends ConsumerStatefulWidget {
  const GoalSetGoal({super.key});

  @override
  ConsumerState<GoalSetGoal> createState() => _GoalSetGoalState();
}

class _GoalSetGoalState extends ConsumerState<GoalSetGoal> {
  final TextEditingController _titleController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay _selectedTime = const TimeOfDay(hour: 23, minute: 59);

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.blue,
              onPrimary: AppColors.white,
              surface: AppColors.blackgray,
              onSurface: AppColors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.blue,
              onPrimary: AppColors.white,
              surface: AppColors.blackgray,
              onSurface: AppColors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _addCountdown() async {
    // 日時チェック
    if (_selectedDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('日付を選択してください')));
      return;
    }

    // 日付と時間を組み合わせてDateTimeを作成
    final targetDate = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    // ヘルパー関数で追加処理（FuncUs層の関数を使用）
    final success = await addCountdownHelper(
      context: context,
      ref: ref,
      title: _titleController.text,
      targetDate: targetDate,
      mounted: mounted,
    );

    // 成功したら前の画面に戻る
    if (success && mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        title: const Text('カウントダウン追加'),
        backgroundColor: AppColors.blackgray,
        foregroundColor: AppColors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // タイトル入力
            CustomCard(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _titleController,
                  style: const TextStyle(color: AppColors.white),
                  decoration: const InputDecoration(
                    labelText: 'タイトル',
                    labelStyle: TextStyle(color: AppColors.white),
                    hintText: 'カウントダウンのタイトルを入力',
                    hintStyle: TextStyle(color: AppColors.gray),
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.gray),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.blue),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // 日付選択
            CustomCard(
              child: InkWell(
                onTap: _selectDate,
                borderRadius: BorderRadius.circular(16.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, color: AppColors.blue),
                      const SizedBox(width: 12),
                      Text(
                        _selectedDate != null
                            ? '${_selectedDate!.year}年${_selectedDate!.month}月${_selectedDate!.day}日'
                            : '日付を選択してください',
                        style: TextStyle(
                          color: _selectedDate != null
                              ? AppColors.white
                              : AppColors.gray,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // 時間選択
            CustomCard(
              child: InkWell(
                onTap: _selectTime,
                borderRadius: BorderRadius.circular(16.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time, color: AppColors.blue),
                      const SizedBox(width: 12),
                      Text(
                        '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            // 追加ボタン
            CustomSnsButton(
              text: '追加',
              onPressed: _addCountdown,
              color: AppColors.blue,
            ),
          ],
        ),
      ),
    );
  }
}
