import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/settings.dart';
import '../../store/settings_provider.dart';
import '../app_constants.dart';
import '../../i18n/app_localizations.dart';
import '../../components/common/app_modal.dart';
import '../../components/common/cancel_button.dart';
import '../../components/common/confirm_button.dart';

/// 设置辅助工具类
/// 提供共享的辅助方法，如对话框显示、文件选择等
class SettingsHelpers {
  /// 显示文本输入对话框
  static Future<void> showTextInputDialog(
    BuildContext context,
    Settings settings,
  ) async {
    final TextEditingController controller = TextEditingController(
      text: settings.displayText ?? '',
    );
    final appLocalizations = AppLocalizations.of(context);
    final language = settings.language;

    return showDialog(
      context: context,
      builder: (context) => AppModal(
        title: appLocalizations.t('text_content', language),
        actions: [
          CancelButton(
            onPressed: () => Navigator.pop(context),
            text: appLocalizations.t('cancel', language),
          ),
          ConfirmButton(
            onPressed: () {
              final text = controller.text.trim();
              if (text.isEmpty) {
                // 允许清空文字
                context.read<SettingsProvider>().updateDisplayText(null);
              } else {
                context.read<SettingsProvider>().updateDisplayText(text);
              }
              Navigator.pop(context);
            },
            text: appLocalizations.t('confirm', language),
          ),
        ],
        child: TextField(
          controller: controller,
          style: AppTextStyles.mediumText,
          decoration: InputDecoration(
            labelStyle: AppTextStyles.label,
            hintText: appLocalizations.t('enter_text_hint', language),
          ),
          autofocus: true,
          maxLines: null,
        ),
      ),
    );
  }

  /// 选择图片文件
  static Future<void> selectImageFile(BuildContext context) async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: ImagePickerConstants.imageQuality,
      );

      if (!context.mounted) return;

      if (image != null && image.path.isNotEmpty) {
        context.read<SettingsProvider>().updateCustomPatternPath(image.path);
      }
    } catch (e) {
      debugPrint('选择文件失败: $e');
    }
  }
}
