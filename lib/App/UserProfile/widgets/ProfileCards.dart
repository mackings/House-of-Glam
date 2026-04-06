import 'package:flutter/material.dart';
import 'package:hog/components/texts.dart';
import 'package:hog/theme/app_theme.dart';

class ProfileInfoCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final bool showArrow;
  final bool accent;

  const ProfileInfoCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.showArrow = false,
    this.accent = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 14,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: accent ? AppColors.accentSoft : AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: accent ? AppColors.accent : AppColors.subtext,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  title,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.subtext,
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 4),
                CustomText(
                  value,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                  textAlign: TextAlign.left,
                ),
              ],
            ),
          ),
          if (showArrow)
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: AppColors.subtext,
            ),
        ],
      ),
    );
  }
}
