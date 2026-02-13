import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../store/settings_provider.dart';
import '../../utils/color_utils.dart';
import '../../config/app_constants.dart';

/// 螺旋动画组件
class SpiralAnimation extends StatefulWidget {
  const SpiralAnimation({super.key});

  @override
  State<SpiralAnimation> createState() => _SpiralAnimationState();
}

class _SpiralAnimationState extends State<SpiralAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _rotationAngle = 0;

  final ValueNotifier<double> _rotationNotifier = ValueNotifier<double>(0);

  /// 在启动时初始化并保存屏幕尺寸
  late double _minDimension;
  bool _isDimensionInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16), // ~60fps
    );
    _controller.addListener(_onTick);
    _controller.repeat();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // 只在第一次初始化时获取屏幕尺寸
    if (!_isDimensionInitialized) {
      final screenSize = MediaQuery.of(context).size;
      _minDimension = math.min(screenSize.width, screenSize.height);
      _isDimensionInitialized = true;
    }
  }

  @override
  void dispose() {
    // 先停止动画控制器，防止在 dispose 后继续触发 _onTick
    _controller.stop();
    _controller.dispose();
    _rotationNotifier.dispose();
    super.dispose();
  }

  /// 动画帧回调
  void _onTick() {
    // 检查 widget 是否仍然 mounted，防止在 widget 被停用后继续执行
    if (!mounted) return;

    // 动态获取动画速度，确保设置变化时能立即响应
    final animationSpeed = context
        .read<SettingsProvider>()
        .settings
        .animationSpeed;

    // 旋转速度：基于 animationSpeed，范围 0-3
    // 转换为合适的旋转速度增量
    final rotationSpeed = animationSpeed * 0.003;

    _rotationAngle += rotationSpeed;
    _rotationNotifier.value = _rotationAngle;
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: ValueListenableBuilder<double>(
        valueListenable: _rotationNotifier,
        builder: (context, rotationAngle, _) {
          return _SpiralAnimationBuilder(
            rotationAngle: rotationAngle,
            minDimension: _minDimension,
          );
        },
      ),
    );
  }
}

/// 螺旋动画绘制器
class SpiralPainter extends CustomPainter {
  final double rotationAngle;
  final String color;
  final int spiralCount;
  final double curvature;
  final double ringThickness;
  final double minDimension;

  SpiralPainter({
    required this.rotationAngle,
    required this.color,
    required this.spiralCount,
    required this.curvature,
    required this.ringThickness,
    required this.minDimension,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final lineWidth = ringThickness;

    final centerX = size.width / 2;
    final centerY = size.height / 2;
    // 使用传入的 minDimension 而不是从 size 计算
    final scale = minDimension * 0.45;

    // 根据屏幕大小动态计算最大螺旋长度
    // 避免绘制超出可见区域的部分
    final maxT = _calculateOptimalMaxT(minDimension, scale, curvature);

    // 根据屏幕大小和螺旋数量动态调整步长
    // 大屏幕需要更精细的步长，小屏幕可以使用较大的步长
    final step = _calculateOptimalStep(minDimension, spiralCount);

    // 保存画布状态
    canvas.save();

    // 移动到中心并旋转
    canvas.translate(centerX, centerY);
    canvas.rotate(rotationAngle);

    // 绘制多条螺旋线
    for (int i = 0; i < spiralCount; i++) {
      _drawSpiralWithVariableWidth(
        canvas,
        i,
        spiralCount,
        curvature,
        maxT,
        scale,
        lineWidth,
        color,
        step,
      );
    }

    // 恢复画布状态
    canvas.restore();
  }

  /// 根据屏幕大小计算最优的最大螺旋长度
  double _calculateOptimalMaxT(double screenDimension, double scale, double curvature) {
    // 计算屏幕对角线的一半作为最大可见半径
    final maxVisibleRadius = screenDimension * 0.707; // sqrt(2)/2

    // 根据螺旋方程反推需要的 maxT
    // r = t^(curvature/10) * 0.02 * scale
    // maxT = (maxVisibleRadius / (0.02 * scale))^(10/curvature)
    if (curvature <= 0.1) {
      return 25.0; // 防止除零或过小的曲率
    }

    final baseRadius = 0.02 * scale;
    if (baseRadius <= 0) return 25.0;

    final maxT = math.pow(maxVisibleRadius / baseRadius, 10 / curvature).toDouble();
    
    // 限制在合理范围内
    return maxT.clamp(10.0, 30.0);
  }

  /// 根据屏幕大小和螺旋数量计算最优的步长
  double _calculateOptimalStep(double screenDimension, int spiralCount) {
    // 屏幕越大，步长越小（更精细）
    // 螺旋线越多，步长越大（避免过度渲染）
    
    // 基准步长
    const baseStep = 0.05;
    
    // 屏幕尺寸因子（基于中等屏幕 400px）
    final screenSizeFactor = 400.0 / screenDimension;
    
    // 螺旋数量因子
    final spiralCountFactor = spiralCount / 8.0; // 以8条为基准
    
    // 综合计算步长
    final optimalStep = baseStep * screenSizeFactor * spiralCountFactor;
    
    // 限制在合理范围内
    return optimalStep.clamp(0.03, 0.15);
  }

  /// 绘制具有可变宽度的螺旋线
  void _drawSpiralWithVariableWidth(
    Canvas canvas,
    int spiralIndex,
    int totalSpirals,
    double curvature,
    double maxT,
    double scale,
    double maxLineWidth,
    String color,
    double step,
  ) {
    math.Point<double>? previousPoint;
    
    // 预计算最大距离，避免在循环中重复计算
    final maxDistance = scale * math.pow(maxT, curvature / 10) * 0.02;
    
    for (double t = 0; t < maxT; t += step) {
      final point = _getSpiralPoint(t, spiralIndex, totalSpirals, curvature);
      final screenX = point.x * scale;
      final screenY = point.y * scale;

      if (previousPoint != null) {
        // 计算当前点到中心的距离（用于确定线条宽度）
        final distance = math.sqrt(screenX * screenX + screenY * screenY);
        
        // 计算宽度比例：越靠近中心，宽度越小
        // 使用幂函数使变化更平滑
        double widthRatio = distance / maxDistance;
        widthRatio = widthRatio.clamp(0.0, 1.0);
        
        // 应用缓动函数，使中心附近的宽度变化更自然
        final easedRatio = _easeInOutQuad(widthRatio);
        
        // 计算当前段的线条宽度
        final currentLineWidth = maxLineWidth * easedRatio;

        // 绘制当前线段
        final paint = Paint()
          ..style = PaintingStyle.stroke
          ..color = ColorUtils.parseColor(color)
          ..strokeWidth = currentLineWidth
          ..strokeCap = StrokeCap.round;

        canvas.drawLine(
          Offset(previousPoint.x, previousPoint.y),
          Offset(screenX, screenY),
          paint,
        );
      }

      previousPoint = math.Point(screenX, screenY);
    }
  }

  /// 缓动函数：使宽度变化更平滑
  double _easeInOutQuad(double t) {
    return t < 0.5 ? 2 * t * t : -1 + (4 - 2 * t) * t;
  }

  /// 高曲率螺旋方程
  /// 计算螺旋线上某一点的坐标
  math.Point<double> _getSpiralPoint(
    double t,
    int spiralIndex,
    int totalSpirals,
    double curvature,
  ) {
    // 半径公式：r = t^(curvature/10) * 0.02
    final r = math.pow(t, curvature / 10) * 0.02;

    // 角度偏移：每个螺旋线均匀分布
    final angleOffset = (spiralIndex / totalSpirals) * math.pi * 2;

    // 极坐标转换为笛卡尔坐标
    final x = r * math.cos(t + angleOffset);
    final y = r * math.sin(t + angleOffset);

    return math.Point(x, y);
  }

  @override
  bool shouldRepaint(SpiralPainter oldDelegate) {
    // 总是返回 true，因为旋转角度每帧都在变化
    // 但由于使用了 RepaintBoundary，重绘只会影响这个组件
    return true;
  }
}

/// 螺旋动画小部件构建器
class _SpiralAnimationBuilder extends StatelessWidget {
  final double rotationAngle;
  final double minDimension;

  const _SpiralAnimationBuilder({
    required this.rotationAngle,
    required this.minDimension,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, _) {
        final settings = settingsProvider.settings;

        return CustomPaint(
          size: Size.infinite,
          painter: SpiralPainter(
            rotationAngle: rotationAngle,
            color: settings.ringColor,
            spiralCount: settings.spiralStrips.toInt(),
            curvature: settings.spiralDistortion * SettingsConstants.spiralAnimationSpeedMultiplier,
            ringThickness: settings.ringThickness * SettingsConstants.spiralThicknessMultiplier,
            minDimension: minDimension,
          ),
        );
      },
    );
  }
}
