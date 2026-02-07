import 'package:flutter/material.dart';
import 'package:hog/TailorApp/Home/Api/subservice.dart';
import 'package:hog/TailorApp/Home/Model/submodel.dart';
import 'package:hog/components/texts.dart';
import 'package:intl/intl.dart';

class SubscriptionSettings extends StatefulWidget {
  const SubscriptionSettings({super.key});

  @override
  State<SubscriptionSettings> createState() => _SubscriptionSettingsState();
}

class _SubscriptionSettingsState extends State<SubscriptionSettings> {
  final SubscriptionService _service = SubscriptionService();
  final NumberFormat _formatter = NumberFormat("#,##0");
  final List<String> _planNames = const ["Standard", "Premium", "Enterprise"];
  final List<String> _durations = const ["monthly", "quarterly", "yearly"];

  bool _loading = true;
  List<SubscriptionPlan> _plans = [];

  @override
  void initState() {
    super.initState();
    _fetchPlans();
  }

  Future<void> _fetchPlans() async {
    setState(() => _loading = true);
    try {
      final response = await _service.getSubscriptionPlans();
      if (!mounted) return;
      setState(() {
        _plans = response.data;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _showCreateOrEditSheet({SubscriptionPlan? plan}) async {
    final nameCtrl = TextEditingController(text: plan?.name ?? "Standard");
    final amountCtrl = TextEditingController(
      text: plan != null ? plan.amount.toString() : "",
    );
    final descCtrl = TextEditingController(text: plan?.description ?? "");
    String duration = plan?.duration ?? "monthly";

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                plan == null ? "Create Subscription Plan" : "Update Plan",
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              const SizedBox(height: 4),
              CustomText(
                "Define plan tier, duration, and secure backend amount.",
                fontSize: 12,
                color: Colors.black54,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: nameCtrl.text,
                items:
                    _planNames
                        .map(
                          (name) => DropdownMenuItem(
                            value: name,
                            child: Text(name),
                          ),
                        )
                        .toList(),
                onChanged: (v) => nameCtrl.text = v ?? nameCtrl.text,
                decoration: const InputDecoration(
                  labelText: "Plan Name",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: duration,
                items:
                    _durations
                        .map(
                          (d) => DropdownMenuItem(
                            value: d,
                            child: Text("${d[0].toUpperCase()}${d.substring(1)}"),
                          ),
                        )
                        .toList(),
                onChanged: (v) => duration = v ?? duration,
                decoration: const InputDecoration(
                  labelText: "Duration",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Amount (NGN)",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: descCtrl,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: "Description",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final amount = int.tryParse(amountCtrl.text.trim());
                    if (amount == null || amount <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Enter a valid amount")),
                      );
                      return;
                    }

                    Map<String, dynamic>? result;
                    if (plan == null) {
                      result = await _service.createSubscriptionPlan(
                        name: nameCtrl.text.trim(),
                        amount: amount,
                        duration: duration,
                        description: descCtrl.text.trim(),
                      );
                    } else {
                      result = await _service.updateSubscriptionPlan(
                        id: plan.id,
                        name: nameCtrl.text.trim(),
                        amount: amount,
                        duration: duration,
                        description: descCtrl.text.trim(),
                      );
                    }

                    if (!mounted) return;
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          result != null
                              ? (plan == null
                                  ? "Plan created successfully"
                                  : "Plan updated successfully")
                              : "Operation failed",
                        ),
                      ),
                    );
                    if (result != null) _fetchPlans();
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
                  child: Text(
                    plan == null ? "Create Plan" : "Update Plan",
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 6),
            ],
          ),
        );
      },
    );
  }

  Future<void> _deletePlan(SubscriptionPlan plan) async {
    final ok = await _service.deleteSubscriptionPlan(plan.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? "Plan deleted successfully" : "Delete failed")),
    );
    if (ok) _fetchPlans();
  }

  @override
  Widget build(BuildContext context) {
    final totalPlans = _plans.length;
    final monthlyCount =
        _plans.where((p) => p.duration.toLowerCase() == "monthly").length;
    final yearlyCount =
        _plans.where((p) => p.duration.toLowerCase() == "yearly").length;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FB),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.purple,
        title: const CustomText(
          "Subscription Settings",
          color: Colors.white,
          fontSize: 18,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.purple,
        onPressed: () => _showCreateOrEditSheet(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                onRefresh: _fetchPlans,
                child: ListView(
                  padding: const EdgeInsets.all(12),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.purple.shade600, Colors.purple.shade400],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _metric("Plans", "$totalPlans"),
                          _metric("Monthly", "$monthlyCount"),
                          _metric("Yearly", "$yearlyCount"),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    if (_plans.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const CustomText(
                          "No subscription plans yet. Tap + to create one.",
                          color: Colors.black54,
                        ),
                      )
                    else
                      ..._plans.map((plan) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x14000000),
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  CustomText(
                                    plan.name,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.purple.shade50,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: CustomText(
                                      plan.duration.toUpperCase(),
                                      fontSize: 11,
                                      color: Colors.purple.shade700,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              CustomText(
                                "₦${_formatter.format(plan.amount)}",
                                fontSize: 20,
                                color: Colors.purple.shade700,
                                fontWeight: FontWeight.bold,
                              ),
                              const SizedBox(height: 6),
                              CustomText(
                                plan.description,
                                fontSize: 13,
                                color: Colors.black87,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton.icon(
                                    onPressed: () => _showCreateOrEditSheet(plan: plan),
                                    icon: const Icon(Icons.edit, size: 16),
                                    label: const Text("Edit"),
                                  ),
                                  const SizedBox(width: 8),
                                  TextButton.icon(
                                    onPressed: () => _deletePlan(plan),
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      size: 16,
                                      color: Colors.red,
                                    ),
                                    label: const Text(
                                      "Delete",
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }),
                  ],
                ),
              ),
    );
  }

  Widget _metric(String label, String value) {
    return Column(
      children: [
        CustomText(
          value,
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        CustomText(label, color: Colors.white70, fontSize: 12),
      ],
    );
  }
}
