import 'package:flutter/material.dart';
import 'package:hog/components/texts.dart';

class ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;
  final Color color;

  const ProfileMenuItem({
    super.key,
    required this.icon,
    required this.text,
    required this.onTap,
    this.color = Colors.black87,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          // 🔲 Each item in its own container
          InkWell(
            onTap: onTap,
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 👇 Icon and text together
                  Row(
                    children: [
                      Icon(icon, color: color, size: 24),
                      const SizedBox(width: 12),
                      CustomText(text, fontSize: 16, color: color),
                    ],
                  ),

                  // 👉 Trailing arrow
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
            ),
          ),

          // ➖ Divider below each container
          const Divider(height: 1, thickness: 0.5, color: Colors.grey),
        ],
      ),
    );
  }
}
