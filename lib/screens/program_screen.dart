import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../data/demo_event_data.dart';
import '../theme/app_colors.dart';
import '../widgets/app_page.dart';
import '../widgets/header_title.dart';
import '../widgets/pressable_scale.dart';

class ProgramScreen extends StatefulWidget {
  const ProgramScreen({super.key});

  @override
  State<ProgramScreen> createState() => _ProgramScreenState();
}

class _ProgramScreenState extends State<ProgramScreen> {
  int selectedDayIndex = 0;

  static const String eventId = 'zurich_2026';

  final List<ProgramDayData> days = const [
    ProgramDayData(title: '1. Gün', subtitle: '14 Mayıs'),
    ProgramDayData(title: '2. Gün', subtitle: '15 Mayıs'),
    ProgramDayData(title: '3. Gün', subtitle: '16 Mayıs'),
  ];

  Stream<QuerySnapshot<Map<String, dynamic>>> getProgramStream() {
    return FirebaseFirestore.instance.collection('event_program').snapshots();
  }

  List<FirestoreProgramItem> buildProgramItems(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) {
    final items = snapshot.docs.map((doc) {
      return FirestoreProgramItem.fromMap(doc.data());
    }).toList();

    items.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    return items;
  }

  @override
  Widget build(BuildContext context) {
    final bool openedAsSubPage = Navigator.of(context).canPop();
    final ProgramDayData selectedDay = days[selectedDayIndex];

    return AppPage(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(18, 16, 18, openedAsSubPage ? 42 : 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            openedAsSubPage
                ? BackHeader(
                    title: 'Etkinlik Programı',
                    subtitle: '${selectedDay.subtitle} · ${selectedDay.title}',
                  )
                : HeaderTitle(
                    title: 'Etkinlik Programı',
                    subtitle: '${selectedDay.subtitle} · ${selectedDay.title}',
                  ),
            const SizedBox(height: 20),
            ProgramHeroCard(selectedDay: selectedDay),
            const SizedBox(height: 18),
            DaySelector(
              days: days,
              selectedDayIndex: selectedDayIndex,
              onDaySelected: (index) {
                setState(() {
                  selectedDayIndex = index;
                });
              },
            ),
            const SizedBox(height: 22),
            const Text(
              'Günün Akışı',
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
              stream: getProgramStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const ProgramLoadingCard();
                }

                if (snapshot.hasError) {
                  return ProgramErrorCard(errorText: snapshot.error.toString());
                }

                final snapshotData = snapshot.data;

                if (snapshotData == null) {
                  return ProgramEmptyCard(dayTitle: selectedDay.title);
                }

                final items = buildProgramItems(snapshotData);

                final visibleItems = items.where((item) {
                  return item.eventId == eventId &&
                      item.guestAppStatus == 'Yayında' &&
                      item.dayIndex == selectedDayIndex;
                }).toList();

                if (visibleItems.isEmpty) {
                  return ProgramEmptyCard(dayTitle: selectedDay.title);
                }

                return Column(
                  children: [
                    ...List.generate(visibleItems.length, (index) {
                      final item = visibleItems[index];

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: ProgramTimelineCard(
                          item: item,
                          index: index,
                          isLast: index == visibleItems.length - 1,
                        ),
                      );
                    }),
                    const SizedBox(height: 8),
                    const ProgramInfoCard(),
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

class ProgramHeroCard extends StatelessWidget {
  final ProgramDayData selectedDay;

  const ProgramHeroCard({super.key, required this.selectedDay});

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
            color: Colors.black.withOpacity(0.38),
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
                  Icons.event_available_rounded,
                  color: AppColors.champagne,
                  size: 28,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${selectedDay.title} Programı',
                      style: const TextStyle(
                        color: Colors.white,
                        decoration: TextDecoration.none,
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Program akışı Firestore üzerinden canlı olarak güncellenir.',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.62),
                        decoration: TextDecoration.none,
                        fontSize: 13.2,
                        height: 1.35,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        ProgramHeroPill(
                          icon: Icons.calendar_today_rounded,
                          label: selectedDay.subtitle,
                        ),
                        const SizedBox(width: 8),
                        ProgramHeroPill(
                          icon: Icons.location_on_rounded,
                          label: demoGuest.location,
                        ),
                      ],
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

class ProgramHeroPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const ProgramHeroPill({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 31,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.10)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white.withOpacity(0.68), size: 14),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.70),
              decoration: TextDecoration.none,
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class DaySelector extends StatelessWidget {
  final List<ProgramDayData> days;
  final int selectedDayIndex;
  final ValueChanged<int> onDaySelected;

  const DaySelector({
    super.key,
    required this.days,
    required this.selectedDayIndex,
    required this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(days.length, (index) {
        final day = days[index];

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: index == days.length - 1 ? 0 : 10),
            child: DayChip(
              title: day.title,
              subtitle: day.subtitle,
              selected: selectedDayIndex == index,
              onTap: () => onDaySelected(index),
            ),
          ),
        );
      }),
    );
  }
}

class DayChip extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const DayChip({
    super.key,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      child: Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.champagne.withOpacity(0.13)
              : Colors.white.withOpacity(0.065),
          borderRadius: BorderRadius.circular(21),
          border: Border.all(
            color: selected
                ? AppColors.champagne.withOpacity(0.34)
                : Colors.white.withOpacity(0.09),
          ),
          boxShadow: [
            BoxShadow(
              color: selected
                  ? AppColors.champagne.withOpacity(0.10)
                  : Colors.black.withOpacity(0.22),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              maxLines: 1,
              style: TextStyle(
                color: selected ? AppColors.champagne : Colors.white,
                decoration: TextDecoration.none,
                fontSize: 13.5,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              subtitle,
              maxLines: 1,
              style: TextStyle(
                color: Colors.white.withOpacity(selected ? 0.70 : 0.46),
                decoration: TextDecoration.none,
                fontSize: 11.2,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProgramTimelineCard extends StatelessWidget {
  final FirestoreProgramItem item;
  final int index;
  final bool isLast;

  const ProgramTimelineCard({
    super.key,
    required this.item,
    required this.index,
    required this.isLast,
  });

  IconData getIcon() {
    final String title = item.title.toLowerCase();

    if (title.contains('kahve')) {
      return Icons.local_cafe_rounded;
    }

    if (title.contains('açılış')) {
      return Icons.record_voice_over_rounded;
    }

    if (title.contains('strateji')) {
      return Icons.insights_rounded;
    }

    if (title.contains('öğle') || title.contains('yemek')) {
      return Icons.restaurant_rounded;
    }

    if (title.contains('gala')) {
      return Icons.celebration_rounded;
    }

    return Icons.event_note_rounded;
  }

  Color getAccent() {
    final String title = item.title.toLowerCase();

    if (title.contains('kahve')) {
      return AppColors.champagne;
    }

    if (title.contains('açılış')) {
      return const Color(0xFF7EA7D8);
    }

    if (title.contains('strateji')) {
      return const Color(0xFF9B8AD8);
    }

    if (title.contains('öğle') || title.contains('yemek')) {
      return const Color(0xFF72C7C2);
    }

    if (title.contains('gala')) {
      return const Color(0xFFD6B16A);
    }

    return Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    final bool isActive = index == 0;
    final Color accent = getAccent();

    return PressableScale(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(isActive ? 0.095 : 0.068),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(
            color: isActive
                ? accent.withOpacity(0.30)
                : Colors.white.withOpacity(0.09),
          ),
          boxShadow: [
            BoxShadow(
              color: isActive
                  ? accent.withOpacity(0.08)
                  : Colors.black.withOpacity(0.24),
              blurRadius: 22,
              offset: const Offset(0, 14),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.22),
              blurRadius: 18,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProgramTimeBox(time: item.time, active: isActive, accent: accent),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isActive) ...[
                    Container(
                      height: 26,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: accent.withOpacity(0.13),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: accent.withOpacity(0.22)),
                      ),
                      child: Center(
                        widthFactor: 1,
                        child: Text(
                          'SIRADAKİ AKIŞ',
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
                    const SizedBox(height: 10),
                  ],
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: accent.withOpacity(0.13),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: accent.withOpacity(0.20)),
                        ),
                        child: Icon(getIcon(), color: accent, size: 18),
                      ),
                      const SizedBox(width: 9),
                      Expanded(
                        child: Text(
                          item.title,
                          style: const TextStyle(
                            color: Colors.white,
                            decoration: TextDecoration.none,
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 9),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        size: 16,
                        color: Colors.white.withOpacity(0.50),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          item.location,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.62),
                            decoration: TextDecoration.none,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.description,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.52),
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
      ),
    );
  }
}

class ProgramTimeBox extends StatelessWidget {
  final String time;
  final bool active;
  final Color accent;

  const ProgramTimeBox({
    super.key,
    required this.time,
    required this.active,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(19),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: active
              ? const [AppColors.amberStart, AppColors.amberEnd]
              : const [AppColors.slateStart, AppColors.slateEnd],
        ),
        border: Border.all(
          color: active
              ? accent.withOpacity(0.26)
              : Colors.white.withOpacity(0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: active
                ? accent.withOpacity(0.16)
                : Colors.black.withOpacity(0.24),
            blurRadius: 16,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Center(
        child: Text(
          time,
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
    );
  }
}

class ProgramLoadingCard extends StatelessWidget {
  const ProgramLoadingCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: glassDecoration(radius: 24, opacity: 0.060),
      child: Row(
        children: [
          const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.4,
              color: AppColors.champagne,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Program yükleniyor...',
            style: TextStyle(
              color: Colors.white.withOpacity(0.66),
              decoration: TextDecoration.none,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class ProgramErrorCard extends StatelessWidget {
  final String errorText;

  const ProgramErrorCard({super.key, required this.errorText});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE08A8A).withOpacity(0.10),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE08A8A).withOpacity(0.22)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: Color(0xFFE08A8A),
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Program bilgisi alınamadı.\n$errorText',
              style: TextStyle(
                color: Colors.white.withOpacity(0.72),
                decoration: TextDecoration.none,
                fontSize: 12.5,
                height: 1.35,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ProgramEmptyCard extends StatelessWidget {
  final String dayTitle;

  const ProgramEmptyCard({super.key, required this.dayTitle});

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
            Icons.event_busy_rounded,
            color: AppColors.champagne,
            size: 23,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '$dayTitle için yayınlanmış program bulunmuyor.',
              style: TextStyle(
                color: Colors.white.withOpacity(0.62),
                decoration: TextDecoration.none,
                fontSize: 13,
                height: 1.35,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ProgramInfoCard extends StatelessWidget {
  const ProgramInfoCard({super.key});

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
              'Program akışı etkinlik süresince güncellenebilir. Güncel salon, saat ve yönlendirme bilgilerini bu ekrandan takip edebilirsiniz.',
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

class ProgramDayData {
  final String title;
  final String subtitle;

  const ProgramDayData({
    required this.title,
    required this.subtitle,
  });
}

class FirestoreProgramItem {
  final String eventId;
  final String guestAppStatus;
  final int dayIndex;
  final String time;
  final String title;
  final String location;
  final String description;
  final int sortOrder;

  const FirestoreProgramItem({
    required this.eventId,
    required this.guestAppStatus,
    required this.dayIndex,
    required this.time,
    required this.title,
    required this.location,
    required this.description,
    required this.sortOrder,
  });

  factory FirestoreProgramItem.fromMap(Map<String, dynamic> map) {
    return FirestoreProgramItem(
      eventId: (map['eventId'] ?? '').toString(),
      guestAppStatus: (map['guestAppStatus'] ?? '').toString(),
      dayIndex: int.tryParse((map['dayIndex'] ?? '0').toString()) ?? 0,
      time: (map['time'] ?? '').toString(),
      title: (map['title'] ?? '').toString(),
      location: (map['location'] ?? '').toString(),
      description: (map['description'] ?? '').toString(),
      sortOrder: int.tryParse((map['sortOrder'] ?? '0').toString()) ?? 0,
    );
  }
}