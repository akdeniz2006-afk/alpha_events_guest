import 'package:flutter/material.dart';

import '../data/demo_event_data.dart';
import '../widgets/app_page.dart';
import '../widgets/header_title.dart';
import '../widgets/pressable_scale.dart';

class VideosScreen extends StatelessWidget {
  const VideosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPage(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const BackHeader(
              title: 'Videolar',
              subtitle: 'Kısa bilgilendirme videoları',
            ),
            const SizedBox(height: 22),
            ...demoVideos.map((video) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: VideoCard(video: video),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class VideoCard extends StatelessWidget {
  final VideoItem video;

  const VideoCard({super.key, required this.video});

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: () => showDemoMessage(context, '${video.title} oynatılacak.'),
      child: Container(
        height: 158,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF17575B), Color(0xFF55A1A4)],
          ),
          border: Border.all(color: Colors.white.withOpacity(0.13)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF17575B).withOpacity(0.26),
              blurRadius: 22,
              offset: const Offset(0, 14),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.32),
              blurRadius: 22,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -20,
              top: -30,
              child: Icon(
                Icons.play_circle_fill_rounded,
                size: 124,
                color: Colors.white.withOpacity(0.10),
              ),
            ),
            Row(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.17),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.14)),
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    size: 46,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        video.thumbnailLabel,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.62),
                          fontSize: 10.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.1,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        video.title,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        video.description,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.68),
                          height: 1.28,
                          fontSize: 13,
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
