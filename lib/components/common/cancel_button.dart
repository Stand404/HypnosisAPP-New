import 'package:flutter/material.dart';
import '../../config/app_constants.dart';

/// 通用取消按钮组件
/// 用于模态框中的取消操作
class CancelButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final double horizontalPadding;

  const CancelButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.horizontalPadding = 30,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: const BorderSide(color: Colors.white),
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
