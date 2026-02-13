import 'package:flutter/material.dart';
import '../../config/app_constants.dart';
import '../../models/settings.dart';
import '../../i18n/app_localizations.dart';

/// 配置项组件
class ConfigItem extends StatelessWidget {
  final String name;
  final Settings settings;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onViewDetails;
  final VoidCallback onDelete;
  final bool canDelete;

  const ConfigItem({
    super.key,
    required this.name,
    required this.settings,
    required this.isSelected,
    required this.onTap,
    required this.onViewDetails,
    required this.onDelete,
    this.canDelete = true,
  });

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);
    final animationTypeName = _getAnimationTypeName(
      settings.animationType,
      appLocalizations,
    );
    final gifPath = _getGifPath(settings.animationType);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: LayoutConstants.settingItemHeight,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryWith30Opacity
              : AppColors.whiteWith10Opacity,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            // 选中标识 - 选中时显示实心圆，未选中时显示空心圆
            Padding(
              padding: const EdgeInsets.only(left: 8, right: 4),
              child: isSelected
                  ? Icon(
                      Icons.check_circle,
                      color: Color(StyleConstants.primaryColorValue),
                      size: 20,
                    )
                  : Icon(
                      Icons.radio_button_unchecked,
                      color: Colors.white54,
                      size: 20,
                    ),
            ),

          const SizedBox(width: 8),
          // GIF 缩略图
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image.asset(
              gifPath,
              width: 40,
              height: 40,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 40,
                  height: 40,
                  color: AppColors.whiteWith10Opacity,
                  child: Icon(
                    Icons.image_not_supported,
                    color: Colors.white54,
                    size: 20,
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 12),

          // 配置名称和动画类型
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTextStyles.mediumText),
                const SizedBox(height: 2),
                Text(animationTypeName, style: AppTextStyles.label),
              ],
            ),
          ),

          // 查看详情按钮
          IconButton(
            icon: const Icon(Icons.visibility, color: Colors.white),
            onPressed: onViewDetails,
          ),

          // 删除按钮
          if (canDelete)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.white),
              onPressed: onDelete,
            ),
        ],
      ),
      ),
    );
  }

  String _getGifPath(AnimationType animationType) {
    switch (animationType) {
      case AnimationType.ringExpansion:
        return 'assets/gifs/ring_expansion.gif';
      case AnimationType.heartExpansion:
        return 'assets/gifs/heart_expansion.gif';
      case AnimationType.classicSpiral:
        return 'assets/gifs/classic_spiral.gif';
    }
  }

  String _getAnimationTypeName(
    AnimationType type,
    AppLocalizations appLocalizations,
  ) {
    final language = 0; // 需要从外部传入，这里简化处理
    switch (type) {
      case AnimationType.ringExpansion:
        return appLocalizations.t('animation_ring_expansion', language);
      case AnimationType.heartExpansion:
        return appLocalizations.t('animation_heart_expansion', language);
      case AnimationType.classicSpiral:
        return appLocalizations.t('animation_classic_spiral', language);
    }
  }
}
