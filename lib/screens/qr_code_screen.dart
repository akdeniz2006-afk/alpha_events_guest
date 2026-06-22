import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/demo_event_data.dart';
import '../theme/app_colors.dart';
import '../widgets/app_page.dart';
import '../widgets/header_title.dart';

class QrCodeScreen extends StatefulWidget {
  const QrCodeScreen({super.key});

  @override
  State<QrCodeScreen> createState() => _QrCodeScreenState();
}

class _QrCodeScreenState extends State<QrCodeScreen> {
  String guestId = 'guest_demo';
  String guestName = '';
  String guestCode = 'ALP001';
  String whatsappNumber = '';
  String eventId = 'zurich_2026';

  @override
  void initState() {
    super.initState();
    loadGuestData();
  }

  Future<void> loadGuestData() async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    setState(() {
      guestId = prefs.getString('guestId') ?? 'guest_demo';
      guestName = prefs.getString('guestName') ?? demoGuest.fullName;
      guestCode = prefs.getString('guestCode') ?? 'ALP001';
      whatsappNumber = prefs.getString('whatsappNumber') ?? '';
      eventId = prefs.getString('eventId') ?? 'zurich_2026';
    });
  }

  String get qrPayload {
    return [
      'ALPHA_EVENTS_CHECKIN',
      'eventId:$eventId',
      'guestId:$guestId',
      'guestName:$guestName',
      'guestCode:$guestCode',
      'phone:$whatsappNumber',
    ].join('|');
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 42),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const BackHeader(
              title: 'QR Kodum',
              subtitle: 'Etkinlik giri\u015Fi i\u00E7in kullan\u0131l\u0131r',
            ),
            const SizedBox(height: 26),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(34),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF101827),
                    Color(0xFF18263A),
                    Color(0xFF22344E),
                  ],
                ),
                border: Border.all(color: Colors.white10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.36),
                    blurRadius: 34,
                    offset: const Offset(0, 20),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 230,
                    height: 230,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: QrImageView(
                      data: qrPayload,
                      version: QrVersions.auto,
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Text(
                    guestName.isEmpty ? demoGuest.fullName : guestName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      decoration: TextDecoration.none,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    demoGuest.eventTitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.66),
                      decoration: TextDecoration.none,
                      fontSize: 13,
                      height: 1.35,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.champagne.withOpacity(0.13),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: AppColors.champagne.withOpacity(0.24),
                      ),
                    ),
                    child: Text(
                      'Kat\u0131l\u0131mc\u0131 Kodu: $guestCode',
                      style: const TextStyle(
                        color: AppColors.champagne,
                        decoration: TextDecoration.none,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: glassDecoration(radius: 26, opacity: 0.070),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    color: AppColors.champagne,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Etkinlik giri\u015Finde bu QR kodu operasyon ekibine g\u00F6sterebilirsiniz.',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.62),
                        decoration: TextDecoration.none,
                        fontSize: 12.8,
                        height: 1.35,
                        fontWeight: FontWeight.w700,
                      ),
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