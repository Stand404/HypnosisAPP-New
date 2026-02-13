import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../store/settings_provider.dart';
import '../../config/app_constants.dart';
import '../../utils/color_utils.dart';
import '../../i18n/app_localizations.dart';

/// 心形相关设置的辅助类
@immutable
class _HeartSettings {
  final bool isBeating;
  final double heartBeatSpeed;
  final String heartOuterFillColor;
  final String heartOuterStrokeColor;
  final String heartInnerStrokeColor;
  final String? customPatternPath;
  final double patternScale;

  const _HeartSettings({
    required this.isBeating,
    required this.heartBeatSpeed,
    required this.heartOuterFillColor,
    required this.heartOuterStrokeColor,
    required this.heartInnerStrokeColor,
    required this.customPatternPath,
    required this.patternScale,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _HeartSettings &&
          runtimeType == other.runtimeType &&
          isBeating == other.isBeating &&
          heartBeatSpeed == other.heartBeatSpeed &&
          heartOuterFillColor == other.heartOuterFillColor &&
          heartOuterStrokeColor == other.heartOuterStrokeColor &&
          heartInnerStrokeColor == other.heartInnerStrokeColor &&
          customPatternPath == other.customPatternPath &&
          patternScale == other.patternScale;

  @override
  int get hashCode =>
      isBeating.hashCode ^
      heartBeatSpeed.hashCode ^
      heartOuterFillColor.hashCode ^
      heartOuterStrokeColor.hashCode ^
      heartInnerStrokeColor.hashCode ^
      customPatternPath.hashCode ^
      patternScale.hashCode;
}

/// 跳动的心组件
class BeatingHeart extends StatefulWidget {
  const BeatingHeart({super.key});

  @override
  State<BeatingHeart> createState() => _BeatingHeartState();
}

class _BeatingHeartState extends State<BeatingHeart>
    with TickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _scaleAnimation;
  double _lastHeartBeatSpeed = 0.0;

  @override
  void initState() {
    super.initState();
    final settings = context.read<SettingsProvider>().settings;
    _lastHeartBeatSpeed = settings.heartBeatSpeed * SettingsConstants.heartBeatSpeedMultiplier;
    _createAnimation(_lastHeartBeatSpeed);
  }

  /// 创建新的动画控制器和动画
  void _createAnimation(double heartBeatSpeed) {
    _controller?.dispose();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: (600 / heartBeatSpeed).round()),
    );

    // 创建正弦波动画
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(parent: _controller!, curve: Curves.easeInOut));

    _controller!.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Selector<SettingsProvider, _HeartSettings>(
        selector: (context, settingsProvider) {
          final settings = settingsProvider.settings;
          return _HeartSettings(
            isBeating: settings.isBeating,
            heartBeatSpeed: settings.heartBeatSpeed,
            heartOuterFillColor: settings.heartOuterFillColor,
            heartOuterStrokeColor: settings.heartOuterStrokeColor,
            heartInnerStrokeColor: settings.heartInnerStrokeColor,
            customPatternPath: settings.customPatternPath,
            patternScale: settings.patternScale,
          );
        },
        builder: (context, heartSettings, _) {
          // 检测心跳速度变化
          if (_lastHeartBeatSpeed != heartSettings.heartBeatSpeed) {
            _lastHeartBeatSpeed = heartSettings.heartBeatSpeed * SettingsConstants.heartBeatSpeedMultiplier;
            _createAnimation(_lastHeartBeatSpeed);
          }

          // 如果关闭心跳动画，显示静态图案
          if (!heartSettings.isBeating) {
            return Transform.scale(
              scale: heartSettings.patternScale * SettingsConstants.patternScaleMultiplier,
              child: Center(
                child: SizedBox(
                  width: 400,
                  height: 400,
                  child: heartSettings.customPatternPath != null
                      ? _CustomImageHeart(
                          imagePath: heartSettings.customPatternPath!,
                        )
                      : _SvgHeart(
                          outerFillColor: heartSettings.heartOuterFillColor,
                          outerStrokeColor: heartSettings.heartOuterStrokeColor,
                          innerStrokeColor: heartSettings.heartInnerStrokeColor,
                        ),
                ),
              ),
            );
          }

          // 如果开启心跳动画，显示动画
          if (_scaleAnimation != null && _controller != null) {
            return AnimatedBuilder(
              key: ValueKey(heartSettings.heartBeatSpeed),
              animation: _scaleAnimation!,
              builder: (context, child) {
                final scale =
                    heartSettings.patternScale * SettingsConstants.patternScaleMultiplier * _scaleAnimation!.value;

                return Transform.scale(
                  scale: scale,
                  child: Center(
                    child: SizedBox(
                      width: 400,
                      height: 400,
                      child: heartSettings.customPatternPath != null
                          ? _CustomImageHeart(
                              imagePath: heartSettings.customPatternPath!,
                            )
                          : _SvgHeart(
                              outerFillColor: heartSettings.heartOuterFillColor,
                              outerStrokeColor: heartSettings.heartOuterStrokeColor,
                              innerStrokeColor: heartSettings.heartInnerStrokeColor,
                            ),
                    ),
                  ),
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

/// SVG 心形组件
class _SvgHeart extends StatelessWidget {
  final String outerFillColor;
  final String outerStrokeColor;
  final String innerStrokeColor;

  const _SvgHeart({
    required this.outerFillColor,
    required this.outerStrokeColor,
    required this.innerStrokeColor,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(400, 400),
      painter: _HeartPainter(
        outerFillColor: ColorUtils.parseColor(outerFillColor),
        outerStrokeColor: ColorUtils.parseColor(outerStrokeColor),
        innerStrokeColor: ColorUtils.parseColor(innerStrokeColor),
      ),
    );
  }
}

/// 心形绘制器
class _HeartPainter extends CustomPainter {
  final Color outerFillColor;
  final Color outerStrokeColor;
  final Color innerStrokeColor;

  _HeartPainter({
    required this.outerFillColor,
    required this.outerStrokeColor,
    required this.innerStrokeColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 500;

    // 心形路径数据

    // 外层心形
    final outerPath = Path();
    outerPath.moveTo(250.23 * scale, 148.82 * scale);
    // 简化的心形路径
    outerPath.cubicTo(
      247.38 * scale,
      144.59 * scale,
      215.17 * scale,
      98.43 * scale,
      165.77 * scale,
      100.04 * scale,
    );
    outerPath.cubicTo(
      119.30 * scale,
      101.55 * scale,
      87.04 * scale,
      144.37 * scale,
      78.14 * scale,
      173.73 * scale,
    );
    outerPath.cubicTo(
      58.28 * scale,
      239.24 * scale,
      125.75 * scale,
      333.15 * scale,
      251.29 * scale,
      400.00 * scale,
    );
    outerPath.cubicTo(
      374.63 * scale,
      333.64 * scale,
      440.99 * scale,
      240.34 * scale,
      421.24 * scale,
      175.77 * scale,
    );
    outerPath.cubicTo(
      412.63 * scale,
      147.18 * scale,
      381.78 * scale,
      104.42 * scale,
      335.72 * scale,
      102.08 * scale,
    );
    outerPath.cubicTo(
      286.00 * scale,
      98.55 * scale,
      252.92 * scale,
      144.93 * scale,
      250.23 * scale,
      148.82 * scale,
    );
    outerPath.close();

    // 绘制外层描边
    final outerStrokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 80 * scale
      ..color = outerStrokeColor
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(outerPath, outerStrokePaint);

    // 绘制内层填充和描边
    final innerPath = Path();
    innerPath.moveTo(250.52 * scale, 148.82 * scale);
    innerPath.cubicTo(
      247.67 * scale,
      144.59 * scale,
      215.46 * scale,
      98.43 * scale,
      165.06 * scale,
      100.04 * scale,
    );
    innerPath.cubicTo(
      118.59 * scale,
      101.55 * scale,
      86.33 * scale,
      144.37 * scale,
      77.43 * scale,
      173.73 * scale,
    );
    innerPath.cubicTo(
      57.57 * scale,
      239.24 * scale,
      125.04 * scale,
      333.15 * scale,
      251.58 * scale,
      400.00 * scale,
    );
    innerPath.cubicTo(
      374.92 * scale,
      333.64 * scale,
      441.26 * scale,
      240.34 * scale,
      421.51 * scale,
      175.77 * scale,
    );
    innerPath.cubicTo(
      412.90 * scale,
      147.18 * scale,
      381.72 * scale,
      104.42 * scale,
      335.66 * scale,
      102.08 * scale,
    );
    innerPath.cubicTo(
      286.29 * scale,
      98.55 * scale,
      253.21 * scale,
      144.93 * scale,
      250.52 * scale,
      148.82 * scale,
    );
    innerPath.close();

    // 绘制内层填充
    final innerFillPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = outerFillColor;
    canvas.drawPath(innerPath, innerFillPaint);

    // 绘制内层描边
    final innerStrokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 40 * scale
      ..color = innerStrokeColor
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(innerPath, innerStrokePaint);
  }

  @override
  bool shouldRepaint(_HeartPainter oldDelegate) {
    return outerFillColor != oldDelegate.outerFillColor ||
        outerStrokeColor != oldDelegate.outerStrokeColor ||
        innerStrokeColor != oldDelegate.innerStrokeColor;
  }
}

/// 自定义图片心形
class _CustomImageHeart extends StatelessWidget {
  final String imagePath;

  const _CustomImageHeart({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);
    final settings = context.watch<SettingsProvider>().settings;
    final language = settings.language;
    
    return Image.file(
      File(imagePath),
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Center(
          child: Text(
            appLocalizations.t('load_image_failed', language),
            style: AppTextStyles.error,
          ),
        );
      },
    );
  }
}
