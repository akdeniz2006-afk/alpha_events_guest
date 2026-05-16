import 'package:flutter/material.dart';

class ClientLogoBadge extends StatelessWidget {
  final String logoPath;
  final String clientName;

  const ClientLogoBadge({
    super.key,
    required this.logoPath,
    required this.clientName,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: 58,
        width: 238,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 9),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.96),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.22),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.24),
              blurRadius: 20,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Image.asset(
          logoPath,
          fit: BoxFit.contain,
          semanticLabel: clientName,
        ),
      ),
    );
  }
}