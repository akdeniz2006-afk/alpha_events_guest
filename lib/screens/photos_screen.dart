import 'dart:html' as html;

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
                    title: 'Foto\u011Fraflar',
                    subtitle: 'Etkinlik alb\u00FCm\u00FC',
                  )
                : const HeaderTitle(
                    title: 'Foto\u011Fraflar',
                    subtitle: 'Etkinlik alb\u00FCm\u00FC',
                  ),
            const SizedBox(height: 18),
            const Text(
              'Etkinlik Alb\u00FCm\u00FC',
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
          ],
        ),
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
      barrierColor: Colors.black.withOpacity(0.94),
      builder: (_) {
        return EventPhotoPreviewDialog(imagePath: imagePath, index: index);
      },
    );
  }

  void downloadPhoto(BuildContext context) {
    downloadAssetPhoto(context, imagePath, index);
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
                      Colors.black.withOpacity(0.12),
                      Colors.black.withOpacity(0.46),
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
                    color: Colors.black.withOpacity(0.36),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.14)),
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
                        'Foto\u011Fraf ${index + 1}',
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
                    GestureDetector(
                      onTap: () => downloadPhoto(context),
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: AppColors.champagne.withOpacity(0.20),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.champagne.withOpacity(0.28),
                          ),
                        ),
                        child: const Icon(
                          Icons.download_rounded,
                          color: AppColors.champagne,
                          size: 18,
                        ),
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

  void downloadPhoto(BuildContext context) {
    downloadAssetPhoto(context, imagePath, index);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: InteractiveViewer(
                minScale: 0.8,
                maxScale: 4,
                child: Center(
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.contain,
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 14,
              right: 14,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.58),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.16)),
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                    size: 24,
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
                  Expanded(
                    child: Container(
                      height: 46,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.56),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Colors.white.withOpacity(0.12)),
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Foto\u011Fraf ${index + 1}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            decoration: TextDecoration.none,
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  PressableScale(
                    onTap: () => downloadPhoto(context),
                    child: Container(
                      height: 46,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.champagne,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.champagne.withOpacity(0.24),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.download_rounded,
                            size: 18,
                            color: Color(0xFF111827),
                          ),
                          SizedBox(width: 7),
                          Text(
                            '\u0130ndir',
                            style: TextStyle(
                              color: Color(0xFF111827),
                              decoration: TextDecoration.none,
                              fontSize: 13,
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
      ),
    );
  }
}

String makeSafeFileName(String value) {
  return value
      .toLowerCase()
      .replaceAll('\u011F', 'g')
      .replaceAll('\u00FC', 'u')
      .replaceAll('\u015F', 's')
      .replaceAll('\u0131', 'i')
      .replaceAll('\u00F6', 'o')
      .replaceAll('\u00E7', 'c')
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'-+'), '-')
      .replaceAll(RegExp(r'^-|-$'), '');
}

void downloadAssetPhoto(BuildContext context, String imagePath, int index) {
  try {
    final String url = imagePath.startsWith('http')
        ? imagePath
        : 'assets/$imagePath';

    final String extension = imagePath.split('.').last.toLowerCase();
    final String safeExtension = extension.length <= 5 ? extension : 'jpg';

    final html.AnchorElement anchor = html.AnchorElement(href: url)
      ..setAttribute(
        'download',
        '${makeSafeFileName(demoGuest.eventTitle)}-fotograf-${index + 1}.$safeExtension',
      )
      ..style.display = 'none';

    html.document.body?.append(anchor);
    anchor.click();
    anchor.remove();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Foto\u011Fraf ${index + 1} indiriliyor.'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF1F1F24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  } catch (_) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Foto\u011Fraf indirilemedi. L\u00FCtfen foto\u011Fraf\u0131 a\u00E7\u0131p bas\u0131l\u0131 tutarak kaydedin.',
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF1F1F24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}