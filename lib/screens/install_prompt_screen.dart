import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/app_page.dart';
import '../widgets/pressable_scale.dart';
import 'login_screen.dart';

class InstallPromptScreen extends StatelessWidget {
  const InstallPromptScreen({super.key});

  void continueToLogin(BuildContext context) {
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  bool isIOS(BuildContext context) {
    final platform = Theme.of(context).platform;
    return platform == TargetPlatform.iOS;
  }

  @override
  Widget build(BuildContext context) {
    final bool showIOS = isIOS(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: AppPage(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),

              const InstallBrandHeader(),

              const SizedBox(height: 26),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(34),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF06080D),
                      Color(0xFF101827),
                      Color(0xFF22344E),
                    ],
                  ),
                  border: Border.all(color: Colors.white.withOpacity(0.10)),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF22344E).withOpacity(0.34),
                      blurRadius: 34,
                      offset: const Offset(0, 18),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.50),
                      blurRadius: 32,
                      offset: const Offset(0, 20),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -70,
                      top: -76,
                      child: Container(
                        width: 220,
                        height: 220,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.borusanOrange.withOpacity(0.10),
                        ),
                      ),
                    ),
                    Positioned(
                      left: -88,
                      bottom: -104,
                      child: Container(
                        width: 230,
                        height: 230,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.champagne.withOpacity(0.08),
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 58,
                          width: 58,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.12),
                            ),
                          ),
                          child: const Icon(
                            Icons.add_to_home_screen_rounded,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                        const SizedBox(height: 26),
                        const Text(
                          'Etkinlik Portalını\nTelefonuna Kaydet',
                          style: TextStyle(
                            color: Colors.white,
                            decoration: TextDecoration.none,
                            fontSize: 34,
                            height: 1.03,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1.1,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Bu portal etkinlik boyunca program, oda bilgileri, duyurular, fotoğraflar ve acil destek için kullanılacaktır.',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.66),
                            decoration: TextDecoration.none,
                            fontSize: 14.5,
                            height: 1.38,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(17),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.075),
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(color: Colors.white.withOpacity(0.10)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.24),
                      blurRadius: 22,
                      offset: const Offset(0, 14),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.champagne.withOpacity(0.13),
                        borderRadius: BorderRadius.circular(17),
                        border: Border.all(
                          color: AppColors.champagne.withOpacity(0.20),
                        ),
                      ),
                      child: Icon(
                        showIOS
                            ? Icons.phone_iphone_rounded
                            : Icons.android_rounded,
                        color: AppColors.champagne,
                        size: 25,
                      ),
                    ),
                    const SizedBox(width: 13),
                    Expanded(
                      child: showIOS
                          ? const IOSInstructions()
                          : const AndroidInstructions(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              PressableScale(
                onTap: () => continueToLogin(context),
                child: Container(
                  height: 58,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.navyStart, AppColors.navyEnd],
                    ),
                    border: Border.all(color: Colors.white.withOpacity(0.16)),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.navyStart.withOpacity(0.36),
                        blurRadius: 22,
                        offset: const Offset(0, 14),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'Ekledim ve Devam Et',
                      style: TextStyle(
                        color: Colors.white,
                        decoration: TextDecoration.none,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: glassDecoration(radius: 22, opacity: 0.06),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      size: 21,
                      color: AppColors.champagne,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Telefon güvenliği nedeniyle portal otomatik eklenemez. Devam etmeden önce ana ekrana ekleme işlemini tamamlamanız önerilir.',
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class InstallBrandHeader extends StatelessWidget {
  const InstallBrandHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 58,
          height: 58,
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.12)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.24),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.asset('assets/logos/Alpha.png', fit: BoxFit.cover),
          ),
        ),
        const SizedBox(width: 13),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Alpha Events',
                style: TextStyle(
                  color: Colors.white,
                  decoration: TextDecoration.none,
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.7,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Guest Portal',
                style: TextStyle(
                  color: Color(0x88FFFFFF),
                  decoration: TextDecoration.none,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class IOSInstructions extends StatelessWidget {
  const IOSInstructions({super.key});

  @override
  Widget build(BuildContext context) {
    return const InstructionContent(
      title: 'iPhone için',
      steps: [
        'Linki Safari ile açın.',
        'Alttaki paylaş ikonuna dokunun.',
        'Ana Ekrana Ekle seçeneğini seçin.',
        'Sağ üstten Ekle butonuna basın.',
      ],
    );
  }
}

class AndroidInstructions extends StatelessWidget {
  const AndroidInstructions({super.key});

  @override
  Widget build(BuildContext context) {
    return const InstructionContent(
      title: 'Android için',
      steps: [
        'Linki Chrome ile açın.',
        'Sağ üstteki üç nokta menüsüne dokunun.',
        'Ana ekrana ekle veya Uygulamayı yükle seçeneğini seçin.',
        'Onaylayarak portala ana ekrandan erişin.',
      ],
    );
  }
}

class InstructionContent extends StatelessWidget {
  final String title;
  final List<String> steps;

  const InstructionContent({
    super.key,
    required this.title,
    required this.steps,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            decoration: TextDecoration.none,
            fontSize: 17,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 9),
        ...List.generate(steps.length, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              '${index + 1}. ${steps[index]}',
              style: TextStyle(
                color: Colors.white.withOpacity(0.64),
                decoration: TextDecoration.none,
                height: 1.3,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        }),
      ],
    );
  }
}
