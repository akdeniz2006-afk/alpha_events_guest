import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class AppPage extends StatelessWidget {
  final Widget child;

  const AppPage({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      child: DefaultTextStyle(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          decoration: TextDecoration.none,
        ),
        child: IconTheme(
          data: const IconThemeData(
            color: Colors.white,
          ),
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topCenter,
                radius: 1.05,
                colors: [
                  AppColors.backgroundTop,
                  Color(0xFF09090D),
                  AppColors.background,
                ],
              ),
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 430,
                ),
                child: SafeArea(
                  bottom: false,
                  child: child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

BoxDecoration glassDecoration({
  double radius = 24,
  double opacity = 0.075,
}) {
  return BoxDecoration(
    color: Colors.white.withOpacity(opacity),
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(
      color: Colors.white.withOpacity(0.10),
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.24),
        blurRadius: 24,
        offset: const Offset(0, 14),
      ),
    ],
  );
}