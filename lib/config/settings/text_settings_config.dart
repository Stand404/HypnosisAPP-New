import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/setting_item_config.dart';
import '../../models/settings.dart';
import '../../store/settings_provider.dart';
import '../app_constants.dart';
import '../../i18n/app_localizations.dart';
import '../../components/setting_items/setting_item.dart';
import 'settings_helpers.dart';

/// 文本设置页面配置
class TextSettingsConfig {
  /// 获取文本设置页面配置
  static SettingPageConfig getConfig() {
    return SettingPageConfig(
      titleKey: 'text_display',
      items: [
        // 文本内容设置
        SettingItemConfig(
          type: SettingItemType.custom,
          titleKey: 'text_content',
          getValue: (settings) => (settings as Settings).displayText,
          onUpdate: (context, value) {},
          customBuilder: (context, settings, title, getValue) {
            final text = getValue(settings) as String?;
            final appLocalizations = AppLocalizations.of(context);
            final language = (settings as Settings).language;
            
            return SettingItem(
              title: title,
              height: LayoutConstants.settingItemHeight,
              onTap: () => SettingsHelpers.showTextInputDialog(context, settings),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    text ?? appLocalizations.t('no_text', language),
                    style: AppTextStyles.value16,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
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
        ),
        // 文本大小
        SettingItemConfig(
          type: SettingItemType.slider,
          titleKey: 'text_size',
          getValue: (settings) => (settings as Settings).textSize,
          onUpdate: (context, value) {
            context.read<SettingsProvider>().updateTextSize(value as double);
          },
          sliderConfig: const SliderConfig(
            min: 12.0,
            max: 100.0,
            step: 1.0,
            decimalPlaces: 0,
          ),
        ),
        // 文本颜色
        SettingItemConfig(
          type: SettingItemType.color,
          titleKey: 'text_color',
          getValue: (settings) => (settings as Settings).textColor,
          onUpdate: (context, value) {
            context.read<SettingsProvider>().updateTextColor(value as String);
          },
        ),
        // 文本水平位置
        SettingItemConfig(
          type: SettingItemType.slider,
          titleKey: 'text_horizontal_position',
          getValue: (settings) => (settings as Settings).textHorizontalPosition,
          onUpdate: (context, value) {
            context.read<SettingsProvider>().updateTextHorizontalPosition(value as double);
          },
          sliderConfig: const SliderConfig(
            min: -1.0,
            max: 1.0,
            step: 0.01,
            decimalPlaces: 2,
          ),
        ),
        // 文本垂直位置
        SettingItemConfig(
          type: SettingItemType.slider,
          titleKey: 'text_vertical_position',
          getValue: (settings) => (settings as Settings).textVerticalPosition,
          onUpdate: (context, value) {
            context.read<SettingsProvider>().updateTextVerticalPosition(value as double);
          },
          sliderConfig: const SliderConfig(
            min: -1.0,
            max: 1.0,
            step: 0.01,
            decimalPlaces: 2,
          ),
        ),
      ],
    );
  }
}
