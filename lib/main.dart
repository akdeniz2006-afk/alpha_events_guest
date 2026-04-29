import 'package:flutter/material.dart';

import 'screens/login_screen.dart';

void main() {
  runApp(const AlphaEventsGuestApp());
}

class AlphaEventsGuestApp extends StatelessWidget {
  const AlphaEventsGuestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Alpha Events Guest Portal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF050507),
        fontFamily: 'Arial',
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}