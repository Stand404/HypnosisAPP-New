import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'store/settings_provider.dart';
import 'models/settings.dart';
import 'models/setting_item_config.dart';
import 'i18n/app_localizations.dart';
import 'config/app_constants.dart';
import 'config/settings/global_settings_config.dart';
import 'config/settings/text_settings_config.dart';
import 'config/settings/animation_settings_config.dart';
import 'config/settings/pattern_settings_config.dart';
import 'components/setting_layout/setting_pages.dart';
import 'components/setting_layout/animation_type_modal.dart';
import 'components/setting_layout/heart_expansion_colors_modal.dart';
import 'components/setting_layout/config_presets_modal.dart';
import 'components/setting_layout/setting_title.dart';
import 'components/setting_layout/setting_pagination.dart';

/// 弧形底部裁剪器
class _CurvedBottomClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    // 确保尺寸有效，避免负值问题
    final effectiveHeight = size.height.clamp(0.0, double.infinity);
    final offset = LayoutConstants.curvedBottomHeightOffset;
    
    // 计算偏移后的底部位置，确保不小于0
    final bottomY = (effectiveHeight - offset).clamp(0.0, effectiveHeight);
    
    // 从左上角开始
    path.moveTo(0, 0);

    // 画到右上角
    path.lineTo(size.width, 0);

    // 画到右下角（向上偏移指定像素）
    path.lineTo(size.width, bottomY);

    // 使用二次贝塞尔曲线创建弧形，向下方凸出
    path.quadraticBezierTo(
      size.width / 2, // 控制点X（中心）
      effectiveHeight + LayoutConstants.curvedBottomControlPointYOffset, // 控制点Y（向下凸出指定像素）
      0, // 终点X
      bottomY, // 终点Y（向上偏移指定像素）
    );

    // 闭合路径
    path.close();

    return path;
  }

  @override
  bool shouldReclip(_CurvedBottomClipper oldClipper) => false;
}

/// 设置面板组件
class SettingPanel extends StatefulWidget {
  const SettingPanel({super.key});

  @override
  State<SettingPanel> createState() => _SettingPanelState();
}

class _SettingPanelState extends State<SettingPanel>
    with TickerProviderStateMixin {
  bool _isOpen = false;
  int _currentPage = 0;
  double _startY = 0;
  double _currentY = 0;
  final double _threshold = LayoutConstants.gestureThreshold;

  bool _isConfigPresetsModalVisible = false;
  late AnimationController _configPresetsModalController;
  late Animation<double> _configPresetsModalAnimation;

  bool _isAnimationTypeModalVisible = false;
  late AnimationController _animationTypeModalController;
  late Animation<double> _animationTypeModalAnimation;

  bool _isHeartExpansionColorsModalVisible = false;
  late AnimationController _heartExpansionColorsModalController;
  late Animation<double> _heartExpansionColorsModalAnimation;

  late AnimationController _elasticController;
  late Animation<double> _elasticAnimation;
  bool _isAnimating = false;

  late List<AnimationController> _slideControllers;
  late List<Animation<Offset>> _slideAnimations;

  @override
  void initState() {
    super.initState();
    _configPresetsModalController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _configPresetsModalAnimation = CurvedAnimation(
      parent: _configPresetsModalController,
      curve: Curves.easeInOut,
    );

    _animationTypeModalController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _animationTypeModalAnimation = CurvedAnimation(
      parent: _animationTypeModalController,
      curve: Curves.easeInOut,
    );

    _heartExpansionColorsModalController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _heartExpansionColorsModalAnimation = CurvedAnimation(
      parent: _heartExpansionColorsModalController,
      curve: Curves.easeInOut,
    );

    _elasticController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    
    // 使用 TweenSequence 实现拉伸 -> 保持 -> 弹性恢复的效果
    _elasticAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.2).chain(
          CurveTween(curve: Curves.easeOut),
        ),
        weight: 60.0,
      ),
      TweenSequenceItem(
        tween: ConstantTween<double>(1.2), // 保持拉伸状态
        weight: 20.0,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.2, end: 1.0).chain(
          CurveTween(curve: Cubic(0.34, 1.56, 0.64, 1.0)),
        ),
        weight: 60.0,
      ),
    ]).animate(_elasticController);

    // 初始化滑动动画控制器
    _slideControllers = List.generate(8, (index) {
      return AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 200),
      );
    });

    _slideAnimations = _slideControllers.map((controller) {
      return Tween<Offset>(
        begin: const Offset(1.0, 0.0), // 从右侧滑入（屏幕外）
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: controller,
          curve: Curves.fastOutSlowIn,
        ),
      );
    }).toList();

    // 默认播放第一页的动画
    _playSlideAnimations();
  }

  @override
  void dispose() {
    _configPresetsModalController.dispose();
    _animationTypeModalController.dispose();
    _heartExpansionColorsModalController.dispose();
    _elasticController.dispose();
    for (var controller in _slideControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _goToPreviousPage() {
    final settings = context.read<SettingsProvider>().settings;
    final actualTotalPages = _getActualTotalPages(settings);
    setState(() {
      _currentPage = _currentPage > 0 ? _currentPage - 1 : actualTotalPages - 1;
    });
    _playSlideAnimations();
  }

  void _goToNextPage() {
    final settings = context.read<SettingsProvider>().settings;
    final actualTotalPages = _getActualTotalPages(settings);
    setState(() {
      _currentPage = _currentPage < actualTotalPages - 1 ? _currentPage + 1 : 0;
    });
    _playSlideAnimations();
  }

  int _getActualTotalPages(Settings settings) {
    // 总是至少有3页（全局设置、动画设置、文本设置）
    // 如果显示中心图案，则有4页（增加中心设置）
    return settings.showCenterPattern ? 4 : 3;
  }

  void _playSlideAnimations() {
    // 重置所有动画
    for (var controller in _slideControllers) {
      controller.reset();
    }

    // 根据当前页面计算需要播放的动画数量
    int itemCount = _getCurrentPageItemCount();

    // 依次播放动画，每个延迟150ms
    for (int i = 0; i < itemCount; i++) {
      Future.delayed(Duration(milliseconds: i * 150), () {
        if (mounted) {
          _slideControllers[i].forward();
        }
      });
    }
  }

  int _getCurrentPageItemCount() {
    final settings = context.read<SettingsProvider>().settings;
    SettingPageConfig? config;
    
    switch (_currentPage) {
      case 0:
        config = GlobalSettingsConfig.getConfig(
          onShowConfigPresetsModal: () {},
          onShowAnimationTypeModal: () {},
        );
        break;
      case 1:
        config = AnimationSettingsConfig.getConfig();
        break;
      case 2:
        config = TextSettingsConfig.getConfig();
        break;
      case 3:
        config = PatternSettingsConfig.getConfig();
        break;
      default:
        return 0;
    }
    
    // 计算满足条件的设置项数量
    return config.items.where((item) {
      return item.condition == null || item.condition!(settings);
    }).length;
  }

  void showConfigPresetsModal() {
    setState(() {
      _isConfigPresetsModalVisible = true;
    });
    _configPresetsModalController.forward();
  }

  void _hideConfigPresetsModal() {
    _configPresetsModalController.reverse().then((_) {
      if (mounted) {
        setState(() {
          _isConfigPresetsModalVisible = false;
        });
      }
    });
  }

  void showAnimationTypeModal() {
    setState(() {
      _isAnimationTypeModalVisible = true;
    });
    _animationTypeModalController.forward();
  }

  void _hideAnimationTypeModal() {
    _animationTypeModalController.reverse().then((_) {
      if (mounted) {
        setState(() {
          _isAnimationTypeModalVisible = false;
        });
      }
    });
  }

  void showHeartExpansionColorsModal() {
    setState(() {
      _isHeartExpansionColorsModalVisible = true;
    });
    _heartExpansionColorsModalController.forward();
  }

  void _hideHeartExpansionColorsModal() {
    _heartExpansionColorsModalController.reverse().then((_) {
      if (mounted) {
        setState(() {
          _isHeartExpansionColorsModalVisible = false;
        });
      }
    });
  }

  void _openPanelWithElastic() {
    if (_isAnimating) return; // 防止重复触发
    
    setState(() {
      _isOpen = true;
      _isAnimating = true;
    });
    
    _elasticController.reset();
    _elasticController.forward().then((_) {
      if (mounted) {
        setState(() {
          _isAnimating = false;
        });
      }
    });
    
    // 延迟后触发配置项的滑动动画
    Future.delayed(Duration(milliseconds: LayoutConstants.panelOpenDelayMs), () {
      if (mounted) {
        _playSlideAnimations();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, _) {
        final settings = settingsProvider.settings;
        final appLocalizations = AppLocalizations.of(context);

        // 如果当前页面超出实际总页数，自动跳转到最后一页
        final actualTotalPages = _getActualTotalPages(settings);
        if (_currentPage >= actualTotalPages) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _currentPage = actualTotalPages - 1;
              });
            }
          });
        }

        return Stack(
          children: [
            // 透明全屏遮罩 - 用于接收滑动手势
            _buildTransparentOverlay(),

            // 设置面板 - 半透明黑色
            _buildDrawer(settings, appLocalizations),

            // 配置存档模态框 - 独立在 Stack 上层
            if (_isConfigPresetsModalVisible)
              ConfigPresetsModal(
                animation: _configPresetsModalAnimation,
                onCancel: _hideConfigPresetsModal,
              ),

            // 动画类型选择模态框 - 独立在 Stack 上层
            if (_isAnimationTypeModalVisible)
              AnimationTypeModal(
                animation: _animationTypeModalAnimation,
                onCancel: _hideAnimationTypeModal,
              ),

            // 爱心扩散颜色列表模态框 - 独立在 Stack 上层
            if (_isHeartExpansionColorsModalVisible)
              HeartExpansionColorsModal(
                animation: _heartExpansionColorsModalAnimation,
                onCancel: _hideHeartExpansionColorsModal,
              ),
          ],
        );
      },
    );
  }

  Widget _buildDrawer(Settings settings, AppLocalizations appLocalizations) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: AnimatedBuilder(
        animation: _elasticAnimation,
        builder: (context, child) {
          return Transform.scale(
            scaleY: _elasticAnimation.value,
            alignment: Alignment.topCenter,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              transform: Matrix4.translationValues(
                0,
                _isOpen ? 0 : -MediaQuery.of(context).size.height,
                0,
              ),
              child: ClipPath(
                clipper: _CurvedBottomClipper(),
                child: Container(
                  decoration: BoxDecoration(color: Color(LayoutConstants.panelBackgroundColorAlpha)),
                  constraints: BoxConstraints(
                    maxHeight: (MediaQuery.of(context).size.height - LayoutConstants.curvedBottomHeightOffset * 2).clamp(
                      MediaQuery.of(context).size.height * 0.5,
                      MediaQuery.of(context).size.height,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: LayoutConstants.titleSpacing),
                      // 标题部分
                      const SettingTitle(),

                      // 分页标题和切换按钮
                      SettingPagination(
                        currentPage: _currentPage,
                        totalPages: _getActualTotalPages(settings),
                        onPreviousPage: _goToPreviousPage,
                        onNextPage: _goToNextPage,
                      ),

                      // 设置内容 - 使用 Flexible 包裹 AnimatedSize 实现高度自适应
                      Flexible(
                        child: Padding(
                          padding: EdgeInsets.only(bottom: LayoutConstants.curvedBottomHeightOffset),
                          child: AnimatedSize(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOutCubic,
                            child: SingleChildScrollView(
                              physics: const ClampingScrollPhysics(),
                              padding: EdgeInsets.zero,
                              child: _buildPageContent(settings, appLocalizations),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPageContent(
    Settings settings,
    AppLocalizations appLocalizations,
  ) {
    return buildPageContent(
      _currentPage,
      settings,
      appLocalizations,
      context,
      _buildAnimatedItem,
      onShowConfigPresetsModal: showConfigPresetsModal,
      onShowAnimationTypeModal: showAnimationTypeModal,
      onShowHeartExpansionColorsModal: showHeartExpansionColorsModal,
    );
  }

  Widget _buildTransparentOverlay() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      bottom: 0,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onVerticalDragStart: (details) {
          _startY = details.globalPosition.dy;
          _currentY = _startY;
        },
        onVerticalDragUpdate: (details) {
          _currentY = details.globalPosition.dy;
        },
        onVerticalDragEnd: (details) {
          final diffY = _currentY - _startY;

          // 未打开时下滑超过阈值打开（带弹性动画）
          if (!_isOpen && diffY > _threshold) {
            _openPanelWithElastic();
          }
          // 已打开时上滑超过阈值关闭
          else if (_isOpen && diffY < -_threshold) {
            setState(() {
              _isOpen = false;
            });
          }
        },
      ),
    );
  }

  Widget _buildAnimatedItem({
    required int index,
    required Widget child,
  }) {
    if (index >= _slideAnimations.length) {
      return child;
    }

    return SlideTransition(
      position: _slideAnimations[index],
      child: child,
    );
  }
}
