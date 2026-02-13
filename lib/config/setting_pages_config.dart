/// 设置页面配置导出文件
/// 
/// 此文件将所有设置页面配置统一导出，便于外部引用
/// 各个具体设置页面的配置已拆分到 settings 目录下的独立文件中：
/// - global_settings_config.dart: 全局设置
/// - text_settings_config.dart: 文本设置
/// - animation_settings_config.dart: 动画设置
/// - pattern_settings_config.dart: 中心图案设置
/// - settings_helpers.dart: 辅助工具类
/// 
/// 使用示例：
/// ```dart
/// import 'package:your_app/config/setting_pages_config.dart';
/// 
/// // 使用全局设置配置
/// final config = GlobalSettingsConfig.getConfig(...);
/// 
/// // 使用文本设置配置
/// final textConfig = TextSettingsConfig.getConfig();
/// 
/// // 使用动画设置配置
/// final animConfig = AnimationSettingsConfig.getConfig(...);
/// 
/// // 使用图案设置配置
/// final patternConfig = PatternSettingsConfig.getConfig();
/// ```

// 导出各个设置配置类
export 'settings/global_settings_config.dart';
export 'settings/text_settings_config.dart';
export 'settings/animation_settings_config.dart';
export 'settings/pattern_settings_config.dart';
export 'settings/settings_helpers.dart';
