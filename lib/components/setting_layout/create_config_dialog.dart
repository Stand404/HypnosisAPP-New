import 'package:flutter/material.dart';
import '../../config/app_constants.dart';
import '../../models/settings.dart';
import '../../i18n/app_localizations.dart';
import '../common/cancel_button.dart';
import '../common/confirm_button.dart';
import '../common/app_modal.dart';

/// 新建配置对话框
class CreateConfigDialog extends StatefulWidget {
  final Function(String name, AnimationType animationType) onCreate;

  const CreateConfigDialog({
    super.key,
    required this.onCreate,
  });

  @override
  State<CreateConfigDialog> createState() => _CreateConfigDialogState();
}

class _CreateConfigDialogState extends State<CreateConfigDialog> {
  late TextEditingController _nameController;
  AnimationType? _selectedAnimationType;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final appLocalizations = AppLocalizations.of(context);
    _nameController = TextEditingController(
      text: appLocalizations.t('my_config', 0),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);

    return AppModal(
      title: appLocalizations.t('create_new_config', 0),
      actions: [
        CancelButton(
          onPressed: () => Navigator.of(context).pop(),
          text: appLocalizations.t('cancel', 0),
        ),
        ConfirmButton(
          onPressed: _handleCreate,
          text: appLocalizations.t('confirm', 0),
        ),
      ],
      child: Column(
        children: [
          // 配置名称输入框
          TextField(
            controller: _nameController,
            style: AppTextStyles.mediumText,
            decoration: InputDecoration(
              labelText: appLocalizations.t('config_name', 0),
              labelStyle: AppTextStyles.label,
            ),
          ),
          const SizedBox(height: 20),

          // 动画类型选择
          Text(
            appLocalizations.t('select_animation_type', 0),
            style: AppTextStyles.mediumText,
          ),
          const SizedBox(height: 12),

          // 动画类型选择器
          _buildAnimationTypeSelector(appLocalizations),
        ],
      ),
    );
  }

  Widget _buildAnimationTypeSelector(AppLocalizations appLocalizations) {
    return Column(
      children: AnimationType.values.map((type) {
        final typeName = _getAnimationTypeName(type, appLocalizations);
        final gifPath = _getGifPath(type);
        final isSelected = _selectedAnimationType == type;

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedAnimationType = type;
            });
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primaryWith30Opacity
                  : AppColors.whiteWith10Opacity,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                // GIF 缩略图
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.asset(
                    gifPath,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 50,
                        height: 50,
                        color: AppColors.whiteWith10Opacity,
                        child: Icon(
                          Icons.image_not_supported,
                          color: Colors.white54,
                          size: 24,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),

                // 动画类型名称
                Expanded(
                  child: Text(
                    typeName,
                    style: AppTextStyles.mediumText,
                  ),
                ),

                // 选中标识
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: Color(StyleConstants.primaryColorValue),
                    size: 24,
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  void _handleCreate() {
    final name = _nameController.text.trim();
    if (name.isNotEmpty && _selectedAnimationType != null) {
      widget.onCreate(name, _selectedAnimationType!);
      Navigator.of(context).pop();
    } else if (_selectedAnimationType == null) {
      // 提示选择动画类型
      final appLocalizations = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            appLocalizations.t('select_animation_type', 0),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
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
    switch (type) {
      case AnimationType.ringExpansion:
        return appLocalizations.t('animation_ring_expansion', 0);
      case AnimationType.heartExpansion:
        return appLocalizations.t('animation_heart_expansion', 0);
      case AnimationType.classicSpiral:
        return appLocalizations.t('animation_classic_spiral', 0);
    }
  }
}
