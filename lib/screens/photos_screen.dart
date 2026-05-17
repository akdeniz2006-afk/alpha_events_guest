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
                    subtitle: 'Etkinlik fotoğrafları ve indirme alanı',
                  )
                : const HeaderTitle(
                    title: 'Fotoğraflar',
                    subtitle: 'Etkinlik fotoğrafları ve indirme alanı',
                  ),
            const SizedBox(height: 20),
            const PhotosHeroCard(),
            const SizedBox(height: 18),
            const PhotoDownloadInfoCard(),
            const SizedBox(height: 22),
            const Text(
              'Etkinlik Albümü',
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
              itemCount: demoEventPhotos.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 11,
                mainAxisSpacing: 11,
                childAspectRatio: 0.82,
              ),
              itemBuilder: (context, index) {
                return EventPhotoGridCard(
                  imagePath: demoEventPhotos[index],
                  index: index,
                );
              },
            ),
            const SizedBox(height: 10),
            const PhotoFooterNote(),
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
    final String imagePath = demoEventPhotos.isNotEmpty
        ? demoEventPhotos.first
        : '';

    return Container(
      height: 246,
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
                    Colors.black.withOpacity(0.05),
                    Colors.black.withOpacity(0.24),
                    Colors.black.withOpacity(0.82),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 18,
              top: 18,
              child: Container(
                height: 30,
                padding: const EdgeInsets.symmetric(horizontal: 11),
                decoration: BoxDecoration(
                  color: AppColors.champagne.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.champagne.withOpacity(0.24),
                  ),
                ),
                child: const Center(
                  child: Text(
                    'ETKİNLİK ALBÜMÜ',
                    style: TextStyle(
                      color: AppColors.champagne,
                      decoration: TextDecoration.none,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                    ),
                  ),
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
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.14),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white.withOpacity(0.14)),
                    ),
                    child: const Icon(
                      Icons.collections_rounded,
                      color: Colors.white,
                      size: 27,
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
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '${demoEventPhotos.length} fotoğraf görüntülenebilir',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.68),
                            decoration: TextDecoration.none,
                            fontSize: 12.6,
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

class PhotoDownloadInfoCard extends StatelessWidget {
  const PhotoDownloadInfoCard({super.key});

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
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.champagne.withOpacity(0.13),
              borderRadius: BorderRadius.circular(17),
              border: Border.all(color: AppColors.champagne.withOpacity(0.20)),
            ),
            child: const Icon(
              Icons.cloud_download_rounded,
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
                  'Fotoğrafları görüntüleyin ve indirin',
                  style: TextStyle(
                    color: Colors.white,
                    decoration: TextDecoration.none,
                    fontSize: 15.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Etkinlik sonrası seçilen fotoğraflar burada yayınlanır. Katılımcılar fotoğrafları önizleyebilir ve indirebilir.',
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

class EventPhotoGridCard extends StatelessWidget {
  final String imagePath;
  final int index;

  const EventPhotoGridCard({
    super.key,
    required this.imagePath,
    required this.index,
  });

  void openPreview(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.88),
      builder: (_) {
        return EventPhotoPreviewDialog(imagePath: imagePath, index: index);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: () => openPreview(context),
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
                      Colors.black.withOpacity(0.16),
                      Colors.black.withOpacity(0.42),
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
              Positioned(
                left: 9,
                bottom: 9,
                right: 9,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Fotoğraf ${index + 1}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          decoration: TextDecoration.none,
                          fontSize: 12.6,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.12),
                        ),
                      ),
                      child: const Icon(
                        Icons.download_rounded,
                        color: Colors.white,
                        size: 17,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EventPhotoPreviewDialog extends StatelessWidget {
  final String imagePath;
  final int index;

  const EventPhotoPreviewDialog({
    super.key,
    required this.imagePath,
    required this.index,
  });

  void showDownloadMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Fotoğraf ${index + 1} demo olarak indirilecek.'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF1F1F24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

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
                  Icons.collections_rounded,
                  color: AppColors.champagne,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Etkinlik fotoğrafı ${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      decoration: TextDecoration.none,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                PressableScale(
                  onTap: () => showDownloadMessage(context),
                  child: Container(
                    height: 38,
                    padding: const EdgeInsets.symmetric(horizontal: 13),
                    decoration: BoxDecoration(
                      color: AppColors.champagne.withOpacity(0.13),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: AppColors.champagne.withOpacity(0.24),
                      ),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.download_rounded,
                          size: 17,
                          color: AppColors.champagne,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'İndir',
                          style: TextStyle(
                            color: AppColors.champagne,
                            decoration: TextDecoration.none,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
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

class PhotoFooterNote extends StatelessWidget {
  const PhotoFooterNote({super.key});

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
              'Gerçek yayında etkinlik fotoğrafları admin panelden yüklenir. Katılımcılar seçilen fotoğrafları bu ekrandan görüntüleyebilir ve indirebilir.',
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
