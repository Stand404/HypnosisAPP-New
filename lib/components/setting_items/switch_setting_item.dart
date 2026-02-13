import 'package:flutter/material.dart';
import '../../config/app_constants.dart';
import 'setting_item.dart';

/// 开关设置项组件
class SwitchSettingItem extends StatelessWidget {
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const SwitchSettingItem({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SettingItem(
      title: title,
      height: LayoutConstants.settingItemHeight,
      onTap: () => onChanged(!value),
      trailing: Switch(
        value: value,
        onChanged: null, // 设置为 null，避免与 InkWell 冲突
        activeColor: Color(StyleConstants.primaryColorValue),
        activeTrackColor: AppColors.primaryWith50Opacity,
      ),
    );
  }
}
