import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hog/App/Auth/Views/signin.dart';
import 'package:hog/App/UserProfile/Api/profileViewS.dart';
import 'package:hog/App/UserProfile/model/profileViewModel.dart';
import 'package:hog/App/UserProfile/widgets/ProfileCards.dart';
import 'package:hog/components/Navigator.dart';
import 'package:hog/components/texts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

class UserProfileView extends StatefulWidget {
  const UserProfileView({super.key});

  @override
  State<UserProfileView> createState() => _UserProfileViewState();
}

class _UserProfileViewState extends State<UserProfileView> {
  UserProfile? _userProfile;
  bool _loading = true;

  Future<void> _launchWhatsApp(String phone) async {
    final url = Uri.parse("https://wa.me/$phone");
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Could not open WhatsApp")));
    }
  }

  Future<void> _launchEmail(String email) async {
    final url = Uri.parse("mailto:$email");
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Could not open Email app")));
    }
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final imageFile = File(pickedFile.path);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Uploading image...")));

      final success = await UserProfileViewService.uploadProfileImage(
        imageFile,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Profile image updated")),
        );
        _fetchProfile(); // Refresh after upload
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("❌ Failed to upload image")),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    final profile = await UserProfileViewService.getProfile();
    setState(() {
      _userProfile = profile;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.purple,
        title: const CustomText("Profile", color: Colors.white, fontSize: 18),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child:
            _loading
                ? const Center(
                  child: CircularProgressIndicator(color: Colors.purple),
                )
                : _userProfile == null
                ? const Center(child: Text("Failed to load profile"))
                : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // 👤 Profile Picture + Upload
                      Center(
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            GestureDetector(
                              onTap: () {
                                _pickAndUploadImage(); // ✅ Now it actually runs the function
                              },
                              child: CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.purple.shade100,
                                backgroundImage:
                                    _userProfile!.billImage != null
                                        ? NetworkImage(_userProfile!.billImage!)
                                        : null,
                                child:
                                    _userProfile!.billImage == null
                                        ? const Icon(
                                          Icons.person,
                                          size: 60,
                                          color: Colors.purple,
                                        )
                                        : null,
                              ),
                            ),
                            if (_userProfile!.isVerified == true)
                              Container(
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                padding: const EdgeInsets.all(3),
                                child: const CircleAvatar(
                                  radius: 12,
                                  backgroundColor: Colors.green,
                                  child: Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),
                      CustomText(
                        _userProfile!.fullName ?? "N/A",
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      const SizedBox(height: 4),
                      CustomText(
                        _userProfile!.email ?? "",
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                      const SizedBox(height: 20),

                      // ✅ Verified Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          color:
                              _userProfile!.isVerified == true
                                  ? Colors.green
                                  : Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: CustomText(
                          _userProfile!.isVerified == true
                              ? "Verified Account"
                              : "Unverified Account",
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 25),
                      const Divider(color: Colors.black12, thickness: 1),

                      // 🧱 Info Cards
                      const SizedBox(height: 15),
                      ProfileInfoCard(
                        icon: Icons.person,
                        title: "Full Name",
                        value: _userProfile!.fullName ?? "N/A",
                      ),
                      ProfileInfoCard(
                        icon: Icons.email,
                        title: "Email",
                        value: _userProfile!.email ?? "N/A",
                      ),
                      ProfileInfoCard(
                        icon: Icons.phone,
                        title: "Phone Number",
                        value: _userProfile!.phoneNumber ?? "N/A",
                      ),
                      ProfileInfoCard(
                        icon: Icons.home,
                        title: "Address",
                        value: _userProfile!.address ?? "N/A",
                      ),
                      ProfileInfoCard(
                        icon: Icons.flag,
                        title: "Country",
                        value: _userProfile!.country ?? "N/A",
                      ),
                      ProfileInfoCard(
                        icon: Icons.workspace_premium,
                        title: "Subscription Plan",
                        value: _userProfile!.subscriptionPlan ?? "Free",
                      ),
                      ProfileInfoCard(
                        icon: Icons.verified_user,
                        title: "Account Type",
                        value: "${_userProfile!.role ?? "Tailor"}",
                      ),

                      const SizedBox(height: 10),

                      GestureDetector(
                        onTap: () => _launchWhatsApp("2348137159066"),
                        child: ProfileInfoCard(
                          icon: Icons.chat_bubble,
                          title: "WhatsApp Support",
                          value: "Admin",
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _launchEmail("macsonline500@gmail.com"),
                        child: ProfileInfoCard(
                          icon: Icons.support_agent,
                          title: "Email Support",
                          value: "Regional Admin",
                        ),
                      ),

                      GestureDetector(
                        onTap: () {
                          Nav.pushReplacementAll(context, Signin());
                        },
                        child: ProfileInfoCard(
                          icon: Icons.exit_to_app,
                          title: "Exit App",
                          value: "Log off",
                        ),
                      ),
                    ],
                  ),
                ),
      ),
    );
  }
}
