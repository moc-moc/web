import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:test_flutter/core/theme.dart';
import 'package:test_flutter/presentation/widgets/buttons.dart';
import 'package:test_flutter/presentation/widgets/cards.dart';
import 'package:test_flutter/feature/goals/goal_data_manager.dart';
import 'package:test_flutter/feature/goals/goal_functions.dart';

class SettingGoal extends ConsumerStatefulWidget {
  const SettingGoal({super.key});

  @override
  ConsumerState<SettingGoal> createState() => _SettingGoalState();
}

class _SettingGoalState extends ConsumerState<SettingGoal> {
  final TextEditingController _tagController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _targetTimeController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  
  DateTime? _selectedDate;
  ComparisonType _comparisonType = ComparisonType.above;
  DetectionItem _detectionItem = DetectionItem.book;

  @override
  void dispose() {
    _tagController.dispose();
    _titleController.dispose();
    _targetTimeController.dispose();
    _durationController.dispose();
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
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _addGoal() async {
    // バリデーション
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('タイトルを入力してください')),
      );
      return;
    }

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('開始日を選択してください')),
      );
      return;
    }

    final targetTime = int.tryParse(_targetTimeController.text);
    if (targetTime == null || targetTime <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('目標時間を正しく入力してください')),
      );
      return;
    }

    final duration = int.tryParse(_durationController.text);
    if (duration == null || duration <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('期間を正しく入力してください')),
      );
      return;
    }

    // 新しい目標を作成
    final goal = Goal(
      id: const Uuid().v4(),
      tag: _tagController.text.trim(),
      title: _titleController.text.trim(),
      targetTime: targetTime,
      comparisonType: _comparisonType,
      detectionItem: _detectionItem,
      startDate: _selectedDate!,
      durationDays: duration,
      consecutiveAchievements: 0,
      achievedTime: null,
      isDeleted: false,
      lastModified: DateTime.now(),
    );

    // 目標を追加
    final success = await addGoalHelper(
      context: context,
      ref: ref,
      goal: goal,
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
        title: const Text('目標設定'),
        backgroundColor: AppColors.blackgray,
        foregroundColor: AppColors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // タグ入力
            CustomCard(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _tagController,
                  style: const TextStyle(color: AppColors.white),
                  decoration: const InputDecoration(
                    labelText: 'タグ',
                    labelStyle: TextStyle(color: AppColors.white),
                    hintText: '例: 勉強、運動',
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
                    hintText: '目標のタイトルを入力',
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
            
            // 目標時間入力
            CustomCard(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _targetTimeController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: AppColors.white),
                  decoration: const InputDecoration(
                    labelText: '目標時間（分）',
                    labelStyle: TextStyle(color: AppColors.white),
                    hintText: '例: 60',
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
            
            // 以上/以下選択
            CustomCard(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: DropdownButtonFormField<ComparisonType>(
                  initialValue: _comparisonType,
                  dropdownColor: AppColors.blackgray,
                  style: const TextStyle(color: AppColors.white, fontSize: 16),
                  decoration: const InputDecoration(
                    labelText: '判定方法',
                    labelStyle: TextStyle(color: AppColors.white),
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.gray),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.blue),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: ComparisonType.above,
                      child: Text('以上'),
                    ),
                    DropdownMenuItem(
                      value: ComparisonType.below,
                      child: Text('以下'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _comparisonType = value;
                      });
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // 検出項目選択
            CustomCard(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: DropdownButtonFormField<DetectionItem>(
                  initialValue: _detectionItem,
                  dropdownColor: AppColors.blackgray,
                  style: const TextStyle(color: AppColors.white, fontSize: 16),
                  decoration: const InputDecoration(
                    labelText: '検出項目',
                    labelStyle: TextStyle(color: AppColors.white),
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.gray),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.blue),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: DetectionItem.book,
                      child: Text('本'),
                    ),
                    DropdownMenuItem(
                      value: DetectionItem.smartphone,
                      child: Text('スマホ'),
                    ),
                    DropdownMenuItem(
                      value: DetectionItem.pc,
                      child: Text('パソコン'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _detectionItem = value;
                      });
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // 開始日選択
            CustomCard(
              child: InkWell(
                onTap: _selectDate,
                borderRadius: BorderRadius.circular(16.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        color: AppColors.blue,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _selectedDate != null
                            ? '${_selectedDate!.year}年${_selectedDate!.month}月${_selectedDate!.day}日'
                            : '開始日を選択してください',
                        style: TextStyle(
                          color: _selectedDate != null ? AppColors.white : AppColors.gray,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // 期間入力
            CustomCard(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _durationController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: AppColors.white),
                  decoration: const InputDecoration(
                    labelText: '期間（日）',
                    labelStyle: TextStyle(color: AppColors.white),
                    hintText: '例: 30',
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
            const SizedBox(height: 32),
            
            // 保存ボタン
            CustomSnsButton(
              text: '目標を設定',
              onPressed: _addGoal,
              color: AppColors.blue,
            ),
          ],
        ),
      ),
    );
  }
}

