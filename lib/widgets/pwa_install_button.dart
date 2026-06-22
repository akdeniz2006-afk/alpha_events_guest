import 'dart:html' as html;
import 'dart:js_util' as js_util;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'pressable_scale.dart';

class PwaInstallButton extends StatefulWidget {
  const PwaInstallButton({super.key});

  @override
  State<PwaInstallButton> createState() => _PwaInstallButtonState();
}

class _PwaInstallButtonState extends State<PwaInstallButton> {
  Object? deferredPrompt;
  bool canInstallOnAndroid = false;
  bool isInstalled = false;

  @override
  void initState() {
    super.initState();

    isInstalled = _isRunningStandalone();

    html.window.addEventListener('beforeinstallprompt', (event) {
      event.preventDefault();

      if (!mounted) return;

      setState(() {
        deferredPrompt = event;
        canInstallOnAndroid = true;
      });
    });
  }

  bool _isRunningStandalone() {
    final displayModeStandalone =
        html.window.matchMedia('(display-mode: standalone)').matches;

    final iosStandalone =
        js_util.getProperty(html.window.navigator, 'standalone') == true;

    return displayModeStandalone || iosStandalone;
  }

  bool _isIOS() {
    final userAgent = html.window.navigator.userAgent.toLowerCase();
    return userAgent.contains('iphone') ||
        userAgent.contains('ipad') ||
        userAgent.contains('ipod');
  }

  bool _isAndroid() {
    final userAgent = html.window.navigator.userAgent.toLowerCase();
    return userAgent.contains('android');
  }

  Future<void> _handleTap() async {
    if (_isRunningStandalone()) {
      _showAlreadyInstalledSheet();
      return;
    }

    if (_isAndroid() && deferredPrompt != null && canInstallOnAndroid) {
      try {
        await js_util.promiseToFuture(
          js_util.callMethod(deferredPrompt!, 'prompt', []),
        );

        if (!mounted) return;

        setState(() {
          deferredPrompt = null;
          canInstallOnAndroid = false;
        });

        return;
      } catch (_) {
        if (!mounted) return;
        _showGuideSheet();
        return;
      }
    }

    _showGuideSheet();
  }

  void _showAlreadyInstalledSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF111827),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) {
        return const _InstallGuideContent(
          title: 'Portal zaten ana ekranda',
          description:
              'Alpha Events Guest Portal ana ekrandan uygulama gibi açılıyor.',
          steps: [
            'Ana ekrandaki Alpha Events ikonuna dokunarak açabilirsiniz.',
          ],
        );
      },
    );
  }

  void _showGuideSheet() {
    final bool ios = _isIOS();
    final bool android = _isAndroid();

    final List<String> steps = ios
        ? const [
            'Safari ile portal linkini açın.',
            'Alt menüdeki paylaş ikonuna dokunun.',
            'Ana Ekrana Ekle seçeneğini seçin.',
            'Ekle’ye dokunun.',
          ]
        : android
            ? const [
                'Chrome ile portal linkini açın.',
                'Sağ üstteki üç nokta menüsüne dokunun.',
                'Ana ekrana ekle veya Uygulamayı yükle seçeneğini seçin.',
                'Onaylayın.',
              ]
            : const [
                'Tarayıcı menüsünü açın.',
                'Ana ekrana ekle veya uygulamayı yükle seçeneğini seçin.',
                'Onaylayın.',
              ];

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF111827),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) {
        return _InstallGuideContent(
          title: 'Portalı ana ekrana ekleyin',
          description:
              'Etkinlik boyunca program, oda, transfer ve duyurulara tek dokunuşla ulaşabilirsiniz.',
          steps: steps,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isInstalled) {
      return const SizedBox.shrink();
    }

    return PressableScale(
      onTap: _handleTap,
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.075),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withOpacity(0.12)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.add_to_home_screen_rounded,
              color: AppColors.champagne,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Ana Ekrana Ekle',
              style: TextStyle(
                color: Colors.white.withOpacity(0.86),
                decoration: TextDecoration.none,
                fontSize: 11.8,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InstallGuideContent extends StatelessWidget {
  final String title;
  final String description;
  final List<String> steps;

  const _InstallGuideContent({
    required this.title,
    required this.description,
    required this.steps,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 20, 22, 26),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 46,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(height: 22),
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: AppColors.champagne.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.champagne.withOpacity(0.24),
                ),
              ),
              child: const Icon(
                Icons.phone_iphone_rounded,
                color: AppColors.champagne,
                size: 30,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                decoration: TextDecoration.none,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.58),
                decoration: TextDecoration.none,
                fontSize: 13,
                height: 1.35,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 18),
            ...steps.asMap().entries.map((entry) {
              final index = entry.key + 1;
              final text = entry.value;

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.065),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: AppColors.champagne.withOpacity(0.16),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          '$index',
                          style: const TextStyle(
                            color: AppColors.champagne,
                            decoration: TextDecoration.none,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Text(
                        text,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.78),
                          decoration: TextDecoration.none,
                          fontSize: 13,
                          height: 1.3,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.champagne,
                  foregroundColor: const Color(0xFF111827),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: const Text(
                  'Anladım',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

