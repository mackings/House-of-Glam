import 'package:flutter/material.dart';
import 'package:hog/TailorApp/Home/Api/subservice.dart';
import 'package:hog/TailorApp/Home/Model/submodel.dart';
import 'package:hog/components/texts.dart';
import 'package:hog/theme/app_theme.dart';
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
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder:
          (_) => _PlanEditorSheet(
            plan: plan,
            service: _service,
            planNames: _planNames,
            durations: _durations,
          ),
    );
    if (saved == true) {
      await _fetchPlans();
    }
  }

  Future<void> _deletePlan(SubscriptionPlan plan) async {
    final ok = await _service.deleteSubscriptionPlan(plan.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? "Plan deleted successfully" : "Delete failed"),
      ),
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
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.canvas,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: AppColors.ink),
        title: const CustomText(
          "Subscription Settings",
          color: AppColors.ink,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.accent,
        onPressed: () => _showCreateOrEditSheet(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                onRefresh: _fetchPlans,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFF7F2FF), Color(0xFFFFFFFF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: const Icon(
                              Icons.verified_outlined,
                              color: AppColors.accent,
                            ),
                          ),
                          const SizedBox(height: 18),
                          const CustomText(
                            "Designer subscription control",
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink,
                            textAlign: TextAlign.left,
                          ),
                          const SizedBox(height: 8),
                          const CustomText(
                            "Create and manage plan tiers, durations, and payable amounts used across the designer flow.",
                            fontSize: 13,
                            color: AppColors.subtext,
                            textAlign: TextAlign.left,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.accentDeep, AppColors.accent],
                        ),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        alignment: WrapAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: (MediaQuery.of(context).size.width - 68) / 3,
                            child: _metric("Plans", "$totalPlans"),
                          ),
                          SizedBox(
                            width: (MediaQuery.of(context).size.width - 68) / 3,
                            child: _metric("Monthly", "$monthlyCount"),
                          ),
                          SizedBox(
                            width: (MediaQuery.of(context).size.width - 68) / 3,
                            child: _metric("Yearly", "$yearlyCount"),
                          ),
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
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(color: AppColors.border),
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: CustomText(
                                      plan.name,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      textAlign: TextAlign.left,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.accentSoft,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: CustomText(
                                      plan.duration.toUpperCase(),
                                      fontSize: 11,
                                      color: AppColors.accentDeep,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              CustomText(
                                "₦${_formatter.format(plan.amount)}",
                                fontSize: 20,
                                color: AppColors.accentDeep,
                                fontWeight: FontWeight.bold,
                              ),
                              const SizedBox(height: 6),
                              CustomText(
                                plan.description,
                                fontSize: 13,
                                color: Colors.black87,
                              ),
                              if (plan.benefits.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                const CustomText(
                                  "Benefits",
                                  fontSize: 12,
                                  color: AppColors.subtext,
                                  fontWeight: FontWeight.w700,
                                  textAlign: TextAlign.left,
                                ),
                                const SizedBox(height: 6),
                                ...plan.benefits.map(
                                  (benefit) => Padding(
                                    padding: const EdgeInsets.only(bottom: 6),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Icon(
                                          Icons.check_circle_rounded,
                                          size: 17,
                                          color: AppColors.success,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: CustomText(
                                            benefit,
                                            fontSize: 12,
                                            textAlign: TextAlign.left,
                                            color: AppColors.ink,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 8),
                              Wrap(
                                alignment: WrapAlignment.end,
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  TextButton.icon(
                                    onPressed:
                                        () =>
                                            _showCreateOrEditSheet(plan: plan),
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
          textAlign: TextAlign.center,
        ),
        CustomText(
          label,
          color: Colors.white70,
          fontSize: 12,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _PlanEditorSheet extends StatefulWidget {
  final SubscriptionPlan? plan;
  final SubscriptionService service;
  final List<String> planNames;
  final List<String> durations;

  const _PlanEditorSheet({
    required this.plan,
    required this.service,
    required this.planNames,
    required this.durations,
  });

  @override
  State<_PlanEditorSheet> createState() => _PlanEditorSheetState();
}

class _PlanEditorSheetState extends State<_PlanEditorSheet> {
  late final TextEditingController _amountController;
  late final TextEditingController _descriptionController;
  late String _name;
  late String _duration;
  late List<TextEditingController> _benefitControllers;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _name = widget.plan?.name ?? widget.planNames.first;
    _duration = widget.plan?.duration ?? widget.durations.first;
    _amountController = TextEditingController(
      text: widget.plan == null ? '' : widget.plan!.amount.toString(),
    );
    _descriptionController = TextEditingController(
      text: widget.plan?.description ?? '',
    );
    final benefits = widget.plan?.benefits ?? const <String>[];
    _benefitControllers =
        (benefits.isEmpty ? const [''] : benefits)
            .map((benefit) => TextEditingController(text: benefit))
            .toList();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    for (final controller in _benefitControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.danger),
    );
  }

  Future<void> _save() async {
    final amount = int.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      _showError('Enter a valid amount in NGN');
      return;
    }

    final benefits =
        _benefitControllers
            .map((controller) => controller.text.trim())
            .where((benefit) => benefit.isNotEmpty)
            .toList();
    if (benefits.isEmpty) {
      _showError('Add at least one plan benefit');
      return;
    }
    if (benefits.any((benefit) => benefit.length > 160)) {
      _showError('Each benefit must be 160 characters or fewer');
      return;
    }
    final uniqueBenefits =
        benefits.map((benefit) => benefit.toLowerCase()).toSet();
    if (uniqueBenefits.length != benefits.length) {
      _showError('Plan benefits cannot contain duplicates');
      return;
    }

    setState(() => _saving = true);
    final result =
        widget.plan == null
            ? await widget.service.createSubscriptionPlan(
              name: _name,
              amount: amount,
              duration: _duration,
              description: _descriptionController.text.trim(),
              benefits: benefits,
            )
            : await widget.service.updateSubscriptionPlan(
              id: widget.plan!.id,
              name: _name,
              amount: amount,
              duration: _duration,
              description: _descriptionController.text.trim(),
              benefits: benefits,
            );
    if (!mounted) return;
    setState(() => _saving = false);
    if (result == null) {
      _showError('Unable to save the subscription plan');
      return;
    }
    final messenger = ScaffoldMessenger.of(context);
    Navigator.pop(context, true);
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          widget.plan == null
              ? 'Plan created successfully'
              : 'Plan updated successfully',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              CustomText(
                widget.plan == null
                    ? 'Create Subscription Plan'
                    : 'Update Plan',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 4),
              const CustomText(
                'Prices are stored in NGN. The backend converts international checkout amounts to USD.',
                fontSize: 12,
                color: AppColors.subtext,
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _name,
                isExpanded: true,
                items:
                    widget.planNames
                        .map(
                          (name) =>
                              DropdownMenuItem(value: name, child: Text(name)),
                        )
                        .toList(),
                onChanged: (value) => _name = value ?? _name,
                decoration: const InputDecoration(labelText: 'Plan name'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _duration,
                isExpanded: true,
                items:
                    widget.durations
                        .map(
                          (duration) => DropdownMenuItem(
                            value: duration,
                            child: Text(
                              '${duration[0].toUpperCase()}${duration.substring(1)}',
                            ),
                          ),
                        )
                        .toList(),
                onChanged: (value) => _duration = value ?? _duration,
                decoration: const InputDecoration(labelText: 'Duration'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Amount (NGN)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  const Expanded(
                    child: CustomText(
                      'Benefits checklist',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      textAlign: TextAlign.left,
                    ),
                  ),
                  CustomText(
                    '${_benefitControllers.length}/7',
                    fontSize: 12,
                    color: AppColors.subtext,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const CustomText(
                'Add 1–7 unique benefits in the order designers should see them.',
                fontSize: 12,
                color: AppColors.subtext,
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 10),
              ...List.generate(_benefitControllers.length, (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextField(
                          key: ValueKey('subscription_benefit_$index'),
                          controller: _benefitControllers[index],
                          maxLength: 160,
                          decoration: InputDecoration(
                            labelText: 'Benefit ${index + 1}',
                            counterText: '',
                          ),
                        ),
                      ),
                      if (_benefitControllers.length > 1) ...[
                        const SizedBox(width: 8),
                        IconButton(
                          tooltip: 'Remove benefit',
                          onPressed: () {
                            final controller = _benefitControllers.removeAt(
                              index,
                            );
                            controller.dispose();
                            setState(() {});
                          },
                          icon: const Icon(
                            Icons.remove_circle_outline,
                            color: AppColors.danger,
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }),
              if (_benefitControllers.length < 7)
                TextButton.icon(
                  key: const ValueKey('add_subscription_benefit'),
                  onPressed: () {
                    setState(() {
                      _benefitControllers.add(TextEditingController());
                    });
                  },
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Add benefit'),
                ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  key: const ValueKey('save_subscription_plan'),
                  onPressed: _saving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(52),
                  ),
                  child:
                      _saving
                          ? const SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                          : Text(
                            widget.plan == null ? 'Create Plan' : 'Update Plan',
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
