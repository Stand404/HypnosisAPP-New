import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../../config/app_constants.dart';
import '../../i18n/app_localizations.dart';
import '../../store/settings_provider.dart';
import 'package:provider/provider.dart';
import 'cancel_button.dart';
import 'confirm_button.dart';
import 'app_modal.dart';

/// 通用颜色选择器对话框
class ColorPickerDialog extends StatefulWidget {
  final Color initialColor;
  final ValueChanged<Color>? onColorSelected;
  final ValueChanged<Color>? onConfirm;
  final bool instantUpdate;
  final bool showConfirmButtons;

  const ColorPickerDialog({
    super.key,
    required this.initialColor,
    this.onColorSelected,
    this.onConfirm,
    this.instantUpdate = false,
    this.showConfirmButtons = true,
  });

  @override
  State<ColorPickerDialog> createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<ColorPickerDialog> {
  late Color _currentColor;
  late Color _initialColor;

  @override
  void initState() {
    super.initState();
    _currentColor = widget.initialColor;
    _initialColor = widget.initialColor;
  }

  void _resetColor() {
    setState(() {
      _currentColor = _initialColor;
    });
    if (widget.onColorSelected != null) {
      widget.onColorSelected!(_currentColor);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(
      context,
      listen: false,
    ).settings;
    final appLocalizations = AppLocalizations.of(context);

    if (widget.showConfirmButtons) {
      return AppModal(
          title: appLocalizations.t('select_color', settings.language),
          actions: [
            if (widget.instantUpdate)
              ConfirmButton(
                onPressed: _resetColor,
                text: appLocalizations.t('reset', settings.language),
                horizontalPadding: 30,
              ),
            CancelButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              text: appLocalizations.t('close', settings.language),
              horizontalPadding: 30,
            ),
            if (!widget.instantUpdate)
              ConfirmButton(
                onPressed: () {
                  if (widget.onConfirm != null) {
                    widget.onConfirm!(_currentColor);
                  }
                  Navigator.of(context).pop();
                },
                text: appLocalizations.t(
                  'confirm',
                  settings.language,
                ),
                horizontalPadding: 30,
              ),
          ],
          child: SizedBox(
            width: double.infinity,
            child: Theme(
              data: ThemeData.dark().copyWith(
                textTheme: TextTheme(
                  bodyMedium: AppTextStyles.mediumText,
                  bodySmall: AppTextStyles.label,
                ),
              ),
              child: ColorPicker(
                pickerColor: _currentColor,
                onColorChanged: (Color newColor) {
                  setState(() {
                    _currentColor = newColor;
                  });
                  if (widget.onColorSelected != null) {
                    widget.onColorSelected!(_currentColor);
                  }
                },
                pickerAreaHeightPercent: 0.8,
                enableAlpha: false,
              ),
            ),
          ),
        );
    } else {
      // 返回纯颜色选择器，不带对话框包装
      return ColorPicker(
        pickerColor: _currentColor,
        onColorChanged: (Color newColor) {
          setState(() {
            _currentColor = newColor;
          });
          if (widget.onColorSelected != null) {
            widget.onColorSelected!(_currentColor);
          }
        },
        pickerAreaHeightPercent: 0.8,
        enableAlpha: false,
      );
    }
  }
}
