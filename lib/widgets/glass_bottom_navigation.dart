import 'dart:ui';

import 'package:flutter/material.dart';

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
    final items = [
      _NavItem(icon: Icons.home_rounded, label: 'Ana Sayfa'),
      _NavItem(icon: Icons.calendar_month_rounded, label: 'Program'),
      _NavItem(icon: Icons.hotel_rounded, label: 'Odam'),
      _NavItem(icon: Icons.photo_library_rounded, label: 'Fotoğraflar'),
      _NavItem(icon: Icons.support_agent_rounded, label: 'Yardım'),
    ];

    return Center(
      heightFactor: 1,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 430),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
              child: Container(
                height: 72,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.09),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: Colors.white.withOpacity(0.13)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.42),
                      blurRadius: 28,
                      offset: const Offset(0, 16),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(items.length, (index) {
                    final item = items[index];
                    final isSelected = index == selectedIndex;

                    return GestureDetector(
                      onTap: () => onChanged(index),
                      behavior: HitTestBehavior.opaque,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.white.withOpacity(0.16)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              item.icon,
                              size: 22,
                              color: isSelected
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.52),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.label,
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: isSelected
                                    ? FontWeight.w800
                                    : FontWeight.w500,
                                color: isSelected
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.50),
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ],
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
  }
}

class _NavItem {
  final IconData icon;
  final String label;

  const _NavItem({required this.icon, required this.label});
}
