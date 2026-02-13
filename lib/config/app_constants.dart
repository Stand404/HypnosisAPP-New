import 'package:flutter/material.dart';

/// 应用常量配置文件
/// 集中管理所有常量，包括默认值、范围、步长等

/// 设置项常量配置
class SettingsConstants {
  // ==================== 布尔类型设置 ====================
  static const bool defaultIsBeating = true;
  static const bool defaultIsFullScreen = true;
  static const bool defaultShowCenterPattern = true;

  // ==================== 语言设置 ====================
  static const int defaultLanguage = 0;
  static const int totalLanguages = 4; // 语言总数

  // ==================== 颜色设置 ====================
  static const String defaultRingColor = '#EF36CD';
  static const String defaultBgColor = '#FFFFFF';
  static const String defaultHeartOuterFillColor = '#FFFFFF';
  static const String defaultHeartOuterStrokeColor = '#A500A1';
  static const String defaultHeartInnerStrokeColor = '#EF36CD';

  // ==================== 数值设置配置 ====================

  /// 圆环粗细配置
  static const double defaultRingThickness = 20.0;
  static const double ringThicknessMin = 1.0;
  static const double ringThicknessMax = 50.0;
  static const double ringThicknessStep = 1.0;
  static const int ringThicknessDecimalPlaces = 0;
  static const int spiralThicknessMultiplier = 4; // 螺旋宽度倍率

  /// 动画速度配置
  static const double defaultAnimationSpeed = 5.0;
  static const double animationSpeedMin = 0.0;
  static const double animationSpeedMax = 10.0;
  static const double animationSpeedStep = 0.1;
  static const int animationSpeedDecimalPlaces = 1;
  static const double ringAnimationSpeedMultiplier = 0.02; // 环形动画速度倍率
  static const double heartAnimationSpeedMultiplier = 0.0002; // 心扩散动画速度倍率
  static const double spiralAnimationSpeedMultiplier = 50; // 螺旋动画速度倍率
  // 生成间隔基数（毫秒），用于计算实际间隔：xxx / animationSpeed * expansionInterval
  // 已包含除以5的系数
  static const int ringSpawnIntervalDivider = 570; // 2800 / 5
  static const int heartSpawnIntervalDivider = 600; // 3000 / 5

  /// 心跳速度配置
  static const double defaultHeartBeatSpeed = 5.0;
  static const double heartBeatSpeedMin = 0.1;
  static const double heartBeatSpeedMax = 10;
  static const double heartBeatSpeedStep = 0.1;
  static const int heartBeatSpeedDecimalPlaces = 1;
  static const double heartBeatSpeedMultiplier = 0.2; // 心跳动画倍率

  /// 扩散间隔配置
  static const double defaultExpansionInterval = 5.0;
  static const double expansionIntervalMin = 1.0;
  static const double expansionIntervalMax = 10.0;
  static const double expansionIntervalStep = 1.0;
  static const int expansionIntervalDecimalPlaces = 0;

  /// 爱心扩散颜色列表配置
  static const List<String> defaultHeartExpansionColors = [
    '#EF36CD',
    '#EE95D6',
    '#FADFF5',
  ];

  /// 螺旋条数配置
  static const double defaultSpiralStrips = 6.0;
  static const double spiralStripsMin = 1.0;
  static const double spiralStripsMax = 10.0;
  static const double spiralStripsStep = 1.0;
  static const int spiralStripsDecimalPlaces = 0;

  /// 螺旋扭曲程度配置
  static const double defaultSpiralDistortion = 0.45;
  static const double spiralDistortionMin = 0.0;
  static const double spiralDistortionMax = 1.0;
  static const double spiralDistortionStep = 0.01;
  static const int spiralDistortionDecimalPlaces = 2;

  /// 图案缩放配置
  static const double defaultPatternScale = 1.0;
  static const double patternScaleMin = 0.0;
  static const double patternScaleMax = 3.0;
  static const double patternScaleStep = 0.01;
  static const int patternScaleDecimalPlaces = 2;
  static const double patternScaleMultiplier = 0.6; // 图案缩放倍率
}

/// UI 布局常量配置
class LayoutConstants {
  /// 弧形底部配置
  static const double curvedBottomHeightOffset = 30.0;
  static const double curvedBottomControlPointYOffset = 30.0;

  /// 面板配置
  static const double panelBottomPadding = 50.0;
  static const double panelTopPadding = 20.0;
  static const double titleSpacing = 24.0;

  /// 手势阈值
  static const double gestureThreshold = 50.0;

  /// 设置项高度
  static const double settingItemHeight = 50.0;

  /// 面板背景色（半透明黑色）- ARGB格式：0x99000000 = alpha=0x99(60%), RGB=0x000000(黑色)
  static const int panelBackgroundColorAlpha = 0x99000000;

  /// 面板打开延迟（用于触发滑动动画）
  static const int panelOpenDelayMs = 100;

  /// 分页配置
  static const int totalPages = 3;

  /// 间距配置
  static const double smallSpacing = 4.0;
  static const double mediumSpacing = 12.0;
  static const double largeSpacing = 16.0;
  static const double extraLargeSpacing = 20.0;

  /// 数值显示宽度
  static const double valueDisplayWidth = 50.0;
}

/// 字体和颜色常量配置
class StyleConstants {
  /// 主要颜色
  static const int primaryColorValue = 0xFFEF36CD;

  /// 滑块样式
  static const double sliderActiveTrackOpacity = 1.0;
  static const double sliderInactiveTrackOpacity = 0.3;
  static const double sliderOverlayOpacity = 0.3;

  /// 图标大小
  static const double iconSize = 20.0;
}

/// 图片选择配置
class ImagePickerConstants {
  /// 图片质量
  static const int imageQuality = 100; // 最高质量，获取原图
}

/// 应用颜色常量配置
/// 集中管理所有重复使用的颜色
class AppColors {
  /// 黑色半透明 - 用于模态框背景
  static final blackWith90Opacity = Colors.black.withOpacity(0.9);

  /// 白色半透明 - 用于装饰背景
  static final whiteWith10Opacity = Colors.white.withOpacity(0.1);
  static final whiteWith20Opacity = Colors.white.withOpacity(0.2);

  /// 主题色半透明 - 用于交互效果
  static final primaryWith20Opacity = const Color(
    StyleConstants.primaryColorValue,
  ).withOpacity(0.2);
  static final primaryWith30Opacity = const Color(
    StyleConstants.primaryColorValue,
  ).withOpacity(0.3);
  static final primaryWith50Opacity = const Color(
    StyleConstants.primaryColorValue,
  ).withOpacity(0.5);

  /// 标题颜色半透明 - 用于禁用状态
  static final titleWith50Opacity = Colors.white.withOpacity(0.5);

  /// 透明颜色
  static const transparent = Colors.transparent;
}

/// 应用文本样式常量配置
/// 按字体大小和粗细分组，只在颜色不同时创建独立样式
class AppTextStyles {
  // ==================== 24号 Bold ====================
  /// 大标题 - 用于模态框标题
  static const title = TextStyle(
    color: Colors.white,
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  // ==================== 20号 W600 ====================
  /// 分页标题
  static final title20 = TextStyle(
    color: Colors.white,
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );

  // ==================== 16号 ====================
  /// 按钮文本
  static const button = TextStyle(
    color: Colors.white,
    fontSize: 16
  );

  // 正文 - 设置项标签、窗口描述文字
  static const mediumText = TextStyle(color: Colors.white, fontSize: 16);

  /// 主题色数值
  static final value16 = TextStyle(
    color: const Color(StyleConstants.primaryColorValue),
    fontSize: 16,
  );

  /// 错误文本
  static const error = TextStyle(color: Colors.red, fontSize: 16);

  // ==================== 12号 ====================
  /// 普通标签
  static const label = TextStyle(color: Colors.white70, fontSize: 12);

  /// 主题色标签 - 作者官网链接
  static final labelPrimary = TextStyle(
    color: const Color(StyleConstants.primaryColorValue),
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );
}

/// 所有常量的统一入口
class AppConstants {
  static final settings = SettingsConstants();
  static final layout = LayoutConstants();
  static final style = StyleConstants();
  static final imagePicker = ImagePickerConstants();
  static final colors = AppColors();
  static final textStyles = AppTextStyles();
}
