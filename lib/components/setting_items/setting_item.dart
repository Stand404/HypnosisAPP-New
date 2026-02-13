import 'package:flutter/material.dart';
import '../../config/app_constants.dart';

/// 通用设置项组件
/// 提供统一的布局和点击反馈效果
class SettingItem extends StatefulWidget {
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool enabled;
  final double height;
  final bool showDivider;
  final bool expandedTrailing;

  const SettingItem({
    super.key,
    required this.title,
    this.trailing,
    this.onTap,
    this.onLongPress,
    this.enabled = true,
    this.height = 50,
    this.showDivider = false,
    this.expandedTrailing = false,
  });

  @override
  State<SettingItem> createState() => _SettingItemState();
}

class _SettingItemState extends State<SettingItem> {
  bool _isPressed = false;

  void _handleTap() {
    if (!widget.enabled) return;

    setState(() {
      _isPressed = true;
    });

    // 延迟后恢复
    Future.delayed(
      Duration(milliseconds: LayoutConstants.panelOpenDelayMs),
      () {
        if (mounted) {
          setState(() {
            _isPressed = false;
          });
        }
      },
    );

    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: _isPressed
              ? AppColors.primaryWith30Opacity
              : AppColors.transparent,
          child: InkWell(
            onTap: widget.enabled ? _handleTap : null,
            hoverColor: Colors.transparent,
            splashColor: Colors.transparent,
            highlightColor: AppColors.primaryWith30Opacity,
            child: Container(
              height: widget.height,
              padding: EdgeInsets.symmetric(
                horizontal: LayoutConstants.largeSpacing,
              ),
              child: widget.trailing != null
                  ? Row(
                      children: widget.expandedTrailing
                          ? [
                              Text(
                                widget.title,
                                style: AppTextStyles.mediumText,
                              ),
                              Expanded(child: widget.trailing!),
                            ]
                          : [
                              Expanded(
                                child: Text(
                                  widget.title,
                                  style: AppTextStyles.mediumText,
                                ),
                              ),
                              widget.trailing!,
                            ],
                    )
                  : Text(widget.title, style: AppTextStyles.mediumText),
            ),
          ),
        ),
        if (widget.showDivider)
          Divider(
            height: 1,
            thickness: 0.5,
            color: AppColors.whiteWith20Opacity,
            indent: 0,
            endIndent: 0,
          ),
      ],
    );
  }
}
