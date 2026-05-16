import 'package:flutter/material.dart';

import '../data/demo_event_data.dart';
import '../theme/app_colors.dart';
import '../widgets/app_page.dart';
import '../widgets/header_title.dart';
import '../widgets/pressable_scale.dart';

class PhotosScreen extends StatelessWidget {
  const PhotosScreen({super.key});

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
                    title: 'Fotoğraflar',
                    subtitle: 'Etkinlik ve konaklama görselleri',
                  )
                : const HeaderTitle(
                    title: 'Fotoğraflar',
                    subtitle: 'Etkinlik ve konaklama görselleri',
                  ),
            const SizedBox(height: 20),
            const PhotosHeroCard(),
            const SizedBox(height: 18),
            const PhotoInfoCard(),
            const SizedBox(height: 22),
            const Text(
              'Galeri',
              style: TextStyle(
                color: Colors.white,
                decoration: TextDecoration.none,
                fontSize: 21,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: demoHotelPhotos.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 11,
                mainAxisSpacing: 11,
                childAspectRatio: 0.82,
              ),
              itemBuilder: (context, index) {
                return PhotoGridCard(
                  imagePath: demoHotelPhotos[index],
                  index: index,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class PhotosHeroCard extends StatelessWidget {
  const PhotosHeroCard({super.key});

  @override
  Widget build(BuildContext context) {
    final String imagePath = demoHotelPhotos.isNotEmpty
        ? demoHotelPhotos.first
        : '';

    return Container(
      height: 238,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withOpacity(0.10)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.38),
            blurRadius: 30,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(31),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (imagePath.isNotEmpty)
              Image.asset(
                imagePath,
                fit: BoxFit.cover,
                alignment: Alignment.center,
              )
            else
              Container(
                color: Colors.white.withOpacity(0.08),
                child: const Icon(
                  Icons.photo_library_rounded,
                  size: 62,
                  color: Colors.white,
                ),
              ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.06),
                    Colors.black.withOpacity(0.28),
                    Colors.black.withOpacity(0.78),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 18,
              right: 18,
              bottom: 18,
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.14),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white.withOpacity(0.14)),
                    ),
                    child: const Icon(
                      Icons.photo_library_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Etkinlik Fotoğrafları',
                          style: TextStyle(
                            color: Colors.white,
                            decoration: TextDecoration.none,
                            fontSize: 21,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '${demoHotelPhotos.length} görsel hazır',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.68),
                            decoration: TextDecoration.none,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
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

class PhotoInfoCard extends StatelessWidget {
  const PhotoInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: glassDecoration(radius: 26, opacity: 0.070),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.champagne.withOpacity(0.13),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.champagne.withOpacity(0.20)),
            ),
            child: const Icon(
              Icons.cloud_download_rounded,
              color: AppColors.champagne,
              size: 23,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Fotoğraf paylaşım alanı',
                  style: TextStyle(
                    color: Colors.white,
                    decoration: TextDecoration.none,
                    fontSize: 15.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Etkinlik sonrası seçilen fotoğraflar burada görüntülenebilir ve indirilebilir olacak.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.58),
                    decoration: TextDecoration.none,
                    fontSize: 12.7,
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

class PhotoGridCard extends StatelessWidget {
  final String imagePath;
  final int index;

  const PhotoGridCard({
    super.key,
    required this.imagePath,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: () {
        showDialog(
          context: context,
          barrierColor: Colors.black.withOpacity(0.88),
          builder: (_) {
            return PhotoPreviewDialog(imagePath: imagePath, index: index);
          },
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.10)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.30),
              blurRadius: 22,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(23),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                imagePath,
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.20),
                    ],
                  ),
                ),
              ),
              Positioned(
                right: 9,
                top: 9,
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.34),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.12)),
                  ),
                  child: const Icon(
                    Icons.open_in_full_rounded,
                    color: Colors.white,
                    size: 17,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PhotoPreviewDialog extends StatelessWidget {
  final String imagePath;
  final int index;

  const PhotoPreviewDialog({
    super.key,
    required this.imagePath,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Stack(
              children: [
                Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.52),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.16),
                        ),
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: glassDecoration(radius: 22, opacity: 0.090),
            child: Row(
              children: [
                const Icon(
                  Icons.image_rounded,
                  color: AppColors.champagne,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Fotoğraf ${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      decoration: TextDecoration.none,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Container(
                  height: 36,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white.withOpacity(0.10)),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.download_rounded,
                        size: 17,
                        color: Colors.white,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'İndir',
                        style: TextStyle(
                          color: Colors.white,
                          decoration: TextDecoration.none,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
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
