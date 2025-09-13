import 'package:flutter/material.dart';


class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    
    final items = [
      {"icon": Icons.home, "label": "Home"},
      {"icon": Icons.card_travel, "label": "Order"},
      {"icon": Icons.history, "label": "History"},
      {"icon": Icons.wallet, "label": "Transactions"},
      {"icon": Icons.person, "label": "Profile"},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            blurRadius: 6,
            offset: Offset(0, -2),
            color: Colors.black12,
          )
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
                // 👇 Indicator on top
                Container(
                  height: 4,
                  width: 24,
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.purple : Colors.transparent,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 6),
                Icon(
                  item["icon"] as IconData,
                  color: isSelected ? Colors.purple : Colors.grey,
                ),
                Text(
                  item["label"] as String,
                  style: TextStyle(
                    fontSize: 12,
                    color: isSelected ? Colors.purple : Colors.grey,
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

