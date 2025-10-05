import 'package:flutter/material.dart';
import 'package:hog/App/Auth/Api/secure.dart';
import 'package:hog/TailorApp/Home/Api/subservice.dart';
import 'package:hog/TailorApp/Home/Model/submodel.dart';
import 'package:hog/TailorApp/Home/Views/payment.dart';
import 'package:hog/components/texts.dart';
import 'package:hog/constants/currency.dart';
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
  String? subscriptionStartDate;
  String? subscriptionEndDate;
  bool isLoading = true;

  String formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return "-";
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('d MMMM yyyy h:mma').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  @override
  void initState() {
    super.initState();
    fetchPlans();
    loadCurrentPlan();
  }

  Future<void> loadCurrentPlan() async {
    final userData =
        await SecurePrefs.getUserData(); // Returns Map<String, dynamic>?
    if (userData != null) {
      setState(() {
        currentPlan = userData["subscriptionPlan"]?.toString();
        subscriptionStartDate = userData["subscriptionStartDate"]?.toString();
        subscriptionEndDate = userData["subscriptionEndDate"]?.toString();
      });
    }
  }

  Future<void> fetchPlans() async {
    try {
      final response = await _service.getSubscriptionPlans();
      setState(() {
        plans = response.data;
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

  @override
  Widget build(BuildContext context) {
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
      body:
          isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Colors.purple),
              )
              : SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 12,
                  ),
                  child: Column(
                    children: [
                      // Show user's current plan at the top
                      currentPlan != null
                          ? Container(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.purple.shade100, Colors.white],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              border: Border.all(
                                color: Colors.purple,
                                width: 2,
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
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    CustomText(
                                      "Your Current Plan",
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                    ),
                                    const Icon(
                                      Icons.check_circle,
                                      color: Colors.purple,
                                      size: 22,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                CustomText(
                                  currentPlan ?? "-",
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.purple,
                                ),
                                const SizedBox(height: 8),
                                CustomText(
                                  "Start: ${formatDate(subscriptionStartDate)}",
                                  fontSize: 13,
                                  color: Colors.black54,
                                ),
                                CustomText(
                                  "Expires: ${formatDate(subscriptionEndDate)}",
                                  fontSize: 13,
                                  color: Colors.black54,
                                ),
                              ],
                            ),
                          )
                          : Container(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: Colors.black12,
                                width: 1,
                              ),
                            ),
                            child: const CustomText(
                              "No plan yet. Get one below!",
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),

                      const SizedBox(height: 10),

                      // Show all plans from API
                      ...plans.map((plan) {
                        final isActive = plan.name == currentPlan;
                        final formattedAmount = formatter.format(plan.amount);

                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors:
                                  isActive
                                      ? [Colors.purple.shade100, Colors.white]
                                      : [Colors.white, Colors.white],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            border: Border.all(
                              color: isActive ? Colors.purple : Colors.black12,
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
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  CustomText(
                                    "${plan.name.toUpperCase()} Plan",
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                  if (isActive)
                                    const Icon(
                                      Icons.check_circle,
                                      color: Colors.purple,
                                      size: 22,
                                    ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              CustomText(
                                "${currencySymbol}$formattedAmount / ${plan.duration}",
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.purple,
                              ),
                              const SizedBox(height: 8),
                              CustomText(
                                plan.duration,
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                              const SizedBox(height: 14),
                              if (!isActive)
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.purple,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      elevation: 3,
                                    ),
                                    onPressed:
                                        () => subscribe(
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
                    ],
                  ),
                ),
              ),
    );
  }
}
