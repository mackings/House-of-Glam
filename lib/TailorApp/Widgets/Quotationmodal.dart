import 'package:flutter/material.dart';
import 'package:hog/TailorApp/Home/Api/TailorHomeservice.dart';
import 'package:hog/components/button.dart';
import 'package:hog/components/formfields.dart';
import 'package:hog/components/texts.dart';
import 'package:intl/intl.dart';

class QuotationBottomSheet extends StatefulWidget {
  final String materialId;

  const QuotationBottomSheet({super.key, required this.materialId});

  @override
  State<QuotationBottomSheet> createState() => _QuotationBottomSheetState();
}

class _QuotationBottomSheetState extends State<QuotationBottomSheet> {
  final _formKey = GlobalKey<FormState>();

  final commentController = TextEditingController();
  final materialCostController = TextEditingController();
  final workmanshipCostController = TextEditingController();
  final deliveryDateController = TextEditingController();
  final reminderDateController = TextEditingController();

  bool isLoading = false;
  final service = TailorHomeService();

  // Format numbers for UI display (e.g., 12000 → 12,000)
  String formatNumber(String value) {
    if (value.isEmpty) return "";
    final number = int.tryParse(value.replaceAll(",", ""));
    if (number == null) return value;
    return NumberFormat("#,###").format(number);
  }

  // Parse number for backend (e.g., "12,000" → "12000")
  String parseNumber(String value) {
    return value.replaceAll(",", "");
  }

  Future<void> pickDate(TextEditingController controller) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
    );

    if (picked != null) {
      controller.text = DateFormat("yyyy-MM-dd").format(picked);
    }
  }

  Future<void> handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Confirm Quotation"),
            content: const Text(
              "By submitting, you confirm that the prices are correct, "
              "originality and authenticity of the quotation have been verified. "
              "Do you wish to proceed?",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Yes, Submit"),
              ),
            ],
          ),
    );

    if (confirm != true) return;

    setState(() => isLoading = true);
    try {
      await service.submitQuotation(
        materialId: widget.materialId,
        comment: commentController.text,
        materialTotalCost: parseNumber(materialCostController.text),
        workmanshipTotalCost: parseNumber(workmanshipCostController.text),
        deliveryDate: deliveryDateController.text,
        reminderDate: reminderDateController.text,
      );

      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("✅ Quotation submitted!")));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("❌ Error: $e")));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: CustomText(
                  "Submit Quotation",
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              CustomTextField(
                title: "Comment",
                controller: commentController,
                hintText: "Enter your notes or message",
                fieldKey: "comment_field",
                validator: (v) => v == null || v.isEmpty ? "Required" : null,
              ),

              CustomTextField(
                title: "Material Cost",
                controller: materialCostController,
                hintText: "e.g. 23,000",
                fieldKey: "material_cost_field",
                keyboardType: TextInputType.number,
                onChanged: (v) {
                  final formatted = formatNumber(v);
                  if (formatted != v) {
                    materialCostController.value = TextEditingValue(
                      text: formatted,
                      selection: TextSelection.collapsed(
                        offset: formatted.length,
                      ),
                    );
                  }
                },
                validator: (v) => v == null || v.isEmpty ? "Required" : null,
              ),

              CustomTextField(
                title: "Workmanship Cost",
                controller: workmanshipCostController,
                hintText: "e.g. 23,000",
                fieldKey: "workmanship_cost_field",
                keyboardType: TextInputType.number,
                onChanged: (v) {
                  final formatted = formatNumber(v);
                  if (formatted != v) {
                    workmanshipCostController.value = TextEditingValue(
                      text: formatted,
                      selection: TextSelection.collapsed(
                        offset: formatted.length,
                      ),
                    );
                  }
                },
                validator: (v) => v == null || v.isEmpty ? "Required" : null,
              ),

              GestureDetector(
                onTap: () => pickDate(deliveryDateController),
                child: AbsorbPointer(
                  child: CustomTextField(
                    title: "Delivery Date",
                    controller: deliveryDateController,
                    hintText: "YYYY-MM-DD",
                    fieldKey: "delivery_date_field",
                    validator:
                        (v) => v == null || v.isEmpty ? "Required" : null,
                  ),
                ),
              ),

              GestureDetector(
                onTap: () => pickDate(reminderDateController),
                child: AbsorbPointer(
                  child: CustomTextField(
                    title: "Reminder Date",
                    controller: reminderDateController,
                    hintText: "YYYY-MM-DD",
                    fieldKey: "reminder_date_field",
                    validator:
                        (v) => v == null || v.isEmpty ? "Required" : null,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              isLoading
                  ? const Center(
                    child: CircularProgressIndicator(color: Colors.purple),
                  )
                  : CustomButton(
                    title: "Submit Quotation",
                    isOutlined: false,
                    onPressed: handleSubmit,
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
