import 'package:flutter/material.dart';
import 'package:hog/theme/app_theme.dart';

class TailorCustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const TailorCustomBottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final items = [
      {"icon": Icons.home_rounded, "label": "Dashboard"},
      {"icon": Icons.assignment_outlined, "label": "Projects"},
      {"icon": Icons.local_shipping_outlined, "label": "Logistics"},
      {"icon": Icons.auto_awesome_mosaic_outlined, "label": "Portfolio"},
      {"icon": Icons.workspace_premium_outlined, "label": "Plans"},
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 6),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            blurRadius: 20,
            offset: Offset(0, 10),
            color: AppColors.shadow,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (index) {
          final item = items[index];
          final isSelected = currentIndex == index;

          return GestureDetector(
            onTap: () => onTap(index),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color:
                        isSelected ? AppColors.accentSoft : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    item["icon"] as IconData,
                    color: isSelected ? AppColors.accent : AppColors.subtext,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item["label"] as String,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? AppColors.accent : AppColors.subtext,
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
