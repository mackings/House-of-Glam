import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hog/TailorApp/Home/Api/TailorHomeservice.dart';
import 'package:hog/components/button.dart';
import 'package:hog/components/formfields.dart';
import 'package:hog/components/texts.dart';
import 'package:intl/intl.dart';

class UpdateQuotationBottomSheet extends StatefulWidget {
  final String materialId;

  const UpdateQuotationBottomSheet({super.key, required this.materialId});

  @override
  State<UpdateQuotationBottomSheet> createState() =>
      _UpdateQuotationBottomSheetState();
}

class _UpdateQuotationBottomSheetState
    extends State<UpdateQuotationBottomSheet> {
  final _formKey = GlobalKey<FormState>();

  final commentController = TextEditingController();
  final materialCostController = TextEditingController();
  final workmanshipCostController = TextEditingController();
  final deliveryDateController = TextEditingController();
  final reminderDateController = TextEditingController();

  bool isLoading = false;
  final service = TailorHomeService();

  String formatNumber(String value) {
    if (value.isEmpty) return "";
    final number = int.tryParse(value.replaceAll(",", ""));
    if (number == null) return value;
    return NumberFormat("#,###").format(number);
  }

  String parseNumber(String value) => value.replaceAll(",", "");

  Future<void> pickDate(TextEditingController controller) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF6B21A8),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF1F2937),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      controller.text = DateFormat("yyyy-MM-dd").format(picked);
    }
  }

  Future<void> handleUpdate() async {
    if (!_formKey.currentState!.validate()) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              "Confirm Update",
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1F2937),
              ),
            ),
            content: Text(
              "Are you sure you want to update this quotation with the new values?",
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: const Color(0xFF6B7280),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  "Cancel",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6B21A8), Color(0xFF7C3AED)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => Navigator.pop(context, true),
                    borderRadius: BorderRadius.circular(10),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      child: Text(
                        "Yes, Update",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
    );

    if (confirm != true) return;

    setState(() => isLoading = true);
    try {
      await service.updateQuotation(
        materialId: widget.materialId,
        comment: commentController.text,
        materialTotalCost: parseNumber(materialCostController.text),
        workmanshipTotalCost: parseNumber(workmanshipCostController.text),
        deliveryDate: deliveryDateController.text,
        reminderDate: reminderDateController.text,
      );

      if (mounted) {
        Navigator.pop(context);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "✅ Quotation updated successfully!",
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("❌ Error: $e", style: GoogleFonts.poppins()),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF6B21A8), Color(0xFF7C3AED)],
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF6B21A8).withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.edit_document,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Update Quotation",
                                style: GoogleFonts.poppins(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF1F2937),
                                ),
                              ),
                              Text(
                                "Provide updated pricing details",
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: const Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // Comment Field
                    _buildFieldLabel("Comment", true),
                    CustomTextField(
                      title: "",
                      controller: commentController,
                      hintText: "Enter your update notes",
                      fieldKey: "update_comment_field",
                      validator:
                          (v) => v == null || v.isEmpty ? "Required" : null,
                    ),

                    const SizedBox(height: 20),

                    // Cost Section
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAF5FF),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF6B21A8).withOpacity(0.1),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF6B21A8,
                                  ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.attach_money_rounded,
                                  size: 18,
                                  color: Color(0xFF6B21A8),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                "Cost Breakdown",
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF1F2937),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildFieldLabel("Material Cost", true),
                          CustomTextField(
                            title: "",
                            controller: materialCostController,
                            hintText: "e.g. 45,000",
                            fieldKey: "update_material_cost_field",
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
                            validator:
                                (v) =>
                                    v == null || v.isEmpty ? "Required" : null,
                          ),
                          const SizedBox(height: 16),
                          _buildFieldLabel("Workmanship Cost", true),
                          CustomTextField(
                            title: "",
                            controller: workmanshipCostController,
                            hintText: "e.g. 12,000",
                            fieldKey: "update_workmanship_cost_field",
                            keyboardType: TextInputType.number,
                            onChanged: (v) {
                              final formatted = formatNumber(v);
                              if (formatted != v) {
                                workmanshipCostController
                                    .value = TextEditingValue(
                                  text: formatted,
                                  selection: TextSelection.collapsed(
                                    offset: formatted.length,
                                  ),
                                );
                              }
                            },
                            validator:
                                (v) =>
                                    v == null || v.isEmpty ? "Required" : null,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Dates Section
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAF5FF),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF6B21A8).withOpacity(0.1),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF6B21A8,
                                  ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.calendar_today_rounded,
                                  size: 18,
                                  color: Color(0xFF6B21A8),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                "Timeline",
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF1F2937),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildFieldLabel("Delivery Date", true),
                          GestureDetector(
                            onTap: () => pickDate(deliveryDateController),
                            child: AbsorbPointer(
                              child: CustomTextField(
                                title: "",
                                controller: deliveryDateController,
                                hintText: "YYYY-MM-DD",
                                fieldKey: "update_delivery_date_field",
                                validator:
                                    (v) =>
                                        v == null || v.isEmpty
                                            ? "Required"
                                            : null,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildFieldLabel("Reminder Date", true),
                          GestureDetector(
                            onTap: () => pickDate(reminderDateController),
                            child: AbsorbPointer(
                              child: CustomTextField(
                                title: "",
                                controller: reminderDateController,
                                hintText: "YYYY-MM-DD",
                                fieldKey: "update_reminder_date_field",
                                validator:
                                    (v) =>
                                        v == null || v.isEmpty
                                            ? "Required"
                                            : null,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Update Button
                    Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6B21A8), Color(0xFF7C3AED)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6B21A8).withOpacity(0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: isLoading ? null : handleUpdate,
                          borderRadius: BorderRadius.circular(16),
                          child: Center(
                            child:
                                isLoading
                                    ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                    : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.check_circle_rounded,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          "Update Quotation",
                                          style: GoogleFonts.poppins(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label, bool required) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1F2937),
            ),
          ),
          if (required) ...[
            const SizedBox(width: 4),
            const Text(
              "*",
              style: TextStyle(color: Color(0xFFEF4444), fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }

  @override
  void dispose() {
    commentController.dispose();
    materialCostController.dispose();
    workmanshipCostController.dispose();
    deliveryDateController.dispose();
    reminderDateController.dispose();
    super.dispose();
  }
}
