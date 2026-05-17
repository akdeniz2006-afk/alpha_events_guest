import 'package:flutter/material.dart';

import '../data/demo_event_data.dart';
import '../theme/app_colors.dart';
import '../widgets/app_page.dart';
import '../widgets/header_title.dart';

class AnnouncementsScreen extends StatelessWidget {
  const AnnouncementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool openedAsSubPage = Navigator.of(context).canPop();

    return AppPage(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(18, 16, 18, openedAsSubPage ? 42 : 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            openedAsSubPage
                ? const BackHeader(
                    title: 'Duyurular',
                    subtitle: 'Etkinlik boyunca güncel bilgiler',
                  )
                : const HeaderTitle(
                    title: 'Duyurular',
                    subtitle: 'Etkinlik boyunca güncel bilgiler',
                  ),
            const SizedBox(height: 20),
            const AnnouncementHeroCard(),
            const SizedBox(height: 20),
            const Text(
              'Canlı Bilgilendirmeler',
              style: TextStyle(
                color: Colors.white,
                decoration: TextDecoration.none,
                fontSize: 21,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 12),
            ...List.generate(demoAnnouncements.length, (index) {
              final item = demoAnnouncements[index];

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: AnnouncementCard(item: item, index: index),
              );
            }),
            const SizedBox(height: 10),
            const AnnouncementInfoCard(),
          ],
        ),
      ),
    );
  }
}

class AnnouncementHeroCard extends StatelessWidget {
  const AnnouncementHeroCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF07101B), Color(0xFF14243A), Color(0xFF263B58)],
        ),
        border: Border.all(color: Colors.white.withOpacity(0.10)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF263B58).withOpacity(0.28),
            blurRadius: 30,
            offset: const Offset(0, 18),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.36),
            blurRadius: 28,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -58,
            top: -68,
            child: Container(
              width: 190,
              height: 190,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.champagne.withOpacity(0.10),
              ),
            ),
          ),
          Positioned(
            left: -70,
            bottom: -86,
            child: Container(
              width: 190,
              height: 190,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.petrolEnd.withOpacity(0.08),
              ),
            ),
          ),
          Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: AppColors.champagne.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.champagne.withOpacity(0.22),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.champagne.withOpacity(0.12),
                      blurRadius: 18,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.campaign_rounded,
                  color: AppColors.champagne,
                  size: 28,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Anlık Duyurular',
                      style: TextStyle(
                        color: Colors.white,
                        decoration: TextDecoration.none,
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Program, salon, transfer ve etkinlik akışına dair önemli güncellemeleri buradan takip edebilirsiniz.',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.62),
                        decoration: TextDecoration.none,
                        fontSize: 13.2,
                        height: 1.35,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class AnnouncementCard extends StatelessWidget {
  final AnnouncementItem item;
  final int index;

  const AnnouncementCard({super.key, required this.item, required this.index});

  Color getAccentColor() {
    if (index == 0) return AppColors.champagne;
    if (index == 1) return const Color(0xFF72C7C2);
    return const Color(0xFF7EA7D8);
  }

  IconData getIcon() {
    final title = item.title.toLowerCase();

    if (title.contains('transfer')) {
      return Icons.directions_bus_filled_rounded;
    }

    if (title.contains('gala')) {
      return Icons.celebration_rounded;
    }

    if (title.contains('yaka')) {
      return Icons.badge_rounded;
    }

    return Icons.notifications_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final Color accent = getAccentColor();
    final bool isImportant = index == 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(isImportant ? 0.095 : 0.070),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: isImportant
              ? accent.withOpacity(0.30)
              : Colors.white.withOpacity(0.09),
        ),
        boxShadow: [
          BoxShadow(
            color: isImportant
                ? accent.withOpacity(0.08)
                : Colors.black.withOpacity(0.24),
            blurRadius: 22,
            offset: const Offset(0, 14),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 16,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.14),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: accent.withOpacity(0.24)),
            ),
            child: Icon(getIcon(), color: accent, size: 25),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (isImportant) ...[
                      Container(
                        height: 25,
                        padding: const EdgeInsets.symmetric(horizontal: 9),
                        decoration: BoxDecoration(
                          color: accent.withOpacity(0.13),
                          borderRadius: BorderRadius.circular(13),
                          border: Border.all(color: accent.withOpacity(0.22)),
                        ),
                        child: Center(
                          child: Text(
                            'ÖNEMLİ',
                            style: TextStyle(
                              color: accent,
                              decoration: TextDecoration.none,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.7,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      item.date,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.46),
                        decoration: TextDecoration.none,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  item.title,
                  style: const TextStyle(
                    color: Colors.white,
                    decoration: TextDecoration.none,
                    fontSize: 16.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  item.message,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.58),
                    decoration: TextDecoration.none,
                    fontSize: 13,
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

class AnnouncementInfoCard extends StatelessWidget {
  const AnnouncementInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: glassDecoration(radius: 24, opacity: 0.060),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: AppColors.champagne,
            size: 21,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Etkinlik süresince yapılan güncellemeler bu ekranda yayınlanır. Önemli değişiklikler için duyuruları düzenli kontrol etmeniz önerilir.',
              style: TextStyle(
                color: Colors.white.withOpacity(0.58),
                decoration: TextDecoration.none,
                height: 1.35,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
