import 'package:flutter/material.dart';
import 'package:test_flutter/core/theme.dart';
import 'package:test_flutter/core/route.dart';
import 'package:test_flutter/presentation/widgets/buttons.dart';
import 'package:test_flutter/presentation/widgets/cards.dart';
import 'package:test_flutter/feature/tracking/tracking_functions.dart';

/// Tracking画面
/// トラッキング実行中の画面
class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  // 5つのカテゴリ用のコントローラー
  late TextEditingController _computerController;
  late TextEditingController _bookController;
  late TextEditingController _totalController;
  late TextEditingController _personController;
  late TextEditingController _smartphoneController;

  @override
  void initState() {
    super.initState();
    // コントローラーを初期化
    _computerController = TextEditingController();
    _bookController = TextEditingController();
    _totalController = TextEditingController();
    _personController = TextEditingController();
    _smartphoneController = TextEditingController();
  }

  @override
  void dispose() {
    // コントローラーを破棄
    _computerController.dispose();
    _bookController.dispose();
    _totalController.dispose();
    _personController.dispose();
    _smartphoneController.dispose();
    super.dispose();
  }

  // 入力された値を取得するヘルパーメソッド
  int get computerMinutes => parseTimeInput(_computerController.text);
  int get bookMinutes => parseTimeInput(_bookController.text);
  int get totalMinutes => parseTimeInput(_totalController.text);
  int get personMinutes => parseTimeInput(_personController.text);
  int get smartphoneMinutes => parseTimeInput(_smartphoneController.text);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text('Tracking'),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.blackgray,
        automaticallyImplyLeading: false, // 戻るボタンを無効化
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    '活動時間を入力',
                    style: TextStyle(
                      color: AppColors.blackgray,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // パソコン
                  TimeInputCard(
                    label: 'パソコン',
                    icon: Icons.computer,
                    iconColor: AppColors.blue,
                    controller: _computerController,
                  ),
                  const SizedBox(height: 12),

                  // 本
                  TimeInputCard(
                    label: '本',
                    icon: Icons.book,
                    iconColor: AppColors.green,
                    controller: _bookController,
                  ),
                  const SizedBox(height: 12),

                  // 総合計
                  TimeInputCard(
                    label: '総合計',
                    icon: Icons.timer,
                    iconColor: AppColors.red,
                    controller: _totalController,
                  ),
                  const SizedBox(height: 12),

                  // 人
                  TimeInputCard(
                    label: '人',
                    icon: Icons.people,
                    iconColor: const Color(0xFF9C27B0), // 紫
                    controller: _personController,
                  ),
                  const SizedBox(height: 12),

                  // スマホ
                  TimeInputCard(
                    label: 'スマホ',
                    icon: Icons.smartphone,
                    iconColor: const Color(0xFFFF9800), // オレンジ
                    controller: _smartphoneController,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Finishedボタン
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: CustomSnsButton(
              text: 'Finished',
              color: AppColors.red,
              onPressed: () {
                // 入力された時間データを取得
                final timeData = {
                  'computer': computerMinutes,
                  'book': bookMinutes,
                  'total': totalMinutes,
                  'person': personMinutes,
                  'smartphone': smartphoneMinutes,
                };

                // データを渡してtracking finished画面へ遷移
                Navigator.pushReplacementNamed(
                  context,
                  AppRoutes.trackingfinished,
                  arguments: timeData,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
