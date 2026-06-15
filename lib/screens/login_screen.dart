import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/demo_event_data.dart';
import '../theme/app_colors.dart';
import '../widgets/app_page.dart';
import '../widgets/client_logo_badge.dart';
import '../widgets/pressable_scale.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const String eventId = 'zurich_2026';

  final TextEditingController phoneController = TextEditingController();
  final TextEditingController codeController = TextEditingController();

  bool obscureCode = true;
  bool isLoading = false;
  String? errorText;

  @override
  void initState() {
    super.initState();

    phoneController.text = '+90 532 123 45 67';
    codeController.text = '';
  }

  @override
  void dispose() {
    phoneController.dispose();
    codeController.dispose();
    super.dispose();
  }

  String onlyDigits(String value) {
    return value.replaceAll(RegExp(r'[^0-9]'), '');
  }

  String makeWhatsappNumber(String value) {
    var digits = onlyDigits(value);

    if (digits.startsWith('00')) {
      digits = digits.substring(2);
    }

    if (digits.startsWith('0') && digits.length == 11) {
      digits = '90${digits.substring(1)}';
    }

    if (digits.length == 10 && digits.startsWith('5')) {
      digits = '90$digits';
    }

    return digits;
  }

  Future<void> login() async {
    final phone = phoneController.text.trim();
    final enteredCode = codeController.text.trim();
    final whatsappNumber = makeWhatsappNumber(phone);

    if (phone.isEmpty || enteredCode.isEmpty || whatsappNumber.isEmpty) {
      setState(() {
        errorText = 'Telefon numarası ve katılımcı kodu zorunludur.';
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorText = null;
    });

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('event_guests')
          .where('whatsappNumber', isEqualTo: whatsappNumber)
          .limit(10)
          .get();

      QueryDocumentSnapshot<Map<String, dynamic>>? matchedDoc;

      for (final doc in snapshot.docs) {
        final data = doc.data();

        final eventMatches = (data['eventId'] ?? '').toString() == eventId;
        final codeMatches =
            (data['code'] ?? '').toString().trim().toLowerCase() ==
                enteredCode.toLowerCase();
        final active = data['isActive'] != false;

        if (eventMatches && codeMatches && active) {
          matchedDoc = doc;
          break;
        }
      }

      if (matchedDoc == null) {
        setState(() {
          errorText = 'Telefon numarası veya katılımcı kodu hatalı.';
          isLoading = false;
        });
        return;
      }

      final data = matchedDoc.data();
      final guestId = (data['guestId'] ?? matchedDoc.id).toString();
      final guestName = (data['guestName'] ?? data['name'] ?? '').toString();
      final guestCode = (data['code'] ?? '').toString();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('guestId', guestId);
      await prefs.setString('guestName', guestName);
      await prefs.setString('guestCode', guestCode);
      await prefs.setString('whatsappNumber', whatsappNumber);
      await prefs.setString('eventId', eventId);
      await prefs.setBool('isLoggedIn', true);

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } catch (error) {
      if (!mounted) return;

      setState(() {
        errorText = 'Giriş yapılamadı. Lütfen tekrar deneyin.';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final previewWhatsapp = makeWhatsappNumber(phoneController.text);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: AppPage(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              const LoginBrandHeader(),
              const SizedBox(height: 26),
              const LoginHeroCard(),
              const SizedBox(height: 28),
              const Text(
                'Giriş',
                style: TextStyle(
                  color: Colors.white,
                  decoration: TextDecoration.none,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.6,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Etkinlik bilgilerinize ulaşmak için size tanımlanan telefon numarası ve katılımcı kodu ile giriş yapın.',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.58),
                  decoration: TextDecoration.none,
                  height: 1.38,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 18),
              LoginTextField(
                controller: phoneController,
                label: 'Telefon numarası',
                hint: '+90 532 123 45 67',
                icon: Icons.phone_rounded,
                keyboardType: TextInputType.phone,
                errorText: errorText,
                onChanged: (_) {
                  setState(() {});
                },
                onSubmitted: (_) => login(),
              ),
              const SizedBox(height: 13),
              LoginTextField(
                controller: codeController,
                label: 'Katılımcı kodu',
                hint: 'ALP001',
                icon: Icons.lock_rounded,
                obscureText: obscureCode,
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      obscureCode = !obscureCode;
                    });
                  },
                  icon: Icon(
                    obscureCode
                        ? Icons.visibility_rounded
                        : Icons.visibility_off_rounded,
                    color: Colors.white.withOpacity(0.54),
                    size: 21,
                  ),
                ),
                onSubmitted: (_) => login(),
              ),
              const SizedBox(height: 16),
              PressableScale(
                onTap: () {
                  if (!isLoading) login();
                },
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
                  child: Center(
                    child: isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text(
                            'Giriş Yap',
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
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: glassDecoration(radius: 22, opacity: 0.06),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.verified_user_rounded,
                      size: 21,
                      color: AppColors.champagne,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        previewWhatsapp.isEmpty
                            ? 'Giriş güvenliği için telefon numarası ve katılımcı kodu birlikte kontrol edilir.'
                            : 'WhatsApp eşleşmesi: $previewWhatsapp\nTelefon numarası ve katılımcı kodu birlikte doğruysa giriş yapılır.',
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
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class LoginBrandHeader extends StatelessWidget {
  const LoginBrandHeader({super.key});

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

class LoginHeroCard extends StatelessWidget {
  const LoginHeroCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 262,
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(34),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF06080D), Color(0xFF101827), Color(0xFF22344E)],
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
            right: -72,
            top: -82,
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
            left: -90,
            bottom: -110,
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
              const SizedBox(
                height: 76,
                child: ClientLogoBadge(
                  logoPath: 'assets/logos/zurich_logo.png',
                  clientName: 'Zurich Sigorta',
                ),
              ),
              const Spacer(),
              Text(
                demoGuest.eventTitle,
                style: const TextStyle(
                  color: Colors.white,
                  decoration: TextDecoration.none,
                  fontSize: 23,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.6,
                  height: 1.08,
                ),
              ),
              const SizedBox(height: 9),
              Text(
                '${demoGuest.eventDate} · ${demoGuest.location}',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.58),
                  decoration: TextDecoration.none,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 14),
              Container(
                height: 34,
                padding: const EdgeInsets.symmetric(horizontal: 11),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.white.withOpacity(0.10)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.verified_rounded,
                      size: 16,
                      color: Colors.white.withOpacity(0.76),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Katılımcı Portalı',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.76),
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
        ],
      ),
    );
  }
}

class LoginTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final String? errorText;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;

  const LoginTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
    this.errorText,
    this.onSubmitted,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      onSubmitted: onSubmitted,
      onChanged: onChanged,
      style: const TextStyle(
        fontSize: 15.5,
        fontWeight: FontWeight.w800,
        color: Colors.white,
        decoration: TextDecoration.none,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        errorText: errorText,
        filled: true,
        fillColor: Colors.white.withOpacity(0.075),
        prefixIcon: Icon(icon, color: Colors.white.withOpacity(0.58), size: 21),
        suffixIcon: suffixIcon,
        labelStyle: TextStyle(
          color: Colors.white.withOpacity(0.62),
          fontWeight: FontWeight.w700,
        ),
        hintStyle: TextStyle(
          color: Colors.white.withOpacity(0.30),
          fontWeight: FontWeight.w600,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.10)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide(
            color: AppColors.champagne.withOpacity(0.72),
            width: 1.3,
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
    );
  }
}
