# Hypnosis - 催眠APP

<p align="center">
  <img src="icon.png" alt="应用图标" width="128" height="128">
</p>

Hypnosis 是一款催眠动画模拟应用，提供多种催眠动画效果和丰富的自定义选项。应用支持多种动画类型，包括圆环扩散、爱心扩散和经典螺旋，并允许用户完全自定义视觉效果、文本内容和中心图案，打造专属的视觉体验。  

基于原本的安卓项目：https://github.com/Stand404/HypnosisAPP

## 目录

- [简介](#简介)
- [支持平台](#支持平台)
- [功能特性](#功能特性)
- [功能设置](#功能设置)
  - [全局设置](#全局设置)
  - [文本显示设置](#文本显示设置)
  - [动画设置](#动画设置)
  - [中心图案设置](#中心图案设置)
  - [配置存档](#配置存档)
- [已知问题](#已知问题)
- [开发指南](#开发指南)
- [项目结构](#项目结构)

## 支持平台

- iOS
- macOS
- Windows
- Android
- Linux(未测试)
- Web

## 功能特性

### 动画类型

1. **圆环扩散动画**
   
   ![圆环扩散动画](assets/gifs/ring_expansion.gif)
   
   - 优雅的圆环从中心向外扩散
   - 可自定义圆环颜色和粗细
   - 可调节扩散间隔和动画速度

2. **爱心扩散动画**
   
   ![爱心扩散动画](assets/gifs/heart_expansion.gif)
   
   - 浪漫的爱心图案扩散效果
   - 支持多色爱心交替扩散
   - 可自定义颜色列表

3. **经典螺旋动画**
   
   ![经典螺旋动画](assets/gifs/classic_spiral.gif)
   
   - 传统的催眠螺旋效果
   - 可调节螺旋条数和扭曲程度
   - 可自定义螺旋颜色和粗细

### 多语言支持

- 简体中文
- 繁体中文
- English
- 日本語

## 功能设置

### 全局设置

全局设置控制应用的基本行为和界面显示：

- **全屏模式**: 开启后应用将占据整个屏幕，提供更沉浸的体验
- **显示中心图案**: 控制是否在动画中心显示图案（爱心或自定义图片）
- **语言**: 切换应用界面语言
- **动画类型**: 选择要使用的催眠动画效果
- **配置存档**: 管理和导入导出自定义配置

### 文本显示设置

自定义催眠文本的显示效果：

- **文本内容**: 设置要显示的催眠文本内容（支持多行文本）
- **文本大小**: 调整文本字体大小（12-100px）
- **文本颜色**: 自定义文本颜色
- **文本水平位置**: 调整文本在屏幕上的水平位置（-1.0 到 1.0）
- **文本垂直位置**: 调整文本在屏幕上的垂直位置（-1.0 到 1.0）

### 动画设置

根据选择的动画类型，提供相应的自定义选项：

#### 通用设置（所有动画类型）

- **背景颜色**: 设置动画背景的颜色
- **动画速度**: 调整动画播放速度

#### 圆环扩散 & 经典螺旋

- **环形颜色**: 设置扩散圆环或螺旋的颜色
- **环形粗细**: 调整圆环或螺旋线条的粗细

#### 扩散动画（圆环扩散 & 爱心扩散）

- **扩散间隔**: 控制每次扩散之间的时间间隔

#### 爱心扩散专用

- **颜色列表**: 设置爱心扩散使用的颜色列表，支持1-8种颜色交替显示

#### 经典螺旋专用

- **螺旋条数**: 调整螺旋的数量
- **螺旋扭曲程度**: 控制螺旋的扭曲效果强度

### 中心图案设置

自定义中心显示的图案效果：

- **心跳动画**: 开启后中心图案会模拟心跳跳动
- **心跳速度**: 调整心跳动画的跳动速度
- **爱心外填充色**: 设置默认爱心图案的填充颜色
- **爱心内边框色**: 设置默认爱心图案的内边框颜色
- **爱心外边框色**: 设置默认爱心图案的外边框颜色
- **选择自定义图案**: 上传自定义图片替换默认爱心图案
- **图案缩放**: 调整中心图案的显示大小

### 配置存档

应用支持配置的保存、导入和导出：

- **保存配置**: 将当前所有设置保存为配置
- **加载配置**: 从已保存的配置中选择加载
- **导出配置**: 将配置导出为 JSON 文件
- **导入配置**: 从 JSON 文件导入配置

## 已知问题

以下是一些已知的问题和限制，计划在未来的版本中修复：

1. **全屏模式恢复**: 在应用内手动退出全屏模式后，无法自动恢复全屏，需要重新开关全屏按钮

2. **自定义图片导入**: 导入包含自定义图片的配置时会显示错误，因为导出的配置文件不包含图像数据

3. **颜色选择器限制**: 在选择纯黑（#000000）或纯白（#FFFFFF）颜色时，RGB 滑块无法拖动，需要先在颜色窗口移动到其他颜色

4. **横屏模式输入**: 在横屏模式下，所有文字输入框可能会被键盘遮挡，导致无法正常编辑

5. **全屏设置限制**: 全屏功能仅在 Android 和 iOS 平台有效，Web 和桌面平台暂时不支持全屏设置

## 开发指南

### 环境要求

- Flutter SDK 3.x 或更高版本
- Dart SDK
- 对应平台的开发环境（Xcode、Android Studio、Visual Studio 等）

### 安装和运行

1. 克隆仓库：
```bash
git clone https://github.com/Stand404/HypnosisAPP-New.git
cd hypnosis
```

2. 安装依赖：
```bash
flutter pub get
```

3. 运行应用：
```bash
# 在特定设备上运行
flutter run

# 或使用 Flutter IDE 工具运行
```

### 构建发布版本

```bash
# Android
flutter build apk --release

# 仅打包arm64-v8a（现代64位设备）
flutter build apk --release --target-platform=android-arm64

# 64位x86（模拟器/Intel设备）
flutter build apk --release --target-platform=android-x64

# iOS
flutter build ios --release

# Web
flutter build web --release

# Windows
flutter build windows --release

# macOS
flutter build macos --release

# Linux
flutter build linux --release
```

## 项目结构

```
lib/
├── main.dart                 # 应用入口
├── main_page.dart            # 主页面
├── setting_panel.dart        # 设置面板
├── components/               # UI 组件
│   ├── animations/          # 动画组件
│   ├── common/              # 通用组件
│   ├── setting_items/       # 设置项组件
│   └── setting_layout/      # 设置布局组件
├── config/                  # 配置文件
│   ├── settings/            # 设置配置
│   ├── app_constants.dart   # 应用常量
│   └── setting_pages_config.dart
├── i18n/                    # 国际化文件
├── models/                  # 数据模型
├── store/                   # 状态管理
└── utils/                   # 工具类
```

### 核心模块说明

- **components/animations/**: 包含所有动画效果的实现
  - `ring_animation.dart`: 圆环扩散动画
  - `heart_animation.dart`: 爱心扩散动画
  - `spiral_animation.dart`: 经典螺旋动画
  - `beating_heart.dart`: 心跳动画效果

- **config/settings/**: 设置页面配置
  - `global_settings_config.dart`: 全局设置配置
  - `text_settings_config.dart`: 文本设置配置
  - `animation_settings_config.dart`: 动画设置配置
  - `pattern_settings_config.dart`: 中心图案设置配置

- **store/**: 使用 Provider 进行状态管理
  - `settings_provider.dart`: 设置数据的管理和更新

## 许可证

本项目采用 MIT 许可证。

---

**注意**: 本应用仅供娱乐和放松使用，不应作为医疗或治疗手段。如有严重的睡眠或焦虑问题，请咨询专业医生。
