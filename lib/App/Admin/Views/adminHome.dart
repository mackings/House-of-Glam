import 'package:flutter/material.dart';
import 'package:hog/App/Admin/Views/DeliverySettings.dart';
import 'package:hog/App/Admin/Views/PickupSettings.dart';
import 'package:hog/App/Admin/Views/PricingSettings.dart';
import 'package:hog/App/Admin/Views/SubscriptionSettings.dart';
import 'package:hog/App/Admin/Views/analytics.dart';
import 'package:hog/App/Admin/Views/billing.dart';
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
                'Admin Workspace',
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 4),
              CustomText(
                _isSuperAdmin
                    ? 'Moderation, marketplace settings, and platform controls'
                    : 'Moderation, oversight, and admin controls',
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
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelColor: AppColors.accent,
                  unselectedLabelColor: AppColors.subtext,
                  labelPadding: EdgeInsets.symmetric(horizontal: 22),
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
                : NestedScrollView(
                  headerSliverBuilder: (context, innerBoxIsScrolled) {
                    return [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                          child: _AdminQuickAccess(
                            onOpenAnalytics:
                                () => _openScreen(context, const Analytics()),
                            onOpenBilling:
                                () => _openScreen(context, const SetBilling()),
                            onOpenDelivery:
                                () => _openScreen(
                                  context,
                                  const DeliverySettings(),
                                ),
                            onOpenPickup:
                                () => _openScreen(
                                  context,
                                  const PickupSettings(),
                                ),
                            onOpenPricing:
                                () => _openScreen(
                                  context,
                                  const PricingSettings(),
                                ),
                            onOpenSubscriptions:
                                () => _openScreen(
                                  context,
                                  const SubscriptionSettings(),
                                ),
                          ),
                        ),
                      ),
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: CustomText(
                              'Moderation',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.ink,
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ),
                      ),
                    ];
                  },
                  body: TabBarView(
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
      ),
    );
  }

  void _openScreen(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }
}

class _AdminQuickAccess extends StatefulWidget {
  final VoidCallback onOpenAnalytics;
  final VoidCallback onOpenBilling;
  final VoidCallback onOpenDelivery;
  final VoidCallback onOpenPickup;
  final VoidCallback onOpenPricing;
  final VoidCallback onOpenSubscriptions;

  const _AdminQuickAccess({
    required this.onOpenAnalytics,
    required this.onOpenBilling,
    required this.onOpenDelivery,
    required this.onOpenPickup,
    required this.onOpenPricing,
    required this.onOpenSubscriptions,
  });

  @override
  State<_AdminQuickAccess> createState() => _AdminQuickAccessState();
}

class _AdminQuickAccessState extends State<_AdminQuickAccess> {
  bool _showAll = false;

  @override
  Widget build(BuildContext context) {
    final shortcuts = [
      (
        label: 'Analytics',
        icon: Icons.analytics_outlined,
        tint: AppColors.accent,
        onTap: widget.onOpenAnalytics,
      ),
      (
        label: 'Billing',
        icon: Icons.percent_rounded,
        tint: AppColors.secondaryDeep,
        onTap: widget.onOpenBilling,
      ),
      (
        label: 'Delivery',
        icon: Icons.local_shipping_outlined,
        tint: AppColors.success,
        onTap: widget.onOpenDelivery,
      ),
      (
        label: 'Pickup',
        icon: Icons.store_mall_directory_outlined,
        tint: const Color(0xFF7C3AED),
        onTap: widget.onOpenPickup,
      ),
      (
        label: 'Tax & VAT',
        icon: Icons.receipt_long_outlined,
        tint: const Color(0xFF2563EB),
        onTap: widget.onOpenPricing,
      ),
      (
        label: 'Subscriptions',
        icon: Icons.workspace_premium_outlined,
        tint: const Color(0xFFEC4899),
        onTap: widget.onOpenSubscriptions,
      ),
    ];
    final visibleShortcuts = _showAll ? shortcuts : shortcuts.take(2).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CustomText(
            'Quick Access',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
            textAlign: TextAlign.left,
          ),
          const SizedBox(height: 6),
          const CustomText(
            'Open the rest of the admin screens from here. Moderation stays below as the main working queue.',
            fontSize: 12,
            color: AppColors.subtext,
            textAlign: TextAlign.left,
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              const spacing = 10.0;
              final availableWidth = constraints.maxWidth;
              final useThreeColumns = availableWidth >= 520;
              final columns = useThreeColumns ? 3 : 2;
              final cardWidth =
                  (availableWidth - (spacing * (columns - 1))) / columns;

              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children:
                    visibleShortcuts
                        .map(
                          (item) => SizedBox(
                            width: cardWidth,
                            child: _AdminShortcut(
                              label: item.label,
                              icon: item.icon,
                              tint: item.tint,
                              onTap: item.onTap,
                            ),
                          ),
                        )
                        .toList(),
              );
            },
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                setState(() => _showAll = !_showAll);
              },
              icon: Icon(
                _showAll
                    ? Icons.keyboard_arrow_up_rounded
                    : Icons.keyboard_arrow_down_rounded,
                color: AppColors.accent,
              ),
              label: Text(_showAll ? 'Collapse Tools' : 'Show All Tools'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.accent,
                minimumSize: const Size(double.infinity, 50),
                side: const BorderSide(color: AppColors.border),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminShortcut extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color tint;
  final VoidCallback onTap;

  const _AdminShortcut({
    required this.label,
    required this.icon,
    required this.tint,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: tint.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: tint.withValues(alpha: 0.16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: tint, size: 20),
            ),
            const SizedBox(height: 10),
            CustomText(
              label,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
