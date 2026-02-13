import 'dart:convert';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/settings.dart';
import '../models/config_preset.dart';
import '../config/app_constants.dart';
import '../i18n/app_localizations.dart';

/// 设置状态管理类
class SettingsProvider extends ChangeNotifier {
  Settings _settings = Settings.defaultSettings;
  
  /// 配置存档列表
  List<ConfigPreset> _configPresets = [];
  
  /// 当前选中的配置ID
  String? _selectedConfigId;
  
  /// 获取当前设置
  Settings get settings => _settings;
  
  /// 获取配置存档列表
  List<ConfigPreset> get configPresets => _configPresets;
  
  /// 获取当前选中的配置
  ConfigPreset? get selectedConfig {
    if (_selectedConfigId == null) return null;
    try {
      return _configPresets.firstWhere((config) => config.id == _selectedConfigId);
    } catch (e) {
      return null;
    }
  }

  /// 构造函数，加载持久化设置
  SettingsProvider() {
    _loadSettings();
    _loadConfigPresets();
  }

  /// 根据系统语言获取语言索引
  int _getSystemLanguageIndex() {
    final systemLocale = ui.window.locale;
    return AppLocalizations.getLanguageIndex(systemLocale);
  }

  /// 从持久化存储加载设置
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final bool isBeating = prefs.getBool('isBeating') ?? SettingsConstants.defaultIsBeating;
      final bool isFullScreen = prefs.getBool('isFullScreen') ?? SettingsConstants.defaultIsFullScreen;
      final bool showCenterPattern = prefs.getBool('showCenterPattern') ?? SettingsConstants.defaultShowCenterPattern;
      final String ringColor = prefs.getString('ringColor') ?? SettingsConstants.defaultRingColor;
      final String bgColor = prefs.getString('bgColor') ?? SettingsConstants.defaultBgColor;
      final String heartOuterFillColor = prefs.getString('heartOuterFillColor') ?? SettingsConstants.defaultHeartOuterFillColor;
      final String heartOuterStrokeColor = prefs.getString('heartOuterStrokeColor') ?? SettingsConstants.defaultHeartOuterStrokeColor;
      final String heartInnerStrokeColor = prefs.getString('heartInnerStrokeColor') ?? SettingsConstants.defaultHeartInnerStrokeColor;
      final int language = prefs.getInt('language') ?? _getSystemLanguageIndex();
      final String? customPatternPath = prefs.getString('customPatternPath');
      final double patternScale = prefs.getDouble('patternScale') ?? SettingsConstants.defaultPatternScale;
      final double ringThickness = prefs.getDouble('ringThickness') ?? SettingsConstants.defaultRingThickness;
      final double animationSpeed = prefs.getDouble('animationSpeed') ?? SettingsConstants.defaultAnimationSpeed;
      final double heartBeatSpeed = prefs.getDouble('heartBeatSpeed') ?? SettingsConstants.defaultHeartBeatSpeed;
      final double expansionInterval = prefs.getDouble('expansionInterval') ?? SettingsConstants.defaultExpansionInterval;
      final int animationTypeIndex = prefs.getInt('animationType') ?? 0;
      final AnimationType animationType = AnimationType.values[animationTypeIndex.clamp(0, AnimationType.values.length - 1)];
      final List<String> heartExpansionColors = prefs.getStringList('heartExpansionColors') ?? SettingsConstants.defaultHeartExpansionColors;
      final double spiralStrips = prefs.getDouble('spiralStrips') ?? SettingsConstants.defaultSpiralStrips;
      final double spiralDistortion = prefs.getDouble('spiralDistortion') ?? SettingsConstants.defaultSpiralDistortion;
      final String? displayText = prefs.getString('displayText');
      final double textSize = prefs.getDouble('textSize') ?? 24.0;
      final double textHorizontalPosition = prefs.getDouble('textHorizontalPosition') ?? 0.0;
      final double textVerticalPosition = prefs.getDouble('textVerticalPosition') ?? 0.0;
      final String textColor = prefs.getString('textColor') ?? '#000000';

      _settings = Settings(
        isBeating: isBeating,
        isFullScreen: isFullScreen,
        showCenterPattern: showCenterPattern,
        ringColor: ringColor,
        bgColor: bgColor,
        heartOuterFillColor: heartOuterFillColor,
        heartOuterStrokeColor: heartOuterStrokeColor,
        heartInnerStrokeColor: heartInnerStrokeColor,
        language: language,
        customPatternPath: customPatternPath,
        patternScale: patternScale,
        ringThickness: ringThickness,
        animationSpeed: animationSpeed,
        heartBeatSpeed: heartBeatSpeed,
        expansionInterval: expansionInterval,
        animationType: animationType,
        heartExpansionColors: heartExpansionColors,
        spiralStrips: spiralStrips,
        spiralDistortion: spiralDistortion,
        displayText: displayText,
        textSize: textSize,
        textHorizontalPosition: textHorizontalPosition,
        textVerticalPosition: textVerticalPosition,
        textColor: textColor,
      );
      
      // 根据加载的设置自动设置全屏模式
      _applyFullScreenMode(_settings.isFullScreen);
      
      notifyListeners();
    } catch (e) {
      debugPrint('加载设置失败: $e');
      _settings = Settings.defaultSettings;
    }
  }

  /// 更新设置（部分更新）
  void updateSettings(Settings newSettings) {
    _settings = newSettings;
    _saveSettings();
    
    // 如果全屏设置有变化，应用全屏模式
    _applyFullScreenMode(_settings.isFullScreen);
    
    notifyListeners();
  }

  /// 保存设置到持久化存储
  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      await prefs.setBool('isBeating', _settings.isBeating);
      await prefs.setBool('isFullScreen', _settings.isFullScreen);
      await prefs.setBool('showCenterPattern', _settings.showCenterPattern);
      await prefs.setString('ringColor', _settings.ringColor);
      await prefs.setString('bgColor', _settings.bgColor);
      await prefs.setString('heartOuterFillColor', _settings.heartOuterFillColor);
      await prefs.setString('heartOuterStrokeColor', _settings.heartOuterStrokeColor);
      await prefs.setString('heartInnerStrokeColor', _settings.heartInnerStrokeColor);
      await prefs.setInt('language', _settings.language);
      await prefs.setDouble('patternScale', _settings.patternScale);
      await prefs.setDouble('ringThickness', _settings.ringThickness);
      await prefs.setDouble('animationSpeed', _settings.animationSpeed);
      await prefs.setDouble('heartBeatSpeed', _settings.heartBeatSpeed);
      await prefs.setDouble('expansionInterval', _settings.expansionInterval);
      await prefs.setInt('animationType', _settings.animationType.index);
      await prefs.setStringList('heartExpansionColors', _settings.heartExpansionColors);
      await prefs.setDouble('spiralStrips', _settings.spiralStrips);
      await prefs.setDouble('spiralDistortion', _settings.spiralDistortion);
      
      if (_settings.displayText != null) {
        await prefs.setString('displayText', _settings.displayText!);
      } else {
        await prefs.remove('displayText');
      }
      await prefs.setDouble('textSize', _settings.textSize);
      await prefs.setDouble('textHorizontalPosition', _settings.textHorizontalPosition);
      await prefs.setDouble('textVerticalPosition', _settings.textVerticalPosition);
      await prefs.setString('textColor', _settings.textColor);
      
      if (_settings.customPatternPath != null) {
        await prefs.setString('customPatternPath', _settings.customPatternPath!);
      } else {
        await prefs.remove('customPatternPath');
      }
    } catch (e) {
      debugPrint('保存设置失败: $e');
    }
  }

  /// 更新心跳动画状态
  void updateIsBeating(bool value) {
    _settings = _settings.copyWith(isBeating: value);
    _saveSingleSetting('isBeating', value);
    syncToSelectedConfig();
    notifyListeners();
  }

  /// 更新全屏状态
  void updateIsFullScreen(bool value) {
    _settings = _settings.copyWith(isFullScreen: value);
    _saveSingleSetting('isFullScreen', value);
    _applyFullScreenMode(value);
    syncToSelectedConfig();
    notifyListeners();
  }

  /// 更新中心图案显示状态
  void updateShowCenterPattern(bool value) {
    _settings = _settings.copyWith(showCenterPattern: value);
    _saveSingleSetting('showCenterPattern', value);
    syncToSelectedConfig();
    notifyListeners();
  }

  /// 更新环形颜色
  void updateRingColor(String color) {
    _settings = _settings.copyWith(ringColor: color);
    _saveSingleSetting('ringColor', color);
    syncToSelectedConfig();
    notifyListeners();
  }

  /// 更新背景颜色
  void updateBgColor(String color) {
    _settings = _settings.copyWith(bgColor: color);
    _saveSingleSetting('bgColor', color);
    syncToSelectedConfig();
    notifyListeners();
  }

  /// 更新心形外填充颜色
  void updateHeartOuterFillColor(String color) {
    _settings = _settings.copyWith(heartOuterFillColor: color);
    _saveSingleSetting('heartOuterFillColor', color);
    syncToSelectedConfig();
    notifyListeners();
  }

  /// 更新心形外描边颜色
  void updateHeartOuterStrokeColor(String color) {
    _settings = _settings.copyWith(heartOuterStrokeColor: color);
    _saveSingleSetting('heartOuterStrokeColor', color);
    syncToSelectedConfig();
    notifyListeners();
  }

  /// 更新心形内描边颜色
  void updateHeartInnerStrokeColor(String color) {
    _settings = _settings.copyWith(heartInnerStrokeColor: color);
    _saveSingleSetting('heartInnerStrokeColor', color);
    syncToSelectedConfig();
    notifyListeners();
  }

  /// 更新语言
  void updateLanguage(int value) {
    _settings = _settings.copyWith(language: value);
    _saveSingleSetting('language', value);
    syncToSelectedConfig();
    notifyListeners();
  }

  /// 更新自定义图案路径
  void updateCustomPatternPath(String? path) {
    _settings = _settings.copyWith(customPatternPath: path);
    _saveCustomPatternPath(path);
    syncToSelectedConfig();
    notifyListeners();
  }

  /// 更新图案缩放
  void updatePatternScale(double value) {
    _settings = _settings.copyWith(patternScale: value);
    _saveSingleSetting('patternScale', value);
    syncToSelectedConfig();
    notifyListeners();
  }

  /// 更新环形粗细
  void updateRingThickness(double value) {
    _settings = _settings.copyWith(ringThickness: value);
    _saveSingleSetting('ringThickness', value);
    syncToSelectedConfig();
    notifyListeners();
  }

  /// 更新动画速度
  void updateAnimationSpeed(double value) {
    _settings = _settings.copyWith(animationSpeed: value);
    _saveSingleSetting('animationSpeed', value);
    syncToSelectedConfig();
    notifyListeners();
  }

  /// 更新心跳速度
  void updateHeartBeatSpeed(double value) {
    _settings = _settings.copyWith(heartBeatSpeed: value);
    _saveSingleSetting('heartBeatSpeed', value);
    syncToSelectedConfig();
    notifyListeners();
  }

  /// 更新动画类型
  void updateAnimationType(AnimationType value) {
    _settings = _settings.copyWith(animationType: value);
    _saveSingleSetting('animationType', value.index);
    syncToSelectedConfig();
    notifyListeners();
  }

  /// 更新扩散间隔
  void updateExpansionInterval(double value) {
    _settings = _settings.copyWith(expansionInterval: value);
    _saveSingleSetting('expansionInterval', value);
    syncToSelectedConfig();
    notifyListeners();
  }

  /// 更新爱心扩散颜色列表
  void updateHeartExpansionColors(List<String> colors) {
    _settings = _settings.copyWith(heartExpansionColors: colors);
    _saveHeartExpansionColors(colors);
    syncToSelectedConfig();
    notifyListeners();
  }

  /// 更新螺旋条数
  void updateSpiralStrips(double value) {
    _settings = _settings.copyWith(spiralStrips: value);
    _saveSingleSetting('spiralStrips', value);
    syncToSelectedConfig();
    notifyListeners();
  }

  /// 更新螺旋扭曲程度
  void updateSpiralDistortion(double value) {
    _settings = _settings.copyWith(spiralDistortion: value);
    _saveSingleSetting('spiralDistortion', value);
    syncToSelectedConfig();
    notifyListeners();
  }

  /// 保存爱心扩散颜色列表
  Future<void> _saveHeartExpansionColors(List<String> colors) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('heartExpansionColors', colors);
    } catch (e) {
      debugPrint('保存爱心扩散颜色列表失败: $e');
    }
  }

  /// 保存单个设置到持久化存储
  Future<void> _saveSingleSetting(String key, dynamic value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      if (value is bool) {
        await prefs.setBool(key, value);
      } else if (value is String) {
        await prefs.setString(key, value);
      } else if (value is int) {
        await prefs.setInt(key, value);
      } else if (value is double) {
        await prefs.setDouble(key, value);
      }
    } catch (e) {
      debugPrint('保存单个设置失败 ($key): $e');
    }
  }

  /// 保存自定义图案路径（单独处理，因为可以是null）
  Future<void> _saveCustomPatternPath(String? path) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      if (path != null) {
        await prefs.setString('customPatternPath', path);
      } else {
        await prefs.remove('customPatternPath');
      }
    } catch (e) {
      debugPrint('保存自定义图案路径失败: $e');
    }
  }

  /// 重置设置为默认值（保留动画类型）
  void resetSettings() {
    // 保存当前动画类型
    final AnimationType currentAnimationType = _settings.animationType;
    
    // 重置为默认设置
    _settings = Settings.defaultSettings;
    
    // 恢复动画类型
    _settings = _settings.copyWith(animationType: currentAnimationType);
    
    _saveSettings();
    _applyFullScreenMode(_settings.isFullScreen);
    notifyListeners();
  }
  
  /// 应用全屏模式
  void _applyFullScreenMode(bool isFullScreen) {
    try {
      if (isFullScreen) {
        // 进入全屏模式
        SystemChrome.setEnabledSystemUIMode(
          SystemUiMode.immersive,
          overlays: [],
        );
      } else {
        // 退出全屏模式
        SystemChrome.setEnabledSystemUIMode(
          SystemUiMode.edgeToEdge,
        );
      }
    } catch (e) {
      debugPrint('设置全屏模式失败: $e');
    }
  }

  // ========== 配置存档管理 ==========

  /// 根据系统语言获取预设名称
  List<String> _getPresetNames() {
    final systemLocale = ui.window.locale;
    final languageCode = systemLocale.languageCode;
    final countryCode = systemLocale.countryCode;
    
    if (languageCode == 'zh') {
      if (countryCode == 'TW') {
        return ['預設1', '預設2', '預設3'];
      }
      return ['预设1', '预设2', '预设3'];
    } else if (languageCode == 'en') {
      return ['Preset 1', 'Preset 2', 'Preset 3'];
    } else if (languageCode == 'ja') {
      return ['プリセット1', 'プリセット2', 'プリセット3'];
    }
    // 默认中文
    return ['预设1', '预设2', '预设3'];
  }

  /// 加载配置存档
  Future<void> _loadConfigPresets() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final configPresetsJson = prefs.getStringList('configPresets');
      
      if (configPresetsJson != null) {
        _configPresets = configPresetsJson
            .map((json) => ConfigPreset.fromJson(
                  const JsonDecoder().convert(json) as Map<String, dynamic>,
                ))
            .toList();
      } else {
        // 如果没有配置存档，创建3个默认预设配置
        final presetNames = _getPresetNames();
        _configPresets = [
          // 预设1：圆环扩散
          ConfigPreset(
            id: _generateId(),
            name: presetNames[0],
            settings: Settings.defaultSettings.copyWith(
              animationType: AnimationType.ringExpansion,
            ),
          ),
          // 预设2：爱心扩散
          ConfigPreset(
            id: _generateId(),
            name: presetNames[1],
            settings: Settings.defaultSettings.copyWith(
              animationType: AnimationType.heartExpansion,
              showCenterPattern: false
            ),
          ),
          // 预设3：经典螺旋（黑色）
          ConfigPreset(
            id: _generateId(),
            name: presetNames[2],
            settings: Settings.defaultSettings.copyWith(
              animationType: AnimationType.classicSpiral,
              ringColor: '#000000',
              showCenterPattern: false
            ),
          ),
        ];
        await _saveConfigPresets();
      }
      
      // 加载选中的配置ID
      _selectedConfigId = prefs.getString('selectedConfigId');
      
      notifyListeners();
    } catch (e) {
      debugPrint('加载配置存档失败: $e');
      // 创建默认配置
      _configPresets = [
        ConfigPreset(
          id: _generateId(),
          name: '我的配置',
          settings: Settings.defaultSettings,
        ),
      ];
      notifyListeners();
    }
  }

  /// 保存配置存档
  Future<void> _saveConfigPresets() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final configPresetsJson = _configPresets
          .map((config) => const JsonEncoder().convert(config.toJson()))
          .toList();
      await prefs.setStringList('configPresets', configPresetsJson);
      
      // 保存选中的配置ID
      if (_selectedConfigId != null) {
        await prefs.setString('selectedConfigId', _selectedConfigId!);
      } else {
        await prefs.remove('selectedConfigId');
      }
    } catch (e) {
      debugPrint('保存配置存档失败: $e');
    }
  }

  /// 生成唯一ID
  String _generateId() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (i) => random.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  /// 保存当前设置为新配置
  Future<void> saveAsConfig(String name) async {
    final newConfig = ConfigPreset(
      id: _generateId(),
      name: name,
      settings: _settings,
    );
    
    _configPresets.add(newConfig);
    await _saveConfigPresets();
    notifyListeners();
  }

  /// 保存指定设置为新配置（用于新建配置时选择动画类型）
  Future<void> saveAsConfigWithType(String name, Settings settings) async {
    final newConfig = ConfigPreset(
      id: _generateId(),
      name: name,
      settings: settings,
    );
    
    _configPresets.add(newConfig);
    await _saveConfigPresets();
    notifyListeners();
  }

  /// 覆盖现有配置
  Future<void> overwriteConfig(String configId) async {
    final index = _configPresets.indexWhere((config) => config.id == configId);
    if (index != -1) {
      _configPresets[index] = _configPresets[index].copyWith(settings: _settings);
      await _saveConfigPresets();
      notifyListeners();
    }
  }

  /// 加载配置
  Future<void> loadConfig(String configId) async {
    final config = _configPresets.firstWhere(
      (c) => c.id == configId,
      orElse: () => _configPresets.first,
    );
    
    _settings = config.settings;
    _selectedConfigId = configId;
    await _saveSettings();
    await _saveConfigPresets();
    _applyFullScreenMode(_settings.isFullScreen);
    notifyListeners();
  }

  /// 删除配置
  Future<void> deleteConfig(String configId) async {
    // 至少保留一个配置
    if (_configPresets.length <= 1) {
      return;
    }
    
    _configPresets.removeWhere((config) => config.id == configId);
    
    // 如果删除的是当前选中的配置，选中第一个配置
    if (_selectedConfigId == configId) {
      _selectedConfigId = _configPresets.first.id;
    }
    
    await _saveConfigPresets();
    notifyListeners();
  }

  /// 更新配置名称
  Future<void> updateConfigName(String configId, String newName) async {
    final index = _configPresets.indexWhere((config) => config.id == configId);
    if (index != -1) {
      _configPresets[index] = _configPresets[index].copyWith(name: newName);
      await _saveConfigPresets();
      notifyListeners();
    }
  }

  /// 更新显示文本
  void updateDisplayText(String? text) {
    _settings = _settings.copyWith(displayText: text);
    _saveDisplayText(text);
    syncToSelectedConfig();
    notifyListeners();
  }

  /// 更新文本水平位置
  void updateTextHorizontalPosition(double value) {
    _settings = _settings.copyWith(textHorizontalPosition: value);
    _saveSingleSetting('textHorizontalPosition', value);
    syncToSelectedConfig();
    notifyListeners();
  }

  /// 更新文本垂直位置
  void updateTextVerticalPosition(double value) {
    _settings = _settings.copyWith(textVerticalPosition: value);
    _saveSingleSetting('textVerticalPosition', value);
    syncToSelectedConfig();
    notifyListeners();
  }

  /// 更新文本大小
  void updateTextSize(double value) {
    _settings = _settings.copyWith(textSize: value);
    _saveSingleSetting('textSize', value);
    syncToSelectedConfig();
    notifyListeners();
  }

  /// 更新文本颜色
  void updateTextColor(String color) {
    _settings = _settings.copyWith(textColor: color);
    _saveSingleSetting('textColor', color);
    syncToSelectedConfig();
    notifyListeners();
  }

  /// 保存显示文本（单独处理，因为可以是null）
  Future<void> _saveDisplayText(String? text) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      if (text != null) {
        await prefs.setString('displayText', text);
      } else {
        await prefs.remove('displayText');
      }
    } catch (e) {
      debugPrint('保存显示文本失败: $e');
    }
  }

  /// 同步当前设置到选中的配置
  Future<void> syncToSelectedConfig() async {
    if (_selectedConfigId != null) {
      await overwriteConfig(_selectedConfigId!);
    }
  }
}
