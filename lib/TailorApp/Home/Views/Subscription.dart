import 'package:flutter/material.dart';
import 'package:hog/App/Auth/Api/secure.dart';
import 'package:hog/TailorApp/Home/Api/subservice.dart';
import 'package:hog/TailorApp/Home/Model/submodel.dart';
import 'package:hog/TailorApp/Home/Views/payment.dart';
import 'package:hog/components/texts.dart';
import 'package:hog/theme/app_theme.dart';
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
      return DateFormat('d MMM yyyy • h:mma').format(date);
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
    final userData = await SecurePrefs.getUserData();
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

  Future<void> subscribe(SubscriptionPlan plan) async {
    try {
      final response = await _service.subscribeToPlan(planId: plan.id);
      final checkoutLink =
          response.authorizationUrl.isNotEmpty
              ? response.authorizationUrl
              : response.checkoutUrl;

      if (checkoutLink.isNotEmpty && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => WebViewScreen(url: checkoutLink)),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Unable to start subscription: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat("#,##0");
    final formatter2 = NumberFormat("#,##0.##");

    final groupedPlans = <String, List<SubscriptionPlan>>{};
    for (final plan in plans) {
      groupedPlans.putIfAbsent(plan.name, () => []).add(plan);
    }

    const durationOrder = ["monthly", "quarterly", "yearly"];

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          "Subscription",
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(14, 8, 14, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFF8F3FF), Colors.white],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomText(
                              "Choose the plan that fits your design workflow",
                              textAlign: TextAlign.left,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                            SizedBox(height: 6),
                            CustomText(
                              "Compare available billing terms, review your active subscription, and continue to payment when you’re ready.",
                              textAlign: TextAlign.left,
                              color: AppColors.subtext,
                            ),
                          ],
                        ),
                      ),
                      if (currentPlan != null && currentPlan!.trim().isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(bottom: 18),
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(26),
                            border: Border.all(
                              color: AppColors.accent,
                              width: 1.2,
                            ),
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
                              Row(
                                children: [
                                  Container(
                                    width: 46,
                                    height: 46,
                                    decoration: BoxDecoration(
                                      color: AppColors.accentSoft,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: const Icon(
                                      Icons.workspace_premium_outlined,
                                      color: AppColors.accent,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const CustomText(
                                          "Current Plan",
                                          fontSize: 12,
                                          color: AppColors.subtext,
                                          textAlign: TextAlign.left,
                                        ),
                                        const SizedBox(height: 2),
                                        CustomText(
                                          currentPlan!,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.ink,
                                          textAlign: TextAlign.left,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.accentSoft,
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.check_circle_rounded,
                                          size: 14,
                                          color: AppColors.accent,
                                        ),
                                        SizedBox(width: 6),
                                        CustomText(
                                          "Active",
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.accent,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: _PlanStat(
                                      label: "Started",
                                      value: formatDate(subscriptionStartDate),
                                      icon: Icons.calendar_today_rounded,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _PlanStat(
                                      label: "Expires",
                                      value: formatDate(subscriptionEndDate),
                                      icon: Icons.event_available_rounded,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                      else
                        Container(
                          margin: const EdgeInsets.only(bottom: 18),
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.info_outline_rounded,
                                color: AppColors.subtext,
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: CustomText(
                                  "No subscription plan is active yet. Choose one below to continue.",
                                  fontSize: 13,
                                  color: AppColors.subtext,
                                  textAlign: TextAlign.left,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ...groupedPlans.entries.map((entry) {
                        final planName = entry.key;
                        final planList = entry.value;

                        planList.sort(
                          (a, b) => durationOrder
                              .indexOf(a.duration)
                              .compareTo(durationOrder.indexOf(b.duration)),
                        );

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(4, 0, 4, 10),
                              child: CustomText(
                                "$planName Plans",
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppColors.ink,
                                textAlign: TextAlign.left,
                              ),
                            ),
                            ...planList.map((plan) {
                              final isActive =
                                  currentPlan != null &&
                                  plan.name.toLowerCase() ==
                                      currentPlan!.toLowerCase();
                              final currencyCode =
                                  plan.displayCurrency.isNotEmpty
                                      ? plan.displayCurrency.toUpperCase()
                                      : "NGN";
                              final amountToShow =
                                  plan.displayAmount > 0
                                      ? plan.displayAmount
                                      : plan.amount.toDouble();
                              final currencyPrefix =
                                  currencyCode == "USD" ? "\$" : "₦";
                              final formattedAmount =
                                  currencyCode == "USD"
                                      ? formatter2.format(amountToShow)
                                      : formatter.format(amountToShow);

                              return Container(
                                margin: const EdgeInsets.only(bottom: 14),
                                padding: const EdgeInsets.all(18),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(26),
                                  border: Border.all(
                                    color:
                                        isActive
                                            ? AppColors.accent
                                            : AppColors.border,
                                    width: isActive ? 1.4 : 1,
                                  ),
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
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.surfaceMuted,
                                            borderRadius: BorderRadius.circular(
                                              999,
                                            ),
                                          ),
                                          child: CustomText(
                                            plan.duration.toUpperCase(),
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.ink,
                                          ),
                                        ),
                                        const Spacer(),
                                        if (isActive)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 8,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.accentSoft,
                                              borderRadius:
                                                  BorderRadius.circular(999),
                                            ),
                                            child: const CustomText(
                                              "Current",
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.accent,
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 14),
                                    CustomText(
                                      "$currencyPrefix$formattedAmount",
                                      fontSize: 24,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.accent,
                                      textAlign: TextAlign.left,
                                    ),
                                    const SizedBox(height: 4),
                                    CustomText(
                                      currencyCode,
                                      fontSize: 12,
                                      color: AppColors.subtext,
                                      textAlign: TextAlign.left,
                                    ),
                                    const SizedBox(height: 14),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        color: AppColors.surfaceMuted,
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                      child: CustomText(
                                        plan.description,
                                        textAlign: TextAlign.left,
                                        fontSize: 13,
                                        color: AppColors.ink,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    SizedBox(
                                      width: double.infinity,
                                      child:
                                          isActive
                                              ? OutlinedButton(
                                                onPressed: null,
                                                style: OutlinedButton.styleFrom(
                                                  minimumSize:
                                                      const Size.fromHeight(52),
                                                  side: const BorderSide(
                                                    color: AppColors.border,
                                                  ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          18,
                                                        ),
                                                  ),
                                                ),
                                                child: const Text(
                                                  "Current Plan",
                                                ),
                                              )
                                              : ElevatedButton.icon(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      AppColors.accent,
                                                  foregroundColor: Colors.white,
                                                  minimumSize:
                                                      const Size.fromHeight(52),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          18,
                                                        ),
                                                  ),
                                                  elevation: 0,
                                                ),
                                                onPressed:
                                                    () => subscribe(plan),
                                                icon: const Icon(
                                                  Icons.arrow_forward_rounded,
                                                  size: 18,
                                                ),
                                                label: const Text(
                                                  "Continue to Subscribe",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
              ),
    );
  }
}

class _PlanStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _PlanStat({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.accent),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  label,
                  fontSize: 11,
                  color: AppColors.subtext,
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 2),
                CustomText(
                  value,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                  textAlign: TextAlign.left,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
