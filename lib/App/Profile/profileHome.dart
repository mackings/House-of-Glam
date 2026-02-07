import 'package:flutter/material.dart';
import 'package:hog/App/Admin/Views/DeliverySettings.dart';
import 'package:hog/App/Admin/Views/PickupSettings.dart';
import 'package:hog/App/Admin/Views/PricingSettings.dart';
import 'package:hog/App/Admin/Views/SubscriptionSettings.dart';
import 'package:hog/App/Admin/Views/adminHome.dart';
import 'package:hog/App/Admin/Views/analytics.dart';
import 'package:hog/App/Admin/Views/billing.dart';
import 'package:hog/App/Auth/Api/secure.dart';
import 'package:hog/App/Profile/Views/Delivery.dart';
import 'package:hog/App/Profile/Views/SellerDeliverylog.dart';
import 'package:hog/App/Profile/Views/UserListings.dart';
import 'package:hog/App/Profile/Views/marketPlace.dart';
import 'package:hog/App/Profile/widgets/profileMenu.dart';
import 'package:hog/TailorApp/Home/Views/Subscription.dart';
import 'package:hog/components/Navigator.dart';

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

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Market place",
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
                icon: Icons.shop,
                text: "Shop",
                onTap: () {
                  Nav.push(context, const MarketPlace());
                },
              ),
              ProfileMenuItem(
                icon: Icons.shopping_bag_outlined,
                text: "Listings",
                onTap: () {
                  Nav.push(context, const Userlistings());
                },
              ),

              // ✅ Only show for admins
              if (isAdmin)
                ProfileMenuItem(
                  icon: Icons.dashboard,
                  text: "Analytics",
                  onTap: () {
                    Nav.push(context, const Analytics());
                  },
                ),

              ProfileMenuItem(
                icon: Icons.shopping_bag_outlined,
                text: "SendOuts",
                onTap: () {
                  Nav.push(context, const SellerDelivery());
                },
              ),

              ProfileMenuItem(
                icon: Icons.delivery_dining,
                text: "Deliveries",
                onTap: () {
                  Nav.push(context, const MarketDelivery());
                },
              ),

              // ✅ Only show for admins
              if (isAdmin)
                ProfileMenuItem(
                  icon: Icons.admin_panel_settings,
                  text: "Listing Approvals",
                  onTap: () {
                    Nav.push(context, const AdminHome());
                  },
                ),

              // Commission hidden from marketplace menu for now
              // if (isAdmin)
              //   ProfileMenuItem(
              //     icon: Icons.money,
              //     text: "Commission",
              //     onTap: () {
              //       Nav.push(context, const SetBilling());
              //     },
              //   ),

              if (isAdmin)
                ProfileMenuItem(
                  icon: Icons.electric_scooter,
                  text: "Delivery Settings",
                  onTap: () {
                    Nav.push(context, const DeliverySettings());
                  },
                ),

              if (isAdmin)
                ProfileMenuItem(
                  icon: Icons.pin_drop_outlined,
                  text: "Set Pickup Location",
                  onTap: () {
                    Nav.push(context, const PickupSettings());
                  },
                ),

              if (isAdmin)
                ProfileMenuItem(
                  icon: Icons.percent_outlined,
                  text: "Tax & VAT",
                  onTap: () {
                    Nav.push(context, const PricingSettings());
                  },
                ),

              if (isAdmin)
                ProfileMenuItem(
                  icon: Icons.subscriptions_outlined,
                  text: "Subscription Settings",
                  onTap: () {
                    Nav.push(context, const SubscriptionSettings());
                  },
                ),

              if (isTailor)
                ProfileMenuItem(
                  icon: Icons.workspace_premium_outlined,
                  text: "My Subscription",
                  onTap: () {
                    Nav.push(context, const Subscription());
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
