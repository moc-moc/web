import 'package:flutter/material.dart';
import 'package:test_flutter/core/theme.dart';

/// 設定画面のタイル
class SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconBackgroundColor;
  final String title;
  final VoidCallback onTap;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.iconBackgroundColor,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(
          color: iconBackgroundColor.withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.large),
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: iconBackgroundColor.withValues(alpha: 0.2),
                  child: Icon(icon, color: iconBackgroundColor, size: 24),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppColors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// テキスト入力フィールド（設定用）
///
/// シンプルなテキスト入力フィールドです。
class CustomTextField extends StatelessWidget {
  final String label;
  final String? initialValue;
  final ValueChanged<String> onChanged;

  const CustomTextField({
    super.key,
    required this.label,
    this.initialValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initialValue,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.gray),
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: AppColors.blackgray),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: AppColors.blue, width: 2),
        ),
      ),
      style: const TextStyle(color: AppColors.gray, fontSize: 16),
    );
  }
}

/// スイッチ付きリストタイル（設定用）
///
/// ON/OFF切り替え用のスイッチ付きタイルです。
class CustomSwitchTile extends StatelessWidget {
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const CustomSwitchTile({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      color: AppColors.blackgray,
      child: SwitchListTile(
        title: Text(
          title,
          style: const TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        value: value,
        onChanged: onChanged,
        activeThumbColor: AppColors.blue,
      ),
    );
  }
}

/// 時間選択ボタン（設定用）
///
/// 時間を選択するボタンです。タップするとTimePickerが表示されます。
class CustomTimePicker extends StatelessWidget {
  final String label;
  final String currentTime;
  final ValueChanged<String> onTimeSelected;

  const CustomTimePicker({
    super.key,
    required this.label,
    required this.currentTime,
    required this.onTimeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      color: AppColors.blackgray,
      child: ListTile(
        leading: const Icon(Icons.access_time, color: AppColors.blue),
        title: Text(
          label,
          style: const TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Text(
          currentTime,
          style: const TextStyle(
            color: AppColors.blue,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        onTap: () async {
          final parts = currentTime.split(':');
          final hour = int.tryParse(parts[0]) ?? 8;
          final minute = int.tryParse(parts[1]) ?? 30;

          final time = await showTimePicker(
            context: context,
            initialTime: TimeOfDay(hour: hour, minute: minute),
          );

          if (time != null) {
            final formattedTime =
                '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
            onTimeSelected(formattedTime);
          }
        },
      ),
    );
  }
}

/// セグメント選択（設定用）
///
/// 複数の選択肢から1つを選ぶセグメントコントロールです。
class CustomSegmentedControl extends StatelessWidget {
  final List<String> options;
  final String selectedValue;
  final ValueChanged<String> onChanged;

  const CustomSegmentedControl({
    super.key,
    required this.options,
    required this.selectedValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      color: AppColors.blackgray,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: options.map((option) {
            final isSelected = option == selectedValue;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Material(
                  color: isSelected ? AppColors.blue : AppColors.lightblackgray,
                  borderRadius: BorderRadius.circular(8.0),
                  child: InkWell(
                    onTap: () => onChanged(option),
                    borderRadius: BorderRadius.circular(8.0),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Text(
                        option,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

/// 色選択ウィジェット（設定用）
///
/// アバター用の色を選択するウィジェットです。
class CustomColorPicker extends StatelessWidget {
  final String selectedColor;
  final ValueChanged<String> onColorSelected;

  const CustomColorPicker({
    super.key,
    required this.selectedColor,
    required this.onColorSelected,
  });

  static const Map<String, Color> colors = {
    'blue': AppColors.blue,
    'red': AppColors.red,
    'green': AppColors.green,
    'purple': Color(0xFF9C27B0),
    'orange': Color(0xFFFF9800),
    'pink': Color(0xFFE91E63),
  };

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      color: AppColors.blackgray,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'アバターの色',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: colors.entries.map((entry) {
                final colorName = entry.key;
                final color = entry.value;
                final isSelected = colorName == selectedColor;

                return GestureDetector(
                  onTap: () => onColorSelected(colorName),
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(color: AppColors.white, width: 3)
                          : null,
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: AppColors.white)
                        : null,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

/// アバター表示ウィジェット（設定用）
///
/// 色+頭文字のアバターを表示するウィジェットです。
class CustomAvatarDisplay extends StatelessWidget {
  final String name;
  final String colorName;
  final double size;

  const CustomAvatarDisplay({
    super.key,
    required this.name,
    required this.colorName,
    this.size = 50,
  });

  Color _getColorFromName(String colorName) {
    return CustomColorPicker.colors[colorName] ?? AppColors.blue;
  }

  @override
  Widget build(BuildContext context) {
    final initial = name.isNotEmpty ? name[0] : '?';

    return CircleAvatar(
      radius: size / 2,
      backgroundColor: _getColorFromName(colorName),
      child: Text(
        initial,
        style: TextStyle(
          color: AppColors.white,
          fontSize: size / 2.5,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
