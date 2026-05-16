import 'dart:html' as html;
import 'dart:js_util' as js_util;

import 'package:flutter/material.dart';

import 'screens/install_prompt_screen.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const AlphaEventsGuestApp());
}

class AlphaEventsGuestApp extends StatelessWidget {
  const AlphaEventsGuestApp({super.key});

  bool isRunningAsInstalledApp() {
    final bool displayModeStandalone = html.window
        .matchMedia('(display-mode: standalone)')
        .matches;

    final bool iosStandalone =
        js_util.getProperty(html.window.navigator, 'standalone') == true;

    return displayModeStandalone || iosStandalone;
  }

  @override
  Widget build(BuildContext context) {
    final bool installedAppMode = isRunningAsInstalledApp();

    return MaterialApp(
      title: 'Alpha Events Guest Portal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF050507),
        fontFamily: 'Arial',
        useMaterial3: true,
      ),
      home: installedAppMode
          ? const LoginScreen()
          : const InstallPromptScreen(),
    );
  }
}
