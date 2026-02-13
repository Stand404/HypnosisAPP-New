import 'package:flutter/material.dart';
import '../../config/app_constants.dart';
import 'package:provider/provider.dart';
import '../../store/settings_provider.dart';
import '../../i18n/app_localizations.dart';
import '../../utils/color_utils.dart';
import '../common/color_picker_dialog.dart';
import '../common/cancel_button.dart';
import '../common/confirm_button.dart';
import '../common/app_modal.dart';

/// 爱心扩散颜色列表管理模态框
class HeartExpansionColorsModal extends StatefulWidget {
  final Animation<double> animation;
  final VoidCallback onCancel;

  const HeartExpansionColorsModal({
    super.key,
    required this.animation,
    required this.onCancel,
  });

  @override
  State<HeartExpansionColorsModal> createState() =>
      _HeartExpansionColorsModalModalState();
}

class _HeartExpansionColorsModalModalState
    extends State<HeartExpansionColorsModal> {
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.animation,
      builder: (context, child) {
        return Opacity(opacity: widget.animation.value, child: child);
      },
      child: _buildModal(context),
    );
  }

  Widget _buildModal(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, _) {
        final settings = settingsProvider.settings;
        final appLocalizations = AppLocalizations.of(context);
        final colors = settings.heartExpansionColors;

        return AppModal(
          title: appLocalizations.t('param_color_list', settings.language),
          actions: [
            // 添加颜色按钮
            ConfirmButton(
              onPressed: () => _addColor(context, settingsProvider),
              text: appLocalizations.t('add', settings.language),
              horizontalPadding: 20,
            ),
            // 关闭按钮
            CancelButton(
              onPressed: widget.onCancel,
              text: appLocalizations.t('close', settings.language),
              horizontalPadding: 20,
            ),
          ],
          child: Column(
            children: colors.asMap().entries.map((entry) {
              final index = entry.key;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildColorItem(
                  context,
                  settingsProvider,
                  colors,
                  index,
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildColorItem(
    BuildContext context,
    SettingsProvider settingsProvider,
    List<String> colors,
    int index,
  ) {
    return Container(
      height: LayoutConstants.settingItemHeight,
      decoration: BoxDecoration(
        color: AppColors.whiteWith10Opacity,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // 序号
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text('${index + 1}', style: AppTextStyles.mediumText),
          ),

          // 颜色预览和选择器
          Expanded(
            child: GestureDetector(
              onTap: () => _editColor(context, settingsProvider, index),
              child: Container(
                height: double.infinity,
                color: Colors.transparent,
                child: Row(
                  children: [
                    // 颜色预览
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Color(
                          int.parse(colors[index].replaceAll('#', '0xFF')),
                        ),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // 颜色值
                    Text(colors[index], style: AppTextStyles.mediumText),
                  ],
                ),
              ),
            ),
          ),

          // 删除按钮
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white),
            onPressed: () => _deleteColor(context, settingsProvider, index),
          ),
        ],
      ),
    );
  }

  void _addColor(BuildContext context, SettingsProvider settingsProvider) {
    final settings = settingsProvider.settings;

    // 打开颜色选择器
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return ColorPickerDialog(
          initialColor: ColorUtils.parseColor(
            SettingsConstants.defaultRingColor,
          ),
          showConfirmButtons: true,
          onColorSelected: (Color color) {
            // 实时颜色更新（可选）
          },
          onConfirm: (Color color) {
            final newColors = List<String>.from(settings.heartExpansionColors);
            newColors.add(_colorToString(color));
            settingsProvider.updateHeartExpansionColors(newColors);
          },
        );
      },
    );
  }

  void _editColor(
    BuildContext context,
    SettingsProvider settingsProvider,
    int index,
  ) {
    final settings = settingsProvider.settings;
    final currentColor = settings.heartExpansionColors[index];

    // 打开颜色选择器
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return ColorPickerDialog(
          initialColor: ColorUtils.parseColor(currentColor),
          showConfirmButtons: true,
          onColorSelected: (Color color) {
            // 实时颜色更新（可选）
          },
          onConfirm: (Color color) {
            final newColors = List<String>.from(settings.heartExpansionColors);
            newColors[index] = _colorToString(color);
            settingsProvider.updateHeartExpansionColors(newColors);
          },
        );
      },
    );
  }

  String _colorToString(Color color) {
    String hex = color.toARGB32().toRadixString(16).substring(2).toUpperCase();
    return '#$hex';
  }

  void _deleteColor(
    BuildContext context,
    SettingsProvider settingsProvider,
    int index,
  ) {
    final settings = settingsProvider.settings;
    final appLocalizations = AppLocalizations.of(context);

    // 至少保留两个颜色
    if (settings.heartExpansionColors.length <= 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            appLocalizations.t('at_least_color', settings.language),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    final newColors = List<String>.from(settings.heartExpansionColors);
    newColors.removeAt(index);
    settingsProvider.updateHeartExpansionColors(newColors);
  }
}
