import 'package:flutter/material.dart';

import '../data/demo_event_data.dart';
import '../theme/app_colors.dart';
import '../widgets/app_page.dart';
import '../widgets/borusan_logo_badge.dart';
import '../widgets/pressable_scale.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController codeController = TextEditingController();
  String? errorText;

  @override
  void initState() {
    super.initState();
    codeController.text = demoGuest.guestCode;
  }

  @override
  void dispose() {
    codeController.dispose();
    super.dispose();
  }

  void login() {
    final enteredCode = codeController.text.trim().toUpperCase();

    if (enteredCode == demoGuest.guestCode) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        ),
      );
      return;
    }

    setState(() {
      errorText = 'Katılımcı kodu bulunamadı. Lütfen tekrar kontrol edin.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: AppPage(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 36),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 14),
              const BorusanLogoBadge(),
              const SizedBox(height: 34),

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
                      color: AppColors.heroEnd.withOpacity(0.36),
                      blurRadius: 34,
                      offset: const Offset(0, 18),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.42),
                      blurRadius: 30,
                      offset: const Offset(0, 18),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -56,
                      top: -54,
                      child: Container(
                        width: 190,
                        height: 190,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.borusanOrange.withOpacity(0.14),
                        ),
                      ),
                    ),
                    Positioned(
                      left: -70,
                      bottom: -80,
                      child: Container(
                        width: 220,
                        height: 220,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.champagne.withOpacity(0.11),
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 54,
                          width: 54,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.14),
                            borderRadius: BorderRadius.circular(19),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.13),
                            ),
                          ),
                          child: const Icon(
                            Icons.confirmation_number_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(height: 26),
                        const Text(
                          'Alpha Events\nGuest Portal',
                          style: TextStyle(
                            fontSize: 35,
                            height: 1.02,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1.1,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          '${demoGuest.eventTitle}\n${demoGuest.eventDate} · ${demoGuest.location}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.68),
                            fontSize: 14.5,
                            height: 1.35,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),
              const Text(
                'Katılımcı Girişi',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Size iletilen katılımcı kodunu girerek etkinlik bilgilerinize ulaşabilirsiniz.',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.58),
                  height: 1.38,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 18),
              TextField(
                controller: codeController,
                textCapitalization: TextCapitalization.characters,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                  color: Colors.white,
                ),
                decoration: InputDecoration(
                  labelText: 'Katılımcı Kodu',
                  hintText: 'Örn: ALP304',
                  errorText: errorText,
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.08),
                  prefixIcon: const Icon(Icons.badge_rounded),
                  labelStyle: TextStyle(
                    color: Colors.white.withOpacity(0.62),
                    fontWeight: FontWeight.w700,
                  ),
                  hintStyle: TextStyle(
                    color: Colors.white.withOpacity(0.34),
                    fontWeight: FontWeight.w600,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: BorderSide(
                      color: Colors.white.withOpacity(0.12),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: const BorderSide(
                      color: AppColors.champagne,
                      width: 1.4,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: const BorderSide(
                      color: AppColors.borusanOrange,
                      width: 1.2,
                    ),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: const BorderSide(
                      color: AppColors.borusanOrange,
                      width: 1.4,
                    ),
                  ),
                ),
                onSubmitted: (_) => login(),
              ),

              const SizedBox(height: 16),
              PressableScale(
                onTap: login,
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
                      'Portala Giriş Yap',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.2,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 18),
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
                        'Demo giriş kodu: ${demoGuest.guestCode}. Gerçek sistemde bu kod Firebase üzerinden kişiye özel çalışacak.',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.58),
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