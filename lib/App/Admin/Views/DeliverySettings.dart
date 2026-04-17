import 'package:flutter/material.dart';
import 'package:hog/App/Admin/Api/DeliveryRservice.dart';
import 'package:hog/components/formfields.dart';
import 'package:hog/components/texts.dart';
import 'package:hog/theme/app_theme.dart';
import 'package:intl/intl.dart';

class DeliverySettings extends StatefulWidget {
  const DeliverySettings({super.key});

  @override
  State<DeliverySettings> createState() => _DeliverySettingsState();
}

class _DeliverySettingsState extends State<DeliverySettings> {
  List<Map<String, dynamic>> deliveryRates = [];
  bool isLoading = false;

  final TextEditingController _amountCtrl = TextEditingController();
  final TextEditingController _typeCtrl = TextEditingController();

  final NumberFormat _formatter = NumberFormat("#,##0", "en_US");

  @override
  void initState() {
    super.initState();
    fetchDeliveryRates();

    // 🟣 Add live formatting listener
    _amountCtrl.addListener(() {
      final text = _amountCtrl.text.replaceAll(',', '');
      if (text.isEmpty) return;

      final value = double.tryParse(text);
      if (value != null) {
        final newText = _formatter.format(value);
        if (newText != _amountCtrl.text) {
          final selectionIndex = newText.length;
          _amountCtrl.value = TextEditingValue(
            text: newText,
            selection: TextSelection.collapsed(offset: selectionIndex),
          );
        }
      }
    });
  }

  Future<void> fetchDeliveryRates() async {
    setState(() => isLoading = true);
    deliveryRates = await DeliveryRateService.getDeliveryRates();
    setState(() => isLoading = false);
  }

  Future<void> _createDeliveryRate() async {
    if (_amountCtrl.text.isEmpty || _typeCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields")),
      );
      return;
    }

    final cleanAmount = _amountCtrl.text.replaceAll(',', '');

    final success = await DeliveryRateService.createDeliveryRate(
      amount: double.parse(cleanAmount),
      deliveryType: _typeCtrl.text,
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Delivery Rate Created Successfully")),
      );
      _amountCtrl.clear();
      _typeCtrl.clear();
      fetchDeliveryRates();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ Failed to create delivery rate")),
      );
    }
  }

  Future<void> _deleteRate(String id) async {
    final success = await DeliveryRateService.deleteDeliveryRate(id);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("🗑️ Rate deleted successfully")),
      );
      fetchDeliveryRates();
    }
  }

  Future<void> _editRate(String id, double currentAmount) async {
    final TextEditingController amountCtrl = TextEditingController(
      text: _formatter.format(currentAmount),
    );

    // 🟣 Add live formatting to edit field
    amountCtrl.addListener(() {
      final text = amountCtrl.text.replaceAll(',', '');
      if (text.isEmpty) return;
      final value = double.tryParse(text);
      if (value != null) {
        final newText = _formatter.format(value);
        if (newText != amountCtrl.text) {
          final selectionIndex = newText.length;
          amountCtrl.value = TextEditingValue(
            text: newText,
            selection: TextSelection.collapsed(offset: selectionIndex),
          );
        }
      }
    });

    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 24,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CustomText(
                    "Edit Delivery Rate",
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    textAlign: TextAlign.left,
                  ),
                  const SizedBox(height: 6),
                  const CustomText(
                    "Update the percentage for this delivery type.",
                    fontSize: 12,
                    color: AppColors.subtext,
                    textAlign: TextAlign.left,
                  ),
                  const SizedBox(height: 18),
                  const CustomText(
                    "Rate",
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    textAlign: TextAlign.left,
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: amountCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: "Enter new amount",
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: const Text("Cancel"),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(110, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () async {
                          final cleanAmount = amountCtrl.text.replaceAll(
                            ',',
                            '',
                          );
                          final updated =
                              await DeliveryRateService.updateDeliveryRate(
                                rateId: id,
                                amount: double.parse(cleanAmount),
                              );
                          if (!mounted) return;
                          Navigator.pop(dialogContext);
                          if (updated) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("✅ Rate updated")),
                            );
                            fetchDeliveryRates();
                          }
                        },
                        child: const Text("Update"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showAddRateDialog() {
    showModalBottomSheet(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              left: 20,
              right: 20,
              top: 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(height: 16),
                const CustomText(
                  "Add Delivery Rate",
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                ),
                const SizedBox(height: 6),
                const CustomText(
                  "Create shipping percentages that can be reused across admin delivery settings.",
                  fontSize: 12,
                  color: AppColors.subtext,
                ),
                const SizedBox(height: 15),
                CustomTextField(
                  fieldKey: "Amount",
                  title: "Delivery Amount",
                  controller: _amountCtrl,
                  hintText: "Enter amount",
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  fieldKey: "Delivery Type",
                  title: "Delivery Type",
                  controller: _typeCtrl,
                  hintText: "Delivery type (e.g. Express)",
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    minimumSize: const Size(double.infinity, 54),
                  ),
                  onPressed: _createDeliveryRate,
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text(
                    "Create Rate",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalRates = deliveryRates.length;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.canvas,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: AppColors.ink),
        title: const CustomText(
          "Delivery Settings",
          color: AppColors.ink,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.accent,
        onPressed: _showAddRateDialog,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SafeArea(
        child:
            isLoading
                ? const Center(
                  child: CircularProgressIndicator(color: AppColors.accent),
                )
                : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                  children: [
                    _HeaderCard(
                      title:
                          deliveryRates.isEmpty
                              ? "No delivery rates yet"
                              : "Delivery rate manager",
                      subtitle:
                          deliveryRates.isEmpty
                              ? "Create shipping percentages for the available delivery types and manage them from here."
                              : "Adjust delivery percentages and keep available logistics options in sync.",
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.border),
                        boxShadow: const [
                          BoxShadow(
                            color: AppColors.shadow,
                            blurRadius: 16,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _DeliveryMetric(
                              label: "Rates",
                              value: "$totalRates",
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _DeliveryMetric(
                              label: "Fastest",
                              value:
                                  deliveryRates.isEmpty
                                      ? "N/A"
                                      : (deliveryRates.first["deliveryType"] ??
                                              "Set")
                                          .toString(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    if (deliveryRates.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const CustomText(
                          "No delivery rates configured yet. Tap the add button to create one.",
                          fontSize: 13,
                          color: AppColors.subtext,
                          textAlign: TextAlign.left,
                        ),
                      )
                    else
                      ...deliveryRates.map((rate) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(color: AppColors.border),
                            boxShadow: const [
                              BoxShadow(
                                color: AppColors.shadow,
                                blurRadius: 16,
                                offset: Offset(0, 8),
                              ),
                            ],
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
                                      Icons.local_shipping_outlined,
                                      color: AppColors.accent,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        CustomText(
                                          rate["deliveryType"] ?? "N/A",
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          textAlign: TextAlign.left,
                                        ),
                                        const SizedBox(height: 4),
                                        CustomText(
                                          "${_formatter.format(rate["amount"])}%",
                                          color: AppColors.subtext,
                                          textAlign: TextAlign.left,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: [
                                  OutlinedButton.icon(
                                    onPressed:
                                        () => _editRate(
                                          rate["_id"],
                                          double.parse(
                                            rate["amount"].toString(),
                                          ),
                                        ),
                                    icon: const Icon(Icons.edit_outlined),
                                    label: const Text("Edit"),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppColors.ink,
                                      side: const BorderSide(
                                        color: AppColors.border,
                                      ),
                                    ),
                                  ),
                                  OutlinedButton.icon(
                                    onPressed: () => _deleteRate(rate["_id"]),
                                    icon: const Icon(Icons.delete_outline),
                                    label: const Text("Delete"),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppColors.danger,
                                      side: const BorderSide(
                                        color: AppColors.border,
                                      ),
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
}

class _HeaderCard extends StatelessWidget {
  final String title;
  final String subtitle;

  const _HeaderCard({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.route_outlined, color: AppColors.accent),
          ),
          const SizedBox(height: 18),
          CustomText(
            title,
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
            textAlign: TextAlign.left,
          ),
          const SizedBox(height: 8),
          CustomText(
            subtitle,
            fontSize: 13,
            color: AppColors.subtext,
            textAlign: TextAlign.left,
          ),
        ],
      ),
    );
  }
}

class _DeliveryMetric extends StatelessWidget {
  final String label;
  final String value;

  const _DeliveryMetric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          CustomText(
            value,
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          CustomText(
            label,
            fontSize: 11,
            color: AppColors.subtext,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
