import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'config/app_constants.dart';
import 'i18n/app_localizations.dart';
import 'store/settings_provider.dart';
import 'main_page.dart';

void main() {
  // 确保绑定初始化
  WidgetsFlutterBinding.ensureInitialized();
  
  // 设置系统UI样式为全屏沉浸式
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  
  // 设置为全屏模式
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  
  runApp(const HypnosisApp());
}

class HypnosisApp extends StatelessWidget {
  const HypnosisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SettingsProvider(),
      child: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, _) {
          // 根据设置的语言创建对应的 Locale
          final settings = settingsProvider.settings;
          Locale currentLocale;
          
          switch (settings.language) {
            case 0:
              currentLocale = const Locale('zh');
              break;
            case 1:
              currentLocale = const Locale('zh', 'TW');
              break;
            case 2:
              currentLocale = const Locale('en');
              break;
            case 3:
              currentLocale = const Locale('ja');
              break;
            default:
              currentLocale = const Locale('zh');
          }

          return MaterialApp(
            title: 'Hypnosis',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(StyleConstants.primaryColorValue),
                brightness: Brightness.light,
              ),
              // 统一TextField边框颜色为主题色
              inputDecorationTheme: InputDecorationTheme(
                // 启用状态下的边框颜色
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: const BorderSide(
                    color: Color(StyleConstants.primaryColorValue),
                    width: 2.0,
                  ),
                ),
                // 默认状态下的边框颜色
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(
                    color: AppColors.primaryWith50Opacity,
                    width: 1.0,
                  ),
                ),
                // 错误状态下的边框颜色
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(
                    color: ColorScheme.fromSeed(
                      seedColor: const Color(StyleConstants.primaryColorValue),
                      brightness: Brightness.light,
                    ).error,
                    width: 1.0,
                  ),
                ),
                // 聚焦但有错误时的边框颜色
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(
                    color: ColorScheme.fromSeed(
                      seedColor: const Color(StyleConstants.primaryColorValue),
                      brightness: Brightness.light,
                    ).error,
                    width: 2.0,
                  ),
                ),
                // 焦点颜色（光标颜色）
                focusColor: const Color(StyleConstants.primaryColorValue),
              ),
            ),
            locale: currentLocale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: const MainPage(),
          );
        },
      ),
    );
  }
}
