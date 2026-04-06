import 'package:flutter/material.dart';
import 'package:hog/App/Admin/Api/AnalyticsService.dart';
import 'package:hog/App/Admin/Widgets/analyticsCard.dart';
import 'package:hog/components/texts.dart';
import 'package:hog/theme/app_theme.dart';

class Analytics extends StatefulWidget {
  const Analytics({super.key});

  @override
  State<Analytics> createState() => _AnalyticsState();
}

class _AnalyticsState extends State<Analytics> {
  int totalUsers = 0;
  int freeListings = 0;
  int paidListings = 0;
  double totalEarnings = 0.0;
  int totalTransactions = 0;
  int totalListings = 0;

  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchAnalytics();
  }

  Future<void> fetchAnalytics() async {
    setState(() => loading = true);

    final users = await AnalyticsService.getTotalUsers();
    final freePaid = await AnalyticsService.getFreeAndPaidListings();
    final earnings = await AnalyticsService.getTotalEarnings();
    final transactions = await AnalyticsService.getTotalTransactions();
    final listings = await AnalyticsService.getTotalListings();

    setState(() {
      totalUsers = users?.totalUsers ?? 0;
      freeListings = freePaid?.freeListings ?? 0;
      paidListings = freePaid?.paidListings ?? 0;
      totalEarnings = earnings?.totalEarnings ?? 0.0;
      totalTransactions = transactions?.totalTransactions ?? 0;
      totalListings = listings?.totalListings ?? 0;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cards = [
      (
        title: "Total Users",
        value: "$totalUsers",
        icon: Icons.people_alt_outlined,
        tint: const Color(0xFF2563EB),
      ),
      (
        title: "Free Listings",
        value: "$freeListings",
        icon: Icons.sell_outlined,
        tint: AppColors.success,
      ),
      (
        title: "Paid Listings",
        value: "$paidListings",
        icon: Icons.workspace_premium_outlined,
        tint: AppColors.accent,
      ),
      (
        title: "Total Earnings",
        value: totalEarnings.toStringAsFixed(2),
        icon: Icons.account_balance_wallet_outlined,
        tint: const Color(0xFFF59E0B),
      ),
      (
        title: "Transactions",
        value: "$totalTransactions",
        icon: Icons.swap_horiz_rounded,
        tint: const Color(0xFF0EA5E9),
      ),
      (
        title: "Total Listings",
        value: "$totalListings",
        icon: Icons.storefront_outlined,
        tint: const Color(0xFFEC4899),
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.canvas,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: AppColors.ink),
        title: const Text(
          "Analytics",
          style: TextStyle(
            fontSize: 18,
            color: AppColors.ink,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body:
          loading
              ? const Center(
                child: CircularProgressIndicator(color: AppColors.accent),
              )
              : RefreshIndicator(
                onRefresh: fetchAnalytics,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFF8F3FF), Color(0xFFFFFFFF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  color: AppColors.accentSoft,
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: const Icon(
                                  Icons.analytics_outlined,
                                  color: AppColors.accent,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: CustomText(
                                  "$totalListings listings",
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.ink,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          const CustomText(
                            "Platform snapshot",
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink,
                            textAlign: TextAlign.left,
                          ),
                          const SizedBox(height: 8),
                          const CustomText(
                            "Quickly monitor marketplace usage, paid inventory, and revenue performance.",
                            fontSize: 13,
                            color: AppColors.subtext,
                            textAlign: TextAlign.left,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children:
                          cards.map((card) {
                            return SizedBox(
                              width:
                                  (MediaQuery.of(context).size.width - 44) / 2,
                              child: AnalyticsCard(
                                title: card.title,
                                value: card.value,
                                icon: card.icon,
                                tint: card.tint,
                              ),
                            );
                          }).toList(),
                    ),
                  ],
                ),
              ),
    );
  }
}
