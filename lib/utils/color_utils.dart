import 'package:flutter/material.dart';

/// 颜色解析工具类
/// 提供将十六进制颜色字符串转换为 Color 对象的工具方法
class ColorUtils {
  /// 解析十六进制颜色字符串为 Color 对象
  /// 
  /// 支持的格式：
  /// - "#RRGGBB" 或 "RRGGBB"
  /// - "#AARRGGBB" 或 "AARRGGBB"
  /// 
  /// 参数:
  /// - [colorString] 十六进制颜色字符串，可以包含或不包含 '#' 前缀
  /// 
  /// 返回:
  /// - Color 对象
  /// 
  /// 示例:
  /// ```dart
  /// ColorUtils.parseColor('#FF0000') // 红色
  /// ColorUtils.parseColor('FF0000')  // 红色
  /// ColorUtils.parseColor('FFFF0000') // 不透明的红色
  /// ```
  static Color parseColor(String colorString) {
    String hexColor = colorString;
    
    // 如果有 # 前缀
    if (hexColor.startsWith('#')) {
      // 移除 # 前缀
      hexColor = hexColor.replaceFirst('#', '');
    }

    // 如果是 6 位十六进制（RGB），添加不透明的 alpha 值
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }

    // 解析十六进制字符串为整数值
    return Color(int.parse(hexColor, radix: 16));
  }
}
