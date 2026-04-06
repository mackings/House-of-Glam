import 'package:flutter/material.dart';
import 'package:hog/App/Admin/Widgets/moderationHistoryTab.dart';
import 'package:hog/App/Admin/Widgets/moderationListingsTab.dart';
import 'package:hog/App/Auth/Api/secure.dart';
import 'package:hog/components/texts.dart';
import 'package:hog/theme/app_theme.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  String? _userRole;
  String? _userId;
  bool _loadingIdentity = true;

  bool get _isSuperAdmin => (_userRole ?? '').toLowerCase() == 'superadmin';

  @override
  void initState() {
    super.initState();
    _loadIdentity();
  }

  Future<void> _loadIdentity() async {
    final role = await SecurePrefs.getUserRole();
    final userId = await SecurePrefs.getUserId();

    if (!mounted) {
      return;
    }

    setState(() {
      _userRole = role;
      _userId = userId;
      _loadingIdentity = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: AppColors.canvas,
        appBar: AppBar(
          backgroundColor: AppColors.canvas,
          surfaceTintColor: Colors.transparent,
          iconTheme: const IconThemeData(color: AppColors.ink),
          toolbarHeight: 92,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CustomText(
                'Listing Moderation',
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 4),
              CustomText(
                _isSuperAdmin
                    ? 'System-wide approval, rejection, and moderator activity'
                    : 'Your approval queue, review history, and decisions',
                fontSize: 12,
                color: AppColors.subtext,
                textAlign: TextAlign.left,
              ),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: CustomText(
                    _isSuperAdmin ? 'Super Admin' : 'Admin',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.accent,
                  ),
                ),
              ),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(64),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.border),
                ),
                child: const TabBar(
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelColor: AppColors.accent,
                  unselectedLabelColor: AppColors.subtext,
                  indicator: BoxDecoration(
                    color: AppColors.accentSoft,
                    borderRadius: BorderRadius.all(Radius.circular(14)),
                  ),
                  tabs: [
                    Tab(text: 'Pending'),
                    Tab(text: 'Approved'),
                    Tab(text: 'Rejected'),
                    Tab(text: 'Activity'),
                  ],
                ),
              ),
            ),
          ),
        ),
        body:
            _loadingIdentity
                ? const Center(
                  child: CircularProgressIndicator(color: AppColors.accent),
                )
                : TabBarView(
                  children: [
                    ModerationListingsTab(
                      status: 'pending',
                      isSuperAdmin: _isSuperAdmin,
                    ),
                    ModerationListingsTab(
                      status: 'approved',
                      isSuperAdmin: _isSuperAdmin,
                    ),
                    ModerationListingsTab(
                      status: 'rejected',
                      isSuperAdmin: _isSuperAdmin,
                    ),
                    ModerationHistoryTab(
                      isSuperAdmin: _isSuperAdmin,
                      userId: _userId,
                    ),
                  ],
                ),
      ),
    );
  }
}
