import 'dart:ui';

import 'package:flutter/material.dart';

import '../l10n/app_text.dart';
import '../l10n/app_language.dart';

class GlassBottomNavigation extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const GlassBottomNavigation({
    super.key,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: AppLanguage.notifier,
      builder: (context, languageCode, _) {
        final items = [
      _NavItem(icon: Icons.home_rounded, label: AppText.t('nav.home'), color: Color(0xFF60A5FA)),
      _NavItem(icon: Icons.calendar_month_rounded, label: AppText.t('nav.program'), color: Color(0xFF38BDF8)),
      _NavItem(icon: Icons.hotel_rounded, label: AppText.t('nav.room'), color: Color(0xFFFBBF24)),
      _NavItem(icon: Icons.photo_library_rounded, label: AppText.t('nav.photos'), color: Color(0xFFA78BFA)),
      _NavItem(icon: Icons.support_agent_rounded, label: AppText.t('nav.help'), color: Color(0xFF34D399)),
    ];

        return Center(
          heightFactor: 1,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 430),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
              child: Container(
                height: 68,
                decoration: BoxDecoration(
                  color: const Color(0xFF111827).withOpacity(0.88),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.20),
                    width: 1.1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.58),
                      blurRadius: 30,
                      offset: const Offset(0, 16),
                    ),
                    BoxShadow(
                      color: const Color(0xFF2563EB).withOpacity(0.16),
                      blurRadius: 24,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: List.generate(items.length, (index) {
                    final item = items[index];
                    final isSelected = index == selectedIndex;

                    return Expanded(
                      child: GestureDetector(
                        onTap: () => onChanged(index),
                        behavior: HitTestBehavior.opaque,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeOut,
                          margin: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 6,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? item.color.withOpacity(0.16)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(24),
                            border: isSelected
                                ? Border.all(
                                    color: item.color.withOpacity(0.28),
                                  )
                                : null,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: isSelected ? 31 : 27,
                                height: isSelected ? 31 : 27,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? item.color.withOpacity(0.28)
                                      : item.color.withOpacity(0.13),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  item.icon,
                                  size: isSelected ? 19 : 17,
                                  color: isSelected
                                      ? item.color
                                      : item.color.withOpacity(0.82),
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                item.label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: isSelected ? 9.2 : 8.8,
                                  fontWeight: isSelected
                                      ? FontWeight.w900
                                      : FontWeight.w700,
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.70),
                                  decoration: TextDecoration.none,
                                  height: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
        ),
      ),
        );
      },
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final Color color;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.color,
  });
}