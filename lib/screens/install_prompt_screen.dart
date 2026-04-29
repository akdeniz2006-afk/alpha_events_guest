import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/app_page.dart';
import '../widgets/borusan_logo_badge.dart';
import '../widgets/pressable_scale.dart';
import 'login_screen.dart';

class InstallPromptScreen extends StatelessWidget {
  const InstallPromptScreen({super.key});

  void continueToLogin(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: AppPage(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 34),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 14),
              const BorusanLogoBadge(),
              const SizedBox(height: 28),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(34),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.heroStart,
                      AppColors.heroMiddle,
                      AppColors.heroEnd,
                    ],
                  ),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.12),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.heroEnd.withOpacity(0.34),
                      blurRadius: 34,
                      offset: const Offset(0, 18),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.46),
                      blurRadius: 30,
                      offset: const Offset(0, 18),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -58,
                      top: -58,
                      child: Container(
                        width: 190,
                        height: 190,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.borusanOrange.withOpacity(0.12),
                        ),
                      ),
                    ),
                    Positioned(
                      left: -72,
                      bottom: -82,
                      child: Container(
                        width: 220,
                        height: 220,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.champagne.withOpacity(0.10),
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
                            color: Colors.white.withOpacity(0.14),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.13),
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
                          'Portalı\nTelefonuna Kaydet',
                          style: TextStyle(
                            color: Colors.white,
                            decoration: TextDecoration.none,
                            fontSize: 35,
                            height: 1.02,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1.1,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Etkinlik boyunca programa, oda bilgilerine, duyurulara ve acil destek kişilerine hızlı ulaşmak için bu portalı ana ekranına eklemeni öneririz.',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.68),
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

              const Text(
                'Nasıl eklenir?',
                style: TextStyle(
                  color: Colors.white,
                  decoration: TextDecoration.none,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),

              const InstructionCard(
                icon: Icons.phone_iphone_rounded,
                title: 'iPhone',
                steps: [
                  'Safari ile linki aç.',
                  'Alttaki paylaş ikonuna dokun.',
                  '“Ana Ekrana Ekle” seçeneğini seç.',
                  'Sağ üstten “Ekle” butonuna bas.',
                ],
              ),

              const SizedBox(height: 12),

              const InstructionCard(
                icon: Icons.android_rounded,
                title: 'Android',
                steps: [
                  'Chrome ile linki aç.',
                  'Sağ üstteki üç nokta menüsüne dokun.',
                  '“Ana ekrana ekle” veya “Uygulamayı yükle” seç.',
                  'Onayla ve portala ana ekrandan eriş.',
                ],
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
                      colors: [
                        AppColors.navyStart,
                        AppColors.navyEnd,
                      ],
                    ),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.16),
                    ),
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
                      'Ekledim, Devam Et',
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

              const SizedBox(height: 12),

              PressableScale(
                onTap: () => continueToLogin(context),
                child: Container(
                  height: 48,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.10),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'Şimdilik Atla',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.72),
                        decoration: TextDecoration.none,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: glassDecoration(
                  radius: 22,
                  opacity: 0.06,
                ),
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
                        'Telefon güvenliği nedeniyle portal ana ekrana otomatik eklenemez. Bu işlem kullanıcının tarayıcı menüsünden onay vermesiyle yapılır.',
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

class InstructionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<String> steps;

  const InstructionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.steps,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.075),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: Colors.white.withOpacity(0.10),
        ),
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
              icon,
              color: AppColors.champagne,
              size: 25,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
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
                const SizedBox(height: 8),
                ...List.generate(steps.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: Text(
                      '${index + 1}. ${steps[index]}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.62),
                        decoration: TextDecoration.none,
                        height: 1.3,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}