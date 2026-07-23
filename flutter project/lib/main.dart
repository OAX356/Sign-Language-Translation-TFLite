import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'app_settings.dart';
import 'app_drawer.dart';
import 'home_page.dart';
import 'prediction_page.dart';
import 'asl_guide.dart';
import 'about_page.dart';
import 'settings_page.dart';
import 'splash_page.dart';
import 'app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  void initState() {
    FlutterNativeSplash.remove();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: AppSettings.themeMode,
      builder: (context, themeMode, child) {
        return MaterialApp(
          title: 'Sign Language Landmark Demo',
          debugShowCheckedModeBanner: false,

          themeMode: themeMode,

          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,

          initialRoute: AppRoutes.splash,

          routes: {
            AppRoutes.splash: (context) => const SplashPage(),
            AppRoutes.home: (context) => const HomePage(),
            AppRoutes.prediction: (context) => const SignClassifierPage(),
            AppRoutes.guide: (context) => const AslGuidePage(),
            AppRoutes.about: (context) => const AboutPage(),
            AppRoutes.settings: (context) => const SettingsPage(),
          },
        );
      },
    );
  }
}
