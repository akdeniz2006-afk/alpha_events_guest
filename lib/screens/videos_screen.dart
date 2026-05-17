import 'package:flutter/material.dart';

import '../data/demo_event_data.dart';
import '../theme/app_colors.dart';
import '../widgets/app_page.dart';
import '../widgets/header_title.dart';
import '../widgets/pressable_scale.dart';

class VideosScreen extends StatelessWidget {
  const VideosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool openedAsSubPage = Navigator.of(context).canPop();

    final VideoItem featuredVideo = demoVideos.isNotEmpty
        ? demoVideos.first
        : const VideoItem(
            title: 'Etkinlik Bilgilendirme Videosu',
            description: 'Program ve genel akış hakkında kısa bilgilendirme.',
            thumbnailLabel: 'INFO',
          );

    final List<VideoItem> otherVideos = demoVideos.length > 1
        ? demoVideos.sublist(1)
        : demoVideos;

    return AppPage(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(18, 16, 18, openedAsSubPage ? 42 : 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            openedAsSubPage
                ? const BackHeader(
                    title: 'Videolar',
                    subtitle: 'Kısa bilgilendirme içerikleri',
                  )
                : const HeaderTitle(
                    title: 'Videolar',
                    subtitle: 'Kısa bilgilendirme içerikleri',
                  ),
            const SizedBox(height: 20),
            const VideosHeroCard(),
            const SizedBox(height: 20),
            FeaturedVideoCard(video: featuredVideo),
            const SizedBox(height: 22),
            const Text(
              'Bilgilendirme Videoları',
              style: TextStyle(
                color: Colors.white,
                decoration: TextDecoration.none,
                fontSize: 21,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 12),
            ...List.generate(otherVideos.length, (index) {
              final video = otherVideos[index];

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: CompactVideoCard(video: video, index: index),
              );
            }),
            const SizedBox(height: 10),
            const VideoInfoCard(),
          ],
        ),
      ),
    );
  }
}

class VideosHeroCard extends StatelessWidget {
  const VideosHeroCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF07101B), Color(0xFF14243A), Color(0xFF263B58)],
        ),
        border: Border.all(color: Colors.white.withOpacity(0.10)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF263B58).withOpacity(0.26),
            blurRadius: 30,
            offset: const Offset(0, 18),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.36),
            blurRadius: 28,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -58,
            top: -68,
            child: Container(
              width: 190,
              height: 190,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.champagne.withOpacity(0.10),
              ),
            ),
          ),
          Positioned(
            left: -70,
            bottom: -86,
            child: Container(
              width: 190,
              height: 190,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.petrolEnd.withOpacity(0.08),
              ),
            ),
          ),
          Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: AppColors.champagne.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.champagne.withOpacity(0.22),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.champagne.withOpacity(0.12),
                      blurRadius: 18,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.play_circle_fill_rounded,
                  color: AppColors.champagne,
                  size: 29,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Etkinlik Video Merkezi',
                      style: TextStyle(
                        color: Colors.white,
                        decoration: TextDecoration.none,
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Program, konaklama ve etkinlik akışına dair kısa bilgilendirme videolarını buradan izleyebilirsiniz.',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.62),
                        decoration: TextDecoration.none,
                        fontSize: 13.2,
                        height: 1.35,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class FeaturedVideoCard extends StatelessWidget {
  final VideoItem video;

  const FeaturedVideoCard({super.key, required this.video});

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: () =>
          showDemoMessage(context, '${video.title} demo olarak oynatılacak.'),
      child: Container(
        height: 232,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: Colors.white.withOpacity(0.11)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF31577B).withOpacity(0.28),
              blurRadius: 28,
              offset: const Offset(0, 18),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.40),
              blurRadius: 28,
              offset: const Offset(0, 18),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(31),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF0A1726),
                      Color(0xFF173758),
                      Color(0xFF2E6E95),
                    ],
                  ),
                ),
              ),
              Positioned(
                right: -34,
                top: -40,
                child: Icon(
                  Icons.play_circle_fill_rounded,
                  size: 180,
                  color: Colors.white.withOpacity(0.07),
                ),
              ),
              Positioned(
                left: -44,
                bottom: -52,
                child: Container(
                  width: 170,
                  height: 170,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.champagne.withOpacity(0.07),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 28,
                      padding: const EdgeInsets.symmetric(horizontal: 11),
                      decoration: BoxDecoration(
                        color: AppColors.champagne.withOpacity(0.14),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.champagne.withOpacity(0.24),
                        ),
                      ),
                      child: const Center(
                        widthFactor: 1,
                        child: Text(
                          'ÖNE ÇIKAN VİDEO',
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
                    const Spacer(),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          width: 68,
                          height: 68,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(0.16),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.22),
                                blurRadius: 18,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 45,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                video.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  decoration: TextDecoration.none,
                                  fontSize: 21,
                                  height: 1.08,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 7),
                              Text(
                                video.description,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.66),
                                  decoration: TextDecoration.none,
                                  fontSize: 12.8,
                                  height: 1.32,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Positioned(
                right: 16,
                top: 16,
                child: Container(
                  height: 32,
                  padding: const EdgeInsets.symmetric(horizontal: 11),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.22),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.10)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.schedule_rounded,
                        color: Colors.white,
                        size: 15,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '01:45',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.84),
                          decoration: TextDecoration.none,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
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

class CompactVideoCard extends StatelessWidget {
  final VideoItem video;
  final int index;

  const CompactVideoCard({super.key, required this.video, required this.index});

  Color getAccent() {
    if (index == 0) return const Color(0xFF72C7C2);
    if (index == 1) return const Color(0xFF7EA7D8);
    return AppColors.champagne;
  }

  String getDuration() {
    if (index == 0) return '02:10';
    if (index == 1) return '01:30';
    return '01:00';
  }

  @override
  Widget build(BuildContext context) {
    final Color accent = getAccent();

    return PressableScale(
      onTap: () =>
          showDemoMessage(context, '${video.title} demo olarak oynatılacak.'),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.070),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: Colors.white.withOpacity(0.09)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.23),
              blurRadius: 20,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 78,
              height: 78,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [accent.withOpacity(0.28), accent.withOpacity(0.10)],
                ),
                border: Border.all(color: accent.withOpacity(0.22)),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      Icons.play_circle_fill_rounded,
                      color: accent,
                      size: 38,
                    ),
                  ),
                  Positioned(
                    left: 9,
                    bottom: 8,
                    child: Text(
                      video.thumbnailLabel,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.58),
                        decoration: TextDecoration.none,
                        fontSize: 8.8,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    video.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      decoration: TextDecoration.none,
                      fontSize: 15.8,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    video.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.54),
                      decoration: TextDecoration.none,
                      height: 1.3,
                      fontSize: 12.4,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(
                        Icons.schedule_rounded,
                        color: Colors.white.withOpacity(0.42),
                        size: 15,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        getDuration(),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.46),
                          decoration: TextDecoration.none,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Icon(
              Icons.chevron_right_rounded,
              color: Colors.white.withOpacity(0.32),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}

class VideoInfoCard extends StatelessWidget {
  const VideoInfoCard({super.key});

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
              'Videolar etkinlik öncesi ve etkinlik süresince kısa bilgilendirme amacıyla paylaşılır. Gerçek yayında videolar admin panelden güncellenebilir.',
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

void showDemoMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
      backgroundColor: const Color(0xFF1F1F24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );
}
