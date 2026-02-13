import 'settings.dart';

/// 配置存档模型
class ConfigPreset {
  final String id;
  final String name;
  final Settings settings;

  ConfigPreset({
    required this.id,
    required this.name,
    required this.settings,
  });

  /// 从 JSON 创建配置存档
  factory ConfigPreset.fromJson(Map<String, dynamic> json) {
    return ConfigPreset(
      id: json['id'] as String,
      name: json['name'] as String,
      settings: Settings.fromJson(json['settings'] as Map<String, dynamic>),
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'settings': settings.toJson(),
    };
  }

  /// 创建副本
  ConfigPreset copyWith({
    String? id,
    String? name,
    Settings? settings,
  }) {
    return ConfigPreset(
      id: id ?? this.id,
      name: name ?? this.name,
      settings: settings ?? this.settings,
    );
  }
}
