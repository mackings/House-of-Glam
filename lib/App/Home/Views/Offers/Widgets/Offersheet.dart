import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hog/components/texts.dart';
import 'package:intl/intl.dart';

class ReusableOfferSheet {
  static Future<Map<String, dynamic>?> show(
    BuildContext context, {
    String title = "Make an Offer",
    required Future<Map<String, dynamic>> Function(
      String comment,
      String materialCost,
      String workCost,
    )
    onSubmit,
  }) async {
    final commentCtrl = TextEditingController();
    final materialCtrl = TextEditingController();
    final workCtrl = TextEditingController();
    bool isLoading = false;

    return await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🔹 Header
                    Row(
                      children: [
                        const Icon(
                          Icons.local_offer,
                          color: Colors.purple,
                          size: 22,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // 🔹 Input fields
                    _buildTextField("Comment", commentCtrl, maxLines: 2),
                    const SizedBox(height: 15),
                    _buildTextField(
                      "Material Total Cost",
                      materialCtrl,
                      icon: Icons.category_outlined,
                      type: TextInputType.number,
                      formatter: ThousandsFormatter(),
                    ),
                    const SizedBox(height: 15),
                    _buildTextField(
                      "Workmanship Total Cost",
                      workCtrl,
                      icon: Icons.handyman_outlined,
                      type: TextInputType.number,
                      formatter: ThousandsFormatter(),
                    ),
                    const SizedBox(height: 25),

                    // 🔹 Action buttons
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ElevatedButton.icon(
                          icon:
                              isLoading
                                  ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : const Icon(
                                    Icons.send_rounded,
                                    color: Colors.white,
                                  ),
                          label: Text(
                            isLoading ? "Submitting..." : "Submit Offer",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed:
                              isLoading
                                  ? null
                                  : () async {
                                    final comment = commentCtrl.text.trim();
                                    final material =
                                        materialCtrl.text
                                            .replaceAll(',', '')
                                            .trim();
                                    final work =
                                        workCtrl.text
                                            .replaceAll(',', '')
                                            .trim();

                                    if (comment.isEmpty ||
                                        material.isEmpty ||
                                        work.isEmpty) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            "Please fill all fields",
                                          ),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                      return;
                                    }

                                    // 🧩 Confirm action before API call
                                    final confirmed = await _confirmAction(
                                      context,
                                    );
                                    if (confirmed != true) return;

                                    setState(() => isLoading = true);
                                    final result = await onSubmit(
                                      comment,
                                      material,
                                      work,
                                    );
                                    setState(() => isLoading = false);

                                    Navigator.pop(context, result);
                                  },
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // 🧱 Reusable TextField Builder
  static Widget _buildTextField(
    String label,
    TextEditingController controller, {
    IconData? icon,
    int maxLines = 1,
    TextInputType? type,
    TextInputFormatter? formatter,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: type,
            inputFormatters: formatter != null ? [formatter] : [],
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              prefixIcon:
                  icon != null ? Icon(icon, color: Colors.purple) : null,
              hintText: "Enter $label",
              hintStyle: const TextStyle(color: Colors.black38),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 14,
                horizontal: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
      ],
    );
  }

  static Future<bool?> _confirmAction(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text("Confirm Submission"),
            content: const Text(
              "Are you sure you want to submit this offer?",
              style: TextStyle(fontSize: 14),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text(
                  "Cancel",
                  style: TextStyle(color: Colors.black),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
                child: const Text("Yes", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
    );
  }

  static Future<bool?> _confirmReject(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text("Reject Offer"),
            content: const Text(
              "Are you sure you want to reject this offer?",
              style: TextStyle(fontSize: 14),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text(
                  "Cancel",
                  style: TextStyle(color: Colors.black54),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
                child: const Text("Yes, Reject"),
              ),
            ],
          ),
    );
  }
}

/// 🔹 Formatter that adds commas as the user types (e.g., 23000 → 23,000)
class ThousandsFormatter extends TextInputFormatter {
  final NumberFormat _formatter = NumberFormat("#,###");

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String digits = newValue.text.replaceAll(',', '');
    if (digits.isEmpty) return newValue;

    final formatted = _formatter.format(int.parse(digits));
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
