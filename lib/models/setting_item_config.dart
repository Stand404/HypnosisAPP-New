import 'package:flutter/material.dart';

/// 设置项类型枚举
enum SettingItemType {
  switch_,
  slider,
  color,
  custom,
}

/// 滑块配置
class SliderConfig {
  final double min;
  final double max;
  final double step;
  final int decimalPlaces;

  const SliderConfig({
    required this.min,
    required this.max,
    required this.step,
    required this.decimalPlaces,
  });
}

/// 设置项配置模型
class SettingItemConfig {
  /// 设置项类型
  final SettingItemType type;
  
  /// 设置项标题的国际化 key
  final String titleKey;
  
  /// 设置值的获取函数（从 Settings 中获取当前值）
  final dynamic Function(dynamic settings) getValue;
  
  /// 设置值的更新函数（更新 SettingsProvider）
  final void Function(BuildContext context, dynamic value) onUpdate;
  
  /// 可选：滑块配置（仅当 type 为 slider 时使用）
  final SliderConfig? sliderConfig;
  
  /// 可选：条件显示函数（返回 true 时显示该设置项）
  final bool Function(dynamic settings)? condition;
  
  /// 可选：自定义构建函数（用于自定义类型的设置项）
  final Widget Function(
    BuildContext context,
    dynamic settings,
    String title,
    dynamic Function(dynamic) getValue,
  )? customBuilder;

  const SettingItemConfig({
    required this.type,
    required this.titleKey,
    required this.getValue,
    required this.onUpdate,
    this.sliderConfig,
    this.condition,
    this.customBuilder,
  });
}

/// 设置页面配置
class SettingPageConfig {
  /// 页面标题的国际化 key
  final String titleKey;
  
  /// 页面包含的所有设置项
  final List<SettingItemConfig> items;

  const SettingPageConfig({
    required this.titleKey,
    required this.items,
  });
}
