import 'package:flutter/material.dart';
import '../../config/app_constants.dart';

/// 通用确认按钮组件
/// 用于模态框中的确认/添加操作
class ConfirmButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final double horizontalPadding;

  const ConfirmButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.horizontalPadding = 30,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(StyleConstants.primaryColorValue),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: 12,
        ),
      ),
      child: Text(
        text,
        style: AppTextStyles.button,
      ),
    );
  }
}
