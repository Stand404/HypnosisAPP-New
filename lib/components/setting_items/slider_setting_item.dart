import 'package:flutter/material.dart';
import '../../config/app_constants.dart';
import 'setting_item.dart';

/// 滑块设置项组件
class SliderSettingItem extends StatelessWidget {
  final String title;
  final double value;
  final double min;
  final double max;
  final double step;
  final ValueChanged<double> onChanged;
  final int decimalPlaces; // 小数位数

  const SliderSettingItem({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    this.min = 0.0,
    this.max = 1.0,
    this.step = 0.1,
    this.decimalPlaces = 1,
  });

  @override
  Widget build(BuildContext context) {
    return SettingItem(
      title: title,
      height: LayoutConstants.settingItemHeight,
      trailing: _buildSliderContent(),
      expandedTrailing: true,
    );
  }

  Widget _buildSliderContent() {
    return SizedBox(
      width: 220,
      child: Row(
        children: [
          // 滑条
          Expanded(
            child: SliderTheme(
              data: SliderThemeData(
                activeTrackColor: Color(StyleConstants.primaryColorValue),
                inactiveTrackColor: Colors.white.withOpacity(
                  StyleConstants.sliderInactiveTrackOpacity
                ),
                thumbColor: Color(StyleConstants.primaryColorValue),
                overlayColor: Color(StyleConstants.primaryColorValue).withOpacity(
                  StyleConstants.sliderOverlayOpacity
                ),
                valueIndicatorColor: Color(StyleConstants.primaryColorValue),
                valueIndicatorTextStyle: AppTextStyles.mediumText,
              ),
              child: Slider(
                value: value,
                min: min,
                max: max,
                divisions: ((max - min) / step).round(),
                label: value.toStringAsFixed(decimalPlaces),
                onChanged: onChanged,
              ),
            ),
          ),
          // 数值显示
          Padding(
            padding: EdgeInsets.only(left: LayoutConstants.mediumSpacing),
            child: SizedBox(
              width: LayoutConstants.valueDisplayWidth,
              child: Text(
                value.toStringAsFixed(decimalPlaces),
                style: AppTextStyles.value16,
                textAlign: TextAlign.right,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
