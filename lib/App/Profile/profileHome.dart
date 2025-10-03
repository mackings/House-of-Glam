import 'package:flutter/material.dart';
import 'package:hog/App/Profile/widgets/profileMenu.dart';


class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Profile",
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
        backgroundColor: Colors.purple,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),


              ProfileMenuItem(
                icon: Icons.laptop_mac_rounded,
                text: "Market Place",
                onTap: () {},
              ),
              ProfileMenuItem(
                icon: Icons.shopping_bag_outlined,
                text: "",
                onTap: () {},
              ),
              ProfileMenuItem(
                icon: Icons.favorite_border,
                text: "Wishlist",
                onTap: () {},
              ),
              ProfileMenuItem(
                icon: Icons.settings_outlined,
                text: "Settings",
                onTap: () {},
              ),


            ],
          ),
        ),
      ),
    );
  }
}
