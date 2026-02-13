import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/setting_item_config.dart';
import '../../models/settings.dart';
import '../../store/settings_provider.dart';
import '../app_constants.dart';
import '../../i18n/app_localizations.dart';
import '../../components/setting_items/setting_item.dart';
import 'settings_helpers.dart';

/// 中心图案设置页面配置
class PatternSettingsConfig {
  /// 获取中心图案设置页面配置
  static SettingPageConfig getConfig() {
    return SettingPageConfig(
      titleKey: 'center_settings',
      items: [
        // 心跳动画
        SettingItemConfig(
          type: SettingItemType.switch_,
          titleKey: 'heartbeat_animation',
          getValue: (settings) => (settings as Settings).isBeating,
          onUpdate: (context, value) {
            context.read<SettingsProvider>().updateIsBeating(value as bool);
          },
        ),
        // 心跳速度（条件显示）
        SettingItemConfig(
          type: SettingItemType.slider,
          titleKey: 'heartbeat_speed',
          getValue: (settings) => (settings as Settings).heartBeatSpeed,
          onUpdate: (context, value) {
            context.read<SettingsProvider>().updateHeartBeatSpeed(
              value as double,
            );
          },
          sliderConfig: const SliderConfig(
            min: SettingsConstants.heartBeatSpeedMin,
            max: SettingsConstants.heartBeatSpeedMax,
            step: SettingsConstants.heartBeatSpeedStep,
            decimalPlaces: SettingsConstants.heartBeatSpeedDecimalPlaces,
          ),
          condition: (settings) => (settings as Settings).isBeating,
        ),
        // 爱心外填充色（默认图案时显示）
        SettingItemConfig(
          type: SettingItemType.color,
          titleKey: 'outer_fill',
          getValue: (settings) => (settings as Settings).heartOuterFillColor,
          onUpdate: (context, value) {
            context.read<SettingsProvider>().updateHeartOuterFillColor(
              value as String,
            );
          },
          condition: (settings) =>
              (settings as Settings).customPatternPath == null,
        ),
        // 爱心内边框色（默认图案时显示）
        SettingItemConfig(
          type: SettingItemType.color,
          titleKey: 'inner_stroke',
          getValue: (settings) => (settings as Settings).heartInnerStrokeColor,
          onUpdate: (context, value) {
            context.read<SettingsProvider>().updateHeartInnerStrokeColor(
              value as String,
            );
          },
          condition: (settings) =>
              (settings as Settings).customPatternPath == null,
        ),
        // 爱心外边框色（默认图案时显示）
        SettingItemConfig(
          type: SettingItemType.color,
          titleKey: 'outer_stroke',
          getValue: (settings) => (settings as Settings).heartOuterStrokeColor,
          onUpdate: (context, value) {
            context.read<SettingsProvider>().updateHeartOuterStrokeColor(
              value as String,
            );
          },
          condition: (settings) =>
              (settings as Settings).customPatternPath == null,
        ),
        // 选择自定义图案
        SettingItemConfig(
          type: SettingItemType.custom,
          titleKey: 'select_pattern',
          getValue: (settings) => (settings as Settings).customPatternPath,
          onUpdate: (context, value) {},
          customBuilder: (context, settings, title, getValue) {
            final appLocalizations = AppLocalizations.of(context);
            final language = (settings as Settings).language;
            final customPath = getValue(settings) as String?;
            return SettingItem(
              title: title,
              height: LayoutConstants.settingItemHeight,
              enabled: customPath == null,
              onTap: () => SettingsHelpers.selectImageFile(context),
              trailing: Row(
                children: [
                  if (customPath != null)
                    TextButton(
                      onPressed: () {
                        context
                            .read<SettingsProvider>()
                            .updateCustomPatternPath(null);
                      },
                      child: Text(
                        appLocalizations.t('clear', language),
                        style: AppTextStyles.button,
                      ),
                    )
                  else
                    Text(
                      appLocalizations.t('no_image', language),
                      style: AppTextStyles.button,
                    ),
                ],
              ),
            );
          },
        ),
        // 图案缩放
        SettingItemConfig(
          type: SettingItemType.slider,
          titleKey: 'scale',
          getValue: (settings) => (settings as Settings).patternScale,
          onUpdate: (context, value) {
            context.read<SettingsProvider>().updatePatternScale(
              value as double,
            );
          },
          sliderConfig: const SliderConfig(
            min: SettingsConstants.patternScaleMin,
            max: SettingsConstants.patternScaleMax,
            step: SettingsConstants.patternScaleStep,
            decimalPlaces: SettingsConstants.patternScaleDecimalPlaces,
          ),
        ),
      ],
    );
  }
}
