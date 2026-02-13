import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/setting_item_config.dart';
import '../../models/settings.dart';
import '../../store/settings_provider.dart';
import '../app_constants.dart';
import '../../components/setting_items/setting_item.dart';

/// 动画设置页面配置
class AnimationSettingsConfig {
  /// 获取动画设置页面配置
  static SettingPageConfig getConfig({
    VoidCallback? onShowHeartExpansionColorsModal,
  }) {
    return SettingPageConfig(
      titleKey: 'animation_settings',
      items: [
        // 通用设置：背景颜色
        SettingItemConfig(
          type: SettingItemType.color,
          titleKey: 'bg_color',
          getValue: (settings) => (settings as Settings).bgColor,
          onUpdate: (context, value) {
            context.read<SettingsProvider>().updateBgColor(value as String);
          },
        ),
        // 通用设置：动画速度
        SettingItemConfig(
          type: SettingItemType.slider,
          titleKey: 'animation_speed',
          getValue: (settings) => (settings as Settings).animationSpeed,
          onUpdate: (context, value) {
            context.read<SettingsProvider>().updateAnimationSpeed(
              value as double,
            );
          },
          sliderConfig: const SliderConfig(
            min: SettingsConstants.animationSpeedMin,
            max: SettingsConstants.animationSpeedMax,
            step: SettingsConstants.animationSpeedStep,
            decimalPlaces: SettingsConstants.animationSpeedDecimalPlaces,
          ),
        ),
        // 扩散动画：扩散间隔
        SettingItemConfig(
          type: SettingItemType.slider,
          titleKey: 'param_expansion_interval',
          getValue: (settings) => (settings as Settings).expansionInterval,
          onUpdate: (context, value) {
            context.read<SettingsProvider>().updateExpansionInterval(
              value as double,
            );
          },
          sliderConfig: const SliderConfig(
            min: SettingsConstants.expansionIntervalMin,
            max: SettingsConstants.expansionIntervalMax,
            step: SettingsConstants.expansionIntervalStep,
            decimalPlaces: SettingsConstants.expansionIntervalDecimalPlaces,
          ),
          condition: (settings) =>
              (settings as Settings).animationType !=
              AnimationType.classicSpiral,
        ),
        // 圆环和螺旋：环形颜色
        SettingItemConfig(
          type: SettingItemType.color,
          titleKey: 'ring_color',
          getValue: (settings) => (settings as Settings).ringColor,
          onUpdate: (context, value) {
            context.read<SettingsProvider>().updateRingColor(value as String);
          },
          condition: (settings) =>
              (settings as Settings).animationType !=
              AnimationType.heartExpansion,
        ),
        // 圆环和螺旋：环形粗细
        SettingItemConfig(
          type: SettingItemType.slider,
          titleKey: 'ring_thickness',
          getValue: (settings) => (settings as Settings).ringThickness,
          onUpdate: (context, value) {
            context.read<SettingsProvider>().updateRingThickness(
              value as double,
            );
          },
          sliderConfig: const SliderConfig(
            min: SettingsConstants.ringThicknessMin,
            max: SettingsConstants.ringThicknessMax,
            step: SettingsConstants.ringThicknessStep,
            decimalPlaces: SettingsConstants.ringThicknessDecimalPlaces,
          ),
          condition: (settings) =>
              (settings as Settings).animationType !=
              AnimationType.heartExpansion,
        ),
        // 爱心扩散特有：颜色列表
        SettingItemConfig(
          type: SettingItemType.custom,
          titleKey: 'param_color_list',
          getValue: (settings) => (settings as Settings).heartExpansionColors,
          onUpdate: (context, value) {},
          customBuilder: (context, settings, title, getValue) {
            final colors = getValue(settings) as List<String>;
            final callback = onShowHeartExpansionColorsModal;

            return SettingItem(
              title: title,
              height: LayoutConstants.settingItemHeight,
              onTap: callback ?? () {},
              enabled: callback != null,
              trailing: Row(
                children: [
                  Text('${colors.length}', style: AppTextStyles.value16),
                  SizedBox(width: LayoutConstants.smallSpacing),
                  Icon(
                    Icons.chevron_right,
                    color: Color(StyleConstants.primaryColorValue),
                    size: StyleConstants.iconSize,
                  ),
                ],
              ),
            );
          },
          condition: (settings) =>
              (settings as Settings).animationType ==
              AnimationType.heartExpansion,
        ),
        // 经典螺旋特有：螺旋条数
        SettingItemConfig(
          type: SettingItemType.slider,
          titleKey: 'param_spiral_count',
          getValue: (settings) => (settings as Settings).spiralStrips,
          onUpdate: (context, value) {
            context.read<SettingsProvider>().updateSpiralStrips(
              value as double,
            );
          },
          sliderConfig: const SliderConfig(
            min: SettingsConstants.spiralStripsMin,
            max: SettingsConstants.spiralStripsMax,
            step: SettingsConstants.spiralStripsStep,
            decimalPlaces: SettingsConstants.spiralStripsDecimalPlaces,
          ),
          condition: (settings) =>
              (settings as Settings).animationType ==
              AnimationType.classicSpiral,
        ),
        // 经典螺旋特有：螺旋扭曲程度
        SettingItemConfig(
          type: SettingItemType.slider,
          titleKey: 'param_twist_degree',
          getValue: (settings) => (settings as Settings).spiralDistortion,
          onUpdate: (context, value) {
            context.read<SettingsProvider>().updateSpiralDistortion(
              value as double,
            );
          },
          sliderConfig: const SliderConfig(
            min: SettingsConstants.spiralDistortionMin,
            max: SettingsConstants.spiralDistortionMax,
            step: SettingsConstants.spiralDistortionStep,
            decimalPlaces: SettingsConstants.spiralDistortionDecimalPlaces,
          ),
          condition: (settings) =>
              (settings as Settings).animationType ==
              AnimationType.classicSpiral,
        ),
      ],
    );
  }
}
