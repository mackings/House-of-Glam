import 'package:flutter/material.dart';
import 'package:hog/components/texts.dart';

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
      backgroundColor: Colors.purple,
      title: CustomText(title, fontSize: 18, color: Colors.white),
      actions: [
        IconButton(
          onPressed: onRefresh,
          icon: const Icon(Icons.refresh, color: Colors.white),
        ),
        IconButton(
          onPressed: onProfileClick,
          icon: const Icon(Icons.person, color: Colors.white),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
