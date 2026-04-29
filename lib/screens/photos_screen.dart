import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/app_page.dart';
import '../widgets/header_title.dart';
import '../widgets/pressable_scale.dart';

class PhotosScreen extends StatelessWidget {
  const PhotosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final photos = [
      PhotoItem(
        title: 'Açılış',
        subtitle: 'Ana Salon',
        icon: Icons.event_available_rounded,
        colors: const [AppColors.navyStart, AppColors.navyEnd],
      ),
      PhotoItem(
        title: 'Toplantı',
        subtitle: 'Strateji Oturumu',
        icon: Icons.groups_rounded,
        colors: const [AppColors.petrolStart, AppColors.petrolEnd],
      ),
      PhotoItem(
        title: 'Gala',
        subtitle: 'Balo Salonu',
        icon: Icons.celebration_rounded,
        colors: const [AppColors.amberStart, AppColors.amberEnd],
      ),
      PhotoItem(
        title: 'Sahne',
        subtitle: 'Akşam Programı',
        icon: Icons.mic_external_on_rounded,
        colors: const [AppColors.slateStart, AppColors.slateEnd],
      ),
    ];

    return AppPage(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 108),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const HeaderTitle(
              title: 'Fotoğraflar',
              subtitle: 'Etkinlik fotoğraflarını görüntüleyin ve indirin',
            ),
            const SizedBox(height: 22),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.96,
              children: photos.map((photo) {
                return PhotoCard(photo: photo);
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class PhotoItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> colors;

  const PhotoItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.colors,
  });
}

class PhotoCard extends StatelessWidget {
  final PhotoItem photo;

  const PhotoCard({
    super.key,
    required this.photo,
  });

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: () => showDemoMessage(
        context,
        '${photo.title} fotoğrafları Firebase Storage sonrası açılacak.',
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: photo.colors,
          ),
          border: Border.all(color: Colors.white.withOpacity(0.12)),
          boxShadow: [
            BoxShadow(
              color: photo.colors.first.withOpacity(0.24),
              blurRadius: 22,
              offset: const Offset(0, 14),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.34),
              blurRadius: 20,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -18,
              top: -18,
              child: Icon(
                photo.icon,
                size: 92,
                color: Colors.white.withOpacity(0.12),
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withOpacity(0.14),
                      Colors.transparent,
                      Colors.black.withOpacity(0.12),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(),
                  Icon(
                    photo.icon,
                    size: 30,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 13),
                  Text(
                    photo.title,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    photo.subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.72),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: SmallPillButton(
                          label: 'Gör',
                          onTap: () => showDemoMessage(
                            context,
                            '${photo.title} fotoğrafları açılacak.',
                          ),
                        ),
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: SmallPillButton(
                          label: 'İndir',
                          onTap: () => showDemoMessage(
                            context,
                            'İndirme özelliği Storage sonrası bağlanacak.',
                          ),
                        ),
                      ),
                    ],
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

class SmallPillButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const SmallPillButton({
    super.key,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      child: Container(
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.18),
          borderRadius: BorderRadius.circular(17),
          border: Border.all(color: Colors.white.withOpacity(0.12)),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w900,
          ),
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