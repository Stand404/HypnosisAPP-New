import 'package:flutter/material.dart';
import '../../config/app_constants.dart';

/// 通用对话框组件
/// 统一的对话框样式，带有弹性打开动画
class AppModal extends StatefulWidget {
  /// 标题（String 类型，自动应用 title20 样式）
  final String? title;

  /// 标题（Widget 类型，自定义样式）
  final Widget? titleWidget;

  /// 内容组件
  final Widget child;

  /// 操作按钮列表
  final List<Widget>? actions;

  /// 圆角半径
  final BorderRadius? borderRadius;

  /// 背景颜色
  final Color? backgroundColor;

  const AppModal({
    super.key,
    this.title,
    this.titleWidget,
    this.actions,
    this.borderRadius,
    this.backgroundColor,
    required this.child,
  });

  @override
  State<AppModal> createState() => _AppModalState();
}

class _AppModalState extends State<AppModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // 创建柔和的缩放动画：使用平滑的缓动曲线
    _scaleAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    // 启动动画
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 默认圆角
    final modalBorderRadius = widget.borderRadius ?? BorderRadius.circular(16);

    // 默认背景色
    final modalBackgroundColor =
        widget.backgroundColor ?? AppColors.blackWith90Opacity;

    // 默认内容内边距
    const defaultContentPadding = EdgeInsets.symmetric(
      horizontal: LayoutConstants.largeSpacing,
    );

    // 默认标题区域内边距
    const titlePadding = EdgeInsets.fromLTRB(
      LayoutConstants.largeSpacing,
      20,
      LayoutConstants.largeSpacing,
      8,
    );

    // 默认操作按钮区域内边距
    const defaultActionsPadding = EdgeInsets.fromLTRB(
      LayoutConstants.largeSpacing,
      8,
      LayoutConstants.largeSpacing,
      LayoutConstants.largeSpacing,
    );

    // 计算标题组件
    Widget? titleContent;
    if (widget.titleWidget != null) {
      titleContent = widget.titleWidget;
    } else if (widget.title != null) {
      titleContent = Padding(
        padding: titlePadding,
        child: Text(widget.title!, style: AppTextStyles.title20),
      );
    }

    // 构建主体内容
    Widget bodyContent;

    if (widget.actions != null && widget.actions!.isNotEmpty) {
      // 有操作按钮时：内容可滚动，按钮固定在底部
      bodyContent = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 标题区域
          if (titleContent != null) titleContent,
          // 内容区域，可滚动
          Flexible(
            child: SingleChildScrollView(
              padding: defaultContentPadding,
              child: widget.child,
            ),
          ),
          // 操作按钮区域，固定在底部（支持多行布局）
          Padding(
            padding: defaultActionsPadding,
            child: Wrap(
              spacing: LayoutConstants.largeSpacing,
              runSpacing: LayoutConstants.largeSpacing,
              alignment: WrapAlignment.end,
              children: widget.actions!,
            ),
          ),
        ],
      );
    } else {
      // 没有操作按钮
      bodyContent = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 标题区域
          if (titleContent != null) titleContent,
          // 内容区域
          Flexible(
            child: SingleChildScrollView(
              padding: defaultContentPadding,
              child: widget.child,
            ),
          ),
        ],
      );
    }

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Dialog(
        backgroundColor: modalBackgroundColor,
        shape: RoundedRectangleBorder(borderRadius: modalBorderRadius),
        insetPadding: const EdgeInsets.all(LayoutConstants.largeSpacing),
        child: bodyContent,
      ),
    );
  }
}
