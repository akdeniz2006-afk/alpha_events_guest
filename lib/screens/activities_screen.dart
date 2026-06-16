import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/app_colors.dart';
import '../widgets/app_page.dart';
import '../widgets/pressable_scale.dart';

class ActivitiesScreen extends StatefulWidget {
  const ActivitiesScreen({super.key});

  @override
  State<ActivitiesScreen> createState() => _ActivitiesScreenState();
}

class _ActivitiesScreenState extends State<ActivitiesScreen> {
  static const String eventId = 'zurich_2026';

  String guestId = '';
  String guestName = '';
  bool isLoadingGuest = true;

  @override
  void initState() {
    super.initState();
    loadGuest();
  }

  Future<void> loadGuest() async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    setState(() {
      guestId = prefs.getString('guestId') ?? '';
      guestName = prefs.getString('guestName') ?? '';
      isLoadingGuest = false;
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getActivitiesStream() {
    return FirebaseFirestore.instance
        .collection('event_activities')
        .where('eventId', isEqualTo: eventId)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getResponsesStream() {
    return FirebaseFirestore.instance
        .collection('event_activity_responses')
        .where('eventId', isEqualTo: eventId)
        .where('guestId', isEqualTo: guestId)
        .snapshots();
  }

  List<ActivityItem> buildActivities(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) {
    final items = snapshot.docs.map((doc) {
      return ActivityItem.fromFirestore(id: doc.id, data: doc.data());
    }).where((item) {
      return item.guestAppVisible;
    }).toList();

    items.sort((a, b) {
      final sortCompare = a.sortOrder.compareTo(b.sortOrder);
      if (sortCompare != 0) return sortCompare;
      return '${a.date} ${a.time}'.compareTo('${b.date} ${b.time}');
    });

    return items;
  }

  Map<String, bool> buildAnswers(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) {
    final result = <String, bool>{};

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final activityId = (data['activityId'] ?? '').toString();
      final answer = data['answer'];

      if (activityId.isNotEmpty && answer is bool) {
        result[activityId] = answer;
      }
    }

    return result;
  }

  Future<void> setAnswer(ActivityItem activity, bool value) async {
    if (guestId.isEmpty) return;

    final docId = '${activity.id}_$guestId';

    await FirebaseFirestore.instance
        .collection('event_activity_responses')
        .doc(docId)
        .set({
      'eventId': eventId,
      'activityId': activity.id,
      'activityTitle': activity.title,
      'guestId': guestId,
      'guestName': guestName,
      'answer': value,
      'status': value ? 'Katılacak' : 'Katılmayacak',
      'updatedAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  Widget build(BuildContext context) {
    if (isLoadingGuest) {
      return const AppPage(
        child: Center(
          child: CircularProgressIndicator(
            color: AppColors.champagne,
            strokeWidth: 2.6,
          ),
        ),
      );
    }

    return AppPage(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ActivitiesHeader(),
            const SizedBox(height: 18),
            const ActivitiesIntroCard(),
            const SizedBox(height: 20),
            const Text(
              'Etkinlik Aktiviteleri',
              style: TextStyle(
                color: Colors.white,
                decoration: TextDecoration.none,
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 12),
            if (guestId.isEmpty)
              const ActivitiesEmptyState(
                icon: Icons.lock_outline_rounded,
                title: 'Katılımcı bilgisi bulunamadı',
                subtitle:
                    'Aktivite yanıtlarını kaydetmek için lütfen tekrar giriş yapınız.',
              )
            else
              StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: getActivitiesStream(),
                builder: (context, activitiesSnapshot) {
                  if (activitiesSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const ActivitiesLoadingState();
                  }

                  if (activitiesSnapshot.hasError) {
                    return ActivitiesErrorState(
                      text:
                          'Aktiviteler alınamadı:\n${activitiesSnapshot.error}',
                    );
                  }

                  final activities = activitiesSnapshot.hasData
                      ? buildActivities(activitiesSnapshot.data!)
                      : <ActivityItem>[];

                  if (activities.isEmpty) {
                    return const ActivitiesEmptyState(
                      icon: Icons.event_busy_rounded,
                      title: 'Aktivite bulunmuyor',
                      subtitle:
                          'Organizasyon ekibi aktivite bilgilerini yayınladığında burada görünecek.',
                    );
                  }

                  return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: getResponsesStream(),
                    builder: (context, responsesSnapshot) {
                      final answers = responsesSnapshot.hasData
                          ? buildAnswers(responsesSnapshot.data!)
                          : <String, bool>{};

                      return Column(
                        children: activities.map((activity) {
                          final answer = answers[activity.id];

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: ActivityCard(
                              activity: activity,
                              answer: answer,
                              onJoin: () => setAnswer(activity, true),
                              onDecline: () => setAnswer(activity, false),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class ActivitiesLoadingState extends StatelessWidget {
  const ActivitiesLoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      alignment: Alignment.center,
      child: const CircularProgressIndicator(
        color: AppColors.champagne,
        strokeWidth: 2.6,
      ),
    );
  }
}

class ActivitiesErrorState extends StatelessWidget {
  final String text;

  const ActivitiesErrorState({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFE08A8A).withOpacity(0.10),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE08A8A).withOpacity(0.22)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white.withOpacity(0.78),
          decoration: TextDecoration.none,
          fontSize: 13,
          height: 1.4,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class ActivitiesEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const ActivitiesEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.075),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.10)),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.champagne, size: 36),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              decoration: TextDecoration.none,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
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
    );
  }
}

class ActivitiesHeader extends StatelessWidget {
  const ActivitiesHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        PressableScale(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.09),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.12)),
            ),
            child: const Icon(
              Icons.arrow_back_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Aktiviteler',
                style: TextStyle(
                  color: Colors.white,
                  decoration: TextDecoration.none,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.6,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Katılım durumunuzu seçiniz',
                style: TextStyle(
                  color: Color(0x88FFFFFF),
                  decoration: TextDecoration.none,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ActivitiesIntroCard extends StatelessWidget {
  const ActivitiesIntroCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF101827), Color(0xFF1D2D45), Color(0xFF28496B)],
        ),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF28496B).withOpacity(0.22),
            blurRadius: 26,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: AppColors.champagne.withOpacity(0.14),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.champagne.withOpacity(0.24),
              ),
            ),
            child: const Icon(
              Icons.event_available_rounded,
              color: AppColors.champagne,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              'Etkinlik sırasında yapılacak aktiviteler için katılım durumunuzu lütfen güncel tutunuz. Seçiminiz organizasyon ekibinin kapasite, transfer ve operasyon planlamasını doğru yapmasına yardımcı olur.',
              style: TextStyle(
                color: Colors.white.withOpacity(0.68),
                decoration: TextDecoration.none,
                fontSize: 13,
                height: 1.42,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ActivityCard extends StatelessWidget {
  final ActivityItem activity;
  final bool? answer;
  final VoidCallback onJoin;
  final VoidCallback onDecline;

  const ActivityCard({
    super.key,
    required this.activity,
    required this.answer,
    required this.onJoin,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    final bool joined = answer == true;
    final bool declined = answer == false;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.075),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: answer == null
              ? Colors.white.withOpacity(0.10)
              : activity.accent.withOpacity(0.32),
        ),
        boxShadow: [
          BoxShadow(
            color: activity.accent.withOpacity(answer == null ? 0.04 : 0.13),
            blurRadius: 22,
            offset: const Offset(0, 14),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.28),
            blurRadius: 24,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ActivityIconBox(activity: activity),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity.title,
                      style: const TextStyle(
                        color: Colors.white,
                        decoration: TextDecoration.none,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${activity.date} · ${activity.time}',
                      style: TextStyle(
                        color: activity.accent.withOpacity(0.94),
                        decoration: TextDecoration.none,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            activity.description,
            style: TextStyle(
              color: Colors.white.withOpacity(0.62),
              decoration: TextDecoration.none,
              fontSize: 13,
              height: 1.42,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          ActivityInfoPill(
            icon: Icons.place_rounded,
            label: activity.location,
          ),
          const SizedBox(height: 8),
          ActivityInfoPill(
            icon: Icons.people_alt_rounded,
            label: 'Kontenjan: ${activity.capacity}',
          ),
          const SizedBox(height: 14),
          StatusBox(answer: answer, accent: activity.accent),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ChoiceButton(
                  label: 'Katılacağım',
                  selected: joined,
                  accent: activity.accent,
                  icon: Icons.check_rounded,
                  onTap: onJoin,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ChoiceButton(
                  label: 'Katılmayacağım',
                  selected: declined,
                  accent: const Color(0xFFE08A8A),
                  icon: Icons.close_rounded,
                  onTap: onDecline,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ActivityIconBox extends StatelessWidget {
  final ActivityItem activity;

  const ActivityIconBox({super.key, required this.activity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        color: activity.accent.withOpacity(0.14),
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: activity.accent.withOpacity(0.24)),
        boxShadow: [
          BoxShadow(
            color: activity.accent.withOpacity(0.14),
            blurRadius: 18,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Icon(activity.icon, color: activity.accent, size: 27),
    );
  }
}

class ActivityInfoPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const ActivityInfoPill({
    super.key,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 38),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.065),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white.withOpacity(0.54), size: 17),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.66),
                decoration: TextDecoration.none,
                fontSize: 12.5,
                height: 1.2,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class StatusBox extends StatelessWidget {
  final bool? answer;
  final Color accent;

  const StatusBox({super.key, required this.answer, required this.accent});

  @override
  Widget build(BuildContext context) {
    String title;
    IconData icon;
    Color color;

    if (answer == true) {
      title = 'Katılımınız onaylandı';
      icon = Icons.check_circle_rounded;
      color = accent;
    } else if (answer == false) {
      title = 'Katılmayacağınız kaydedildi';
      icon = Icons.cancel_rounded;
      color = const Color(0xFFE08A8A);
    } else {
      title = 'Cevap bekleniyor';
      icon = Icons.schedule_rounded;
      color = const Color(0xFFD6B16A);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: color.withOpacity(0.20)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 19),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: color,
                decoration: TextDecoration.none,
                fontSize: 12.8,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChoiceButton extends StatelessWidget {
  final String label;
  final bool selected;
  final Color accent;
  final IconData icon;
  final VoidCallback onTap;

  const ChoiceButton({
    super.key,
    required this.label,
    required this.selected,
    required this.accent,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 45,
        decoration: BoxDecoration(
          color: selected
              ? accent.withOpacity(0.18)
              : Colors.white.withOpacity(0.07),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected
                ? accent.withOpacity(0.44)
                : Colors.white.withOpacity(0.10),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: selected ? accent : Colors.white.withOpacity(0.62),
              size: 18,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: selected ? accent : Colors.white.withOpacity(0.70),
                  decoration: TextDecoration.none,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ActivityItem {
  final String id;
  final String title;
  final String date;
  final String time;
  final String location;
  final String capacity;
  final String description;
  final Color accent;
  final IconData icon;
  final bool guestAppVisible;
  final int sortOrder;

  const ActivityItem({
    required this.id,
    required this.title,
    required this.date,
    required this.time,
    required this.location,
    required this.capacity,
    required this.description,
    required this.accent,
    required this.icon,
    required this.guestAppVisible,
    required this.sortOrder,
  });

  factory ActivityItem.fromFirestore({
    required String id,
    required Map<String, dynamic> data,
  }) {
    int parseInt(dynamic value) {
      if (value is int) return value;
      return int.tryParse((value ?? '0').toString()) ?? 0;
    }

    return ActivityItem(
      id: id,
      title: (data['title'] ?? '').toString(),
      date: (data['date'] ?? '').toString(),
      time: (data['time'] ?? '').toString(),
      location: (data['location'] ?? '').toString(),
      capacity: (data['capacity'] ?? 'Belirlenmedi').toString(),
      description: (data['description'] ?? '').toString(),
      accent: activityAccent((data['category'] ?? '').toString()),
      icon: activityIcon((data['category'] ?? '').toString()),
      guestAppVisible: data['guestAppVisible'] != false,
      sortOrder: parseInt(data['sortOrder']),
    );
  }
}

Color activityAccent(String category) {
  switch (category) {
    case 'Deniz':
      return const Color(0xFF72C7C2);
    case 'Gala':
      return const Color(0xFFD6B16A);
    case 'Workshop':
      return const Color(0xFF9B8AD8);
    case 'Şehir':
      return const Color(0xFF7EA7D8);
    case 'Networking':
      return const Color(0xFF88D18A);
    default:
      return const Color(0xFFD6B16A);
  }
}

IconData activityIcon(String category) {
  switch (category) {
    case 'Deniz':
      return Icons.directions_boat_filled_rounded;
    case 'Gala':
      return Icons.dinner_dining_rounded;
    case 'Workshop':
      return Icons.groups_rounded;
    case 'Şehir':
      return Icons.location_city_rounded;
    case 'Networking':
      return Icons.handshake_rounded;
    default:
      return Icons.event_available_rounded;
  }
}
