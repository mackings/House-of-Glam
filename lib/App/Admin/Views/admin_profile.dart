import 'package:flutter/material.dart';
import 'package:hog/App/Auth/Api/secure.dart';
import 'package:hog/App/Auth/Views/signin.dart';
import 'package:hog/components/Navigator.dart';
import 'package:hog/components/texts.dart';
import 'package:hog/theme/app_theme.dart';

class AdminProfile extends StatefulWidget {
  const AdminProfile({super.key});

  @override
  State<AdminProfile> createState() => _AdminProfileState();
}

class _AdminProfileState extends State<AdminProfile> {
  late Future<Map<String, dynamic>?> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = SecurePrefs.getUserData();
  }

  Future<void> _logout() async {
    await SecurePrefs.clearAll();
    if (!mounted) return;
    Nav.pushReplacementAll(context, const Signin());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: const Text('Admin Profile'),
        backgroundColor: AppColors.canvas,
        surfaceTintColor: Colors.transparent,
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _profileFuture,
        builder: (context, snapshot) {
          final profile = snapshot.data ?? const <String, dynamic>{};
          final name =
              _firstText(profile, const ['name', 'fullName', 'username']) ??
              'Administrator';
          final email = _firstText(profile, const ['email']) ?? 'No email';
          final role =
              (_firstText(profile, const ['role']) ?? 'admin').toUpperCase();

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 34,
                      backgroundColor: AppColors.accentSoft,
                      child: Icon(
                        Icons.admin_panel_settings_outlined,
                        color: AppColors.accent,
                        size: 34,
                      ),
                    ),
                    const SizedBox(height: 14),
                    CustomText(name, fontSize: 20, fontWeight: FontWeight.w800),
                    const SizedBox(height: 4),
                    CustomText(email, color: AppColors.subtext),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accentSoft,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: CustomText(
                        role,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.accent,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _logout,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.logout_rounded, color: AppColors.danger),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomText(
                              'Log Out',
                              fontWeight: FontWeight.w800,
                              textAlign: TextAlign.left,
                            ),
                            SizedBox(height: 3),
                            CustomText(
                              'End this admin session',
                              fontSize: 12,
                              color: AppColors.subtext,
                              textAlign: TextAlign.left,
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.subtext,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

String? _firstText(Map<String, dynamic> record, List<String> keys) {
  for (final key in keys) {
    final value = record[key]?.toString().trim();
    if (value != null && value.isNotEmpty) return value;
  }
  return null;
}
