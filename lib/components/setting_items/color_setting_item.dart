import 'package:flutter/material.dart';
import '../../config/app_constants.dart';
import '../../utils/color_utils.dart';
import 'setting_item.dart';
import '../common/color_picker_dialog.dart';

class ColorSettingItem extends StatelessWidget {
  final String title;
  final String color;
  final ValueChanged<String> onChanged;

  const ColorSettingItem({
    super.key,
    required this.title,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SettingItem(
      title: title,
      height: LayoutConstants.settingItemHeight,
      onTap: () => _showColorPicker(context),
      trailing: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: ColorUtils.parseColor(color),
          shape: BoxShape.circle
        ),
      ),
    );
  }

  void _showColorPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ColorPickerDialog(
          initialColor: ColorUtils.parseColor(color),
          instantUpdate: true,
          onColorSelected: (Color selectedColor) {
            onChanged(_colorToString(selectedColor));
          },
        );
      },
    );
  }

  String _colorToString(Color color) {
    // 使用 toARGB32() 确保正确的格式，然后移除 alpha 通道
    // ARGB 格式为 AARRGGBB，我们只需要 RRGGBB
    String hex = color.toARGB32().toRadixString(16).substring(2).toUpperCase();
    return '#$hex';
  }
}
