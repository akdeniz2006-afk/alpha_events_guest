import 'package:flutter/material.dart';

import '../data/demo_event_data.dart';
import '../theme/app_colors.dart';
import '../widgets/app_page.dart';
import '../widgets/header_title.dart';

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
        return AppColors.navyEnd;
      case 'transfer':
        return AppColors.petrolEnd;
      case 'health':
        return AppColors.borusanOrange;
      default:
        return AppColors.champagne;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool openedAsSubPage = Navigator.of(context).canPop();

    return AppPage(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          18,
          16,
          18,
          openedAsSubPage ? 40 : 108,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            openedAsSubPage
                ? const BackHeader(
                    title: 'Yardım',
                    subtitle: 'Acil durum ve iletişim kişileri',
                  )
                : const HeaderTitle(
                    title: 'Yardım',
                    subtitle: 'Acil durum ve iletişim kişileri',
                  ),
            const SizedBox(height: 22),
            ...demoContacts.map((contact) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ContactCard(
                  contact: contact,
                  icon: iconForType(contact.type),
                  accentColor: colorForType(contact.type),
                ),
              );
            }),
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

  const ContactCard({
    super.key,
    required this.contact,
    required this.icon,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: glassDecoration(
        radius: 24,
        opacity: 0.075,
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(17),
              border: Border.all(
                color: accentColor.withOpacity(0.20),
              ),
            ),
            child: Icon(
              icon,
              color: accentColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contact.title,
                  style: const TextStyle(
                    color: Colors.white,
                    decoration: TextDecoration.none,
                    fontWeight: FontWeight.w900,
                    fontSize: 15.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${contact.name} · ${contact.phone}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.56),
                    decoration: TextDecoration.none,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => showDemoMessage(
              context,
              '${contact.phone} aranacak.',
            ),
            icon: const Icon(Icons.call_rounded, size: 21),
          ),
          IconButton(
            onPressed: () => showDemoMessage(
              context,
              'WhatsApp bağlantısı açılacak.',
            ),
            icon: const Icon(Icons.chat_rounded, size: 21),
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
  );
}