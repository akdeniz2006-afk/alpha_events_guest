import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/app_page.dart';
import '../widgets/header_title.dart';
import '../widgets/pressable_scale.dart';

class TransportScreen extends StatelessWidget {
  const TransportScreen({super.key});

  static const String eventId = 'zurich_2026';

  Stream<QuerySnapshot<Map<String, dynamic>>> getTransportStream() {
    return FirebaseFirestore.instance
        .collection('event_transports')
        .where('eventId', isEqualTo: eventId)
        .snapshots();
  }

  List<GuestTransportItem> buildItems(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) {
    final items = snapshot.docs.map((doc) {
      return GuestTransportItem.fromFirestore(id: doc.id, data: doc.data());
    }).where((item) {
      return item.guestAppVisible;
    }).toList();

    items.sort((a, b) {
      final sort = a.sortOrder.compareTo(b.sortOrder);
      if (sort != 0) return sort;
      return a.title.compareTo(b.title);
    });

    return items;
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 140),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const HeaderTitle(
              title: 'Ulaşım',
              subtitle: 'Transfer ve shuttle bilgileriniz',
            ),
            const SizedBox(height: 18),
            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: getTransportStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const TransportLoadingState();
                }

                if (snapshot.hasError) {
                  return TransportErrorState(errorText: snapshot.error.toString());
                }

                final items = snapshot.hasData
                    ? buildItems(snapshot.data!)
                    : <GuestTransportItem>[];

                if (items.isEmpty) {
                  return const EmptyTransportState();
                }

                return Column(
                  children: [
                    TransportHeroCard(item: items.first),
                    const SizedBox(height: 18),
                    const SectionLabel(title: 'Transfer Bilgileri'),
                    const SizedBox(height: 12),
                    ...items.map((item) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: TransportInfoCard(item: item),
                      );
                    }),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class TransportLoadingState extends StatelessWidget {
  const TransportLoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 260,
      alignment: Alignment.center,
      child: const CircularProgressIndicator(color: AppColors.champagne),
    );
  }
}

class TransportErrorState extends StatelessWidget {
  final String errorText;

  const TransportErrorState({super.key, required this.errorText});

  @override
  Widget build(BuildContext context) {
    return TransportNoticeCard(
      icon: Icons.error_outline_rounded,
      title: 'Ulaşım bilgileri alınamadı',
      subtitle: errorText,
      accent: AppColors.champagne,
    );
  }
}

class EmptyTransportState extends StatelessWidget {
  const EmptyTransportState({super.key});

  @override
  Widget build(BuildContext context) {
    return const TransportNoticeCard(
      icon: Icons.directions_bus_rounded,
      title: 'Henüz ulaşım bilginiz yayınlanmadı.',
      subtitle: 'Organizasyon ekibi bilgileri yayınladığında burada görünecektir.',
      accent: AppColors.champagne,
    );
  }
}

class TransportNoticeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color accent;

  const TransportNoticeCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.075),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.10)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.28),
            blurRadius: 26,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.16),
              borderRadius: BorderRadius.circular(17),
              border: Border.all(color: accent.withOpacity(0.25)),
            ),
            child: Icon(icon, color: accent, size: 25),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    decoration: TextDecoration.none,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.58),
                    decoration: TextDecoration.none,
                    fontSize: 12.8,
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

class SectionLabel extends StatelessWidget {
  final String title;

  const SectionLabel({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        decoration: TextDecoration.none,
        fontSize: 22,
        fontWeight: FontWeight.w900,
        letterSpacing: -0.5,
      ),
    );
  }
}

class TransportHeroCard extends StatelessWidget {
  final GuestTransportItem item;

  const TransportHeroCard({super.key, required this.item});

  Color get accent {
    if (item.category == 'IST') return const Color(0xFF7EA7D8);
    if (item.category == 'SAW') return const Color(0xFF9B8AD8);
    if (item.category == 'VIP') return const Color(0xFFD6B16A);
    return const Color(0xFF72C7C2);
  }

  IconData get icon {
    if (item.category == 'IST' || item.category == 'SAW') {
      return Icons.flight_land_rounded;
    }
    if (item.category == 'VIP') return Icons.star_rounded;
    if (item.category == 'Otele Direkt') return Icons.directions_car_rounded;
    return Icons.directions_bus_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: () {},
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(34),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF06080D), Color(0xFF101827), Color(0xFF22344E)],
          ),
          border: Border.all(color: Colors.white.withOpacity(0.10)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF22344E).withOpacity(0.36),
              blurRadius: 36,
              offset: const Offset(0, 20),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.55),
              blurRadius: 34,
              offset: const Offset(0, 22),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: accent.withOpacity(0.14),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: accent.withOpacity(0.24)),
              ),
              child: Icon(icon, color: accent, size: 31),
            ),
            const SizedBox(height: 20),
            Text(
              item.title,
              style: const TextStyle(
                color: Colors.white,
                decoration: TextDecoration.none,
                fontSize: 31,
                fontWeight: FontWeight.w900,
                height: 1.05,
                letterSpacing: -1.0,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${item.type} · ${item.location}',
              style: TextStyle(
                color: Colors.white.withOpacity(0.70),
                decoration: TextDecoration.none,
                fontSize: 14,
                height: 1.35,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                HeroChip(icon: Icons.schedule_rounded, label: item.time),
                HeroChip(icon: Icons.place_rounded, label: item.meetingPoint),
                HeroChip(icon: Icons.groups_rounded, label: '${item.participantCount} kişi'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class HeroChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const HeroChip({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 11),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.10),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.10)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white.withOpacity(0.74)),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white.withOpacity(0.76),
                decoration: TextDecoration.none,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TransportInfoCard extends StatelessWidget {
  final GuestTransportItem item;

  const TransportInfoCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: () {},
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.075),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white.withOpacity(0.10)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.28),
              blurRadius: 26,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: Column(
          children: [
            TransportRow(
              icon: Icons.schedule_rounded,
              title: 'Saat',
              subtitle: item.time,
              accent: const Color(0xFFD6B16A),
            ),
            const SizedBox(height: 13),
            TransportRow(
              icon: Icons.place_rounded,
              title: 'Buluşma Noktası',
              subtitle: item.meetingPoint,
              accent: const Color(0xFF72C7C2),
            ),
            const SizedBox(height: 13),
            TransportRow(
              icon: Icons.directions_car_rounded,
              title: 'Araç / Plaka',
              subtitle: '${item.vehicle} · ${item.plate.isEmpty ? 'Plaka bilgisi paylaşılacak' : item.plate}',
              accent: const Color(0xFF7EA7D8),
            ),
            const SizedBox(height: 13),
            TransportRow(
              icon: Icons.badge_rounded,
              title: 'Sürücü',
              subtitle: item.driver.isEmpty ? 'Bilgi paylaşılacak' : item.driver,
              accent: const Color(0xFF9B8AD8),
            ),
            const SizedBox(height: 13),
            TransportRow(
              icon: Icons.support_agent_rounded,
              title: 'Sorumlu',
              subtitle: '${item.responsible} · ${item.phone}',
              accent: const Color(0xFFC7B58A),
            ),
            if (item.note.isNotEmpty) ...[
              const SizedBox(height: 13),
              TransportRow(
                icon: Icons.notes_rounded,
                title: 'Not',
                subtitle: item.note,
                accent: const Color(0xFFD6B16A),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class TransportRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color accent;

  const TransportRow({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 39,
          height: 39,
          decoration: BoxDecoration(
            color: accent.withOpacity(0.16),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: accent.withOpacity(0.25)),
          ),
          child: Icon(icon, size: 20, color: accent),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  decoration: TextDecoration.none,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.56),
                  decoration: TextDecoration.none,
                  fontSize: 12.7,
                  height: 1.32,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class GuestTransportItem {
  final String id;
  final String title;
  final String type;
  final String category;
  final String location;
  final String time;
  final String meetingPoint;
  final String responsible;
  final String phone;
  final String vehicle;
  final String plate;
  final String driver;
  final int participantCount;
  final String status;
  final String note;
  final bool guestAppVisible;
  final int sortOrder;

  const GuestTransportItem({
    required this.id,
    required this.title,
    required this.type,
    required this.category,
    required this.location,
    required this.time,
    required this.meetingPoint,
    required this.responsible,
    required this.phone,
    required this.vehicle,
    required this.plate,
    required this.driver,
    required this.participantCount,
    required this.status,
    required this.note,
    required this.guestAppVisible,
    required this.sortOrder,
  });

  factory GuestTransportItem.fromFirestore({
    required String id,
    required Map<String, dynamic> data,
  }) {
    int parseInt(dynamic value) {
      if (value is int) return value;
      return int.tryParse((value ?? '0').toString()) ?? 0;
    }

    return GuestTransportItem(
      id: id,
      title: (data['title'] ?? '').toString(),
      type: (data['type'] ?? '').toString(),
      category: (data['category'] ?? '').toString(),
      location: (data['location'] ?? '').toString(),
      time: (data['time'] ?? '').toString(),
      meetingPoint: (data['meetingPoint'] ?? '').toString(),
      responsible: (data['responsible'] ?? '').toString(),
      phone: (data['phone'] ?? '').toString(),
      vehicle: (data['vehicle'] ?? '').toString(),
      plate: (data['plate'] ?? '').toString(),
      driver: (data['driver'] ?? '').toString(),
      participantCount: parseInt(data['participantCount']),
      status: (data['status'] ?? '').toString(),
      note: (data['note'] ?? '').toString(),
      guestAppVisible: data['guestAppVisible'] != false,
      sortOrder: parseInt(data['sortOrder']),
    );
  }
}
