import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/app_constants.dart';
import '../../models/settings.dart';
import '../../models/config_preset.dart';
import '../../i18n/app_localizations.dart';
import '../../utils/settings_json_parser.dart';
import '../common/cancel_button.dart';
import '../common/confirm_button.dart';
import '../common/app_modal.dart';

/// 配置详情对话框
class ConfigDetailsDialog extends StatefulWidget {
  final String configName;
  final String configId;
  final Settings configSettings;
  final Function(String newName) onSave;
  final Function(String)? onExport;

  const ConfigDetailsDialog({
    super.key,
    required this.configName,
    required this.configId,
    required this.configSettings,
    required this.onSave,
    this.onExport,
  });

  @override
  State<ConfigDetailsDialog> createState() => _ConfigDetailsDialogState();
}

class _ConfigDetailsDialogState extends State<ConfigDetailsDialog> {
  late TextEditingController _nameController;
  TextEditingController? _detailsController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.configName);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 确保 controller 只初始化一次
    _detailsController ??= TextEditingController(
      text: _buildConfigDetailsText(),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _detailsController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);

    return AppModal(
      title: appLocalizations.t('config_parameters', 0),
      actions: [
        if (widget.onExport != null)
          TextButton.icon(
            onPressed: _handleExport,
            icon: Icon(
              Icons.copy,
              color: Color(StyleConstants.primaryColorValue),
            ),
            label: Text(
              appLocalizations.t('export', 0),
              style: AppTextStyles.button,
            ),
            style: TextButton.styleFrom(
              foregroundColor: Color(StyleConstants.primaryColorValue),
            ),
          ),
        CancelButton(
          onPressed: () => Navigator.of(context).pop(),
          text: appLocalizations.t('cancel', 0),
        ),
        ConfirmButton(
          onPressed: _handleSave,
          text: appLocalizations.t('confirm', 0),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
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

          // 配置详情多行文本显示
          TextField(
            controller: _detailsController,
            maxLines: null,
            readOnly: true,
            style: AppTextStyles.label,
            decoration: InputDecoration(
              labelText: appLocalizations.t('config_parameters', 0),
              labelStyle: AppTextStyles.label,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建配置详情文本
  String _buildConfigDetailsText() {
    final appLocalizations = AppLocalizations.of(context);
    final buffer = StringBuffer();

    // 动画类型
    buffer.writeln(
      '${appLocalizations.t('animation_type', 0)}: ${_getAnimationTypeName(widget.configSettings.animationType)}',
    );

    // 动画设置
    buffer.writeln();
    buffer.writeln(appLocalizations.t('animation_settings', 0));
    buffer.writeln(
      '${appLocalizations.t('bg_color', 0)}: ${widget.configSettings.bgColor}',
    );
    buffer.writeln(
      '${appLocalizations.t('animation_speed', 0)}: ${widget.configSettings.animationSpeed}',
    );

    // 根据动画类型显示不同参数
    if (widget.configSettings.animationType == AnimationType.heartExpansion) {
      buffer.writeln(
        '${appLocalizations.t('param_expansion_interval', 0)}: ${widget.configSettings.expansionInterval}',
      );
      buffer.writeln(
        '${appLocalizations.t('param_color_list', 0)}: ${widget.configSettings.heartExpansionColors.length} colors',
      );
    }

    if (widget.configSettings.animationType == AnimationType.ringExpansion ||
        widget.configSettings.animationType == AnimationType.classicSpiral) {
      buffer.writeln(
        '${appLocalizations.t('ring_color', 0)}: ${widget.configSettings.ringColor}',
      );
      buffer.writeln(
        '${appLocalizations.t('ring_thickness', 0)}: ${widget.configSettings.ringThickness}',
      );
    }

    if (widget.configSettings.animationType == AnimationType.classicSpiral) {
      buffer.writeln(
        '${appLocalizations.t('param_spiral_count', 0)}: ${widget.configSettings.spiralStrips}',
      );
      buffer.writeln(
        '${appLocalizations.t('param_twist_degree', 0)}: ${widget.configSettings.spiralDistortion}',
      );
    }

    // 中心设置
    buffer.writeln();
    buffer.writeln(appLocalizations.t('center_settings', 0));
    buffer.writeln(
      '${appLocalizations.t('heartbeat_animation', 0)}: ${_formatBoolean(widget.configSettings.isBeating, appLocalizations)}',
    );

    if (widget.configSettings.isBeating) {
      buffer.writeln(
        '${appLocalizations.t('heartbeat_speed', 0)}: ${widget.configSettings.heartBeatSpeed}',
      );
    }

    buffer.writeln(
      '${appLocalizations.t('scale', 0)}: ${widget.configSettings.patternScale}',
    );

    return buffer.toString().trim();
  }

  /// 格式化布尔值为多语言文本
  String _formatBoolean(bool value, AppLocalizations appLocalizations) {
    return value ? appLocalizations.t('on', 0) : appLocalizations.t('off', 0);
  }

  void _handleSave() {
    final newName = _nameController.text.trim();
    if (newName.isNotEmpty) {
      widget.onSave(newName);
      Navigator.of(context).pop();
    }
  }

  String _getAnimationTypeName(AnimationType type) {
    final appLocalizations = AppLocalizations.of(context);
    switch (type) {
      case AnimationType.ringExpansion:
        return appLocalizations.t('animation_ring_expansion', 0);
      case AnimationType.heartExpansion:
        return appLocalizations.t('animation_heart_expansion', 0);
      case AnimationType.classicSpiral:
        return appLocalizations.t('animation_classic_spiral', 0);
    }
  }

  /// 处理导出配置
  void _handleExport() {
    if (widget.onExport == null) return;

    // 创建 ConfigPreset 对象
    final configPreset = ConfigPreset(
      id: widget.configId,
      name: widget.configName,
      settings: widget.configSettings,
    );

    // 使用 JSON 解析器导出
    final result = SettingsJsonParser.exportConfig(configPreset, pretty: true);

    if (result.success && result.jsonString != null) {
      // 复制到剪贴板
      Clipboard.setData(ClipboardData(text: result.jsonString!));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).t('config_exported', 0)),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${AppLocalizations.of(context).t('export_failed', 0)}: ${result.error}',
            ),
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
