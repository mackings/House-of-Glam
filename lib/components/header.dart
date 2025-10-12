import 'package:flutter/material.dart';
import 'package:hog/App/Profile/profileHome.dart';
import 'package:hog/App/UserProfile/Views/UserProfile.dart';
import 'package:hog/components/Navigator.dart';
import 'package:intl/intl.dart';

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

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Left side: Avatar + Greeting + Name
        Row(
          children: [
            GestureDetector(
              onTap: () {
                Nav.push(context, UserProfileView());
              },
              child: CircleAvatar(
                radius: 24,
                backgroundImage: NetworkImage(avatarUrl),
                backgroundColor: Colors.grey[300],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                Text(
                  userName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),

        // Right side: Notifications Bell
        Row(
          children: [
            IconButton(
              onPressed: onNotificationTap ?? () {},
              icon: const Icon(
                Icons.delivery_dining_outlined,
                size: 28,
                color: Colors.black87,
              ),
            ),

            IconButton(
              onPressed: (){
                 Nav.push(context, UserProfile());
              },
              icon: const Icon(
                Icons.shopping_bag,
                size: 28,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
