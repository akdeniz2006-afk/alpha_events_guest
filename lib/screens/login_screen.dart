import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/demo_event_data.dart';
import '../l10n/app_language.dart';
import '../theme/app_colors.dart';
import '../widgets/app_page.dart';
import '../widgets/client_logo_badge.dart';
import '../widgets/pressable_scale.dart';
import 'home_screen.dart';
import 'operation_dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const String eventId = 'zurich_2026';

  final TextEditingController phoneController = TextEditingController();
  final TextEditingController codeController = TextEditingController();
  final TextEditingController staffEmailController = TextEditingController(
    text: 'operasyon@alphaevents.com.tr',
  );
  final TextEditingController staffPasswordController = TextEditingController(
    text: 'op123',
  );

  String loginMode = 'guest';

  bool obscureCode = true;
  bool isLoading = false;
  bool rememberMe = true;
  bool checkingSavedLogin = true;
  String? errorText;

  @override
  void initState() {
    super.initState();

    AppLanguage.load().then((_) {
      if (mounted) setState(() {});
    });

    phoneController.text = '';
    codeController.text = '';

    checkSavedLogin();
  }

  Future<void> checkSavedLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') == true;
    final savedGuestId = prefs.getString('guestId') ?? '';
    final savedRole = prefs.getString('appRole') ?? 'guest';

    if (!mounted) return;

    if (isLoggedIn && savedRole == 'operation_staff') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const OperationDashboardScreen()),
      );
      return;
    }

    if (isLoggedIn && savedGuestId.isNotEmpty) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
      return;
    }

    setState(() {
      checkingSavedLogin = false;
    });
  }

  @override
  void dispose() {
    phoneController.dispose();
    codeController.dispose();
    staffEmailController.dispose();
    staffPasswordController.dispose();
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

  String tx(String tr, String en) {
    return AppLanguage.isEnglish ? en : tr;
  }

  Future<void> operationLogin() async {
    final email = staffEmailController.text.trim().toLowerCase();
    final password = staffPasswordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        errorText = tx(
          'Operasyon e-mail ve şifre zorunludur.',
          'Operation e-mail and password are required.',
        );
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorText = null;
    });

    await Future.delayed(const Duration(milliseconds: 250));

    if (email != 'operasyon@alphaevents.com.tr' || password != 'op123') {
      if (!mounted) return;

      setState(() {
        errorText = tx(
          'Operasyon e-mail veya şifre hatalı.',
          'Operation e-mail or password is incorrect.',
        );
        isLoading = false;
      });
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('appRole', 'operation_staff');
    await prefs.setString('staffEmail', email);
    await prefs.setString('staffName', tx('Operasyon Ekibi', 'Operation Team'));
    await prefs.setString('eventId', eventId);
    await prefs.setBool('isLoggedIn', rememberMe);

    await prefs.remove('guestId');
    await prefs.remove('guestName');
    await prefs.remove('guestCode');
    await prefs.remove('whatsappNumber');

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const OperationDashboardScreen()),
    );
  }

  Future<void> login() async {
    final phone = phoneController.text.trim();
    final enteredCode = codeController.text.trim();
    final whatsappNumber = makeWhatsappNumber(phone);

    if (phone.isEmpty || enteredCode.isEmpty || whatsappNumber.isEmpty) {
      setState(() {
        errorText = tx(
          'Telefon numarası ve katılımcı kodu zorunludur.',
          'Phone number and participant code are required.',
        );
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
          errorText = tx(
            'Telefon numarası veya katılımcı kodu hatalı.',
            'Phone number or participant code is incorrect.',
          );
          isLoading = false;
        });
        return;
      }

      final data = matchedDoc.data();
      final guestId = (data['guestId'] ?? matchedDoc.id).toString();
      final guestName = (data['guestName'] ?? data['name'] ?? '').toString();
      final guestCode = (data['code'] ?? '').toString();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('appRole', 'guest');
      await prefs.setString('guestId', guestId);
      await prefs.setString('guestName', guestName);
      await prefs.setString('guestCode', guestCode);
      await prefs.setString('whatsappNumber', whatsappNumber);
      await prefs.setString('eventId', eventId);
      await prefs.setBool('isLoggedIn', rememberMe);

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } catch (error) {
      if (!mounted) return;

      setState(() {
        errorText = tx(
          'Giriş yapılamadı. Lütfen tekrar deneyin.',
          'Login failed. Please try again.',
        );
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (checkingSavedLogin) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: AppPage(
          child: Center(
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.075),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: Colors.white.withOpacity(0.10)),
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  color: AppColors.champagne,
                  strokeWidth: 2.6,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return ValueListenableBuilder<String>(
      valueListenable: AppLanguage.notifier,
      builder: (context, languageCode, _) {
        final isEnglish = languageCode == 'en';

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
                  const SizedBox(height: 14),
                  LoginLanguageSelector(
                    onChanged: () {
                      setState(() {
                        errorText = null;
                      });
                    },
                  ),
                  const SizedBox(height: 22),
                  const LoginHeroCard(),
                  const SizedBox(height: 28),
                  LoginModeSelector(
                    selectedMode: loginMode,
                    onChanged: (mode) {
                      setState(() {
                        loginMode = mode;
                        errorText = null;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  if (loginMode == 'guest') ...[
                    LoginTextField(
                      controller: phoneController,
                      label: isEnglish ? 'Phone number' : 'Telefon numarası',
                      hint: '+90 5XX XXX XX XX',
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
                      label: isEnglish ? 'Participant code' : 'Katılımcı kodu',
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
                  ] else ...[
                    LoginTextField(
                      controller: staffEmailController,
                      label: isEnglish ? 'Operation e-mail' : 'Operasyon e-mail',
                      hint: 'operasyon@alphaevents.com.tr',
                      icon: Icons.mail_rounded,
                      keyboardType: TextInputType.emailAddress,
                      errorText: errorText,
                      onSubmitted: (_) => operationLogin(),
                    ),
                    const SizedBox(height: 13),
                    LoginTextField(
                      controller: staffPasswordController,
                      label: isEnglish ? 'Operation password' : 'Operasyon şifresi',
                      hint: 'op123',
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
                      onSubmitted: (_) => operationLogin(),
                    ),
                  ],
                  const SizedBox(height: 13),
                  PressableScale(
                    onTap: () {
                      setState(() {
                        rememberMe = !rememberMe;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: glassDecoration(radius: 20, opacity: 0.055),
                      child: Row(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: rememberMe
                                  ? AppColors.champagne.withOpacity(0.24)
                                  : Colors.white.withOpacity(0.06),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: rememberMe
                                    ? AppColors.champagne
                                    : Colors.white.withOpacity(0.18),
                              ),
                            ),
                            child: rememberMe
                                ? const Icon(
                                    Icons.check_rounded,
                                    color: AppColors.champagne,
                                    size: 18,
                                  )
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              isEnglish ? 'Remember me' : 'Beni hatırla',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.78),
                                decoration: TextDecoration.none,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  PressableScale(
                    onTap: () {
                      if (isLoading) return;

                      if (loginMode == 'guest') {
                        login();
                      } else {
                        operationLogin();
                      }
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
                            : Text(
                                loginMode == 'guest'
                                    ? (isEnglish ? 'Guest Login' : 'Misafir Girişi Yap')
                                    : (isEnglish ? 'Operation Login' : 'Operasyon Girişi Yap'),
                                style: const TextStyle(
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
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class LoginLanguageSelector extends StatelessWidget {
  final VoidCallback onChanged;

  const LoginLanguageSelector({
    super.key,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: AppLanguage.notifier,
      builder: (context, languageCode, _) {
        final isEnglish = languageCode == 'en';

        return Container(
          padding: const EdgeInsets.all(5),
          decoration: glassDecoration(radius: 22, opacity: 0.055),
          child: Row(
            children: [
              Expanded(
                child: _LanguageButton(
                  title: 'Türkçe',
                  shortCode: 'TR',
                  selected: !isEnglish,
                  onTap: () async {
                    await AppLanguage.setLanguage('tr');
                    onChanged();
                  },
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _LanguageButton(
                  title: 'English',
                  shortCode: 'EN',
                  selected: isEnglish,
                  onTap: () async {
                    await AppLanguage.setLanguage('en');
                    onChanged();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LanguageButton extends StatelessWidget {
  final String title;
  final String shortCode;
  final bool selected;
  final VoidCallback onTap;

  const _LanguageButton({
    required this.title,
    required this.shortCode,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.champagne.withOpacity(0.18) : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected
                ? AppColors.champagne.withOpacity(0.62)
                : Colors.white.withOpacity(0.08),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.language_rounded,
              color: selected ? AppColors.champagne : Colors.white.withOpacity(0.58),
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              shortCode,
              style: TextStyle(
                color: selected ? AppColors.champagne : Colors.white,
                decoration: TextDecoration.none,
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(width: 7),
            Flexible(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: selected ? AppColors.champagne : Colors.white.withOpacity(0.72),
                  decoration: TextDecoration.none,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
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
    return ValueListenableBuilder<String>(
      valueListenable: AppLanguage.notifier,
      builder: (context, languageCode, _) {
        final isEnglish = languageCode == 'en';

        return Container(
          height: 262,
          width: double.infinity,
          padding: const EdgeInsets.all(18),
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
                    isEnglish
                        ? 'Zurich Insurance Leadership Meeting 2026'
                        : demoGuest.eventTitle,
                    textAlign: TextAlign.center,
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
                    isEnglish
                        ? 'May 14-16, 2026 · Istanbul'
                        : '${demoGuest.eventDate} · ${demoGuest.location}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.58),
                      decoration: TextDecoration.none,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class LoginModeSelector extends StatelessWidget {
  final String selectedMode;
  final ValueChanged<String> onChanged;

  const LoginModeSelector({
    super.key,
    required this.selectedMode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: AppLanguage.notifier,
      builder: (context, languageCode, _) {
        final isEnglish = languageCode == 'en';

        return Container(
          padding: const EdgeInsets.all(5),
          decoration: glassDecoration(radius: 22, opacity: 0.055),
          child: Row(
            children: [
              Expanded(
                child: LoginModeButton(
                  title: isEnglish ? 'Guest' : 'Misafir',
                  subtitle: isEnglish ? 'Phone + code' : 'Telefon + kod',
                  icon: Icons.person_rounded,
                  selected: selectedMode == 'guest',
                  onTap: () => onChanged('guest'),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: LoginModeButton(
                  title: isEnglish ? 'Operation' : 'Operasyon',
                  subtitle: isEnglish ? 'Team login' : 'Ekip girişi',
                  icon: Icons.engineering_rounded,
                  selected: selectedMode == 'operation',
                  onTap: () => onChanged('operation'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class LoginModeButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const LoginModeButton({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
        decoration: BoxDecoration(
          color: selected ? AppColors.champagne.withOpacity(0.18) : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? AppColors.champagne.withOpacity(0.62) : Colors.white.withOpacity(0.08),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: selected ? AppColors.champagne : Colors.white.withOpacity(0.56),
              size: 22,
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: selected ? AppColors.champagne : Colors.white,
                      decoration: TextDecoration.none,
                      fontSize: 13.2,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.46),
                      decoration: TextDecoration.none,
                      fontSize: 11.3,
                      fontWeight: FontWeight.w600,
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
