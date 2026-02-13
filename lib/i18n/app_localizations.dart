import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

/// 应用国际化基础类
class AppLocalizations {
  final Locale locale;
  
  late Map<String, String> _localizedStrings;

  AppLocalizations(this.locale);

  /// 支持的语言列表
  static const List<Locale> supportedLocales = [
    Locale('zh'), // 中文简体
    Locale('zh', 'TW'), // 中文繁体
    Locale('en'), // 英文
    Locale('ja'), // 日文
  ];

  /// 从 locale 获取对应的语言索引
  /// 0 = 中文简体, 1 = 中文繁体, 2 = 英文, 3 = 日文
  static int getLanguageIndex(Locale locale) {
    if (locale.languageCode == 'zh') {
      if (locale.countryCode == 'TW') {
        return 1; // 繁体中文
      }
      return 0; // 简体中文
    }
    switch (locale.languageCode) {
      case 'en':
        return 2;
      case 'ja':
        return 3;
      default:
        return 0;
    }
  }

  /// 辅助方法：从语言索引获取翻译
  String translate(int languageIndex, String key) {
    return _localizedStrings[key] ?? key;
  }

  /// 获取翻译文本
  String t(String key, int languageIndex) {
    return translate(languageIndex, key);
  }

  /// 静态方法，用于在构建时访问
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  /// 加载本地化资源
  static Future<AppLocalizations> load(Locale locale) async {
    final AppLocalizations localizations = AppLocalizations(locale);
    
    // 加载对应的语言文件
    String jsonString;
    if (locale.languageCode == 'zh') {
      if (locale.countryCode == 'TW') {
        jsonString = await rootBundle.loadString('lib/i18n/app_localizations_zh_TW.json');
      } else {
        jsonString = await rootBundle.loadString('lib/i18n/app_localizations_zh.json');
      }
    } else {
      switch (locale.languageCode) {
        case 'en':
          jsonString = await rootBundle.loadString('lib/i18n/app_localizations_en.json');
          break;
        case 'ja':
          jsonString = await rootBundle.loadString('lib/i18n/app_localizations_ja.json');
          break;
        default:
          jsonString = await rootBundle.loadString('lib/i18n/app_localizations_zh.json');
          break;
      }
    }
    
    Map<String, dynamic> jsonMap = json.decode(jsonString);
    localizations._localizedStrings = jsonMap.map((key, value) {
      return MapEntry(key, value.toString());
    });
    
    return localizations;
  }

  /// 国际化代理
  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();
}

/// 国际化代理类
class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    if (locale.languageCode == 'zh' && locale.countryCode == 'TW') {
      return true;
    }
    return ['zh', 'en', 'ja'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations.load(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
