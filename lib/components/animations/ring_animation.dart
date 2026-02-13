import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../store/settings_provider.dart';
import '../../config/app_constants.dart';
import '../../utils/color_utils.dart';

/// 环形动画组件
class RingAnimation extends StatefulWidget {
  const RingAnimation({super.key});

  @override
  State<RingAnimation> createState() => _RingAnimationState();
}

class _RingAnimationState extends State<RingAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  List<RingData> _rings = [];
  int _nextId = 0;
  late int _lastSpawnTime;

  /// 保存 SettingsProvider 的引用，避免在 dispose 时访问 context
  SettingsProvider? _settingsProvider;

  /// 保存上一次的圆环相关设置，用于检测是否需要重新初始化
  String? _lastRingColor;
  double? _lastRingThickness;
  double? _lastAnimationSpeed;
  double? _lastExpansionInterval;

  /// 在启动时初始化并保存屏幕尺寸
  late double _maxDimension;
  bool _isDimensionInitialized = false;

  /// 动画参数
  int get baseSpawnInterval =>
      ((SettingsConstants.ringSpawnIntervalDivider /
                  context.read<SettingsProvider>().settings.animationSpeed) *
              context.read<SettingsProvider>().settings.expansionInterval)
          .round(); // 毫秒
  double get _baseStroke =>
      context.read<SettingsProvider>().settings.ringThickness;
  // 速度需要乘以倍率
  double get _speed =>
      context.read<SettingsProvider>().settings.animationSpeed *
      SettingsConstants.ringAnimationSpeedMultiplier;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16), // ~60fps
    );
    _lastSpawnTime = DateTime.now().millisecondsSinceEpoch;
    _controller.addListener(_onTick);
    _controller.repeat();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    final settings = context.read<SettingsProvider>();
    
    // 只在第一次初始化时获取屏幕尺寸并初始化圆环
    if (!_isDimensionInitialized) {
      final screenSize = MediaQuery.of(context).size;
      final diagonal = math.sqrt(
        screenSize.width * screenSize.width +
            screenSize.height * screenSize.height,
      );
      _maxDimension = diagonal / 2;
      _isDimensionInitialized = true;
      
      _initializeRings();
      
      // 保存 SettingsProvider 的引用
      _settingsProvider = settings;
      // 保存当前的圆环相关设置
      _lastRingColor = _settingsProvider!.settings.ringColor;
      _lastRingThickness = _settingsProvider!.settings.ringThickness;
      _lastAnimationSpeed = _settingsProvider!.settings.animationSpeed;
      _lastExpansionInterval = _settingsProvider!.settings.expansionInterval;
      // 监听设置变化
      _settingsProvider!.addListener(_onSettingsChanged);
    }
  }

  void _onSettingsChanged() {
    // 使用保存的 _settingsProvider 引用，并检查 widget 是否仍然 mounted
    if (!mounted || _settingsProvider == null) return;
    
    final settings = _settingsProvider!.settings;

    // 只有当圆环相关的设置发生变化时才重新初始化
    if (settings.ringColor != _lastRingColor ||
        settings.ringThickness != _lastRingThickness ||
        settings.animationSpeed != _lastAnimationSpeed ||
        settings.expansionInterval != _lastExpansionInterval) {
      // 更新保存的设置值
      _lastRingColor = settings.ringColor;
      _lastRingThickness = settings.ringThickness;
      _lastAnimationSpeed = settings.animationSpeed;
      _lastExpansionInterval = settings.expansionInterval;

      _initializeRings();
    }
  }

  /// 通知圆环数据已更新（用于触发重绘）
  final _ringsNotifier = ValueNotifier<List<RingData>>([]);

  @override
  Widget build(BuildContext context) {
    _ringsNotifier.value = _rings;
    return RepaintBoundary(
      child: ValueListenableBuilder<List<RingData>>(
        valueListenable: _ringsNotifier,
        builder: (context, rings, _) {
          return _RingAnimationBuilder(rings: rings);
        },
      ),
    );
  }

  @override
  void dispose() {
    // 先停止动画控制器，防止在 dispose 后继续触发 _onTick
    _controller.stop();
    _controller.dispose();
    _ringsNotifier.dispose();
    // 使用保存的 SettingsProvider 引用移除监听器，避免访问已停用的 context
    _settingsProvider?.removeListener(_onSettingsChanged);
    super.dispose();
  }

  /// 初始化圆环
  void _initializeRings() {
    // 使用初始化时保存的尺寸
    final maxRadius = _maxDimension + _baseStroke;
    final currentTime = DateTime.now().millisecondsSinceEpoch;

    // 计算圆环间距（基于生成间隔和速度）
    final ringSpacing = baseSpawnInterval * _speed;

    // 计算初始圆环数量
    final initialCircleCount = (maxRadius / ringSpacing).ceil();

    _rings.clear();

    for (int i = 0; i < initialCircleCount; i++) {
      final initialRadius = (i / initialCircleCount) * maxRadius;
      final startTime = currentTime - (initialRadius / _speed).round();

      _rings.add(
        RingData(
          id: _nextId++,
          radius: initialRadius,
          strokeWidth: _baseStroke * (1 + initialRadius / maxRadius),
          startTime: startTime,
        ),
      );
    }

    _lastSpawnTime = currentTime;
  }

  /// 动画帧回调
  void _onTick() {
    // 检查 widget 是否仍然 mounted，防止在 widget 被停用后继续执行
    if (!mounted) return;
    
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    // 使用初始化时保存的尺寸
    final maxRadius = _maxDimension + _baseStroke;

    // 生成新圆环
    if (currentTime - _lastSpawnTime >= baseSpawnInterval) {
      _rings.add(
        RingData(
          id: _nextId++,
          radius: 0,
          strokeWidth: _baseStroke,
          startTime: currentTime,
        ),
      );
      _lastSpawnTime = currentTime;
    }

    // 更新所有圆环状态
    _rings = _rings.where((ring) {
      // 基于时间计算半径
      final elapsed = currentTime - ring.startTime;
      ring.radius = elapsed * _speed;

      // 超过最大半径移除圆环
      if (ring.radius >= maxRadius) {
        return false;
      }

      // 更新描边宽度
      ring.strokeWidth = _baseStroke * (1 + ring.radius / maxRadius);
      return true;
    }).toList();

    // 使用 ValueNotifier 触发重绘，比 setState 更高效
    _ringsNotifier.value = _rings;
  }
}

/// 圆环数据类
class RingData {
  final int id;
  double radius;
  double strokeWidth;
  final int startTime; // 圆环开始时间（毫秒时间戳）

  RingData({
    required this.id,
    required this.radius,
    required this.strokeWidth,
    required this.startTime,
  });
}

/// 环形动画绘制器
class RingPainter extends CustomPainter {
  final List<RingData> rings;
  final String color;

  RingPainter({
    required this.rings,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 如果没有圆环，直接返回，避免不必要的绘制
    if (rings.isEmpty) {
      return;
    }
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = ColorUtils.parseColor(color);

    for (final ring in rings) {
      paint.strokeWidth = ring.strokeWidth;
      canvas.drawCircle(Offset(centerX, centerY), ring.radius, paint);
    }
  }

  @override
  bool shouldRepaint(RingPainter oldDelegate) {
    // 总是返回 true，因为圆环每帧都在变化
    // 但由于使用了 RepaintBoundary，重绘只会影响这个组件
    return true;
  }
}

/// 环形动画小部件构建器
class _RingAnimationBuilder extends StatelessWidget {
  final List<RingData> rings;

  const _RingAnimationBuilder({required this.rings});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, _) {
        final settings = settingsProvider.settings;

        return CustomPaint(
          size: Size.infinite,
          painter: RingPainter(
            rings: rings,
            color: settings.ringColor,
          ),
        );
      },
    );
  }
}
