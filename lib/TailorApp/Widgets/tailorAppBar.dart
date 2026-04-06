import 'package:flutter/material.dart';
import 'package:hog/components/texts.dart';
import 'package:hog/theme/app_theme.dart';

class TailorAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback onRefresh;
  final VoidCallback onProfileClick;

  const TailorAppBar({
    super.key,
    required this.title,
    required this.onRefresh,
    required this.onProfileClick,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      toolbarHeight: 76,
      backgroundColor: AppColors.canvas,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      titleSpacing: 18,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            title,
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
            textAlign: TextAlign.left,
          ),
          const SizedBox(height: 3),
          CustomText(
            "Fresh assignments and deliveries in one place",
            fontSize: 12,
            color: AppColors.subtext,
            textAlign: TextAlign.left,
          ),
        ],
      ),
      actions: [
        _ActionButton(
          icon: Icons.refresh_rounded,
          tooltip: "Refresh",
          onTap: onRefresh,
        ),
        _ActionButton(
          icon: Icons.person_outline_rounded,
          tooltip: "Profile",
          onTap: onProfileClick,
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: Tooltip(
        message: tooltip,
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 14,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Icon(icon, color: AppColors.ink, size: 20),
            ),
          ),
        ),
      ),
    );
  }
}
