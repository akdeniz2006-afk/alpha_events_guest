import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/app_colors.dart';
import '../widgets/app_page.dart';
import '../widgets/client_logo_badge.dart';
import '../widgets/header_title.dart';
import '../widgets/pressable_scale.dart';

class RoomScreen extends StatelessWidget {
  const RoomScreen({super.key});

  static const String eventId = 'zurich_2026';
  static const String guestId = 'demo_guest';

  Stream<QuerySnapshot<Map<String, dynamic>>> getRoomStream() {
    // GEÇİCİ TEST:
    // Şimdilik filtre kullanmadan event_rooms collection içindeki ilk odayı okuyoruz.
    // Bu çalışırsa sonra eventId / guestId filtresini tekrar güvenli şekilde ekleyeceğiz.
    return FirebaseFirestore.instance
        .collection('event_rooms')
        .limit(1)
        .snapshots();
  }

  Future<void> callHotel(BuildContext context, RoomInfo room) async {
    final cleanPhone = room.receptionPhone.replaceAll(' ', '');
    final uri = Uri.parse('tel:$cleanPhone');

    if (!await launchUrl(uri)) {
      if (!context.mounted) return;
      showRoomMessage(
        context,
        'Arama başlatılamadı. Bu özellik cihaz/tarayıcı desteğine bağlıdır.',
      );
    }
  }

  RoomInfo? buildRoomInfo(QuerySnapshot<Map<String, dynamic>> snapshot) {
    if (snapshot.docs.isEmpty) return null;
    return RoomInfo.fromFirestore(snapshot.docs.first.data());
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
                    title: 'Odam',
                    subtitle: 'Konaklama bilgileriniz',
                  )
                : const HeaderTitle(
                    title: 'Odam',
                    subtitle: 'Konaklama bilgileriniz',
                  ),
            const SizedBox(height: 20),
            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: getRoomStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const RoomLoadingState();
                }

                if (snapshot.hasError) {
                  return RoomErrorState(errorText: snapshot.error.toString());
                }

                final room = snapshot.hasData ? buildRoomInfo(snapshot.data!) : null;

                if (room == null) {
                  return const EmptyRoomState();
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RoomHeroCard(room: room),
                    const SizedBox(height: 18),
                    RoomStatusCard(room: room),
                    const SizedBox(height: 22),
                    const Text(
                      'Oda Bilgileri',
                      style: TextStyle(
                        color: Colors.white,
                        decoration: TextDecoration.none,
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    RoomDetailsCard(room: room),
                    const SizedBox(height: 18),
                    const Text(
                      'Konaklama Notları',
                      style: TextStyle(
                        color: Colors.white,
                        decoration: TextDecoration.none,
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    StayNotesCard(room: room),
                    const SizedBox(height: 18),
                    PressableScale(
                      onTap: () => callHotel(context, room),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: glassDecoration(radius: 26, opacity: 0.075),
                        child: Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: AppColors.champagne.withOpacity(0.13),
                                borderRadius: BorderRadius.circular(17),
                                border: Border.all(
                                  color: AppColors.champagne.withOpacity(0.20),
                                ),
                              ),
                              child: const Icon(
                                Icons.phone_rounded,
                                color: AppColors.champagne,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 13),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Otel Resepsiyonunu Ara',
                                    style: TextStyle(
                                      color: Colors.white,
                                      decoration: TextDecoration.none,
                                      fontSize: 15.5,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    room.receptionPhone,
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.56),
                                      decoration: TextDecoration.none,
                                      fontSize: 12.5,
                                      height: 1.32,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.chevron_right_rounded,
                              color: Colors.white.withOpacity(0.56),
                            ),
                          ],
                        ),
                      ),
                    ),
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

class RoomLoadingState extends StatelessWidget {
  const RoomLoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      width: double.infinity,
      alignment: Alignment.center,
      decoration: glassDecoration(radius: 28, opacity: 0.070),
      child: const CircularProgressIndicator(color: AppColors.champagne),
    );
  }
}

class RoomErrorState extends StatelessWidget {
  final String errorText;

  const RoomErrorState({super.key, required this.errorText});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: glassDecoration(radius: 28, opacity: 0.070),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: AppColors.champagne,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Oda bilgileri şu anda alınamadı. Lütfen daha sonra tekrar kontrol edin.\n$errorText',
              style: TextStyle(
                color: Colors.white.withOpacity(0.62),
                decoration: TextDecoration.none,
                height: 1.35,
                fontSize: 12.8,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class EmptyRoomState extends StatelessWidget {
  const EmptyRoomState({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: glassDecoration(radius: 28, opacity: 0.070),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.hotel_rounded,
            color: AppColors.champagne,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Henüz oda bilginiz yayınlanmadı. Organizasyon ekibi bilgileri yayınladığında burada görünecektir.',
              style: TextStyle(
                color: Colors.white.withOpacity(0.62),
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

class RoomHeroCard extends StatelessWidget {
  final RoomInfo room;

  const RoomHeroCard({super.key, required this.room});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 292,
      width: double.infinity,
      padding: const EdgeInsets.all(18),
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
            color: const Color(0xFF22344E).withOpacity(0.34),
            blurRadius: 34,
            offset: const Offset(0, 18),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.50),
            blurRadius: 32,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -72,
            top: -82,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.champagne.withOpacity(0.10),
              ),
            ),
          ),
          Positioned(
            left: -90,
            bottom: -110,
            child: Container(
              width: 230,
              height: 230,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.petrolEnd.withOpacity(0.08),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 78,
                child: ClientLogoBadge(
                  logoPath: room.clientLogoPath,
                  clientName: room.clientName,
                ),
              ),
              const Spacer(),
              Container(
                height: 58,
                width: 58,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.12)),
                ),
                child: const Icon(
                  Icons.hotel_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                room.hotelName,
                style: const TextStyle(
                  color: Colors.white,
                  decoration: TextDecoration.none,
                  fontSize: 25,
                  height: 1.08,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.7,
                ),
              ),
              const SizedBox(height: 9),
              Text(
                'Oda ${room.roomNumber} · ${room.roomType}',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.66),
                  decoration: TextDecoration.none,
                  fontSize: 14,
                  height: 1.35,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class RoomStatusCard extends StatelessWidget {
  final RoomInfo room;

  const RoomStatusCard({super.key, required this.room});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: glassDecoration(radius: 28, opacity: 0.075),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: AppColors.champagne.withOpacity(0.13),
              borderRadius: BorderRadius.circular(19),
              border: Border.all(color: AppColors.champagne.withOpacity(0.22)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.champagne.withOpacity(0.10),
                  blurRadius: 16,
                  offset: const Offset(0, 9),
                ),
              ],
            ),
            child: const Icon(
              Icons.key_rounded,
              color: AppColors.champagne,
              size: 27,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  room.statusTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    decoration: TextDecoration.none,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  room.checkInNote,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.56),
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

class RoomDetailsCard extends StatelessWidget {
  final RoomInfo room;

  const RoomDetailsCard({super.key, required this.room});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: glassDecoration(radius: 28, opacity: 0.075),
      child: Column(
        children: [
          RoomDetailRow(
            icon: Icons.meeting_room_rounded,
            title: 'Oda Numarası',
            value: room.roomNumber,
            accent: const Color(0xFF7EA7D8),
          ),
          const RoomDivider(),
          RoomDetailRow(
            icon: Icons.king_bed_rounded,
            title: 'Oda Tipi',
            value: room.roomType,
            accent: const Color(0xFF9B8AD8),
          ),
          const RoomDivider(),
          RoomDetailRow(
            icon: Icons.login_rounded,
            title: 'Giriş',
            value: room.checkIn,
            accent: const Color(0xFFD6B16A),
          ),
          const RoomDivider(),
          RoomDetailRow(
            icon: Icons.logout_rounded,
            title: 'Çıkış',
            value: room.checkOut,
            accent: const Color(0xFF72C7C2),
          ),
          const RoomDivider(),
          RoomDetailRow(
            icon: Icons.people_alt_rounded,
            title: 'Oda Arkadaşı',
            value: room.roommateName,
            accent: const Color(0xFFAAB4C3),
          ),
        ],
      ),
    );
  }
}

class RoomDetailRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color accent;

  const RoomDetailRow({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.13),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: accent.withOpacity(0.22)),
            ),
            child: Icon(icon, color: accent, size: 22),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.52),
                    decoration: TextDecoration.none,
                    fontSize: 12.3,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value.isEmpty ? '-' : value,
                  style: const TextStyle(
                    color: Colors.white,
                    decoration: TextDecoration.none,
                    fontSize: 15.2,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.1,
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

class RoomDivider extends StatelessWidget {
  const RoomDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      color: Colors.white.withOpacity(0.075),
    );
  }
}

class StayNotesCard extends StatelessWidget {
  final RoomInfo room;

  const StayNotesCard({super.key, required this.room});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: glassDecoration(radius: 28, opacity: 0.075),
      child: Column(
        children: [
          StayNoteRow(
            icon: Icons.restaurant_rounded,
            title: 'Kahvaltı',
            subtitle: '${room.breakfastTime} · ${room.breakfastLocation}',
            accent: const Color(0xFFD6B16A),
          ),
          const SizedBox(height: 13),
          StayNoteRow(
            icon: Icons.wifi_rounded,
            title: 'Wi-Fi',
            subtitle: 'Ağ: ${room.wifiName} · Şifre: ${room.wifiPassword}',
            accent: const Color(0xFF7EA7D8),
          ),
          const SizedBox(height: 13),
          StayNoteRow(
            icon: Icons.luggage_rounded,
            title: 'Bagaj',
            subtitle: room.luggageNote,
            accent: const Color(0xFF72C7C2),
          ),
          const SizedBox(height: 13),
          StayNoteRow(
            icon: Icons.logout_rounded,
            title: 'Check-out',
            subtitle: room.checkOutNote,
            accent: const Color(0xFFAAB4C3),
          ),
        ],
      ),
    );
  }
}

class StayNoteRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color accent;

  const StayNoteRow({
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
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: accent.withOpacity(0.13),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: accent.withOpacity(0.22)),
          ),
          child: Icon(icon, color: accent, size: 21),
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
                  fontSize: 14.8,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle.isEmpty ? '-' : subtitle,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.56),
                  decoration: TextDecoration.none,
                  fontSize: 12.6,
                  height: 1.33,
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

class RoomInfo {
  final String hotelName;
  final String roomNumber;
  final String roomType;
  final String checkIn;
  final String checkOut;
  final String roommateName;
  final String receptionPhone;
  final String checkInNote;
  final String checkOutNote;
  final String breakfastTime;
  final String breakfastLocation;
  final String wifiName;
  final String wifiPassword;
  final String luggageNote;
  final String statusTitle;
  final String clientName;
  final String clientLogoPath;

  const RoomInfo({
    required this.hotelName,
    required this.roomNumber,
    required this.roomType,
    required this.checkIn,
    required this.checkOut,
    required this.roommateName,
    required this.receptionPhone,
    required this.checkInNote,
    required this.checkOutNote,
    required this.breakfastTime,
    required this.breakfastLocation,
    required this.wifiName,
    required this.wifiPassword,
    required this.luggageNote,
    required this.statusTitle,
    required this.clientName,
    required this.clientLogoPath,
  });

  factory RoomInfo.fromFirestore(Map<String, dynamic> data) {
    return RoomInfo(
      hotelName: (data['hotelName'] ?? '').toString(),
      roomNumber: (data['roomNumber'] ?? '').toString(),
      roomType: (data['roomType'] ?? '').toString(),
      checkIn: (data['checkIn'] ?? '').toString(),
      checkOut: (data['checkOut'] ?? '').toString(),
      roommateName: (data['roommateName'] ?? '').toString(),
      receptionPhone: (data['receptionPhone'] ?? '').toString(),
      checkInNote: (data['checkInNote'] ?? '').toString(),
      checkOutNote: (data['checkOutNote'] ?? '').toString(),
      breakfastTime: (data['breakfastTime'] ?? '').toString(),
      breakfastLocation: (data['breakfastLocation'] ?? '').toString(),
      wifiName: (data['wifiName'] ?? '').toString(),
      wifiPassword: (data['wifiPassword'] ?? '').toString(),
      luggageNote: (data['luggageNote'] ?? '').toString(),
      statusTitle: (data['statusTitle'] ?? 'Odanız Hazır').toString(),
      clientName: (data['clientName'] ?? 'Alpha Events').toString(),
      clientLogoPath: (data['clientLogoPath'] ?? '').toString(),
    );
  }
}

void showRoomMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
      backgroundColor: const Color(0xFF1F1F24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );
}
