import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/demo_event_data.dart';
import '../theme/app_colors.dart';
import '../widgets/app_page.dart';
import '../widgets/client_logo_badge.dart';
import '../widgets/header_title.dart';
import '../widgets/pressable_scale.dart';

class RoomScreen extends StatelessWidget {
  const RoomScreen({super.key});

  Future<void> callHotel(BuildContext context) async {
    final cleanPhone = demoAccommodationInfo.receptionPhone.replaceAll(' ', '');
    final uri = Uri.parse('tel:$cleanPhone');

    if (!await launchUrl(uri)) {
      if (!context.mounted) return;
      showRoomMessage(
        context,
        'Arama başlatılamadı. Bu özellik cihaz/tarayıcı desteğine bağlıdır.',
      );
    }
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
            const RoomHeroCard(),
            const SizedBox(height: 18),
            const RoomStatusCard(),
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
            const RoomDetailsCard(),
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
            const StayNotesCard(),
            const SizedBox(height: 18),
            PressableScale(
              onTap: () => callHotel(context),
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
                            demoAccommodationInfo.receptionPhone,
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
        ),
      ),
    );
  }
}

class RoomHeroCard extends StatelessWidget {
  const RoomHeroCard({super.key});

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
                  logoPath: demoGuest.clientLogoPath,
                  clientName: demoGuest.clientName,
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
                demoGuest.hotelName,
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
                'Oda ${demoGuest.roomNumber} · ${demoGuest.roomType}',
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
  const RoomStatusCard({super.key});

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
                const Text(
                  'Odanız Hazır',
                  style: TextStyle(
                    color: Colors.white,
                    decoration: TextDecoration.none,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  demoAccommodationInfo.checkInNote,
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
  const RoomDetailsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: glassDecoration(radius: 28, opacity: 0.075),
      child: Column(
        children: [
          RoomDetailRow(
            icon: Icons.meeting_room_rounded,
            title: 'Oda Numarası',
            value: demoGuest.roomNumber,
            accent: const Color(0xFF7EA7D8),
          ),
          const RoomDivider(),
          RoomDetailRow(
            icon: Icons.king_bed_rounded,
            title: 'Oda Tipi',
            value: demoGuest.roomType,
            accent: const Color(0xFF9B8AD8),
          ),
          const RoomDivider(),
          RoomDetailRow(
            icon: Icons.login_rounded,
            title: 'Giriş',
            value: demoGuest.checkIn,
            accent: const Color(0xFFD6B16A),
          ),
          const RoomDivider(),
          RoomDetailRow(
            icon: Icons.logout_rounded,
            title: 'Çıkış',
            value: demoGuest.checkOut,
            accent: const Color(0xFF72C7C2),
          ),
          const RoomDivider(),
          RoomDetailRow(
            icon: Icons.people_alt_rounded,
            title: 'Oda Arkadaşı',
            value: demoGuest.roommateName,
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
                  value,
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
  const StayNotesCard({super.key});

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
            subtitle:
                '${demoAccommodationInfo.breakfastTime} · ${demoAccommodationInfo.breakfastLocation}',
            accent: const Color(0xFFD6B16A),
          ),
          const SizedBox(height: 13),
          StayNoteRow(
            icon: Icons.wifi_rounded,
            title: 'Wi-Fi',
            subtitle:
                'Ağ: ${demoAccommodationInfo.wifiName} · �?ifre: ${demoAccommodationInfo.wifiPassword}',
            accent: const Color(0xFF7EA7D8),
          ),
          const SizedBox(height: 13),
          StayNoteRow(
            icon: Icons.luggage_rounded,
            title: 'Bagaj',
            subtitle: demoAccommodationInfo.luggageNote,
            accent: const Color(0xFF72C7C2),
          ),
          const SizedBox(height: 13),
          StayNoteRow(
            icon: Icons.logout_rounded,
            title: 'Check-out',
            subtitle: demoAccommodationInfo.checkOutNote,
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
                subtitle,
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
