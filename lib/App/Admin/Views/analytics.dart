import 'package:flutter/material.dart';
import 'package:hog/App/Admin/Api/AnalyticsService.dart';
import 'package:hog/App/Admin/Widgets/analyticsCard.dart';




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
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Analytics",
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
        backgroundColor: Colors.purple,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: fetchAnalytics,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  AnalyticsCard(
                    title: "Total Users",
                    value: "$totalUsers",
                    icon: Icons.people,
     
                  ),
                  const SizedBox(height: 12),
                  AnalyticsCard(
                    title: "Free Listings",
                    value: "$freeListings",
                    icon: Icons.list_alt,
       
                  ),
                  const SizedBox(height: 12),
                  AnalyticsCard(
                    title: "Paid Listings",
                    value: "$paidListings",
                    icon: Icons.monetization_on,
      
                  ),
                  const SizedBox(height: 12),
                  AnalyticsCard(
                    title: "Total Earnings",
                    value: "${totalEarnings.toStringAsFixed(2)}",
                    icon: Icons.account_balance_wallet,

                  ),
                  const SizedBox(height: 12),
                  AnalyticsCard(
                    title: "Total Transactions",
                    value: "$totalTransactions",
                    icon: Icons.swap_horiz,
                  ),
                  const SizedBox(height: 12),
                  AnalyticsCard(
                    title: "Total Listings",
                    value: "$totalListings",
                    icon: Icons.storefront,
    
                  ),
                ],
              ),
            ),
    );
  }
}