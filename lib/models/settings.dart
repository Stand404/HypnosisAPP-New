import '../config/app_constants.dart';

/// 动画类型枚举
enum AnimationType {
  ringExpansion, // 圆环扩散
  heartExpansion, // 爱心扩散
  classicSpiral, // 经典螺旋
}

/// 设置数据模型
class Settings {
  final bool isBeating;
  final bool isFullScreen;
  final bool showCenterPattern;
  final String ringColor;
  final String bgColor;
  final String heartOuterFillColor;
  final String heartOuterStrokeColor;
  final String heartInnerStrokeColor;
  final int language; // 0=中文, 1=英文, 2=日文
  final String? customPatternPath;
  final double patternScale;
  final double ringThickness; // 环形动画粗细 1-50
  final double animationSpeed; // 动画速度 0-3
  final double heartBeatSpeed; // 心跳速度 0.1-2
  final double expansionInterval; // 扩散间隔 1-10
  final AnimationType animationType; // 动画类型
  final List<String> heartExpansionColors; // 爱心扩散颜色列表
  final double spiralStrips; // 螺旋条数 1-10
  final double spiralDistortion; // 螺旋扭曲程度 0-1
  
  // 文本显示设置
  final String? displayText; // 显示的文本内容
  final double textSize; // 文本大小
  final double textHorizontalPosition; // 文本水平位置 -1到1 (-1=左, 0=居中, 1=右)
  final double textVerticalPosition; // 文本垂直位置 -1到1 (-1=上, 0=居中, 1=下)
  final String textColor; // 文本颜色

  // 用于区分未提供参数和显式设置为 null 的哨兵值
  static const _unset = Object();

  const Settings({
    this.isBeating = SettingsConstants.defaultIsBeating,
    this.isFullScreen = SettingsConstants.defaultIsFullScreen,
    this.showCenterPattern = SettingsConstants.defaultShowCenterPattern,
    this.ringColor = SettingsConstants.defaultRingColor,
    this.bgColor = SettingsConstants.defaultBgColor,
    this.heartOuterFillColor = SettingsConstants.defaultHeartOuterFillColor,
    this.heartOuterStrokeColor = SettingsConstants.defaultHeartOuterStrokeColor,
    this.heartInnerStrokeColor = SettingsConstants.defaultHeartInnerStrokeColor,
    this.language = SettingsConstants.defaultLanguage,
    this.customPatternPath,
    this.patternScale = SettingsConstants.defaultPatternScale,
    this.ringThickness = SettingsConstants.defaultRingThickness,
    this.animationSpeed = SettingsConstants.defaultAnimationSpeed,
    this.heartBeatSpeed = SettingsConstants.defaultHeartBeatSpeed,
    this.expansionInterval = SettingsConstants.defaultExpansionInterval,
    AnimationType? animationType,
    this.heartExpansionColors = SettingsConstants.defaultHeartExpansionColors,
    this.spiralStrips = SettingsConstants.defaultSpiralStrips,
    this.spiralDistortion = SettingsConstants.defaultSpiralDistortion,
    this.displayText,
    this.textSize = 24.0,
    this.textHorizontalPosition = 0.0,
    this.textVerticalPosition = 0.0,
    this.textColor = '#000000',
  }) : animationType = animationType ?? AnimationType.ringExpansion;

  /// 创建默认设置
  static Settings get defaultSettings => const Settings();

  /// 复制并修改部分属性
  /// 使用 _unset 哨兵值来区分未提供参数和显式设置为 null 的情况
  Settings copyWith({
    bool? isBeating,
    bool? isFullScreen,
    bool? showCenterPattern,
    String? ringColor,
    String? bgColor,
    String? heartOuterFillColor,
    String? heartOuterStrokeColor,
    String? heartInnerStrokeColor,
    int? language,
    Object? customPatternPath = _unset, // 使用哨兵值
    double? patternScale,
    double? ringThickness,
    double? animationSpeed,
    double? heartBeatSpeed,
    double? expansionInterval,
    AnimationType? animationType,
    List<String>? heartExpansionColors,
    double? spiralStrips,
    double? spiralDistortion,
    Object? displayText = _unset, // 使用哨兵值
    double? textSize,
    double? textHorizontalPosition,
    double? textVerticalPosition,
    String? textColor,
  }) {
    return Settings(
      isBeating: isBeating ?? this.isBeating,
      isFullScreen: isFullScreen ?? this.isFullScreen,
      showCenterPattern: showCenterPattern ?? this.showCenterPattern,
      ringColor: ringColor ?? this.ringColor,
      bgColor: bgColor ?? this.bgColor,
      heartOuterFillColor: heartOuterFillColor ?? this.heartOuterFillColor,
      heartOuterStrokeColor: heartOuterStrokeColor ?? this.heartOuterStrokeColor,
      heartInnerStrokeColor: heartInnerStrokeColor ?? this.heartInnerStrokeColor,
      language: language ?? this.language,
      customPatternPath: customPatternPath == _unset 
          ? this.customPatternPath 
          : customPatternPath as String?,
      patternScale: patternScale ?? this.patternScale,
      ringThickness: ringThickness ?? this.ringThickness,
      animationSpeed: animationSpeed ?? this.animationSpeed,
      heartBeatSpeed: heartBeatSpeed ?? this.heartBeatSpeed,
      expansionInterval: expansionInterval ?? this.expansionInterval,
      animationType: animationType ?? this.animationType,
      heartExpansionColors: heartExpansionColors ?? this.heartExpansionColors,
      spiralStrips: spiralStrips ?? this.spiralStrips,
      spiralDistortion: spiralDistortion ?? this.spiralDistortion,
      displayText: displayText == _unset 
          ? this.displayText 
          : displayText as String?,
      textSize: textSize ?? this.textSize,
      textHorizontalPosition: textHorizontalPosition ?? this.textHorizontalPosition,
      textVerticalPosition: textVerticalPosition ?? this.textVerticalPosition,
      textColor: textColor ?? this.textColor,
    );
  }

  /// 将设置转换为 JSON 格式（用于持久化存储）
  Map<String, dynamic> toJson() {
    return {
      'isBeating': isBeating,
      'isFullScreen': isFullScreen,
      'showCenterPattern': showCenterPattern,
      'ringColor': ringColor,
      'bgColor': bgColor,
      'heartOuterFillColor': heartOuterFillColor,
      'heartOuterStrokeColor': heartOuterStrokeColor,
      'heartInnerStrokeColor': heartInnerStrokeColor,
      'language': language,
      'customPatternPath': customPatternPath,
      'patternScale': patternScale,
      'ringThickness': ringThickness,
      'animationSpeed': animationSpeed,
      'heartBeatSpeed': heartBeatSpeed,
      'expansionInterval': expansionInterval,
      'animationType': animationType.index,
      'heartExpansionColors': heartExpansionColors,
      'spiralStrips': spiralStrips,
      'spiralDistortion': spiralDistortion,
      'displayText': displayText,
      'textSize': textSize,
      'textHorizontalPosition': textHorizontalPosition,
      'textVerticalPosition': textVerticalPosition,
      'textColor': textColor,
    };
  }

  /// 从 JSON 格式创建设置
  factory Settings.fromJson(Map<String, dynamic> json) {
    return Settings(
      isBeating: json['isBeating'] as bool? ?? SettingsConstants.defaultIsBeating,
      isFullScreen: json['isFullScreen'] as bool? ?? SettingsConstants.defaultIsFullScreen,
      showCenterPattern: json['showCenterPattern'] as bool? ?? SettingsConstants.defaultShowCenterPattern,
      ringColor: json['ringColor'] as String? ?? SettingsConstants.defaultRingColor,
      bgColor: json['bgColor'] as String? ?? SettingsConstants.defaultBgColor,
      heartOuterFillColor: json['heartOuterFillColor'] as String? ?? SettingsConstants.defaultHeartOuterFillColor,
      heartOuterStrokeColor: json['heartOuterStrokeColor'] as String? ?? SettingsConstants.defaultHeartOuterStrokeColor,
      heartInnerStrokeColor: json['heartInnerStrokeColor'] as String? ?? SettingsConstants.defaultHeartInnerStrokeColor,
      language: json['language'] as int? ?? SettingsConstants.defaultLanguage,
      customPatternPath: json['customPatternPath'] as String?,
      patternScale: (json['patternScale'] as num?)?.toDouble() ?? SettingsConstants.defaultPatternScale,
      ringThickness: (json['ringThickness'] as num?)?.toDouble() ?? SettingsConstants.defaultRingThickness,
      animationSpeed: (json['animationSpeed'] as num?)?.toDouble() ?? SettingsConstants.defaultAnimationSpeed,
      heartBeatSpeed: (json['heartBeatSpeed'] as num?)?.toDouble() ?? SettingsConstants.defaultHeartBeatSpeed,
      expansionInterval: (json['expansionInterval'] as num?)?.toDouble() ?? SettingsConstants.defaultExpansionInterval,
      animationType: json['animationType'] != null
          ? AnimationType.values[(json['animationType'] as int)]
          : AnimationType.ringExpansion,
      heartExpansionColors: (json['heartExpansionColors'] as List<dynamic>?)?.cast<String>() ?? SettingsConstants.defaultHeartExpansionColors,
      spiralStrips: (json['spiralStrips'] as num?)?.toDouble() ?? SettingsConstants.defaultSpiralStrips,
      spiralDistortion: (json['spiralDistortion'] as num?)?.toDouble() ?? SettingsConstants.defaultSpiralDistortion,
      displayText: json['displayText'] as String?,
      textSize: (json['textSize'] as num?)?.toDouble() ?? 24.0,
      textHorizontalPosition: (json['textHorizontalPosition'] as num?)?.toDouble() ?? 0.0,
      textVerticalPosition: (json['textVerticalPosition'] as num?)?.toDouble() ?? 0.0,
      textColor: json['textColor'] as String? ?? '#000000',
    );
  }
}
