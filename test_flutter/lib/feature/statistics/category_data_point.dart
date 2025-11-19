/// カテゴリ別データポイント
/// 
/// レポート画面で使用する、カテゴリ別の時間データを表すクラス
class CategoryDataPoint {
  final String label;
  final Map<String, double> values; // カテゴリー別の値（時間単位）

  CategoryDataPoint({
    required this.label,
    required this.values,
  });
}

