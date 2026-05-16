import 'package:flutter/material.dart';

class BorusanLogoBadge extends StatelessWidget {
  const BorusanLogoBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 82,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.44),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.14)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.36),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Image.asset(
        'assets/logos/Borusan.png',
        fit: BoxFit.contain,
        alignment: Alignment.centerLeft,
      ),
    );
  }
}
