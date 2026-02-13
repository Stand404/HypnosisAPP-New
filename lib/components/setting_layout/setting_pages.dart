import 'package:flutter/material.dart';
import '../../models/setting_item_config.dart';
import '../../models/settings.dart';
import '../../i18n/app_localizations.dart';
import '../../config/settings/global_settings_config.dart';
import '../../config/settings/text_settings_config.dart';
import '../../config/settings/animation_settings_config.dart';
import '../../config/settings/pattern_settings_config.dart';
import '../setting_items/switch_setting_item.dart';
import '../setting_items/slider_setting_item.dart';
import '../setting_items/color_setting_item.dart';

/// 构建页面内容
Widget buildPageContent(
  int currentPage,
  Settings settings,
  AppLocalizations appLocalizations,
  BuildContext context,
  Widget Function({required int index, required Widget child})
  buildAnimatedItem, {
  VoidCallback? onShowConfigPresetsModal,
  VoidCallback? onShowAnimationTypeModal,
  VoidCallback? onShowHeartExpansionColorsModal,
}) {
  // 根据当前页面获取对应的配置
  final config = _getPageConfig(
    currentPage,
    onShowConfigPresetsModal: onShowConfigPresetsModal,
    onShowAnimationTypeModal: onShowAnimationTypeModal,
    onShowHeartExpansionColorsModal: onShowHeartExpansionColorsModal,
  );

  if (config == null) {
    return const SizedBox.shrink();
  }

  // 根据配置动态生成设置项列表
  final items = <Widget>[];
  int itemIndex = 0;

  for (final itemConfig in config.items) {
    // 检查条件，决定是否显示该设置项
    if (itemConfig.condition != null && !itemConfig.condition!(settings)) {
      continue;
    }

    final itemWidget = _buildSettingItem(
      context,
      settings,
      appLocalizations,
      itemConfig,
    );

    items.add(
      buildAnimatedItem(
        index: itemIndex,
        child: itemWidget,
      ),
    );

    itemIndex++;
  }

  // 构建页面内容
  return Column(children: items);
}

/// 根据页面索引获取对应的配置
SettingPageConfig? _getPageConfig(
  int currentPage, {
  VoidCallback? onShowConfigPresetsModal,
  VoidCallback? onShowAnimationTypeModal,
  VoidCallback? onShowHeartExpansionColorsModal,
}) {
  switch (currentPage) {
    case 0:
      return GlobalSettingsConfig.getConfig(
        onShowConfigPresetsModal: onShowConfigPresetsModal ?? () {},
        onShowAnimationTypeModal: onShowAnimationTypeModal ?? () {},
      );
    case 1:
      return AnimationSettingsConfig.getConfig(
        onShowHeartExpansionColorsModal: onShowHeartExpansionColorsModal,
      );
    case 2:
      return TextSettingsConfig.getConfig();
    case 3:
      return PatternSettingsConfig.getConfig();
    default:
      return null;
  }
}

/// 根据配置构建单个设置项
Widget _buildSettingItem(
  BuildContext context,
  Settings settings,
  AppLocalizations appLocalizations,
  SettingItemConfig config,
) {
  final title = appLocalizations.t(config.titleKey, settings.language);

  switch (config.type) {
    case SettingItemType.switch_:
      return SwitchSettingItem(
        title: title,
        value: config.getValue(settings) as bool,
        onChanged: (value) {
          config.onUpdate(context, value);
        },
      );

    case SettingItemType.slider:
      final sliderConfig = config.sliderConfig;
      if (sliderConfig == null) {
        return const SizedBox.shrink();
      }
      return SliderSettingItem(
        title: title,
        value: config.getValue(settings) as double,
        min: sliderConfig.min,
        max: sliderConfig.max,
        step: sliderConfig.step,
        decimalPlaces: sliderConfig.decimalPlaces,
        onChanged: (value) {
          config.onUpdate(context, value);
        },
      );

    case SettingItemType.color:
      return ColorSettingItem(
        title: title,
        color: config.getValue(settings) as String,
        onChanged: (color) {
          config.onUpdate(context, color);
        },
      );

    case SettingItemType.custom:
      final customBuilder = config.customBuilder;
      if (customBuilder == null) {
        return const SizedBox.shrink();
      }
      return customBuilder(
        context,
        settings,
        title,
        config.getValue,
      );
  }
}
