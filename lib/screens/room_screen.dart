import 'package:flutter/material.dart';

import '../data/demo_event_data.dart';
import '../theme/app_colors.dart';
import '../widgets/app_page.dart';
import '../widgets/borusan_logo_badge.dart';
import '../widgets/header_title.dart';
import '../widgets/info_list_card.dart';
import '../widgets/pressable_scale.dart';

class RoomScreen extends StatelessWidget {
  const RoomScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPage(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 108),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const HeaderTitle(
              title: 'Odam',
              subtitle: 'Konaklama bilgileriniz',
            ),
            const SizedBox(height: 22),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF111827),
                    Color(0xFF27334A),
                    Color(0xFF3C465C),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF3C465C).withOpacity(0.22),
                    blurRadius: 30,
                    offset: const Offset(0, 18),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const BorusanLogoBadge(),
                  const SizedBox(height: 22),
                  const Icon(
                    Icons.hotel_rounded,
                    size: 38,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 18),
                  Text(
                    demoGuest.hotelName,
                    style: const TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Oda ${demoGuest.roomNumber} · ${demoGuest.roomType}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.68),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            InfoListCard(
              items: [
                InfoListItem(
                  icon: Icons.meeting_room_rounded,
                  title: 'Oda Numarası',
                  value: demoGuest.roomNumber,
                ),
                InfoListItem(
                  icon: Icons.king_bed_rounded,
                  title: 'Oda Tipi',
                  value: demoGuest.roomType,
                ),
                InfoListItem(
                  icon: Icons.login_rounded,
                  title: 'Giriş',
                  value: demoGuest.checkIn,
                ),
                InfoListItem(
                  icon: Icons.logout_rounded,
                  title: 'Çıkış',
                  value: demoGuest.checkOut,
                ),
                InfoListItem(
                  icon: Icons.people_alt_rounded,
                  title: 'Oda Arkadaşı',
                  value: demoGuest.roommateName,
                ),
              ],
            ),
            const SizedBox(height: 16),
            PressableScale(
              onTap: () => showDemoMessage(
                context,
                'Otel arama özelliği Firebase sonrası bağlanacak.',
              ),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: glassDecoration(),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.phone_rounded, size: 23),
                    ),
                    const SizedBox(width: 13),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Otel Resepsiyonunu Ara',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Otel ile hızlı iletişim',
                            style: TextStyle(
                              color: AppColors.mutedText,
                              fontSize: 12.5,
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

void showDemoMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
      backgroundColor: const Color(0xFF1F1F24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
  );
}