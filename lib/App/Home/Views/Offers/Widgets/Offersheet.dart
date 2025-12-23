import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hog/components/texts.dart';
import 'package:hog/constants/currency.dart';
import 'package:hog/constants/currencyHelper.dart';
import 'package:intl/intl.dart';

class ReusableOfferSheet {
  static Future<Map<String, dynamic>?> show(
    BuildContext context, {
    String title = "Make an Offer",
    required Future<Map<String, dynamic>> Function(
      String comment,
      String materialCost,
      String workCost,
    ) onSubmit,
  }) async {
    final commentCtrl = TextEditingController();
    final materialCtrl = TextEditingController();
    final workCtrl = TextEditingController();
    bool isLoading = false;

    return await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            // ✅ Real-time total calculation
            double getMaterialAmount() {
              final text = materialCtrl.text.replaceAll(',', '').trim();
              return double.tryParse(text) ?? 0;
            }

            double getWorkAmount() {
              final text = workCtrl.text.replaceAll(',', '').trim();
              return double.tryParse(text) ?? 0;
            }

            double getTotal() {
              return getMaterialAmount() + getWorkAmount();
            }

            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ✅ Fintech-style gradient header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.purple, Colors.purple.shade700],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                    ),
                    child: Column(
                      children: [
                        // Drag handle
                        Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Title
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.local_offer_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // ✅ Live total display
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                "Total Offer Amount",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withOpacity(0.9),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "$currencySymbol${NumberFormat('#,###.##').format(getTotal())}",
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Content
                  Flexible(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                        left: 20,
                        right: 20,
                        top: 24,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Comment field
                          _buildTextField(
                            "Comment",
                            commentCtrl,
                            maxLines: 3,
                            icon: Icons.comment_outlined,
                            hint: "Share your thoughts about this offer...",
                            onChanged: (_) => setState(() {}),
                          ),
                          const SizedBox(height: 20),

                          // ✅ Cost breakdown section
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.purple.shade50.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.purple.shade100,
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.calculate_outlined,
                                      size: 18,
                                      color: Colors.purple.shade700,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      "Cost Breakdown",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.purple.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),

                                _buildTextField(
                                  "Material Cost ($currencySymbol)",
                                  materialCtrl,
                                  icon: Icons.checkroom,
                                  type: TextInputType.number,
                                  formatter: DecimalThousandsFormatter(),
                                  hint: "0.00",
                                  onChanged: (_) => setState(() {}),
                                ),
                                const SizedBox(height: 16),

                                _buildTextField(
                                  "Workmanship Cost ($currencySymbol)",
                                  workCtrl,
                                  icon: Icons.handyman,
                                  type: TextInputType.number,
                                  formatter: DecimalThousandsFormatter(),
                                  hint: "0.00",
                                  onChanged: (_) => setState(() {}),
                                ),

                                // ✅ Breakdown summary
                                if (getMaterialAmount() > 0 || getWorkAmount() > 0) ...[
                                  const SizedBox(height: 16),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      children: [
                                        _buildSummaryRow(
                                          "Material",
                                          getMaterialAmount(),
                                          Icons.checkroom,
                                        ),
                                        const SizedBox(height: 8),
                                        _buildSummaryRow(
                                          "Workmanship",
                                          getWorkAmount(),
                                          Icons.handyman,
                                        ),
                                        const Padding(
                                          padding: EdgeInsets.symmetric(vertical: 8),
                                          child: Divider(height: 1),
                                        ),
                                        _buildSummaryRow(
                                          "Total",
                                          getTotal(),
                                          Icons.attach_money,
                                          isBold: true,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // ✅ Fintech-style action button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: isLoading
                                  ? null
                                  : () async {
                                      final comment = commentCtrl.text.trim();
                                      final materialDisplay =
                                          materialCtrl.text.replaceAll(',', '').trim();
                                      final workDisplay =
                                          workCtrl.text.replaceAll(',', '').trim();

                                      if (comment.isEmpty ||
                                          materialDisplay.isEmpty ||
                                          workDisplay.isEmpty) {
                                        _showSnack(
                                          context,
                                          "Please fill all fields",
                                          isError: true,
                                        );
                                        return;
                                      }

                                      // Confirm action
                                      final confirmed = await _confirmAction(context);
                                      if (confirmed != true) return;

                                      setState(() => isLoading = true);

                                      // ✅ Convert to NGN before submitting
                                      final materialNGN =
                                          await CurrencyHelper.convertToNGN(
                                        double.tryParse(materialDisplay) ?? 0,
                                      );
                                      final workNGN = await CurrencyHelper.convertToNGN(
                                        double.tryParse(workDisplay) ?? 0,
                                      );

                                      final result = await onSubmit(
                                        comment,
                                        materialNGN.toString(),
                                        workNGN.toString(),
                                      );

                                      setState(() => isLoading = false);
                                      Navigator.pop(context, result);
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.purple,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 0,
                              ),
                              child: isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.send_rounded,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          "Submit Offer • $currencySymbol${NumberFormat('#,###.##').format(getTotal())}",
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ✅ Updated TextField with better styling
  static Widget _buildTextField(
    String label,
    TextEditingController controller, {
    IconData? icon,
    int maxLines = 1,
    TextInputType? type,
    TextInputFormatter? formatter,
    String? hint,
    Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade200, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: type,
            inputFormatters: formatter != null ? [formatter] : [],
            onChanged: onChanged,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              prefixIcon: icon != null
                  ? Icon(icon, color: Colors.purple.shade400, size: 22)
                  : null,
              hintText: hint ?? "Enter $label",
              hintStyle: TextStyle(
                color: Colors.grey.shade400,
                fontWeight: FontWeight.normal,
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
          ),
        ),
      ],
    );
  }

  static Widget _buildSummaryRow(String label, double amount, IconData icon,
      {bool isBold = false}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.purple.shade400),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade700,
              fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
        Text(
          "$currencySymbol${NumberFormat('#,###.##').format(amount)}",
          style: TextStyle(
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: isBold ? Colors.purple.shade700 : Colors.black87,
          ),
        ),
      ],
    );
  }

  static void _showSnack(BuildContext context, String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(msg, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
        backgroundColor: isError ? Colors.red.shade600 : Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  static Future<bool?> _confirmAction(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.purple.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.help_outline, color: Colors.purple.shade700),
            ),
            const SizedBox(width: 12),
            const Text(
              "Confirm Submission",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        content: const Text(
          "Are you sure you want to submit this offer?",
          style: TextStyle(fontSize: 14, color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel", style: TextStyle(color: Colors.black54)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              "Yes, Submit",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

/// ✅ Updated formatter that supports decimals
class DecimalThousandsFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String text = newValue.text.replaceAll(',', '');
    
    // Allow only numbers and one decimal point
    if (text.isEmpty) return newValue;
    if (!RegExp(r'^\d*\.?\d*$').hasMatch(text)) {
      return oldValue;
    }

    // Split into integer and decimal parts
    final parts = text.split('.');
    String integerPart = parts[0];
    String? decimalPart = parts.length > 1 ? parts[1] : null;

    // Format integer part with commas
    if (integerPart.isNotEmpty) {
      final formatter = NumberFormat('#,###');
      integerPart = formatter.format(int.parse(integerPart));
    }

    // Reconstruct with decimal
    String formatted = integerPart;
    if (decimalPart != null) {
      formatted += '.$decimalPart';
    } else if (text.endsWith('.')) {
      formatted += '.';
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
