import 'package:flutter/material.dart';
import '../../config/app_constants.dart';

/// 通用导入配置按钮组件
/// 用于模态框中的导入配置操作
class ImportConfigButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final double horizontalPadding;

  const ImportConfigButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.horizontalPadding = 30,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      label: Text(
        text,
        style: AppTextStyles.value16,
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(StyleConstants.primaryColorValue),
        side: const BorderSide(
          color: Color(StyleConstants.primaryColorValue),
          width: 2,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: 12,
        ),
      ),
    );
  }
}
