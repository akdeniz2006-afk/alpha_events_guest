import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/demo_event_data.dart';
import '../theme/app_colors.dart';
import '../widgets/app_page.dart';
import '../widgets/header_title.dart';
import '../widgets/pressable_scale.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  IconData iconForType(String type) {
    switch (type) {
      case 'coordinator':
        return Icons.support_agent_rounded;
      case 'hotel':
        return Icons.hotel_rounded;
      case 'transfer':
        return Icons.directions_car_rounded;
      case 'health':
        return Icons.local_hospital_rounded;
      default:
        return Icons.phone_rounded;
    }
  }

  Color colorForType(String type) {
    switch (type) {
      case 'coordinator':
        return AppColors.champagne;
      case 'hotel':
        return const Color(0xFF7EA7D8);
      case 'transfer':
        return const Color(0xFF72C7C2);
      case 'health':
        return const Color(0xFFE07A5F);
      default:
        return AppColors.champagne;
    }
  }

  String labelForType(String type) {
    switch (type) {
      case 'coordinator':
        return 'KOORDİNATÖR';
      case 'hotel':
        return 'OTEL';
      case 'transfer':
        return 'TRANSFER';
      case 'health':
        return 'ACİL';
      default:
        return 'DESTEK';
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool openedAsSubPage = Navigator.of(context).canPop();

    return AppPage(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(18, 16, 18, openedAsSubPage ? 42 : 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            openedAsSubPage
                ? const BackHeader(
                    title: 'Yardım',
                    subtitle: 'İletişim ve acil destek noktaları',
                  )
                : const HeaderTitle(
                    title: 'Yardım',
                    subtitle: 'İletişim ve acil destek noktaları',
                  ),
            const SizedBox(height: 20),
            const HelpHeroCard(),
            const SizedBox(height: 18),
            const EmergencyQuickCard(),
            const SizedBox(height: 22),
            const Text(
              'Hızlı İletişim',
              style: TextStyle(
                color: Colors.white,
                decoration: TextDecoration.none,
                fontSize: 21,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 12),
            ...demoContacts.where((contact) => contact.type != 'health').map((
              contact,
            ) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ContactCard(
                  contact: contact,
                  icon: iconForType(contact.type),
                  accentColor: colorForType(contact.type),
                  typeLabel: labelForType(contact.type),
                ),
              );
            }),
            const SizedBox(height: 10),
            const EmergencyNoteCard(),
          ],
        ),
      ),
    );
  }
}

class HelpHeroCard extends StatelessWidget {
  const HelpHeroCard({super.key});

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
                  Icons.support_agent_rounded,
                  color: AppColors.champagne,
                  size: 28,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Etkinlik Destek Merkezi',
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
                      'Koordinasyon, otel, transfer ve acil durum destek kişilerine buradan hızlıca ulaşabilirsiniz.',
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

class EmergencyQuickCard extends StatelessWidget {
  const EmergencyQuickCard({super.key});

  Future<void> callEmergency(BuildContext context) async {
    final uri = Uri.parse('tel:112');

    if (!await launchUrl(uri)) {
      if (!context.mounted) return;
      showDemoMessage(
        context,
        '112 araması başlatılamadı. Bu özellik cihaz/tarayıcı desteğine bağlıdır.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: () => callEmergency(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFE07A5F).withOpacity(0.12),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: const Color(0xFFE07A5F).withOpacity(0.26)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFE07A5F).withOpacity(0.10),
              blurRadius: 22,
              offset: const Offset(0, 14),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.22),
              blurRadius: 18,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFFE07A5F).withOpacity(0.16),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: const Color(0xFFE07A5F).withOpacity(0.28),
                ),
              ),
              child: const Icon(
                Icons.local_hospital_rounded,
                color: Color(0xFFE07A5F),
                size: 26,
              ),
            ),
            const SizedBox(width: 13),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Acil Durum',
                    style: TextStyle(
                      color: Colors.white,
                      decoration: TextDecoration.none,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Sağlık veya güvenlik acil durumlarında doğrudan 112’yi arayın.',
                    style: TextStyle(
                      color: Color(0xAAFFFFFF),
                      decoration: TextDecoration.none,
                      fontSize: 12.5,
                      height: 1.32,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.call_rounded,
                color: Color(0xFFE07A5F),
                size: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ContactCard extends StatelessWidget {
  final ContactItem contact;
  final IconData icon;
  final Color accentColor;
  final String typeLabel;

  const ContactCard({
    super.key,
    required this.contact,
    required this.icon,
    required this.accentColor,
    required this.typeLabel,
  });

  Future<void> callNumber(BuildContext context) async {
    final cleanPhone = contact.phone.replaceAll(' ', '');
    final uri = Uri.parse('tel:$cleanPhone');

    if (!await launchUrl(uri)) {
      if (!context.mounted) return;
      showDemoMessage(
        context,
        'Arama başlatılamadı. Bu özellik cihaz/tarayıcı desteğine bağlıdır.',
      );
    }
  }

  Future<void> openWhatsApp(BuildContext context) async {
    final cleanPhone = contact.phone
        .replaceAll('+', '')
        .replaceAll(' ', '')
        .replaceAll('-', '')
        .replaceAll('(', '')
        .replaceAll(')', '');

    if (cleanPhone == '112') {
      showDemoMessage(
        context,
        '112 acil durum için WhatsApp yerine direkt arama kullanın.',
      );
      return;
    }

    final message = Uri.encodeComponent(
      'Merhaba, etkinlik portalı üzerinden yazıyorum.',
    );

    final uri = Uri.parse('https://wa.me/$cleanPhone?text=$message');

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!context.mounted) return;
      showDemoMessage(
        context,
        'WhatsApp açılamadı. Numara veya cihaz desteği kontrol edilmeli.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isEmergency = contact.type == 'health';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(isEmergency ? 0.085 : 0.070),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: isEmergency
              ? accentColor.withOpacity(0.24)
              : Colors.white.withOpacity(0.09),
        ),
        boxShadow: [
          BoxShadow(
            color: isEmergency
                ? accentColor.withOpacity(0.08)
                : Colors.black.withOpacity(0.22),
            blurRadius: 20,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: accentColor.withOpacity(0.22)),
                  boxShadow: [
                    BoxShadow(
                      color: accentColor.withOpacity(0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 9),
                    ),
                  ],
                ),
                child: Icon(icon, color: accentColor, size: 25),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 24,
                      padding: const EdgeInsets.symmetric(horizontal: 9),
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(13),
                        border: Border.all(
                          color: accentColor.withOpacity(0.20),
                        ),
                      ),
                      child: Center(
                        widthFactor: 1,
                        child: Text(
                          typeLabel,
                          style: TextStyle(
                            color: accentColor,
                            decoration: TextDecoration.none,
                            fontSize: 9.8,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.65,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      contact.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        decoration: TextDecoration.none,
                        fontWeight: FontWeight.w900,
                        fontSize: 15.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      contact.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.58),
                        decoration: TextDecoration.none,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.055),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withOpacity(0.075)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.phone_rounded,
                  size: 16,
                  color: Colors.white.withOpacity(0.46),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    contact.phone,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.58),
                      decoration: TextDecoration.none,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ContactActionButton(
                  icon: Icons.call_rounded,
                  label: 'Ara',
                  accentColor: accentColor,
                  onTap: () => callNumber(context),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ContactActionButton(
                  icon: Icons.chat_rounded,
                  label: 'WhatsApp',
                  accentColor: accentColor,
                  onTap: () => openWhatsApp(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ContactActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color accentColor;
  final VoidCallback onTap;

  const ContactActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      child: Container(
        height: 42,
        decoration: BoxDecoration(
          color: accentColor.withOpacity(0.12),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: accentColor.withOpacity(0.22)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: accentColor, size: 18),
            const SizedBox(width: 7),
            Text(
              label,
              style: TextStyle(
                color: accentColor,
                decoration: TextDecoration.none,
                fontSize: 12.8,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EmergencyNoteCard extends StatelessWidget {
  const EmergencyNoteCard({super.key});

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
              'Acil sağlık durumlarında doğrudan 112 aranmalıdır. WhatsApp mesajları acil durum iletişimi için uygun değildir.',
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
