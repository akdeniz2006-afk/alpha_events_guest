import 'package:flutter/material.dart';

import '../data/demo_event_data.dart';
import '../theme/app_colors.dart';
import '../widgets/app_page.dart';
import '../widgets/header_title.dart';

class ProgramScreen extends StatelessWidget {
  const ProgramScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool openedAsSubPage = Navigator.of(context).canPop();

    return AppPage(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          18,
          16,
          18,
          openedAsSubPage ? 40 : 108,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            openedAsSubPage
                ? const BackHeader(
                    title: 'Etkinlik Programı',
                    subtitle: '14 Mayıs · 1. Gün',
                  )
                : const HeaderTitle(
                    title: 'Etkinlik Programı',
                    subtitle: '14 Mayıs · 1. Gün',
                  ),
            const SizedBox(height: 22),
            ...List.generate(demoProgram.length, (index) {
              final item = demoProgram[index];

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ProgramCard(
                  item: item,
                  index: index,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class ProgramCard extends StatelessWidget {
  final ProgramItem item;
  final int index;

  const ProgramCard({
    super.key,
    required this.item,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final bool isFirst = index == 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(isFirst ? 0.105 : 0.075),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isFirst
              ? AppColors.champagne.withOpacity(0.34)
              : Colors.white.withOpacity(0.10),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.28),
            blurRadius: 22,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(19),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isFirst
                    ? const [
                        AppColors.amberStart,
                        AppColors.amberEnd,
                      ]
                    : const [
                        AppColors.slateStart,
                        AppColors.slateEnd,
                      ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.22),
                  blurRadius: 12,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Center(
              child: Text(
                item.time,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  decoration: TextDecoration.none,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.2,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    color: Colors.white,
                    decoration: TextDecoration.none,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 7),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_rounded,
                      size: 16,
                      color: Colors.white.withOpacity(0.52),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        item.location,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.66),
                          decoration: TextDecoration.none,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 9),
                Text(
                  item.description,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.56),
                    decoration: TextDecoration.none,
                    fontSize: 13.5,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}