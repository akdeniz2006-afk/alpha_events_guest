import 'package:flutter/material.dart';

class PressableScale extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const PressableScale({super.key, required this.child, required this.onTap});

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale> {
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) {
        setState(() {
          isPressed = true;
        });
      },
      onTapCancel: () {
        setState(() {
          isPressed = false;
        });
      },
      onTapUp: (_) {
        setState(() {
          isPressed = false;
        });
      },
      child: AnimatedScale(
        scale: isPressed ? 0.97 : 1,
        duration: const Duration(milliseconds: 120),
        child: widget.child,
      ),
    );
  }
}
