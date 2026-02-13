import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../store/settings_provider.dart';
import '../../models/settings.dart';
import '../../utils/color_utils.dart';

/// 显示文本组件
/// 负责在屏幕上显示定位的文本
class DisplayTextWidget extends StatelessWidget {
  const DisplayTextWidget({super.key});

  /// 构建显示的文本，正确计算居中位置
  Widget _buildDisplayText(BuildContext context, Settings settings) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: settings.displayText!,
        style: TextStyle(
          color: ColorUtils.parseColor(settings.textColor),
          fontSize: settings.textSize,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final textSize = textPainter.size;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // 计算文本位置，使其相对于屏幕中心定位
    // textHorizontalPosition 和 textVerticalPosition 的值范围是 -1 到 1
    // 0 表示居中，-1 表示左/上边缘，1 表示右/下边缘
    double left = (screenWidth / 2) + (settings.textHorizontalPosition * screenWidth / 2) - (textSize.width / 2);
    double top = (screenHeight / 2) + (settings.textVerticalPosition * screenHeight / 2) - (textSize.height / 2);

    // 验证计算的位置值是否有效（非 NaN 且有限）
    // 如果无效，则使用默认居中位置
    if (!left.isFinite || left.isNaN) {
      left = (screenWidth - textSize.width) / 2;
    }
    if (!top.isFinite || top.isNaN) {
      top = (screenHeight - textSize.height) / 2;
    }

    return Positioned(
      left: left,
      top: top,
      child: Text(
        settings.displayText!,
        style: TextStyle(
          color: ColorUtils.parseColor(settings.textColor),
          fontSize: settings.textSize,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, _) {
        final settings = settingsProvider.settings;

        // 只有当有文本内容时才显示
        if (settings.displayText == null || settings.displayText!.isEmpty) {
          return const SizedBox.shrink();
        }

        return _buildDisplayText(context, settings);
      },
    );
  }
}
