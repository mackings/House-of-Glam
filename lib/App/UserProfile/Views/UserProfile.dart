import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hog/App/Auth/Api/secure.dart';
import 'package:hog/App/Auth/Views/signin.dart';
import 'package:hog/App/Banks/View/userBanks.dart';
import 'package:hog/App/Home/Views/Orders/Transactions/TransactionHistory.dart';
import 'package:hog/App/UserProfile/Api/profileViewS.dart';
import 'package:hog/App/UserProfile/model/profileViewModel.dart';
import 'package:hog/App/UserProfile/widgets/ProfileCards.dart';
import 'package:hog/TailorApp/Home/Views/Subscription.dart';
import 'package:hog/components/Navigator.dart';
import 'package:hog/components/texts.dart';
import 'package:hog/theme/app_theme.dart';
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
    } else if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Could not open WhatsApp")));
    }
  }

  Future<void> _launchEmail(String email) async {
    final url = Uri.parse("mailto:$email");
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Could not open Email app")));
    }
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null || !mounted) return;

    final imageFile = File(pickedFile.path);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Uploading image...")));

    final success = await UserProfileViewService.uploadProfileImage(imageFile);
    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Profile image updated")));
      _fetchProfile();
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to upload image")));
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    final profile = await UserProfileViewService.getProfile();
    if (!mounted) return;
    setState(() {
      _userProfile = profile;
      _loading = false;
    });
  }

  String _formatLabel(String? value, {String fallback = "N/A"}) {
    if (value == null || value.trim().isEmpty) return fallback;
    return value.trim();
  }

  String _formatCapitalized(String? value, {String fallback = "Free"}) {
    final normalized = value?.trim() ?? '';
    if (normalized.isEmpty) return fallback;
    if (normalized.toLowerCase() == 'tailor') return 'Designer';
    return "${normalized[0].toUpperCase()}${normalized.substring(1)}";
  }

  @override
  Widget build(BuildContext context) {
    final profile = _userProfile;
    final isDesigner = _isDesignerRole(profile?.role);

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          "Profile",
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child:
            _loading
                ? const Center(child: CircularProgressIndicator())
                : profile == null
                ? ListView(
                  padding: const EdgeInsets.fromLTRB(20, 40, 20, 24),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Column(
                        children: [
                          Icon(
                            Icons.person_off_outlined,
                            size: 42,
                            color: AppColors.subtext,
                          ),
                          SizedBox(height: 16),
                          CustomText(
                            "Failed to load profile",
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ],
                      ),
                    ),
                  ],
                )
                : RefreshIndicator(
                  onRefresh: _fetchProfile,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(14, 8, 14, 24),
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFF8F3FF), Colors.white],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          children: [
                            Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                GestureDetector(
                                  onTap: _pickAndUploadImage,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: AppColors.accentSoft,
                                        width: 4,
                                      ),
                                    ),
                                    child: CircleAvatar(
                                      radius: 50,
                                      backgroundColor: AppColors.accentSoft,
                                      backgroundImage:
                                          profile.billImage != null
                                              ? NetworkImage(profile.billImage!)
                                              : null,
                                      child:
                                          profile.billImage == null
                                              ? const Icon(
                                                Icons.person_outline_rounded,
                                                size: 56,
                                                color: AppColors.accent,
                                              )
                                              : null,
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: AppColors.border),
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt_outlined,
                                    size: 18,
                                    color: AppColors.accent,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            CustomText(
                              _formatLabel(profile.fullName),
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: AppColors.ink,
                            ),
                            const SizedBox(height: 4),
                            CustomText(
                              _formatLabel(profile.email, fallback: ""),
                              fontSize: 13,
                              color: AppColors.subtext,
                            ),
                            const SizedBox(height: 14),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              alignment: WrapAlignment.center,
                              children: [
                                _StatusChip(
                                  icon:
                                      profile.isVerified == true
                                          ? Icons.verified_rounded
                                          : Icons.error_outline_rounded,
                                  label:
                                      profile.isVerified == true
                                          ? "Verified"
                                          : "Unverified Account",
                                  foreground:
                                      profile.isVerified == true
                                          ? AppColors.success
                                          : AppColors.danger,
                                  background:
                                      profile.isVerified == true
                                          ? const Color(0xFFEEF8F2)
                                          : const Color(0xFFFDECEC),
                                ),
                                if (isDesigner)
                                  _StatusChip(
                                    icon: Icons.workspace_premium_outlined,
                                    label: _formatCapitalized(
                                      profile.subscriptionPlan,
                                    ),
                                    foreground: AppColors.accent,
                                    background: AppColors.accentSoft,
                                  ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _QuickAction(
                                    icon: Icons.account_balance_outlined,
                                    label: "My Wallet",
                                    onTap: () {
                                      Nav.push(context, MyBanksPage());
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _QuickAction(
                                    icon: Icons.receipt_long_outlined,
                                    label: "Transaction History",
                                    onTap: () {
                                      Nav.push(context, Transactions());
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      const _SectionTitle("Account Details"),
                      ProfileInfoCard(
                        icon: Icons.person_outline_rounded,
                        title: "Full Name",
                        value: _formatLabel(profile.fullName),
                      ),
                      ProfileInfoCard(
                        icon: Icons.email_outlined,
                        title: "Email",
                        value: _formatLabel(profile.email),
                      ),
                      ProfileInfoCard(
                        icon: Icons.phone_outlined,
                        title: "Phone Number",
                        value: _formatLabel(profile.phoneNumber),
                      ),
                      ProfileInfoCard(
                        icon: Icons.home_outlined,
                        title: "Address",
                        value: _formatLabel(profile.address),
                      ),
                      ProfileInfoCard(
                        icon: Icons.flag_outlined,
                        title: "Country",
                        value: _formatLabel(profile.country),
                      ),
                      ProfileInfoCard(
                        icon: Icons.verified_user_outlined,
                        title: "Account Type",
                        value: _formatCapitalized(
                          profile.role,
                          fallback: "Designer",
                        ),
                      ),
                      const SizedBox(height: 10),
                      const _SectionTitle("Support"),
                      GestureDetector(
                        onTap: () => _launchWhatsApp("2348137159066"),
                        child: const ProfileInfoCard(
                          icon: Icons.chat_bubble_outline_rounded,
                          title: "WhatsApp Support",
                          value: "Chat with Support",
                          showArrow: true,
                          accent: true,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _launchEmail("macsonline500@gmail.com"),
                        child: const ProfileInfoCard(
                          icon: Icons.support_agent_outlined,
                          title: "Email Support",
                          value: "Email Support Team",
                          showArrow: true,
                        ),
                      ),
                      if (isDesigner &&
                          (profile.subscriptionPlan == null ||
                              profile.subscriptionPlan!.isEmpty ||
                              profile.subscriptionPlan!.toLowerCase() ==
                                  "free")) ...[
                        const SizedBox(height: 10),
                        const _SectionTitle("Upgrade"),
                        GestureDetector(
                          onTap: () {
                            Nav.push(context, Subscription());
                          },
                          child: const ProfileInfoCard(
                            icon: Icons.workspace_premium_outlined,
                            title: "Subscription Plan",
                            value: "Upgrade Your Plan",
                            showArrow: true,
                            accent: true,
                          ),
                        ),
                      ],
                      const SizedBox(height: 10),
                      const _SectionTitle("Session"),
                      GestureDetector(
                        onTap: () async {
                          await SecurePrefs.clearAll();
                          if (!context.mounted) return;
                          Nav.pushReplacementAll(context, const Signin());
                        },
                        child: const ProfileInfoCard(
                          icon: Icons.logout_rounded,
                          title: "Exit App",
                          value: "Log Out",
                          showArrow: true,
                        ),
                      ),
                    ],
                  ),
                ),
      ),
    );
  }
}

bool _isDesignerRole(String? role) {
  final normalized = role?.trim().toLowerCase() ?? '';
  return const {'tailor', 'designer', 'vendor', 'seller'}.contains(normalized);
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.accent),
            const SizedBox(width: 8),
            Expanded(
              child: CustomText(
                label,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
                textAlign: TextAlign.left,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color foreground;
  final Color background;

  const _StatusChip({
    required this.icon,
    required this.label,
    required this.foreground,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: foreground),
          const SizedBox(width: 6),
          CustomText(
            label,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: foreground,
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 4),
      child: CustomText(
        title,
        fontSize: 14,
        fontWeight: FontWeight.w800,
        color: AppColors.ink,
        textAlign: TextAlign.left,
      ),
    );
  }
}
