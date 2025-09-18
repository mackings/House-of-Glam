import 'package:flutter/material.dart';
import 'package:hog/TailorApp/Home/Api/subservice.dart';
import 'package:hog/TailorApp/Home/Model/submodel.dart';
import 'package:hog/TailorApp/Home/Views/payment.dart';
import 'package:hog/components/texts.dart';
import 'package:url_launcher/url_launcher.dart';



import 'package:intl/intl.dart';

class Subscription extends StatefulWidget {
  const Subscription({super.key});

  @override
  State<Subscription> createState() => _SubscriptionState();
}

class _SubscriptionState extends State<Subscription> {
  final SubscriptionService _service = SubscriptionService();
  List<SubscriptionPlan> plans = [];
  String? currentPlan;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPlans();
  }

  Future<void> fetchPlans() async {
    try {
      final response = await _service.getSubscriptionPlans();
      setState(() {
        plans = response.data;
        currentPlan = "Standard"; // ✅ Replace with actual user subscription
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Future<void> subscribe(String plan, String amount, String billTerm) async {
    try {
      final response = await _service.subscribeToPlan(
        plan: plan,
        amount: amount,
        billTerm: billTerm,
      );
      if (response.authorizationUrl.isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => WebViewScreen(url: response.authorizationUrl),
          ),
        );
      }
    } catch (e) {
      print("❌ Error subscribing: $e");
    }
  }

  // ✅ Helper: group plans by type
  Map<String, List<SubscriptionPlan>> groupPlansByType() {
    final Map<String, List<SubscriptionPlan>> grouped = {};
    for (var plan in plans) {
      grouped.putIfAbsent(plan.name, () => []).add(plan);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final groupedPlans = groupPlansByType();
    final formatter = NumberFormat("#,##0"); // For 2,000 formatting

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: const CustomText(
          "Subscription",
          fontSize: 18,
          color: Colors.white,
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.purple))
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                child: Column(
                  children: groupedPlans.entries.map((entry) {
                    final planType = entry.key;
                    final planList = entry.value;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Group Title
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: CustomText(
                            planType,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),

                        // Plans under this group
                        Column(
                          children: planList.map((plan) {
                            final isActive = plan.name == currentPlan;
                            final formattedAmount =
                                formatter.format(plan.amount);

                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: isActive
                                      ? [Colors.purple.shade100, Colors.white]
                                      : [Colors.white, Colors.white],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                border: Border.all(
                                  color:
                                      isActive ? Colors.purple : Colors.black12,
                                  width: isActive ? 2 : 1,
                                ),
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Plan Header
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      CustomText(
                                        "${plan.duration.toUpperCase()} Plan",
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black,
                                      ),
                                      if (isActive)
                                        const Icon(Icons.check_circle,
                                            color: Colors.purple, size: 22),
                                    ],
                                  ),
                                  const SizedBox(height: 8),

                                  // Price
                                  CustomText(
                                    "₦$formattedAmount / ${plan.duration}",
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.purple,
                                  ),
                                  const SizedBox(height: 8),

                                  // Description
                                  CustomText(
                                    plan.description,
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                  const SizedBox(height: 14),

                                  // Subscribe Button
                                  if (!isActive)
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.purple,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 12),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(14),
                                          ),
                                          elevation: 3,
                                        ),
                                        onPressed: () => subscribe(
                                          plan.name,
                                          plan.amount.toString(),
                                          plan.duration,
                                        ),
                                        child: const CustomText(
                                          "Subscribe",
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
    );
  }
}

