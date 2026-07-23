import 'package:flutter/material.dart';

class AppSettings {
  static final ValueNotifier<double> confidenceThreshold =
      ValueNotifier<double>(0.65);

  static final ValueNotifier<bool> showTopPredictions = ValueNotifier<bool>(
    true,
  );

  static final ValueNotifier<bool> useFrontCamera = ValueNotifier<bool>(false);

  static final ValueNotifier<String> translationLanguage =
      ValueNotifier<String>('Arabic');

  static final ValueNotifier<ThemeMode> themeMode = ValueNotifier<ThemeMode>(
    ThemeMode.light,
  );

  static void resetToDefault() {
    confidenceThreshold.value = 0.65;
    showTopPredictions.value = true;
    useFrontCamera.value = false;
    translationLanguage.value = 'Arabic';
    themeMode.value = ThemeMode.light;
  }
}
