import 'dart:async';

import 'package:flutter/material.dart';

import '../data/demo_event_data.dart';
import '../theme/app_colors.dart';
import '../widgets/app_page.dart';
import '../widgets/borusan_logo_badge.dart';
import '../widgets/info_list_card.dart';
import '../widgets/pressable_scale.dart';

import 'announcements_screen.dart';
import 'help_screen.dart';
import 'hotel_gallery_screen.dart';
import 'management_message_screen.dart';
import 'program_screen.dart';
import 'videos_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  void openPage(BuildContext context, Widget page) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 140),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AnimatedEntrance(
              delay: 0,
              child: DashboardTopBar(),
            ),
            const SizedBox(height: 18),
            const AnimatedEntrance(
              delay: 80,
              child: CleanHeroCard(),
            ),
            const SizedBox(height: 18),
            const AnimatedEntrance(
              delay: 140,
              child: TodayCompactCard(),
            ),
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
                    subtitle: 'Günün akışı',
                    icon: Icons.calendar_month_rounded,
                    accent: const Color(0xFF7EA7D8),
                    onTap: () => openPage(context, const ProgramScreen()),
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
                    title: 'Yönetim Notu',
                    subtitle: 'Karşılama',
                    icon: Icons.mark_email_read_rounded,
                    accent: const Color(0xFFC7B58A),
                    onTap: () => openPage(
                      context,
                      const ManagementMessageScreen(),
                    ),
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
            const AnimatedEntrance(
              delay: 460,
              child: DashboardSectionTitle(title: 'Konaklama Galerisi'),
            ),
            const SizedBox(height: 12),
            const AnimatedEntrance(
              delay: 500,
              child: CompactHotelGalleryCard(),
            ),
            const SizedBox(height: 22),
            const AnimatedEntrance(
              delay: 540,
              child: DashboardSectionTitle(title: 'Etkinlik Bilgileri'),
            ),
            const SizedBox(height: 12),
            AnimatedEntrance(
              delay: 580,
              child: InfoListCard(
                items: [
                  InfoListItem(
                    icon: Icons.business_rounded,
                    title: 'Şirket',
                    value: demoGuest.company,
                  ),
                  InfoListItem(
                    icon: Icons.location_on_rounded,
                    title: 'Lokasyon',
                    value: demoGuest.location,
                  ),
                  InfoListItem(
                    icon: Icons.badge_rounded,
                    title: 'Katılımcı Kodu',
                    value: demoGuest.guestCode,
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

class AnimatedEntrance extends StatefulWidget {
  final Widget child;
  final int delay;

  const AnimatedEntrance({
    super.key,
    required this.child,
    required this.delay,
  });

  @override
  State<AnimatedEntrance> createState() => _AnimatedEntranceState();
}

class _AnimatedEntranceState extends State<AnimatedEntrance> {
  bool visible = false;
  Timer? timer;

  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Alpha Events',
                style: TextStyle(
                  color: Colors.white,
                  decoration: TextDecoration.none,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.8,
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
        AnimatedHoverLift(
          borderRadius: 24,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.09),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.12),
              ),
            ),
            child: const Icon(
              Icons.person_rounded,
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
            colors: [
              Color(0xFF06080D),
              Color(0xFF101827),
              Color(0xFF22344E),
            ],
          ),
          border: Border.all(
            color: Colors.white.withOpacity(0.10),
          ),
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
                const SizedBox(
                  height: 78,
                  child: BorusanLogoBadge(),
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

  const FloatingGlow({
    super.key,
    required this.color,
    required this.size,
  });

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

    animation = Tween<double>(begin: 0.92, end: 1.08).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      ),
    );
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
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.color,
        ),
      ),
    );
  }
}

class HeroMiniChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const HeroMiniChip({
    super.key,
    required this.icon,
    required this.label,
  });

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
          border: Border.all(
            color: Colors.white.withOpacity(0.10),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: Colors.white.withOpacity(0.74),
            ),
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
          border: Border.all(
            color: Colors.white.withOpacity(0.10),
          ),
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

    glow = Tween<double>(begin: 0.10, end: 0.22).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeInOut),
    );
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
            border: Border.all(
              color: widget.accent.withOpacity(0.26),
            ),
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

class DashboardSectionTitle extends StatelessWidget {
  final String title;

  const DashboardSectionTitle({
    super.key,
    required this.title,
  });

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

    glow = Tween<double>(begin: 0.14, end: 0.25).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeInOut),
    );
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
            border: Border.all(
              color: widget.accent.withOpacity(0.25),
            ),
            boxShadow: [
              BoxShadow(
                color: widget.accent.withOpacity(glow.value * 0.7),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Icon(
            widget.icon,
            size: 20,
            color: widget.accent,
          ),
        );
      },
    );
  }
}

class CompactHotelGalleryCard extends StatelessWidget {
  const CompactHotelGalleryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedHoverLift(
      borderRadius: 28,
      child: PressableScale(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const HotelGalleryScreen(),
            ),
          );
        },
        child: Container(
          height: 164,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.075),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: Colors.white.withOpacity(0.10),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.30),
                blurRadius: 24,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(28),
                ),
                child: SizedBox(
                  width: 145,
                  height: double.infinity,
                  child: Image.asset(
                    demoHotelPhotos.first,
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.white.withOpacity(0.08),
                        child: const Icon(
                          Icons.apartment_rounded,
                          color: Colors.white,
                          size: 44,
                        ),
                      );
                    },
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(15, 14, 14, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Konaklama Galerisi',
                        style: TextStyle(
                          color: Colors.white,
                          decoration: TextDecoration.none,
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        demoGuest.hotelName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.58),
                          decoration: TextDecoration.none,
                          fontSize: 12.6,
                          height: 1.25,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Text(
                            '${demoHotelPhotos.length} fotoğraf',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.50),
                              decoration: TextDecoration.none,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.10),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.chevron_right_rounded,
                              color: Colors.white.withOpacity(0.72),
                            ),
                          ),
                        ],
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