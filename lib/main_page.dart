import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'store/settings_provider.dart';
import 'models/settings.dart';
import 'components/animations/ring_animation.dart';
import 'components/animations/heart_animation.dart';
import 'components/animations/spiral_animation.dart';
import 'components/animations/beating_heart.dart';
import 'components/common/display_text_widget.dart';
import 'setting_panel.dart';
import 'utils/color_utils.dart';

/// 主页面
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  /// 根据动画类型构建对应的动画组件
  Widget _buildAnimation(AnimationType animationType) {
    switch (animationType) {
      case AnimationType.ringExpansion:
        return const RingAnimation();
      case AnimationType.heartExpansion:
        return const HeartAnimation();
      case AnimationType.classicSpiral:
        return const SpiralAnimation();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, _) {
        final settings = settingsProvider.settings;
        
        return Scaffold(
          body: Container(
            color: ColorUtils.parseColor(settings.bgColor),
            child: Stack(
              children: [
                // 根据动画类型切换动画
                _buildAnimation(settings.animationType),
                
                // 跳动的心（根据 showCenterPattern 控制显示）
                if (settings.showCenterPattern) const BeatingHeart(),
                
                // 显示文本（如果有文本内容）
                const DisplayTextWidget(),
                
                // 设置面板
                const SettingPanel(),
              ],
            ),
          ),
        );
      },
    );
  }
}
