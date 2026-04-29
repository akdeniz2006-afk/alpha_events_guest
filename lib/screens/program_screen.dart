import 'package:flutter/material.dart';

import '../data/demo_event_data.dart';
import '../theme/app_colors.dart';
import '../widgets/app_page.dart';
import '../widgets/header_title.dart';

class ProgramScreen extends StatelessWidget {
  const ProgramScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPage(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 108),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const HeaderTitle(
              title: 'Etkinlik Programı',
              subtitle: '14 Mayıs · 1. Gün',
            ),
            const SizedBox(height: 22),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: glassDecoration(),
              child: Column(
                children: List.generate(demoProgram.length, (index) {
                  final item = demoProgram[index];
                  final isLast = index == demoProgram.length - 1;

                  return ProgramRow(
                    item: item,
                    isLast: isLast,
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProgramRow extends StatelessWidget {
  final ProgramItem item;
  final bool isLast;

  const ProgramRow({
    super.key,
    required this.item,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 56,
            child: Text(
              item.time,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: AppColors.champagne,
              ),
            ),
          ),
          Column(
            children: [
              Container(
                width: 13,
                height: 13,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.champagne,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    color: Colors.white.withOpacity(0.13),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.location,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.60),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    item.description,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.54),
                      height: 1.32,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}