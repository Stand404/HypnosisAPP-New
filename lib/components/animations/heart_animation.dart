import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../store/settings_provider.dart';
import '../../config/app_constants.dart';
import '../../utils/color_utils.dart';

/// 心形扩散动画组件
/// 参考ring_animation.dart的实现模式，但使用心形形状
class HeartAnimation extends StatefulWidget {
  const HeartAnimation({super.key});

  @override
  State<HeartAnimation> createState() => _HeartAnimationState();
}

class _HeartAnimationState extends State<HeartAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  List<HeartData> _hearts = [];
  int _nextId = 0;
  late int _lastSpawnTime;
  int _colorIndex = 0; // 用于轮换颜色

  /// 保存 SettingsProvider 的引用，避免在 dispose 时访问 context
  SettingsProvider? _settingsProvider;

  /// 保存上一次的设置，用于检测是否需要重新初始化
  List<String>? _lastHeartExpansionColors;
  double? _lastAnimationSpeed;
  double? _lastExpansionInterval;

  /// 在启动时初始化并保存屏幕尺寸
  late double _maxDimension;
  bool _isDimensionInitialized = false;

  /// 动画参数
  int get baseSpawnInterval =>
      ((SettingsConstants.heartSpawnIntervalDivider /
              context.read<SettingsProvider>().settings.animationSpeed) *
          context.read<SettingsProvider>().settings.expansionInterval)
          .round();

  // 速度需要乘以倍率（与ring_animation一致）
  double get _speed =>
      context.read<SettingsProvider>().settings.animationSpeed *
      SettingsConstants.heartAnimationSpeedMultiplier;

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
    
    // 只在第一次初始化时获取屏幕尺寸并初始化心形
    if (!_isDimensionInitialized) {
      final screenSize = MediaQuery.of(context).size;
      _maxDimension = math.max(screenSize.width, screenSize.height);
      _isDimensionInitialized = true;
      
      _initializeHearts();
      
      // 保存 SettingsProvider 的引用
      _settingsProvider = settings;
      // 保存当前的设置
      _lastHeartExpansionColors = _settingsProvider!.settings.heartExpansionColors;
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

    // 只有当相关的设置发生变化时才重新初始化
    if (_lastHeartExpansionColors == null ||
        !_listEquals(_lastHeartExpansionColors!, settings.heartExpansionColors) ||
        settings.animationSpeed != _lastAnimationSpeed ||
        settings.expansionInterval != _lastExpansionInterval) {
      // 更新保存的设置值
      _lastHeartExpansionColors = settings.heartExpansionColors;
      _lastAnimationSpeed = settings.animationSpeed;
      _lastExpansionInterval = settings.expansionInterval;

      _initializeHearts();
    }
  }

  /// 比较两个列表是否相等
  bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  /// 获取当前应该使用的颜色（轮流切换）
  String _getCurrentColor() {
    final settings = context.read<SettingsProvider>().settings;
    final colors = settings.heartExpansionColors;
    return colors[_colorIndex % colors.length];
  }

  /// 通知心形数据已更新（用于触发重绘）
  final _heartsNotifier = ValueNotifier<List<HeartData>>([]);

  @override
  Widget build(BuildContext context) {
    _heartsNotifier.value = _hearts;
    return RepaintBoundary(
      child: ValueListenableBuilder<List<HeartData>>(
        valueListenable: _heartsNotifier,
        builder: (context, hearts, _) {
          return _HeartAnimationBuilder(hearts: hearts);
        },
      ),
    );
  }

  @override
  void dispose() {
    // 先停止动画控制器，防止在 dispose 后继续触发 _onTick
    _controller.stop();
    _controller.dispose();
    _heartsNotifier.dispose();
    // 使用保存的 SettingsProvider 引用移除监听器，避免访问已停用的 context
    _settingsProvider?.removeListener(_onSettingsChanged);
    super.dispose();
  }

  /// 初始化心形
  void _initializeHearts() {
    // 使用初始化时保存的尺寸
    final maxDimension = _maxDimension;
    final maxScale = (maxDimension * 3) / 400; // 400是基础心形大小
    final currentTime = DateTime.now().millisecondsSinceEpoch;

    // 计算心形间距（基于生成间隔和速度）
    final heartSpacing = baseSpawnInterval * _speed;

    // 计算初始心形数量
    final initialHeartCount = (maxScale / heartSpacing).ceil();

    _hearts.clear();

    for (int i = initialHeartCount - 1; i >= 0; i--) {
      final initialScale = (i / initialHeartCount) * maxScale;
      final startTime = currentTime - (initialScale / _speed).round();

      _hearts.add(
        HeartData(
          id: _nextId++,
          scale: initialScale,
          startTime: startTime,
          color: _getCurrentColor(),
        ),
      );

      // 每创建一个心形，切换到下一个颜色
      _colorIndex++;
    }

    _lastSpawnTime = currentTime;
  }

  /// 动画帧回调
  void _onTick() {
    // 检查 widget 是否仍然 mounted，防止在 widget 被停用后继续执行
    if (!mounted) return;
    
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    // 使用初始化时保存的尺寸
    final maxDimension = _maxDimension;
    final maxScale = (maxDimension * 3) / 400;

    // 生成新心形
    if (currentTime - _lastSpawnTime >= baseSpawnInterval) {
      _hearts.add(
        HeartData(
          id: _nextId++,
          scale: 0,
          startTime: currentTime,
          color: _getCurrentColor(),
        ),
      );
      _lastSpawnTime = currentTime;

      // 每创建一个心形，切换到下一个颜色
      _colorIndex++;
    }

    // 更新所有心形状态
    _hearts = _hearts.where((heart) {
      // 基于时间计算缩放（与 ring_animation 一致）
      final elapsed = currentTime - heart.startTime;
      heart.scale = elapsed * _speed;

      // 超过最大缩放移除心形
      if (heart.scale >= maxScale) {
        return false;
      }

      return true;
    }).toList();

    // 使用 ValueNotifier 触发重绘，比 setState 更高效
    _heartsNotifier.value = _hearts;
  }
}

/// 心形数据类
class HeartData {
  final int id;
  double scale;
  final int startTime; // 心形开始时间（毫秒时间戳）
  final String color; // 心形颜色

  HeartData({
    required this.id,
    required this.scale,
    required this.startTime,
    required this.color,
  });
}

/// 心形动画绘制器
class HeartPainter extends CustomPainter {
  final List<HeartData> hearts;

  HeartPainter({required this.hearts});

  @override
  void paint(Canvas canvas, Size size) {
    // 如果没有心形，直接返回，避免不必要的绘制
    if (hearts.isEmpty) {
      return;
    }

    final centerX = size.width / 2;
    final centerY = size.height / 2;

    for (final heart in hearts) {
      // 使用每个心形自己的颜色
      final paint = Paint()
        ..style = PaintingStyle.fill
        ..color = ColorUtils.parseColor(heart.color);

      // 保存当前画布状态
      canvas.save();

      // 移动到中心并缩放
      canvas.translate(centerX, centerY);
      canvas.scale(heart.scale);
      canvas.translate(-centerX, -centerY);

      // 绘制心形路径
      final heartPath = _createHeartPath(centerX, centerY);
      canvas.drawPath(heartPath, paint);

      // 恢复画布状态
      canvas.restore();
    }
  }

  /// 创建心形路径
  Path _createHeartPath(double centerX, double centerY) {
    final path = Path();
    final scale = 400 / 500; // 基础缩放，使心形适应400x400的区域

    path.moveTo(250.23 * scale + centerX - 200, 148.82 * scale + centerY - 200);
    path.cubicTo(
      247.38 * scale + centerX - 200,
      144.59 * scale + centerY - 200,
      215.17 * scale + centerX - 200,
      98.43 * scale + centerY - 200,
      165.77 * scale + centerX - 200,
      100.04 * scale + centerY - 200,
    );
    path.cubicTo(
      119.30 * scale + centerX - 200,
      101.55 * scale + centerY - 200,
      87.04 * scale + centerX - 200,
      144.37 * scale + centerY - 200,
      78.14 * scale + centerX - 200,
      173.73 * scale + centerY - 200,
    );
    path.cubicTo(
      58.28 * scale + centerX - 200,
      239.24 * scale + centerY - 200,
      125.75 * scale + centerX - 200,
      333.15 * scale + centerY - 200,
      251.29 * scale + centerX - 200,
      400.00 * scale + centerY - 200,
    );
    path.cubicTo(
      374.63 * scale + centerX - 200,
      333.64 * scale + centerY - 200,
      440.99 * scale + centerX - 200,
      240.34 * scale + centerY - 200,
      421.24 * scale + centerX - 200,
      175.77 * scale + centerY - 200,
    );
    path.cubicTo(
      412.63 * scale + centerX - 200,
      147.18 * scale + centerY - 200,
      381.78 * scale + centerX - 200,
      104.42 * scale + centerY - 200,
      335.72 * scale + centerX - 200,
      102.08 * scale + centerY - 200,
    );
    path.cubicTo(
      286.00 * scale + centerX - 200,
      98.55 * scale + centerY - 200,
      252.92 * scale + centerX - 200,
      144.93 * scale + centerY - 200,
      250.23 * scale + centerX - 200,
      148.82 * scale + centerY - 200,
    );
    path.close();

    return path;
  }

  @override
  bool shouldRepaint(HeartPainter oldDelegate) {
    // 总是返回 true，因为心形每帧都在变化
    // 但由于使用了 RepaintBoundary，重绘只会影响这个组件
    return true;
  }
}

/// 心形动画小部件构建器
class _HeartAnimationBuilder extends StatelessWidget {
  final List<HeartData> hearts;

  const _HeartAnimationBuilder({required this.hearts});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: HeartPainter(hearts: hearts),
    );
  }
}
