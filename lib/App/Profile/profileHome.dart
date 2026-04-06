import 'package:flutter/material.dart';
import 'package:hog/App/Admin/Views/DeliverySettings.dart';
import 'package:hog/App/Admin/Views/PickupSettings.dart';
import 'package:hog/App/Admin/Views/PricingSettings.dart';
import 'package:hog/App/Admin/Views/SubscriptionSettings.dart';
import 'package:hog/App/Admin/Views/adminHome.dart';
import 'package:hog/App/Admin/Views/analytics.dart';
import 'package:hog/App/Auth/Api/secure.dart';
import 'package:hog/App/Profile/Views/Delivery.dart';
import 'package:hog/App/Profile/Views/SellerDeliverylog.dart';
import 'package:hog/App/Profile/Views/UserListings.dart';
import 'package:hog/App/Profile/Views/marketPlace.dart';
import 'package:hog/App/Profile/widgets/profileMenu.dart';
import 'package:hog/TailorApp/Home/Views/Subscription.dart';
import 'package:hog/components/Navigator.dart';
import 'package:hog/components/customAppbar.dart';
import 'package:hog/components/texts.dart';
import 'package:hog/theme/app_theme.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  String? userRole;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadUserRole();
  }

  Future<void> loadUserRole() async {
    final role = await SecurePrefs.getUserRole();
    setState(() {
      userRole = role;
      loading = false;
    });
  }

  bool get isAdmin {
    final role = (userRole ?? '').trim().toLowerCase();
    return role.contains('admin');
  }

  bool get isTailor {
    final role = (userRole ?? '').trim().toLowerCase();
    return role.contains('tailor');
  }

  String get roleLabel {
    final role = (userRole ?? '').trim();
    if (role.isEmpty) return "Customer tools";
    return "${role[0].toUpperCase()}${role.substring(1)} tools";
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: const CustomAppBar(title: "Profile Hub", enableAction: false),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.fromLTRB(14, 8, 14, 14),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF8F3FF), Colors.white],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.accentSoft,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.account_circle_outlined,
                            color: AppColors.accent,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const CustomText(
                                "Manage your account tools",
                                textAlign: TextAlign.left,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                              const SizedBox(height: 2),
                              CustomText(
                                roleLabel,
                                textAlign: TextAlign.left,
                                color: AppColors.subtext,
                                fontSize: 12,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    CustomText(
                      isAdmin
                          ? "Marketplace, delivery, and admin controls are available below based on your access."
                          : "Reach your marketplace, deliveries, listings, and subscription tools from one consistent hub.",
                      textAlign: TextAlign.left,
                      color: AppColors.subtext,
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(18, 0, 18, 8),
                child: CustomText(
                  "Marketplace",
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  textAlign: TextAlign.left,
                ),
              ),
              ProfileMenuItem(
                icon: Icons.storefront_outlined,
                text: "Shop",
                subtitle: "Browse approved marketplace listings",
                accent: true,
                onTap: () {
                  Nav.push(context, const MarketPlace());
                },
              ),
              ProfileMenuItem(
                icon: Icons.shopping_bag_outlined,
                text: "Listings",
                subtitle: "Manage your uploaded marketplace items",
                onTap: () {
                  Nav.push(context, const Userlistings());
                },
              ),
              ProfileMenuItem(
                icon: Icons.local_shipping_outlined,
                text: "SendOuts",
                subtitle: "Review orders you’ve sent out",
                onTap: () {
                  Nav.push(context, const SellerDelivery());
                },
              ),
              ProfileMenuItem(
                icon: Icons.delivery_dining_outlined,
                text: "Deliveries",
                subtitle: "Track incoming marketplace deliveries",
                onTap: () {
                  Nav.push(context, const MarketDelivery());
                },
              ),
              if (isTailor) ...[
                const Padding(
                  padding: EdgeInsets.fromLTRB(18, 12, 18, 8),
                  child: CustomText(
                    "Subscription",
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    textAlign: TextAlign.left,
                  ),
                ),
                ProfileMenuItem(
                  icon: Icons.workspace_premium_outlined,
                  text: "My Subscription",
                  subtitle: "Check or upgrade your tailor plan",
                  onTap: () {
                    Nav.push(context, const Subscription());
                  },
                ),
              ],
              if (isAdmin) ...[
                const Padding(
                  padding: EdgeInsets.fromLTRB(18, 12, 18, 8),
                  child: CustomText(
                    "Admin Tools",
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    textAlign: TextAlign.left,
                  ),
                ),
                ProfileMenuItem(
                  icon: Icons.dashboard_outlined,
                  text: "Analytics",
                  subtitle: "Review marketplace and app insights",
                  onTap: () {
                    Nav.push(context, const Analytics());
                  },
                ),
                ProfileMenuItem(
                  icon: Icons.admin_panel_settings_outlined,
                  text: "Listing Approvals",
                  subtitle: "Moderate seller listings and activity",
                  onTap: () {
                    Nav.push(context, const AdminHome());
                  },
                ),
                ProfileMenuItem(
                  icon: Icons.electric_scooter_outlined,
                  text: "Delivery Settings",
                  subtitle: "Configure delivery options and rates",
                  onTap: () {
                    Nav.push(context, const DeliverySettings());
                  },
                ),
                ProfileMenuItem(
                  icon: Icons.pin_drop_outlined,
                  text: "Set Pickup Location",
                  subtitle: "Manage pickup destinations for deliveries",
                  onTap: () {
                    Nav.push(context, const PickupSettings());
                  },
                ),
                ProfileMenuItem(
                  icon: Icons.percent_outlined,
                  text: "Tax & VAT",
                  subtitle: "Adjust pricing rules and tax values",
                  onTap: () {
                    Nav.push(context, const PricingSettings());
                  },
                ),
                ProfileMenuItem(
                  icon: Icons.subscriptions_outlined,
                  text: "Subscription Settings",
                  subtitle: "Configure subscription plans and access",
                  onTap: () {
                    Nav.push(context, const SubscriptionSettings());
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
