import 'package:flutter/material.dart';

import 'app_page.dart';

class InfoListCard extends StatelessWidget {
  final List<InfoListItem> items;

  const InfoListCard({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: glassDecoration(),
      child: Column(
        children: List.generate(items.length, (index) {
          final item = items[index];
          final isLast = index == items.length - 1;

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: isLast
                      ? Colors.transparent
                      : Colors.white.withOpacity(0.07),
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  item.icon,
                  size: 21,
                  color: Colors.white.withOpacity(0.72),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Text(
                    item.title,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.56),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Flexible(
                  child: Text(
                    item.value,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class InfoListItem {
  final IconData icon;
  final String title;
  final String value;

  const InfoListItem({
    required this.icon,
    required this.title,
    required this.value,
  });
}