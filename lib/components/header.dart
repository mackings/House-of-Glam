import 'package:flutter/material.dart';
import 'package:hog/App/Profile/profileHome.dart';
import 'package:hog/App/UserProfile/Views/UserProfile.dart';
import 'package:hog/components/Navigator.dart';
import 'package:hog/theme/app_theme.dart';

class Header extends StatelessWidget {
  final String userName;
  final String avatarUrl;
  final VoidCallback? onNotificationTap;

  const Header({
    Key? key,
    required this.userName,
    required this.avatarUrl,
    this.onNotificationTap,
  }) : super(key: key);

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return "Good morning";
    } else if (hour < 17) {
      return "Good afternoon";
    } else {
      return "Good evening";
    }
  }

  @override
  Widget build(BuildContext context) {
    final greeting = _getGreeting();
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Nav.push(context, UserProfileView());
                  },
                  child: CircleAvatar(
                    radius: 28,
                    backgroundImage: NetworkImage(avatarUrl),
                    backgroundColor: Colors.grey[300],
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        greeting,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.subtext,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        userName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Row(
            children: [
              _HeaderIconButton(
                icon: Icons.local_shipping_outlined,
                onTap: onNotificationTap ?? () {},
              ),
              const SizedBox(width: 8),
              _HeaderIconButton(
                icon: Icons.storefront_outlined,
                onTap: () {
                  Nav.push(context, UserProfile());
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(icon, size: 22, color: AppColors.ink),
      ),
    );
  }
}
