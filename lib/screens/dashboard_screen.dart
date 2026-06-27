import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/demo_event_data.dart';
import '../theme/app_colors.dart';
import '../widgets/app_page.dart';
import '../widgets/client_logo_badge.dart';
import '../widgets/pressable_scale.dart';
import '../widgets/pwa_install_button.dart';

import 'activities_screen.dart';
import 'announcements_screen.dart';
import 'help_screen.dart';
import 'hotel_gallery_screen.dart';
import 'login_screen.dart';
import 'program_screen.dart';
import 'qr_code_screen.dart';
import 'transport_screen.dart';
import 'videos_screen.dart';
import 'evaluation_screen.dart';
import '../speakers_screen.dart';
import '../business_card_screen.dart';
import '../push_notification_service.dart';
import 'notification_permission_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  void openPage(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 140),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AnimatedEntrance(delay: 0, child: DashboardTopBar()),
            const SizedBox(height: 18),
            const AnimatedEntrance(delay: 80, child: CleanHeroCard()),
            const SizedBox(height: 18),
            const AnimatedEntrance(delay: 140, child: TodayCompactCard()),
            const SizedBox(height: 22),
            const AnimatedEntrance(
              delay: 180,
              child: DashboardSectionTitle(title: 'Hızlı Erişim'),
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 3.15,
              children: [
                AnimatedEntrance(
                  delay: 220,
                  child: CompactDashboardButton(
                    title: 'Program',
                    subtitle: 'Gün akışı',
                    icon: Icons.calendar_month_rounded,
                    accent: const Color(0xFF7EA7D8),
                    onTap: () => openPage(context, const ProgramScreen()),
                  ),
                ),
                AnimatedEntrance(
                  delay: 225,
                  child: CompactDashboardButton(
                    title: 'Konuşmacılar',
                    subtitle: 'Soru sor',
                    icon: Icons.record_voice_over_rounded,
                    accent: const Color(0xFF9B8AFB),
                    onTap: () => openPage(context, const SpeakersScreen()),
                  ),
                ),

                AnimatedEntrance(
                  delay: 227,
                  child: CompactDashboardButton(
                    title: 'Kartvizitim',
                    subtitle: 'QR ile paylaş',
                    icon: Icons.badge_rounded,
                    accent: const Color(0xFF14B8A6),
                    onTap: () => openPage(context, const BusinessCardScreen()),
                  ),
                ),

                AnimatedEntrance(
                  delay: 229,
                  child: CompactDashboardButton(
                    title: 'Bildirimler',
                    subtitle: 'Push izni ver',
                    icon: Icons.notifications_active_rounded,
                    accent: const Color(0xFFF59E0B),
                    onTap: () => openPage(
                      context,
                      const NotificationPermissionScreen(),
                    ),
                  ),
                ),
                AnimatedEntrance(
                  delay: 230,
                  child: CompactDashboardButton(
                    title: 'Ulaşım',
                    subtitle: 'Transfer bilgileri',
                    icon: Icons.directions_bus_rounded,
                    accent: const Color(0xFFD6B16A),
                    onTap: () => openPage(context, const TransportScreen()),
                  ),
                ),
                AnimatedEntrance(
                  delay: 240,
                  child: CompactDashboardButton(
                    title: 'Aktiviteler',
                    subtitle: 'Katılım onayı',
                    icon: Icons.event_available_rounded,
                    accent: const Color(0xFF72C7C2),
                    onTap: () => openPage(context, const ActivitiesScreen()),
                  ),
                ),
                AnimatedEntrance(
                  delay: 260,
                  child: CompactDashboardButton(
                    title: 'Duyurular',
                    subtitle: 'Son bilgiler',
                    icon: Icons.notifications_rounded,
                    accent: const Color(0xFFD6B16A),
                    onTap: () => openPage(context, const AnnouncementsScreen()),
                  ),
                ),
                AnimatedEntrance(
                  delay: 300,
                  child: CompactDashboardButton(
                    title: 'Değerlendirme',
                    subtitle: 'Geri bildirim',
                    icon: Icons.rate_review_rounded,
                    accent: const Color(0xFFC7B58A),
                    onTap: () => openPage(context, const EvaluationScreen()),
                  ),
                ),
                AnimatedEntrance(
                  delay: 340,
                  child: CompactDashboardButton(
                    title: 'Acil Destek',
                    subtitle: 'Koordinatör',
                    icon: Icons.support_agent_rounded,
                    accent: const Color(0xFFAAB4C3),
                    onTap: () => openPage(context, const HelpScreen()),
                  ),
                ),
                AnimatedEntrance(
                  delay: 380,
                  child: CompactDashboardButton(
                    title: 'Videolar',
                    subtitle: 'Bilgilendirme',
                    icon: Icons.play_circle_fill_rounded,
                    accent: const Color(0xFF72C7C2),
                    onTap: () => openPage(context, const VideosScreen()),
                  ),
                ),
                AnimatedEntrance(
                  delay: 420,
                  child: CompactDashboardButton(
                    title: 'Otel Galerisi',
                    subtitle: 'Fotoğraflar',
                    icon: Icons.apartment_rounded,
                    accent: const Color(0xFF9B8AD8),
                    onTap: () => openPage(context, const HotelGalleryScreen()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            AnimatedEntrance(
              delay: 460,
              child: QrAccessCard(
                onTap: () => openPage(context, const QrCodeScreen()),
              ),
            ),
            const SizedBox(height: 12),
            const AnimatedEntrance(
              delay: 500,
              child: DailyNotesCompactButton(),
            ),
          ],
        ),
      ),
    );
  }
}

class AnimatedEntrance extends StatefulWidget {
  final Widget child;
  final int delay;

  const AnimatedEntrance({super.key, required this.child, required this.delay});

  @override
  State<AnimatedEntrance> createState() => _AnimatedEntranceState();
}

class _AnimatedEntranceState extends State<AnimatedEntrance> {
  bool visible = false;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    PushNotificationService.initializeAndSaveToken();
    timer = Timer(Duration(milliseconds: widget.delay), () {
      if (!mounted) return;
      setState(() {
        visible = true;
      });
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: visible ? 1 : 0,
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
      child: AnimatedSlide(
        offset: visible ? Offset.zero : const Offset(0, 0.08),
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}

class DashboardTopBar extends StatelessWidget {
  const DashboardTopBar({super.key});

  Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('guestId');
    await prefs.remove('guestName');
    await prefs.remove('guestCode');
    await prefs.remove('whatsappNumber');
    await prefs.remove('eventId');
    await prefs.setBool('isLoggedIn', false);

    if (!context.mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  void showLogoutDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: const Color(0xFF101827),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: AppColors.champagne.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.champagne.withOpacity(0.24),
                    ),
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    color: AppColors.champagne,
                    size: 29,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Çıkış yapılsın mı?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    decoration: TextDecoration.none,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Çıkış yaptığınızda bir sonraki girişte telefon numarası ve katılımcı kodu tekrar istenir.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.58),
                    decoration: TextDecoration.none,
                    fontSize: 12.8,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: BorderSide(
                            color: Colors.white.withOpacity(0.18),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Vazgeç',
                          style: TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                          logout(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.champagne,
                          foregroundColor: const Color(0xFF101827),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Çıkış Yap',
                          style: TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.white.withOpacity(0.12)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.22),
                      blurRadius: 18,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(13),
                  child: Image.asset(
                    'assets/logos/Alpha.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Alpha Events',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        decoration: TextDecoration.none,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.6,
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
          ),
        ),
        const PwaInstallButton(),
        const SizedBox(width: 10),
        PressableScale(
          onTap: () => showLogoutDialog(context),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.09),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.12)),
            ),
            child: const Icon(
              Icons.logout_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
        ),
      ],
    );
  }
}

class CleanHeroCard extends StatelessWidget {
  const CleanHeroCard({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedHoverLift(
      borderRadius: 34,
      child: Container(
        height: 292,
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
              color: const Color(0xFF22344E).withOpacity(0.36),
              blurRadius: 36,
              offset: const Offset(0, 20),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.55),
              blurRadius: 34,
              offset: const Offset(0, 22),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -72,
              top: -82,
              child: FloatingGlow(
                color: AppColors.borusanOrange.withOpacity(0.12),
                size: 220,
              ),
            ),
            Positioned(
              left: -90,
              bottom: -110,
              child: FloatingGlow(
                color: AppColors.champagne.withOpacity(0.08),
                size: 230,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 78,
                  child: ClientLogoBadge(
                    logoPath: demoGuest.clientLogoPath,
                    clientName: demoGuest.clientName,
                  ),
                ),
                const Spacer(),
                Text(
                  'Merhaba,',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.62),
                    decoration: TextDecoration.none,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  demoGuest.fullName,
                  style: const TextStyle(
                    color: Colors.white,
                    decoration: TextDecoration.none,
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    height: 1.02,
                    letterSpacing: -1.1,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  demoGuest.eventTitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.84),
                    decoration: TextDecoration.none,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  '${demoGuest.eventDate} · ${demoGuest.location}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.54),
                    decoration: TextDecoration.none,
                    fontSize: 13.2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    HeroMiniChip(
                      icon: Icons.hotel_rounded,
                      label: 'Oda ${demoGuest.roomNumber}',
                    ),
                    const SizedBox(width: 8),
                    const HeroMiniChip(
                      icon: Icons.event_available_rounded,
                      label: '1. Gün',
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class FloatingGlow extends StatefulWidget {
  final Color color;
  final double size;

  const FloatingGlow({super.key, required this.color, required this.size});

  @override
  State<FloatingGlow> createState() => _FloatingGlowState();
}

class _FloatingGlowState extends State<FloatingGlow>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;
  late final Animation<double> animation;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat(reverse: true);

    animation = Tween<double>(
      begin: 0.92,
      end: 1.08,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: animation,
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: widget.color),
      ),
    );
  }
}

class HeroMiniChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const HeroMiniChip({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return AnimatedHoverLift(
      borderRadius: 18,
      child: Container(
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
            Icon(icon, size: 16, color: Colors.white.withOpacity(0.74)),
            const SizedBox(width: 6),
            Text(
              label,
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
    );
  }
}

class TodayCompactCard extends StatelessWidget {
  const TodayCompactCard({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedHoverLift(
      borderRadius: 28,
      child: Container(
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.075),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white.withOpacity(0.10)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.28),
              blurRadius: 26,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: Column(
          children: const [
            TodayRow(
              time: '09:30',
              title: 'Karşılama Kahvesi',
              subtitle: 'Fuaye Alanı',
              accent: Color(0xFFD6B16A),
            ),
            SizedBox(height: 12),
            TodayRow(
              time: '18:30',
              title: 'Akşam Transferi',
              subtitle: 'Otel ana girişi',
              accent: Color(0xFF72C7C2),
            ),
          ],
        ),
      ),
    );
  }
}

class TodayRow extends StatelessWidget {
  final String time;
  final String title;
  final String subtitle;
  final Color accent;

  const TodayRow({
    super.key,
    required this.time,
    required this.title,
    required this.subtitle,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AnimatedGlowIconBox(
          accent: accent,
          child: Text(
            time,
            style: TextStyle(
              color: accent,
              decoration: TextDecoration.none,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
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
                  fontSize: 15.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.52),
                  decoration: TextDecoration.none,
                  fontSize: 12.5,
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

class AnimatedGlowIconBox extends StatefulWidget {
  final Color accent;
  final Widget child;

  const AnimatedGlowIconBox({
    super.key,
    required this.accent,
    required this.child,
  });

  @override
  State<AnimatedGlowIconBox> createState() => _AnimatedGlowIconBoxState();
}

class _AnimatedGlowIconBoxState extends State<AnimatedGlowIconBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;
  late final Animation<double> glow;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    glow = Tween<double>(
      begin: 0.10,
      end: 0.22,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: glow,
      builder: (context, _) {
        return Container(
          height: 42,
          width: 58,
          decoration: BoxDecoration(
            color: widget.accent.withOpacity(glow.value),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: widget.accent.withOpacity(0.26)),
            boxShadow: [
              BoxShadow(
                color: widget.accent.withOpacity(glow.value),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(child: widget.child),
        );
      },
    );
  }
}

class WelcomeMessageCard extends StatelessWidget {
  final VoidCallback onTap;

  const WelcomeMessageCard({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF101827), Color(0xFF1D2D45), Color(0xFF28496B)],
          ),
          border: Border.all(color: Colors.white24),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF28496B).withOpacity(0.22),
              blurRadius: 26,
              offset: Offset(0, 16),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: AppColors.champagne.withOpacity(0.14),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.champagne.withOpacity(0.24),
                ),
              ),
              child: const Icon(
                Icons.mark_email_read_rounded,
                color: AppColors.champagne,
                size: 29,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Hoş Geldiniz',
                    style: TextStyle(
                      color: Colors.white,
                      decoration: TextDecoration.none,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Zurich Sigorta Liderlik Buluşması için hazırlanan karşılama mesajını görüntüleyin.',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.58),
                      decoration: TextDecoration.none,
                      fontSize: 12.8,
                      height: 1.35,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chevron_right_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardSectionTitle extends StatelessWidget {
  final String title;

  const DashboardSectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        decoration: TextDecoration.none,
        fontSize: 21,
        fontWeight: FontWeight.w900,
        letterSpacing: -0.4,
      ),
    );
  }
}

class CompactDashboardButton extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final VoidCallback onTap;

  const CompactDashboardButton({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.onTap,
  });

  @override
  State<CompactDashboardButton> createState() => _CompactDashboardButtonState();
}

class _CompactDashboardButtonState extends State<CompactDashboardButton> {
  bool hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() {
          hovered = true;
        });
      },
      onExit: (_) {
        setState(() {
          hovered = false;
        });
      },
      child: PressableScale(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          transform: Matrix4.translationValues(0, hovered ? -4 : 0, 0),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(hovered ? 0.105 : 0.075),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: widget.accent.withOpacity(hovered ? 0.28 : 0.14),
            ),
            boxShadow: [
              BoxShadow(
                color: widget.accent.withOpacity(hovered ? 0.16 : 0.04),
                blurRadius: hovered ? 22 : 12,
                offset: const Offset(0, 12),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.30),
                blurRadius: 18,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Row(
            children: [
              AnimatedGlowIconContainer(
                accent: widget.accent,
                icon: widget.icon,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        decoration: TextDecoration.none,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.52),
                        decoration: TextDecoration.none,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
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

class AnimatedGlowIconContainer extends StatefulWidget {
  final Color accent;
  final IconData icon;

  const AnimatedGlowIconContainer({
    super.key,
    required this.accent,
    required this.icon,
  });

  @override
  State<AnimatedGlowIconContainer> createState() =>
      _AnimatedGlowIconContainerState();
}

class _AnimatedGlowIconContainerState extends State<AnimatedGlowIconContainer>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;
  late final Animation<double> glow;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2100),
    )..repeat(reverse: true);

    glow = Tween<double>(
      begin: 0.14,
      end: 0.25,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: glow,
      builder: (context, _) {
        return Container(
          width: 39,
          height: 39,
          decoration: BoxDecoration(
            color: widget.accent.withOpacity(glow.value),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: widget.accent.withOpacity(0.25)),
            boxShadow: [
              BoxShadow(
                color: widget.accent.withOpacity(glow.value * 0.7),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Icon(widget.icon, size: 20, color: widget.accent),
        );
      },
    );
  }
}

class QrAccessCard extends StatelessWidget {
  final VoidCallback onTap;

  const QrAccessCard({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF101827),
              Color(0xFF1B2A3E),
              Color(0xFF263D5C),
            ],
          ),
          border: Border.all(color: Colors.white10),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF22344E).withOpacity(0.28),
              blurRadius: 28,
              offset: Offset(0, 16),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.champagne.withOpacity(0.14),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.champagne.withOpacity(0.24),
                ),
              ),
              child: const Icon(
                Icons.qr_code_2_rounded,
                color: AppColors.champagne,
                size: 30,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'QR Kodum',
                    style: TextStyle(
                      color: Colors.white,
                      decoration: TextDecoration.none,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Etkinlik giri\u015Finde QR kodunuzu g\u00F6sterin.',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.60),
                      decoration: TextDecoration.none,
                      fontSize: 12.8,
                      height: 1.35,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chevron_right_rounded,
                color: Colors.white,
                size: 25,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DailyNotesCompactButton extends StatelessWidget {
  const DailyNotesCompactButton({super.key});

  void showDailyNotes(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF111827),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
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
                const SizedBox(height: 18),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'G\u00FCn\u00FCn Notlar\u0131',
                    style: TextStyle(
                      color: Colors.white,
                      decoration: TextDecoration.none,
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const DailyNotesCard(),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: () => showDailyNotes(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: glassDecoration(radius: 26, opacity: 0.070),
        child: Row(
          children: [
            AnimatedGlowIconContainer(
              accent: const Color(0xFF7EA7D8),
              icon: Icons.notes_rounded,
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'G\u00FCn\u00FCn Notlar\u0131',
                    style: TextStyle(
                      color: Colors.white,
                      decoration: TextDecoration.none,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Hava durumu, transfer ve etkinlik notlar\u0131',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.56),
                      decoration: TextDecoration.none,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Colors.white70,
              size: 25,
            ),
          ],
        ),
      ),
    );
  }
}
class DailyNotesCard extends StatelessWidget {
  const DailyNotesCard({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedHoverLift(
      borderRadius: 28,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: glassDecoration(radius: 28, opacity: 0.075),
        child: Column(
          children: const [
            DailyNoteRow(
              icon: Icons.cloud_rounded,
              title: 'Hava Durumu',
              subtitle: 'İstanbul · 18°C · Hafif yağmurlu. İnce mont önerilir.',
              accent: Color(0xFF7EA7D8),
            ),
            SizedBox(height: 13),
            DailyNoteRow(
              icon: Icons.directions_bus_filled_rounded,
              title: 'Transfer Notu',
              subtitle: '18:30’da otel ana girişinden hareket edilecektir.',
              accent: Color(0xFFD6B16A),
            ),
            SizedBox(height: 13),
            DailyNoteRow(
              icon: Icons.badge_rounded,
              title: 'Etkinlik Notu',
              subtitle: 'Yaka kartınızı gün boyunca yanınızda bulundurunuz.',
              accent: Color(0xFF72C7C2),
            ),
          ],
        ),
      ),
    );
  }
}

class DailyNoteRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color accent;

  const DailyNoteRow({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedGlowIconContainer(accent: accent, icon: icon),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  decoration: TextDecoration.none,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.56),
                  decoration: TextDecoration.none,
                  fontSize: 12.7,
                  height: 1.32,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class AnimatedHoverLift extends StatefulWidget {
  final Widget child;
  final double borderRadius;

  const AnimatedHoverLift({
    super.key,
    required this.child,
    required this.borderRadius,
  });

  @override
  State<AnimatedHoverLift> createState() => _AnimatedHoverLiftState();
}

class _AnimatedHoverLiftState extends State<AnimatedHoverLift> {
  bool hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() {
          hovered = true;
        });
      },
      onExit: (_) {
        setState(() {
          hovered = false;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0, hovered ? -4 : 0, 0),
        child: widget.child,
      ),
    );
  }
}

