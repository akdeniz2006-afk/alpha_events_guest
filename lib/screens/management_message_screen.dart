import 'package:flutter/material.dart';

import '../widgets/app_page.dart';
import '../widgets/header_title.dart';

class ManagementMessageScreen extends StatelessWidget {
  const ManagementMessageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPage(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const BackHeader(
              title: 'Yönetim Mesajı',
              subtitle: 'Etkinlik karşılama notu',
            ),
            const SizedBox(height: 22),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: glassDecoration(),
              child: Text(
                'Değerli Katılımcımız,\n\n'
                'Borusan Liderlik Zirvesi 2026’ya hoş geldiniz.\n\n'
                'Bu etkinlik boyunca program, konaklama, transfer, fotoğraf ve acil durum bilgilerinize bu portal üzerinden kolayca ulaşabilirsiniz.\n\n'
                'Alpha Events olarak sizlere konforlu, güvenli ve keyifli bir etkinlik deneyimi sunmaktan mutluluk duyuyoruz.\n\n'
                'Keyifli ve verimli bir etkinlik dileriz.\n\n'
                'Alpha Events Ekibi',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.80),
                  fontSize: 15.5,
                  height: 1.52,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
