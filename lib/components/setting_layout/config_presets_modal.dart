import 'package:flutter/material.dart';
import '../../config/app_constants.dart';
import 'package:provider/provider.dart';
import '../../store/settings_provider.dart';
import '../../i18n/app_localizations.dart';
import '../../models/settings.dart';
import '../common/cancel_button.dart';
import '../common/confirm_button.dart';
import '../common/import_config_button.dart';
import '../common/app_modal.dart';
import 'config_item.dart';
import 'create_config_dialog.dart';
import 'config_details_dialog.dart';
import 'import_config_dialog.dart';

/// 配置存档管理模态框
class ConfigPresetsModal extends StatefulWidget {
  final Animation<double> animation;
  final VoidCallback onCancel;

  const ConfigPresetsModal({
    super.key,
    required this.animation,
    required this.onCancel,
  });

  @override
  State<ConfigPresetsModal> createState() => _ConfigPresetsModalState();
}

class _ConfigPresetsModalState extends State<ConfigPresetsModal> {
  @override
  void initState() {
    super.initState();
    // 确保有默认选中的配置
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ensureDefaultConfigSelected();
    });
  }

  /// 确保有一个默认选中的配置
  void _ensureDefaultConfigSelected() {
    final settingsProvider = Provider.of<SettingsProvider>(
      context,
      listen: false,
    );
    if (settingsProvider.selectedConfig == null &&
        settingsProvider.configPresets.isNotEmpty) {
      // 如果没有选中配置，默认选中第一个
      settingsProvider.loadConfig(settingsProvider.configPresets.first.id);
    }
  }

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
        final configs = settingsProvider.configPresets;
        final selectedConfigId = settingsProvider.selectedConfig?.id;

        return AppModal(
          title: appLocalizations.t('config_presets', settings.language),
          actions: [
            // 导入配置按钮
            ImportConfigButton(
              onPressed: () =>
                  _showImportConfigDialog(context, settingsProvider),
              text: appLocalizations.t('import', settings.language),
              horizontalPadding: 20,
            ),
            // 新建配置按钮
            ConfirmButton(
              onPressed: () =>
                  _showCreateConfigDialog(context, settingsProvider),
              text: appLocalizations.t('create_new_config', settings.language),
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
            children: configs.asMap().entries.map((entry) {
              final index = entry.key;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ConfigItem(
                  name: configs[index].name,
                  settings: configs[index].settings,
                  isSelected: configs[index].id == selectedConfigId,
                  onTap: () =>
                      _loadConfig(context, settingsProvider, configs[index].id),
                  onViewDetails: () => _showConfigDetails(
                    context,
                    settingsProvider,
                    configs[index],
                  ),
                  onDelete: () => _deleteConfig(
                    context,
                    settingsProvider,
                    configs[index].id,
                  ),
                  canDelete: settingsProvider.configPresets.length > 1,
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _loadConfig(
    BuildContext context,
    SettingsProvider settingsProvider,
    String configId,
  ) async {
    await settingsProvider.loadConfig(configId);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(
              context,
            ).t('load_config', settingsProvider.settings.language),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _deleteConfig(
    BuildContext context,
    SettingsProvider settingsProvider,
    String configId,
  ) async {
    final appLocalizations = AppLocalizations.of(context);
    final settings = settingsProvider.settings;

    // 确认删除
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.blackWith90Opacity,
        title: Text(
          appLocalizations.t('delete_config', settings.language),
          style: AppTextStyles.mediumText,
        ),
        content: Text(
          appLocalizations.t('delete_confirm', settings.language),
          style: AppTextStyles.label,
        ),
        actions: [
          CancelButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            text: appLocalizations.t('cancel', settings.language),
            horizontalPadding: 20,
          ),
          ConfirmButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            text: appLocalizations.t('confirm', settings.language),
            horizontalPadding: 20,
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await settingsProvider.deleteConfig(configId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(appLocalizations.t('config_saved', settings.language)),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _showCreateConfigDialog(
    BuildContext context,
    SettingsProvider settingsProvider,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => CreateConfigDialog(
        onCreate: (name, animationType) async {
          // 创建新的配置，使用选中的动画类型和默认设置
          final newSettings = Settings.defaultSettings.copyWith(
            animationType: animationType,
          );

          await settingsProvider.saveAsConfigWithType(name, newSettings);
          if (context.mounted) {
            final appLocalizations = AppLocalizations.of(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  appLocalizations.t(
                    'config_saved',
                    settingsProvider.settings.language,
                  ),
                ),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        },
      ),
    );
  }

  void _showConfigDetails(
    BuildContext context,
    SettingsProvider settingsProvider,
    config,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => ConfigDetailsDialog(
        configName: config.name,
        configId: config.id,
        configSettings: config.settings,
        onSave: (newName) async {
          await settingsProvider.updateConfigName(config.id, newName);
        },
        onExport: (jsonString) {
          // 导出逻辑已在对话框内部处理
        },
      ),
    );
  }

  void _showImportConfigDialog(
    BuildContext context,
    SettingsProvider settingsProvider,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => ImportConfigDialog(
        onImport: (configName, configSettings) async {
          // 使用导入的配置创建新的配置存档
          await settingsProvider.saveAsConfigWithType(
            configName,
            configSettings,
          );

          if (context.mounted) {
            final appLocalizations = AppLocalizations.of(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  appLocalizations.t(
                    'config_imported',
                    settingsProvider.settings.language,
                  ),
                ),
                duration: const Duration(seconds: 2),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
      ),
    );
  }
}
