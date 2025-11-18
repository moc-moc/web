import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:test_flutter/core/route.dart';
import 'package:test_flutter/core/theme.dart';
import 'package:test_flutter/presentation/widgets/app_bars.dart';
import 'package:test_flutter/presentation/widgets/buttons.dart';
import 'package:test_flutter/presentation/widgets/cards.dart';
import 'package:test_flutter/presentation/widgets/charts.dart';
import 'package:test_flutter/presentation/widgets/dialogs.dart';
import 'package:test_flutter/presentation/widgets/input_fields.dart';
import 'package:test_flutter/presentation/widgets/layouts.dart';
import 'package:test_flutter/presentation/widgets/navigation.dart';
import 'package:test_flutter/presentation/widgets/progress_bars.dart';
import 'package:test_flutter/presentation/widgets/settings_widgets.dart';
import 'package:test_flutter/presentation/widgets/stats_display.dart';
import 'package:test_flutter/presentation/widgets/tab_bars.dart';
import 'package:test_flutter/presentation/widgets/toggles_chips.dart';

class WidgetCatalogScreen extends StatefulWidget {
  const WidgetCatalogScreen({super.key});

  @override
  State<WidgetCatalogScreen> createState() => _WidgetCatalogScreenState();
}

class _WidgetCatalogScreenState extends State<WidgetCatalogScreen> {
  final TextEditingController _textController =
      TextEditingController(text: 'サンプルテキスト');
  final TextEditingController _timeInputController =
      TextEditingController(text: '90');

  bool _toggleValue = true;
  bool _filterSelected = true;
  DateTime? _selectedDate = DateTime.now();
  TimeOfDay? _selectedTime = const TimeOfDay(hour: 8, minute: 30);
  String _selectedSegment = 'ライト';
  String _selectedColorName = 'blue';
  String _settingsText = '通知メッセージ';
  bool _settingsSwitch = true;
  String _settingsTime = '08:30';
  int _tabSelectedIndex = 0;
  int _periodSelectedIndex = 1;
  int _navigationIndex = 0;

  late final List<_CatalogTab> _tabs = [
    _CatalogTab('ボタン', _buildButtonsTab),
    _CatalogTab('入力', _buildInputTab),
    _CatalogTab('トグル&チップ', _buildToggleTab),
    _CatalogTab('プログレス', _buildProgressTab),
    _CatalogTab('カード', _buildCardsTab),
    _CatalogTab('統計表示', _buildStatsTab),
    _CatalogTab('レイアウト', _buildLayoutsTab),
    _CatalogTab('チャート', _buildChartsTab),
    _CatalogTab('タブ', _buildTabsTab),
    _CatalogTab('ナビゲーション', _buildNavigationTab),
    _CatalogTab('アプリバー', _buildAppBarsTab),
    _CatalogTab('ダイアログ', _buildDialogsTab),
    _CatalogTab('設定ウィジェット', _buildSettingsWidgetsTab),
  ];

  @override
  void dispose() {
    _textController.dispose();
    _timeInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _tabs.length,
      child: Scaffold(
        backgroundColor: AppColors.black,
        appBar: AppBar(
          title: const Text('コンポーネントチェック'),
          backgroundColor: AppColors.black,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          bottom: TabBar(
            isScrollable: true,
            indicatorColor: AppColors.blue,
            tabs: _tabs.map((tab) => Tab(text: tab.label)).toList(),
          ),
        ),
        body: TabBarView(
          children: _tabs.map((tab) => tab.builder()).toList(),
        ),
      ),
    );
  }

  Widget _buildButtonsTab() {
    return _buildCatalogList([
      _buildPreviewCard(
        title: 'プライマリ / セカンダリ / アウトライン / テキスト',
        child: Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: [
            PrimaryButton(text: 'Primary', onPressed: () {}),
            PrimaryButton(
              text: 'Loading',
              isLoading: true,
              onPressed: () {},
              size: ButtonSize.small,
            ),
            SecondaryButton(text: 'Secondary', onPressed: () {}),
            OutlineButton(text: 'Outline', onPressed: () {}),
            AppTextButton(text: 'テキストボタン', onPressed: () {}),
          ],
        ),
      ),
      _buildPreviewCard(
        title: 'カスタムボタン',
        description: '旧来の遷移系ボタンはタップを無効化して表示しています。',
        child: Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: [
            CustomIconButton(icon: Icons.settings, onPressed: () {}),
            CustomSnsButton(text: 'SNSで共有', onPressed: () {}),
            AbsorbPointer(
              child: CustomPushButton(
                icon: Icons.play_arrow,
                routeName: AppRoutes.home,
              ),
            ),
            AbsorbPointer(
              child: CustomReplacementButton(
                text: '置き換え遷移',
                routeName: AppRoutes.home,
              ),
            ),
            AbsorbPointer(
              child: CustomPopAndPushButton(
                text: 'Pop & Push',
                routeName: AppRoutes.home,
              ),
            ),
            AbsorbPointer(
              child: CustomBackToHomeButton(text: 'ホームに戻る'),
            ),
          ],
        ),
      ),
    ]);
  }

  Widget _buildInputTab() {
    return _buildCatalogList([
      _buildPreviewCard(
        title: 'テキストフィールド',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppTextField(
              label: 'ユーザー名',
              placeholder: 'お名前を入力',
              controller: _textController,
            ),
            SizedBox(height: AppSpacing.md),
            const AppTextField(
              label: 'パスワード',
              placeholder: 'パスワードを入力',
              obscureText: true,
            ),
          ],
        ),
      ),
      _buildPreviewCard(
        title: '日付 / 時刻ピッカー',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppDatePicker(
              label: '日付選択',
              selectedDate: _selectedDate,
              onDateSelected: (date) {
                setState(() {
                  _selectedDate = date;
                });
              },
            ),
            SizedBox(height: AppSpacing.md),
            AppTimePicker(
              label: '時刻選択',
              selectedTime: _selectedTime,
              onTimeSelected: (time) {
                setState(() {
                  _selectedTime = time;
                });
              },
            ),
          ],
        ),
      ),
    ]);
  }

  Widget _buildToggleTab() {
    return _buildCatalogList([
      _buildPreviewCard(
        title: 'トグル',
        child: Row(
          children: [
            AppToggleSwitch(
              value: _toggleValue,
              onChanged: (value) {
                setState(() {
                  _toggleValue = value;
                });
              },
            ),
            SizedBox(width: AppSpacing.md),
            Text(
              _toggleValue ? 'ON' : 'OFF',
              style: AppTextStyles.body1,
            ),
          ],
        ),
      ),
      _buildPreviewCard(
        title: 'チップ',
        child: Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            AppChip.blue(label: 'Blue'),
            AppChip.green(label: 'Green', icon: Icons.eco),
            AppChip.purple(label: 'Purple', onDelete: () {}),
            AppChip.gray(label: 'Gray'),
          ],
        ),
      ),
      _buildPreviewCard(
        title: 'フィルターチップ',
        child: AppFilterChip(
          label: '集中モード',
          selected: _filterSelected,
          onSelected: (value) {
            setState(() {
              _filterSelected = value;
            });
          },
          icon: Icons.center_focus_strong,
        ),
      ),
    ]);
  }

  Widget _buildProgressTab() {
    return _buildCatalogList([
      _buildPreviewCard(
        title: '円形 / 線形プログレス',
        child: Wrap(
          spacing: AppSpacing.lg,
          runSpacing: AppSpacing.lg,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: const [
            CircularProgressBar(percentage: 0.72),
            LinearProgressBar(percentage: 0.45, height: 12),
          ],
        ),
      ),
      _buildPreviewCard(
        title: '目標進捗カード',
        child: GoalProgressCard(
          goalName: '週次学習時間',
          percentage: 0.64,
          currentValue: '12h',
          targetValue: '18h',
        ),
      ),
    ]);
  }

  Widget _buildCardsTab() {
    return _buildCatalogList([
      _buildPreviewCard(
        title: '基本カード',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StandardCard(
              child: Row(
                children: [
                  const Icon(Icons.dashboard, color: AppColors.blue, size: 32),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('標準カード', style: AppTextStyles.h3),
                        SizedBox(height: AppSpacing.xs),
                        Text(
                          '説明テキストが入ります。',
                          style: AppTextStyles.body2
                              .copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right,
                      color: AppColors.textSecondary),
                ],
              ),
            ),
            SizedBox(height: AppSpacing.md),
            GradientCard(
              gradientColors: const [AppColors.blue, AppColors.purple],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('グラデーションカード', style: AppTextStyles.h2),
                  SizedBox(height: AppSpacing.xs),
                  Text(
                    'スタイリッシュなアクセントに。',
                    style: AppTextStyles.body2.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      _buildPreviewCard(
        title: '統計 / 入力カード',
        child: Column(
          children: [
            StatCard(
              icon: Icons.timer,
              iconColor: AppColors.green,
              value: '12h 45m',
              label: '今週の集中時間',
            ),
            SizedBox(height: AppSpacing.md),
            TimeInputCard(
              label: '学習時間を追加',
              icon: Icons.menu_book,
              iconColor: AppColors.blue,
              controller: _timeInputController,
            ),
          ],
        ),
      ),
      _buildPreviewCard(
        title: 'カスタム / インタラクティブ',
        child: Column(
          children: [
            InteractiveCard(
              onTap: () {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('カードがタップされました')),
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('タップ可能カード', style: AppTextStyles.h3),
                  SizedBox(height: AppSpacing.xs),
                  Text(
                    'タップでスナックバーを表示',
                    style: AppTextStyles.body2
                        .copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            SizedBox(height: AppSpacing.md),
            TotalStatsCard(
              totalWorkTime: '312時間',
            ),
          ],
        ),
      ),
    ]);
  }

  Widget _buildStatsTab() {
    return _buildCatalogList([
      _buildPreviewCard(
        title: '統計アイテム',
        child: StatRow(
          stats: const [
            StatItem(
              icon: Icons.timer,
              iconColor: AppColors.blue,
              value: '12h',
              label: '集中',
            ),
            StatItem(
              icon: Icons.flag,
              iconColor: AppColors.green,
              value: '5',
              label: '目標',
            ),
            StatItem(
              icon: Icons.auto_graph,
              iconColor: AppColors.purple,
              value: '+18%',
              label: '成長',
            ),
          ],
        ),
      ),
      _buildPreviewCard(
        title: 'カウントダウン表示',
        child: CountdownDisplay(
          eventName: 'Mid-term Exams',
          days: 15,
          hours: 12,
          minutes: 30,
          seconds: 45,
          onTap: () {},
          onEdit: () {},
        ),
      ),
      _buildPreviewCard(
        title: 'アバター',
        child: Wrap(
          spacing: AppSpacing.md,
          children: const [
            AvatarWidget(initials: 'KI', size: 48),
            AvatarWidget(
              initials: 'AB',
              size: 64,
              backgroundColor: AppColors.purple,
            ),
          ],
        ),
      ),
    ]);
  }

  Widget _buildLayoutsTab() {
    return _buildCatalogList([
      _buildPreviewCard(
        title: 'スクロール / セーフエリア',
        child: Column(
          children: [
            SizedBox(
              height: 140,
              child: ScrollableContent(
                child: Column(
                  children: List.generate(
                    5,
                    (index) => Padding(
                      padding: EdgeInsets.only(bottom: AppSpacing.sm),
                      child: Text(
                        '行 ${index + 1}',
                        style: AppTextStyles.body1,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: AppSpacing.md),
            Container(
              color: AppColors.backgroundSecondary,
              child: SafeContent(
                padding: EdgeInsets.all(AppSpacing.sm),
                child: Text(
                  'SafeContent が適用された領域',
                  style: AppTextStyles.body2,
                ),
              ),
            ),
          ],
        ),
      ),
      _buildPreviewCard(
        title: '中央配置 / 幅制限',
        child: Column(
          children: [
            SizedBox(
              height: 160,
              child: CenteredLayout(
                child: Container(
                  padding: EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.blackgray,
                    borderRadius: BorderRadius.circular(AppRadius.medium),
                  ),
                  child: const Text('CenteredLayout'),
                ),
              ),
            ),
            SizedBox(height: AppSpacing.md),
            ConstrainedContent(
              maxWidth: 240,
              child: const Text(
                'ConstrainedContent により最大幅が制限されています。',
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
      _buildPreviewCard(
        title: 'スペースドレイアウト',
        child: Column(
          children: [
            SpacedColumn(
              spacing: AppSpacing.sm,
              children: const [
                Text('行1'),
                Text('行2'),
                Text('行3'),
              ],
            ),
            SizedBox(height: AppSpacing.lg),
            SpacedRow(
              spacing: AppSpacing.md,
              children: const [
                Icon(Icons.star, color: AppColors.yellow),
                Icon(Icons.star, color: AppColors.yellow),
                Icon(Icons.star, color: AppColors.yellow),
              ],
            ),
          ],
        ),
      ),
      _buildPreviewCard(
        title: 'AppScaffold',
        description: '縮小表示のため、固定高さで表示しています。',
        child: SizedBox(
          height: 220,
          child: AppScaffold(
            appBar: SimpleAppBar(title: 'プレビュー'),
            body: Center(
              child: Text(
                'AppScaffold の内容',
                style: AppTextStyles.body1,
              ),
            ),
          ),
        ),
      ),
    ]);
  }

  Widget _buildChartsTab() {
    double minutes(int value) => value / 60;

    BarChartGroupData buildStackedBar(
      int x,
      List<Map<String, dynamic>> segments,
    ) {
      double current = 0;
      final stackItems = <BarChartRodStackItem>[];
      for (final segment in segments) {
        final duration = segment['duration'] as double;
        final color = segment['color'] as Color;
        final start = current;
        final end = (current + duration).clamp(0, 1.0).toDouble();
        stackItems.add(BarChartRodStackItem(start, end, color));
        current = end;
      }
      return BarChartGroupData(
        x: x,
        barRods: [
          BarChartRodData(
            toY: current,
            width: 18,
            borderRadius: BorderRadius.circular(AppRadius.large),
            rodStackItems: stackItems,
            color: Colors.transparent,
          ),
        ],
      );
    }

    final barGroups = [
      buildStackedBar(0, [
        {'duration': 1.0, 'color': AppColors.lightblackgray},
      ]),
      buildStackedBar(1, [
        {'duration': minutes(15), 'color': AppColors.orange},
        {'duration': minutes(20), 'color': AppColors.lightblackgray},
        {'duration': minutes(25), 'color': AppColors.blue},
      ]),
      buildStackedBar(2, [
        {'duration': minutes(20), 'color': AppColors.green},
        {'duration': minutes(10), 'color': AppColors.lightblackgray},
        {'duration': minutes(30), 'color': AppColors.blue},
      ]),
      buildStackedBar(3, [
        {'duration': minutes(25), 'color': AppColors.purple},
        {'duration': minutes(35), 'color': AppColors.blue},
      ]),
      buildStackedBar(4, [
        {'duration': minutes(10), 'color': AppColors.lightblackgray},
        {'duration': minutes(30), 'color': AppColors.blue},
        {'duration': minutes(20), 'color': AppColors.orange},
      ]),
      buildStackedBar(5, [
        {'duration': minutes(40), 'color': AppColors.green},
        {'duration': minutes(20), 'color': AppColors.lightblackgray},
      ]),
      buildStackedBar(6, [
        {'duration': minutes(30), 'color': AppColors.blue},
        {'duration': minutes(15), 'color': AppColors.purple},
        {'duration': minutes(15), 'color': AppColors.lightblackgray},
      ]),
      buildStackedBar(7, [
        {'duration': minutes(20), 'color': AppColors.orange},
        {'duration': minutes(25), 'color': AppColors.green},
        {'duration': minutes(15), 'color': AppColors.blue},
      ]),
    ];

    final pieSections = [
      PieChartSectionData(
        value: 40,
        color: AppColors.blue,
        title: '',
        showTitle: false,
        radius: 56,
      ),
      PieChartSectionData(
        value: 30,
        color: AppColors.green,
        title: '',
        showTitle: false,
        radius: 56,
      ),
      PieChartSectionData(
        value: 20,
        color: AppColors.purple,
        title: '',
        showTitle: false,
        radius: 56,
      ),
      PieChartSectionData(
        value: 10,
        color: AppColors.yellow,
        title: '',
        showTitle: false,
        radius: 56,
      ),
    ];

    final legendItems = [
      LegendItem(label: 'Study', color: AppColors.blue, value: '30m'),
      LegendItem(label: 'PC', color: AppColors.green, value: '20m'),
      LegendItem(label: 'Break', color: AppColors.purple, value: '25m'),
      LegendItem(label: 'Other', color: AppColors.orange, value: '15m'),
      LegendItem(
        label: 'No detection',
        color: AppColors.lightblackgray,
        value: 'gap',
      ),
    ];

    return _buildCatalogList([
      _buildPreviewCard(
        title: '棒グラフ',
        child: AppBarChart(
          title: '時間帯別学習量',
          barGroups: barGroups,
          maxY: 1,
          getBottomTitles: (value, meta) {
            const labels = [
              '0:00',
              '3:00',
              '6:00',
              '9:00',
              '12:00',
              '15:00',
              '18:00',
              '21:00',
            ];
            final index = value.toInt();
            if (index < 0 || index >= labels.length) {
              return const SizedBox.shrink();
            }
            final label = labels[index];
            if (label.isEmpty) {
              return const SizedBox.shrink();
            }
            return Text(label, style: AppTextStyles.caption);
          },
          getLeftTitles: (value, meta) {
            if (value < 0 || value > 1) {
              return const SizedBox.shrink();
            }
            final minutesLabel = (value * 60).round();
            if (minutesLabel % 30 != 0 && minutesLabel != 60 && minutesLabel != 0) {
              return const SizedBox.shrink();
            }
            final label = minutesLabel == 60
                ? '60m'
                : minutesLabel == 0
                    ? '0m'
                    : '${minutesLabel}m';
            return Text(label, style: AppTextStyles.caption);
          },
        ),
      ),
      _buildPreviewCard(
        title: '円グラフ',
        child: Column(
          children: [
            AppPieChart(
              sections: pieSections,
              centerText: '80h 30m\nTotal',
            ),
            SizedBox(height: AppSpacing.md),
            ChartLegend(items: legendItems, alignment: WrapAlignment.center),
          ],
        ),
      ),
    ]);
  }

  Widget _buildTabsTab() {
    final tabs = ['概要', '統計', '設定'];

    return _buildCatalogList([
      _buildPreviewCard(
        title: 'AppTabBar',
        child: AppTabBar(
          tabs: tabs,
          selectedIndex: _tabSelectedIndex,
          onTabSelected: (index) {
            setState(() {
              _tabSelectedIndex = index;
            });
          },
        ),
      ),
      _buildPreviewCard(
        title: 'PeriodTabBar',
        child: PeriodTabBar(
          selectedIndex: _periodSelectedIndex,
          onPeriodSelected: (index) {
            setState(() {
              _periodSelectedIndex = index;
            });
          },
        ),
      ),
    ]);
  }

  Widget _buildNavigationTab() {
    final navigationItems = [
      NavigationItem(
        icon: Icons.home,
        label: 'Home',
        screen: const Center(child: Text('Home')),
        activeColor: AppColors.blue,
      ),
      NavigationItem(
        icon: Icons.flag,
        label: 'Goals',
        screen: const Center(child: Text('Goals')),
        activeColor: AppColors.orange,
      ),
      NavigationItem(
        icon: Icons.assessment,
        label: 'Report',
        screen: const Center(child: Text('Report')),
        activeColor: AppColors.green,
      ),
    ];

    return _buildCatalogList([
      _buildPreviewCard(
        title: 'AppBottomNavigationBar',
        child: Container(
          color: AppColors.backgroundSecondary,
          padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: AppBottomNavigationBar(
            currentIndex: _navigationIndex,
            onTap: (index) {
              setState(() {
                _navigationIndex = index;
              });
            },
            items: navigationItems,
          ),
        ),
      ),
    ]);
  }

  Widget _buildAppBarsTab() {
    return _buildCatalogList([
      _buildPreviewCard(
        title: 'AppBar バリエーション',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: kToolbarHeight,
              child: Material(
                color: Colors.transparent,
                child: AppBarWithBack(
                  title: '戻るボタン付き',
                  onBack: () {},
                ),
              ),
            ),
            SizedBox(height: AppSpacing.md),
            SizedBox(
              height: kToolbarHeight,
              child: Material(
                color: Colors.transparent,
                child: AppBarWithActions(
                  title: 'アクション付き',
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.search),
                      color: AppColors.textPrimary,
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: AppSpacing.md),
            SizedBox(
              height: kToolbarHeight,
              child: Material(
                color: Colors.transparent,
                child: SimpleAppBar(title: 'シンプル'),
              ),
            ),
            SizedBox(height: AppSpacing.md),
            SizedBox(
              height: kToolbarHeight,
              child: Material(
                color: Colors.transparent,
                child: TransparentAppBar(
                  title: '透過',
                  leading: IconButton(
                    icon: const Icon(Icons.menu),
                    color: AppColors.textPrimary,
                    onPressed: () {},
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.settings),
                      color: AppColors.textPrimary,
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ]);
  }

  Widget _buildDialogsTab() {
    return _buildCatalogList([
      _buildPreviewCard(
        title: 'ダイアログを表示',
        description: '各ボタンを押してダイアログの見た目を確認できます。',
        child: Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: [
            PrimaryButton(
              text: '確認ダイアログ',
              onPressed: () async {
                await ConfirmDialog.show(
                  context,
                  title: '削除しますか？',
                  message: 'この項目を削除すると元に戻せません。',
                );
              },
            ),
            SecondaryButton(
              text: '目標設定ダイアログ',
              onPressed: () {
                AppDialogBase.show(
                  context,
                  const GoalSettingDialog(isEdit: true),
                );
              },
            ),
            OutlineButton(
              text: 'カウントダウン設定',
              onPressed: () {
                AppDialogBase.show(
                  context,
                  const CountdownSettingDialog(),
                );
              },
            ),
          ],
        ),
      ),
    ]);
  }

  Widget _buildSettingsWidgetsTab() {
    final segmentOptions = ['ライト', 'ダーク', 'システム'];

    return _buildCatalogList([
      _buildPreviewCard(
        title: '設定タイル / スイッチ',
        child: Column(
          children: [
            SettingsTile(
              icon: Icons.person,
              iconBackgroundColor: AppColors.blue,
              title: 'アカウント設定',
              onTap: () {},
            ),
            SizedBox(height: AppSpacing.md),
            CustomSwitchTile(
              title: 'プッシュ通知',
              value: _settingsSwitch,
              onChanged: (value) {
                setState(() {
                  _settingsSwitch = value;
                });
              },
            ),
          ],
        ),
      ),
      _buildPreviewCard(
        title: '入力 / 時刻 / セグメント',
        child: Column(
          children: [
            CustomTextField(
              label: '通知文言',
              initialValue: _settingsText,
              onChanged: (value) {
                setState(() {
                  _settingsText = value;
                });
              },
            ),
            SizedBox(height: AppSpacing.md),
            CustomTimePicker(
              label: 'リマインド時刻',
              currentTime: _settingsTime,
              onTimeSelected: (value) {
                setState(() {
                  _settingsTime = value;
                });
              },
            ),
            SizedBox(height: AppSpacing.md),
            CustomSegmentedControl(
              options: segmentOptions,
              selectedValue: _selectedSegment,
              onChanged: (value) {
                setState(() {
                  _selectedSegment = value;
                });
              },
            ),
          ],
        ),
      ),
      _buildPreviewCard(
        title: 'カラー / アバター表示',
        child: Column(
          children: [
            CustomColorPicker(
              selectedColor: _selectedColorName,
              onColorSelected: (value) {
                setState(() {
                  _selectedColorName = value;
                });
              },
            ),
            SizedBox(height: AppSpacing.md),
            CustomAvatarDisplay(
              name: 'Kikuchi Ichiro',
              colorName: _selectedColorName,
              size: 80,
            ),
          ],
        ),
      ),
    ]);
  }

  Widget _buildCatalogList(List<Widget> children) {
    return ListView(
      padding: EdgeInsets.all(AppSpacing.lg),
      children: children,
    );
  }

  Widget _buildPreviewCard({
    required String title,
    required Widget child,
    String? description,
  }) {
    return Card(
      color: AppColors.blackgray,
      margin: EdgeInsets.only(bottom: AppSpacing.lg),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.large),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTextStyles.h3),
            if (description != null) ...[
              SizedBox(height: AppSpacing.xs),
              Text(
                description,
                style: AppTextStyles.body2
                    .copyWith(color: AppColors.textSecondary),
              ),
            ],
            SizedBox(height: AppSpacing.md),
            child,
          ],
        ),
      ),
    );
  }
}

class _CatalogTab {
  final String label;
  final Widget Function() builder;

  const _CatalogTab(this.label, this.builder);
}

