import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../store/settings_provider.dart';
import '../../models/settings.dart';
import '../../i18n/app_localizations.dart';
import '../../config/app_constants.dart';
import '../common/cancel_button.dart';
import '../common/confirm_button.dart';
import '../common/app_modal.dart';

// 导出 AppColors 以便使用
export '../../config/app_constants.dart' show AppColors;

/// 动画类型选择模态框组件
/// 显示三种动画类型供用户选择
class AnimationTypeModal extends StatefulWidget {
  final Animation<double> animation;
  final VoidCallback onCancel;

  const AnimationTypeModal({
    super.key,
    required this.animation,
    required this.onCancel,
  });

  @override
  State<AnimationTypeModal> createState() => _AnimationTypeModalState();
}

class _AnimationTypeModalState extends State<AnimationTypeModal> {
  AnimationType? _tempSelectedType;

  @override
  void initState() {
    super.initState();
    // 初始化临时选择为当前设置的类型
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settingsProvider = context.read<SettingsProvider>();
      setState(() {
        _tempSelectedType = settingsProvider.settings.animationType;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, _) {
        final settings = settingsProvider.settings;
        final appLocalizations = AppLocalizations.of(context);

        return _buildAnimationTypeModal(
          settings,
          appLocalizations,
          settingsProvider,
          context,
        );
      },
    );
  }

  Widget _buildAnimationTypeModal(
    Settings settings,
    AppLocalizations appLocalizations,
    SettingsProvider settingsProvider,
    BuildContext context,
  ) {
    return FadeTransition(
      opacity: widget.animation,
      child: AppModal(
        title: appLocalizations.t('animation_type', settings.language),
        actions: [
          CancelButton(
            onPressed: widget.onCancel,
            text: appLocalizations.t('cancel', settings.language),
            horizontalPadding: 30,
          ),
          ConfirmButton(
            onPressed: () {
              if (_tempSelectedType != null) {
                settingsProvider.updateAnimationType(_tempSelectedType!);
              }
              widget.onCancel();
            },
            text: appLocalizations.t('confirm', settings.language),
            horizontalPadding: 30,
          ),
        ],
        child: Column(
          children: [
            _buildAnimationTypeItem(
              context,
              settings,
              settingsProvider,
              AnimationType.ringExpansion,
              _getRingExpansionPreview(),
              appLocalizations.t('animation_ring_expansion', settings.language),
              [
                appLocalizations.t('ring_thickness', settings.language),
                appLocalizations.t('ring_color', settings.language),
              ],
            ),
            const SizedBox(height: 15),
            _buildAnimationTypeItem(
              context,
              settings,
              settingsProvider,
              AnimationType.heartExpansion,
              _getHeartExpansionPreview(),
              appLocalizations.t(
                'animation_heart_expansion',
                settings.language,
              ),
              [appLocalizations.t('param_color_list', settings.language)],
            ),
            const SizedBox(height: 15),
            _buildAnimationTypeItem(
              context,
              settings,
              settingsProvider,
              AnimationType.classicSpiral,
              _getClassicSpiralPreview(),
              appLocalizations.t('animation_classic_spiral', settings.language),
              [
                appLocalizations.t('ring_thickness', settings.language),
                appLocalizations.t('ring_color', settings.language),
                appLocalizations.t('param_spiral_count', settings.language),
                appLocalizations.t('param_twist_degree', settings.language),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimationTypeItem(
    BuildContext context,
    Settings settings,
    SettingsProvider settingsProvider,
    AnimationType type,
    Widget preview,
    String title,
    List<String> params,
  ) {
    final isSelected = _tempSelectedType == type;

    return GestureDetector(
      onTap: () {
        setState(() {
          _tempSelectedType = type;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryWith30Opacity
              : AppColors.transparent,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            // 左侧圆角预览图
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.primaryWith20Opacity,
                ),
                child: Center(child: preview),
              ),
            ),
            const SizedBox(width: 15),
            // 右侧名称和参数列表
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.button),
                  const SizedBox(height: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: params
                        .map(
                          (param) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              children: [
                                Container(
                                  width: 4,
                                  height: 4,
                                  margin: const EdgeInsets.only(right: 8),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    param,
                                    style: AppTextStyles.label,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 获取圆环扩散预览
  Widget _getRingExpansionPreview() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.asset(
        'assets/gifs/ring_expansion.gif',
        width: 60,
        height: 60,
        fit: BoxFit.cover,
      ),
    );
  }

  /// 获取爱心扩散预览
  Widget _getHeartExpansionPreview() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.asset(
        'assets/gifs/heart_expansion.gif',
        width: 60,
        height: 60,
        fit: BoxFit.cover,
      ),
    );
  }

  /// 获取经典螺旋预览
  Widget _getClassicSpiralPreview() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.asset(
        'assets/gifs/classic_spiral.gif',
        width: 60,
        height: 60,
        fit: BoxFit.cover,
      ),
    );
  }
}
