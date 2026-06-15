import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/app_page.dart';
import '../widgets/header_title.dart';

class AnnouncementsScreen extends StatelessWidget {
  const AnnouncementsScreen({super.key});

  static const String eventId = 'zurich_2026';

  Stream<QuerySnapshot<Map<String, dynamic>>> getAnnouncementsStream() {
    return FirebaseFirestore.instance
        .collection('event_announcements')
        .where('eventId', isEqualTo: eventId)
        .snapshots();
  }

  List<GuestAnnouncementItem> buildAnnouncements(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) {
    final items = snapshot.docs
        .map((doc) => GuestAnnouncementItem.fromFirestore(doc.data()))
        .where((item) => item.status == 'Yayında')
        .toList();

    items.sort((a, b) => b.sortOrder.compareTo(a.sortOrder));

    return items;
  }

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
            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: getAnnouncementsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const AnnouncementLoadingState();
                }

                if (snapshot.hasError) {
                  return AnnouncementErrorState(
                    errorText: snapshot.error.toString(),
                  );
                }

                final announcements = snapshot.hasData
                    ? buildAnnouncements(snapshot.data!)
                    : <GuestAnnouncementItem>[];

                if (announcements.isEmpty) {
                  return const EmptyGuestAnnouncementsState();
                }

                return Column(
                  children: List.generate(announcements.length, (index) {
                    final item = announcements[index];

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: AnnouncementCard(item: item, index: index),
                    );
                  }),
                );
              },
            ),
            const SizedBox(height: 10),
            const AnnouncementInfoCard(),
          ],
        ),
      ),
    );
  }
}

class AnnouncementLoadingState extends StatelessWidget {
  const AnnouncementLoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 118,
      width: double.infinity,
      alignment: Alignment.center,
      decoration: glassDecoration(radius: 24, opacity: 0.060),
      child: const CircularProgressIndicator(
        color: AppColors.champagne,
      ),
    );
  }
}

class AnnouncementErrorState extends StatelessWidget {
  final String errorText;

  const AnnouncementErrorState({super.key, required this.errorText});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: glassDecoration(radius: 24, opacity: 0.070),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: AppColors.champagne,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Duyurular şu anda alınamadı. Lütfen daha sonra tekrar kontrol edin.\n$errorText',
              style: TextStyle(
                color: Colors.white.withOpacity(0.62),
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

class EmptyGuestAnnouncementsState extends StatelessWidget {
  const EmptyGuestAnnouncementsState({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: glassDecoration(radius: 24, opacity: 0.060),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.notifications_none_rounded,
            color: AppColors.champagne,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Şu anda yayında duyuru bulunmuyor. Etkinlik güncellemeleri yayınlandığında burada görünecektir.',
              style: TextStyle(
                color: Colors.white.withOpacity(0.60),
                decoration: TextDecoration.none,
                height: 1.35,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
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
  final GuestAnnouncementItem item;
  final int index;

  const AnnouncementCard({super.key, required this.item, required this.index});

  Color getAccentColor() {
    if (item.isUrgent || item.priority == 'Acil') return AppColors.champagne;
    if (item.type == 'Transfer') return const Color(0xFF72C7C2);
    if (item.type == 'VIP') return const Color(0xFFD7B56D);
    if (item.type == 'Program') return const Color(0xFF7EA7D8);
    if (index == 0) return AppColors.champagne;
    if (index == 1) return const Color(0xFF72C7C2);
    return const Color(0xFF7EA7D8);
  }

  IconData getIcon() {
    if (item.isUrgent || item.priority == 'Acil') {
      return Icons.warning_amber_rounded;
    }

    if (item.type == 'Transfer') {
      return Icons.directions_bus_filled_rounded;
    }

    if (item.type == 'Program') {
      return Icons.calendar_month_rounded;
    }

    if (item.type == 'VIP') {
      return Icons.star_rounded;
    }

    if (item.type == 'Hatırlatma') {
      return Icons.badge_rounded;
    }

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
    final bool isImportant = index == 0 || item.isUrgent || item.priority == 'Acil';

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
                            item.priority == 'Acil' ? 'ACİL' : 'ÖNEMLİ',
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
                    Expanded(
                      child: Text(
                        '${item.date} · ${item.time}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.46),
                          decoration: TextDecoration.none,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
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
                  item.description,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.58),
                    decoration: TextDecoration.none,
                    fontSize: 13,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (item.target.isNotEmpty) ...[
                  const SizedBox(height: 9),
                  Text(
                    item.target,
                    style: TextStyle(
                      color: accent.withOpacity(0.82),
                      decoration: TextDecoration.none,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
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

class GuestAnnouncementItem {
  final String title;
  final String description;
  final String date;
  final String time;
  final String type;
  final String status;
  final String target;
  final String priority;
  final bool isUrgent;
  final int sortOrder;

  const GuestAnnouncementItem({
    required this.title,
    required this.description,
    required this.date,
    required this.time,
    required this.type,
    required this.status,
    required this.target,
    required this.priority,
    required this.isUrgent,
    required this.sortOrder,
  });

  factory GuestAnnouncementItem.fromFirestore(Map<String, dynamic> data) {
    return GuestAnnouncementItem(
      title: (data['title'] ?? '').toString(),
      description: (data['description'] ?? '').toString(),
      date: (data['date'] ?? '').toString(),
      time: (data['time'] ?? '').toString(),
      type: (data['type'] ?? 'Bilgi').toString(),
      status: (data['status'] ?? 'Taslak').toString(),
      target: (data['target'] ?? '').toString(),
      priority: (data['priority'] ?? 'Bilgi').toString(),
      isUrgent: data['isUrgent'] == true ||
          (data['priority'] ?? '').toString() == 'Acil',
      sortOrder: int.tryParse((data['sortOrder'] ?? '0').toString()) ?? 0,
    );
  }
}
