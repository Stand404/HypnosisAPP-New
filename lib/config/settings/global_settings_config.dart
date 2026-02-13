import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/setting_item_config.dart';
import '../../models/settings.dart';
import '../../store/settings_provider.dart';
import '../app_constants.dart';
import '../../i18n/app_localizations.dart';
import '../../components/setting_items/setting_item.dart';

/// 全局设置页面配置
class GlobalSettingsConfig {
  /// 获取全局设置页面配置
  static SettingPageConfig getConfig({
    required VoidCallback onShowConfigPresetsModal,
    required VoidCallback onShowAnimationTypeModal,
  }) {
    return SettingPageConfig(
      titleKey: 'global_settings',
      items: [
        SettingItemConfig(
          type: SettingItemType.switch_,
          titleKey: 'fullscreen',
          getValue: (settings) => (settings as Settings).isFullScreen,
          onUpdate: (context, value) {
            context.read<SettingsProvider>().updateIsFullScreen(value as bool);
          },
        ),
        SettingItemConfig(
          type: SettingItemType.switch_,
          titleKey: 'show_center_pattern',
          getValue: (settings) => (settings as Settings).showCenterPattern,
          onUpdate: (context, value) {
            context.read<SettingsProvider>().updateShowCenterPattern(
              value as bool,
            );
          },
        ),
        SettingItemConfig(
          type: SettingItemType.custom,
          titleKey: 'language',
          getValue: (settings) => (settings as Settings).language,
          onUpdate: (context, value) {},
          customBuilder: (context, settings, title, getValue) {
            final lang = getValue(settings) as int;
            final appLocalizations = AppLocalizations.of(context);
            final language = (settings as Settings).language;
            return SettingItem(
              title: title,
              height: LayoutConstants.settingItemHeight,
              onTap: () {
                int newLanguage = (lang + 1) % SettingsConstants.totalLanguages;
                context.read<SettingsProvider>().updateLanguage(newLanguage);
              },
              trailing: Row(
                children: [
                  Text(
                    appLocalizations.t('self_lang', language),
                    style: AppTextStyles.value16,
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
        SettingItemConfig(
          type: SettingItemType.custom,
          titleKey: 'animation_type',
          getValue: (settings) => (settings as Settings).animationType,
          onUpdate: (context, value) {},
          customBuilder: (context, settings, title, getValue) {
            final animType = getValue(settings) as AnimationType;
            final appLocalizations = AppLocalizations.of(context);
            final language = (settings as Settings).language;
            return SettingItem(
              title: title,
              height: LayoutConstants.settingItemHeight,
              onTap: onShowAnimationTypeModal,
              trailing: Row(
                children: [
                  Text(
                    _getAnimationTypeName(animType, appLocalizations, language),
                    style: AppTextStyles.value16,
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
        // 配置存档入口
        SettingItemConfig(
          type: SettingItemType.custom,
          titleKey: 'config_presets',
          getValue: (settings) => (settings as Settings).language,
          onUpdate: (context, value) {},
          customBuilder: (context, settings, title, getValue) {
            final provider = context.watch<SettingsProvider>();
            final selectedConfig = provider.selectedConfig;
            final appLocalizations = AppLocalizations.of(context);
            final language = (settings as Settings).language;
            
            return SettingItem(
              title: title,
              height: LayoutConstants.settingItemHeight,
              onTap: onShowConfigPresetsModal,
              trailing: Row(
                children: [
                  Text(
                    selectedConfig?.name ?? appLocalizations.t('no_config_selected', language),
                    style: AppTextStyles.value16,
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
      ],
    );
  }

  /// 获取动画类型名称
  static String _getAnimationTypeName(
    AnimationType type,
    AppLocalizations appLocalizations,
    int language,
  ) {
    switch (type) {
      case AnimationType.ringExpansion:
        return appLocalizations.t('animation_ring_expansion', language);
      case AnimationType.heartExpansion:
        return appLocalizations.t('animation_heart_expansion', language);
      case AnimationType.classicSpiral:
        return appLocalizations.t('animation_classic_spiral', language);
    }
  }
}
