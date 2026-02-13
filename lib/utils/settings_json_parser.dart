import 'dart:convert';
import '../models/settings.dart';
import '../models/config_preset.dart';

/// 设置 JSON 解析器工具类
/// 用于解析配置项和输出 JSON 字符串
class SettingsJsonParser {
  /// 解析单个配置存档 JSON 字符串
  /// 
  /// [jsonString] JSON 字符串
  /// 返回 [ConfigPreset] 对象
  /// 如果解析失败，返回 null
  static ConfigPreset? parseConfigPreset(String jsonString) {
    try {
      final dynamic json = jsonDecode(jsonString);
      if (json is Map<String, dynamic>) {
        return ConfigPreset.fromJson(json);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 解析多个配置存档 JSON 字符串列表
  /// 
  /// [jsonStrings] JSON 字符串列表
  /// 返回 [ConfigPreset] 对象列表
  /// 会过滤掉解析失败的项
  static List<ConfigPreset> parseConfigPresetList(List<String> jsonStrings) {
    final List<ConfigPreset> result = [];
    
    for (final jsonString in jsonStrings) {
      final config = parseConfigPreset(jsonString);
      if (config != null) {
        result.add(config);
      }
    }
    
    return result;
  }

  /// 将配置存档转换为 JSON 字符串
  /// 
  /// [config] 配置存档对象
  /// [pretty] 是否格式化输出（默认 true）
  /// 返回 JSON 字符串，如果转换失败返回 null
  static String? configPresetToJson(ConfigPreset config, {bool pretty = true}) {
    try {
      final json = config.toJson();
      if (pretty) {
        return const JsonEncoder.withIndent('  ').convert(json);
      }
      return jsonEncode(json);
    } catch (e) {
      return null;
    }
  }

  /// 将配置存档列表转换为 JSON 字符串列表
  /// 
  /// [configs] 配置存档对象列表
  /// [pretty] 是否格式化输出（默认 true）
  /// 返回 JSON 字符串列表，会过滤掉转换失败的项
  static List<String> configPresetListToJson(
    List<ConfigPreset> configs, {
    bool pretty = true,
  }) {
    final List<String> result = [];
    
    for (final config in configs) {
      final jsonString = configPresetToJson(config, pretty: pretty);
      if (jsonString != null) {
        result.add(jsonString);
      }
    }
    
    return result;
  }

  /// 解析设置 JSON 字符串
  /// 
  /// [jsonString] JSON 字符串
  /// 返回 [Settings] 对象
  /// 如果解析失败，返回 null
  static Settings? parseSettings(String jsonString) {
    try {
      final dynamic json = jsonDecode(jsonString);
      if (json is Map<String, dynamic>) {
        return Settings.fromJson(json);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 将设置转换为 JSON 字符串
  /// 
  /// [settings] 设置对象
  /// [pretty] 是否格式化输出（默认 true）
  /// 返回 JSON 字符串，如果转换失败返回 null
  static String? settingsToJson(Settings settings, {bool pretty = true}) {
    try {
      final json = settings.toJson();
      if (pretty) {
        return const JsonEncoder.withIndent('  ').convert(json);
      }
      return jsonEncode(json);
    } catch (e) {
      return null;
    }
  }

  /// 验证 JSON 字符串是否为有效的配置存档
  /// 
  /// [jsonString] JSON 字符串
  /// 返回 true 表示有效，false 表示无效
  static bool isValidConfigPreset(String jsonString) {
    try {
      final dynamic json = jsonDecode(jsonString);
      if (json is! Map<String, dynamic>) {
        return false;
      }
      
      // 检查必需字段
      if (!json.containsKey('id') || !json.containsKey('name') || !json.containsKey('settings')) {
        return false;
      }
      
      // 验证字段类型
      if (json['id'] is! String || json['name'] is! String || json['settings'] is! Map) {
        return false;
      }
      
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 验证 JSON 字符串是否为有效的设置
  /// 
  /// [jsonString] JSON 字符串
  /// 返回 true 表示有效，false 表示无效
  static bool isValidSettings(String jsonString) {
    try {
      final dynamic json = jsonDecode(jsonString);
      if (json is! Map<String, dynamic>) {
        return false;
      }
      
      // 尝试解析，如果成功则说明有效
      Settings.fromJson(json);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 从 JSON 字符串导入配置（带错误处理）
  /// 
  /// [jsonString] JSON 字符串
  /// 返回包含成功/失败信息和配置对象的结果
  static ({
    bool success,
    String? error,
    ConfigPreset? config,
  }) importConfig(String jsonString) {
    try {
      if (jsonString.isEmpty) {
        return (
          success: false,
          error: 'JSON 字符串为空',
          config: null,
        );
      }

      final config = parseConfigPreset(jsonString);
      if (config == null) {
        return (
          success: false,
          error: 'JSON 格式错误或无效',
          config: null,
        );
      }

      return (
        success: true,
        error: null,
        config: config,
      );
    } catch (e) {
      return (
        success: false,
        error: '导入失败: ${e.toString()}',
        config: null,
      );
    }
  }

  /// 导出配置为 JSON 字符串（带错误处理）
  /// 
  /// [config] 配置存档对象
  /// [pretty] 是否格式化输出
  /// 返回包含成功/失败信息和 JSON 字符串的结果
  static ({
    bool success,
    String? error,
    String? jsonString,
  }) exportConfig(ConfigPreset config, {bool pretty = true}) {
    try {
      final jsonString = configPresetToJson(config, pretty: pretty);
      if (jsonString == null) {
        return (
          success: false,
          error: '导出失败：无法转换为 JSON',
          jsonString: null,
        );
      }

      return (
        success: true,
        error: null,
        jsonString: jsonString,
      );
    } catch (e) {
      return (
        success: false,
        error: '导出失败: ${e.toString()}',
        jsonString: null,
      );
    }
  }

  /// 批量导入配置
  /// 
  /// [jsonStrings] JSON 字符串列表
  /// 返回包含成功导入的配置列表和失败信息的结果
  static ({
    List<ConfigPreset> configs,
    List<String> errors,
  }) importConfigs(List<String> jsonStrings) {
    final List<ConfigPreset> configs = [];
    final List<String> errors = [];

    for (int i = 0; i < jsonStrings.length; i++) {
      final result = importConfig(jsonStrings[i]);
      if (result.success && result.config != null) {
        configs.add(result.config!);
      } else {
        errors.add('配置 ${i + 1}: ${result.error ?? "未知错误"}');
      }
    }

    return (configs: configs, errors: errors);
  }

  /// 批量导出配置
  /// 
  /// [configs] 配置存档列表
  /// [pretty] 是否格式化输出
  /// 返回包含成功导出的 JSON 字符串列表和失败信息的结果
  static ({
    List<String> jsonStrings,
    List<String> errors,
  }) exportConfigs(List<ConfigPreset> configs, {bool pretty = true}) {
    final List<String> jsonStrings = [];
    final List<String> errors = [];

    for (int i = 0; i < configs.length; i++) {
      final result = exportConfig(configs[i], pretty: pretty);
      if (result.success && result.jsonString != null) {
        jsonStrings.add(result.jsonString!);
      } else {
        errors.add('配置 ${i + 1}: ${result.error ?? "未知错误"}');
      }
    }

    return (jsonStrings: jsonStrings, errors: errors);
  }
}
