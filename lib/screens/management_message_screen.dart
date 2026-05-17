import 'package:flutter/material.dart';

import '../data/demo_event_data.dart';
import '../widgets/app_page.dart';
import '../widgets/header_title.dart';

class ManagementMessageScreen extends StatelessWidget {
  const ManagementMessageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPage(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 90),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BackHeader(
              title: 'Ho\u015F Geldiniz',
              subtitle: demoGuest.eventTitle,
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(26),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.075),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white.withOpacity(0.10)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.28),
                    blurRadius: 28,
                    offset: const Offset(0, 18),
                  ),
                ],
              ),
              child: Text(
                'De\u011Ferli Kat\u0131l\u0131mc\u0131m\u0131z,\n\n'
                '${demoGuest.eventTitle} etkinli\u011Fine ho\u015F geldiniz.\n\n'
                'Bu etkinlik boyunca program, konaklama, duyuru, foto\u011Fraf ve acil destek bilgilerinize bu portal \u00FCzerinden kolayca ula\u015Fabilirsiniz.\n\n'
                'Alpha Events olarak sizlere konforlu, g\u00FCvenli ve keyifli bir etkinlik deneyimi sunmaktan mutluluk duyuyoruz.\n\n'
                'Keyifli ve verimli bir etkinlik dileriz.\n\n'
                'Alpha Events Ekibi',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.82),
                  decoration: TextDecoration.none,
                  fontSize: 17,
                  height: 1.55,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
