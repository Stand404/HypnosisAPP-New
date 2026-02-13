import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/app_constants.dart';
import '../../models/settings.dart';
import '../../i18n/app_localizations.dart';
import '../../utils/settings_json_parser.dart';
import '../common/cancel_button.dart';
import '../common/confirm_button.dart';
import '../common/app_modal.dart';

/// 导入配置对话框
class ImportConfigDialog extends StatefulWidget {
  final Function(String configName, Settings configSettings) onImport;

  const ImportConfigDialog({
    super.key,
    required this.onImport,
  });

  @override
  State<ImportConfigDialog> createState() => _ImportConfigDialogState();
}

class _ImportConfigDialogState extends State<ImportConfigDialog> {
  late TextEditingController _jsonController;
  late TextEditingController _nameController;
  String? _errorMessage;
  bool _isJsonValid = false;

  @override
  void initState() {
    super.initState();
    _jsonController = TextEditingController();
    _nameController = TextEditingController();
    
    // 监听 JSON 输入变化
    _jsonController.addListener(_validateJson);
  }

  @override
  void dispose() {
    _jsonController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  /// 验证 JSON 格式
  void _validateJson() {
    final jsonString = _jsonController.text.trim();
    
    if (jsonString.isEmpty) {
      setState(() {
        _errorMessage = null;
        _isJsonValid = false;
      });
      return;
    }

    final result = SettingsJsonParser.importConfig(jsonString);
    
    setState(() {
      if (result.success && result.config != null) {
        _errorMessage = null;
        _isJsonValid = true;
        // 如果名称输入框为空，自动填充配置名称
        if (_nameController.text.isEmpty) {
          _nameController.text = result.config!.name;
        }
      } else {
        _errorMessage = result.error ?? '无效的配置格式';
        _isJsonValid = false;
      }
    });
  }

  /// 从剪贴板粘贴
  Future<void> _pasteFromClipboard() async {
    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    if (clipboardData?.text != null) {
      _jsonController.text = clipboardData!.text!;
    }
  }

  /// 处理导入
  void _handleImport() {
    final jsonString = _jsonController.text.trim();
    final configName = _nameController.text.trim();

    if (configName.isEmpty) {
      setState(() {
        _errorMessage = '请输入配置名称';
      });
      return;
    }

    final result = SettingsJsonParser.importConfig(jsonString);
    
    if (result.success && result.config != null) {
      widget.onImport(configName, result.config!.settings);
      if (mounted) {
        Navigator.of(context).pop();
      }
    } else {
      setState(() {
        _errorMessage = result.error ?? '导入失败';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);

    return AppModal(
      title: appLocalizations.t('import_config', 0),
      actions: [
        CancelButton(
          onPressed: () => Navigator.of(context).pop(),
          text: appLocalizations.t('cancel', 0),
        ),
        ConfirmButton(
          onPressed: _isJsonValid ? _handleImport : () {},
          text: appLocalizations.t('import', 0),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // JSON 输入区域
          Text(
            appLocalizations.t('paste_config_json', 0),
            style: AppTextStyles.label,
          ),
          const SizedBox(height: 8),
          
          // JSON 输入框和粘贴按钮
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextField(
                  controller: _jsonController,
                  maxLines: 10,
                  style: AppTextStyles.label,
                  decoration: InputDecoration(
                    hintText: appLocalizations.t('json_input_hint', 0),
                    hintStyle: AppTextStyles.label.copyWith(
                      color: Colors.white38,
                    ),
                    errorText: _errorMessage,
                    errorStyle: const TextStyle(color: Colors.red),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // 粘贴按钮
              IconButton(
                onPressed: _pasteFromClipboard,
                icon: const Icon(Icons.content_paste),
                color: const Color(StyleConstants.primaryColorValue),
                tooltip: appLocalizations.t('paste_from_clipboard', 0),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 配置名称输入框
          TextField(
            controller: _nameController,
            style: AppTextStyles.mediumText,
            decoration: InputDecoration(
              labelText: appLocalizations.t('config_name', 0),
              labelStyle: AppTextStyles.label,
            ),
          ),

          const SizedBox(height: 16),

          // 验证状态提示
          if (_isJsonValid)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      appLocalizations.t('config_format_valid', 0),
                      style: const TextStyle(color: Colors.green, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
