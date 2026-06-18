import 'package:flutter/material.dart';
import 'package:hog/components/texts.dart';
import 'package:hog/theme/app_theme.dart';

class AnalyticsCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color tint;
  final VoidCallback? onTap;

  const AnalyticsCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.tint,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.border),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 18,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: tint.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, size: 22, color: tint),
                ),
                const Spacer(),
                if (onTap != null)
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 15,
                    color: AppColors.subtext,
                  ),
              ],
            ),
            const SizedBox(height: 16),
            CustomText(
              title,
              fontSize: 12,
              color: AppColors.subtext,
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 8),
            CustomText(
              value,
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
              textAlign: TextAlign.left,
            ),
          ],
        ),
      ),
    );
  }
}
