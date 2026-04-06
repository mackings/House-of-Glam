import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hog/components/texts.dart';
import 'package:hog/constants/currency.dart';
import 'package:hog/constants/currencyHelper.dart';
import 'package:hog/theme/app_theme.dart';
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
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
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

            return SafeArea(
              top: true,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 12),
                    Container(
                      width: 52,
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    Flexible(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                          left: 20,
                          right: 20,
                          top: 18,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                _HeaderChip(
                                  icon: Icons.local_offer_outlined,
                                  onTap: () => Navigator.pop(context),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      CustomText(
                                        title,
                                        fontSize: 21,
                                        fontWeight: FontWeight.w800,
                                        textAlign: TextAlign.left,
                                      ),
                                      const SizedBox(height: 2),
                                      const CustomText(
                                        "Review the breakdown before sending your offer.",
                                        fontSize: 12,
                                        color: AppColors.subtext,
                                        textAlign: TextAlign.left,
                                      ),
                                    ],
                                  ),
                                ),
                                _HeaderChip(
                                  icon: Icons.close_rounded,
                                  onTap: () => Navigator.pop(context),
                                  filled: false,
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFF8F3FF), Colors.white],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(26),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Column(
                                children: [
                                  const CustomText(
                                    "Total Offer Amount",
                                    fontSize: 12,
                                    color: AppColors.subtext,
                                  ),
                                  const SizedBox(height: 8),
                                  CustomText(
                                    "$currencySymbol${NumberFormat('#,###.##').format(getTotal())}",
                                    fontSize: 30,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.accent,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 18),
                            _buildTextField(
                              "Comment",
                              commentCtrl,
                              maxLines: 3,
                              icon: Icons.comment_outlined,
                              hint: "Share your thoughts about this offer...",
                              onChanged: (_) => setState(() {}),
                            ),
                            const SizedBox(height: 18),
                            Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: AppColors.border),
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
                                  const CustomText(
                                    "Cost Breakdown",
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    textAlign: TextAlign.left,
                                  ),
                                  const SizedBox(height: 6),
                                  const CustomText(
                                    "Split your offer between material and workmanship.",
                                    fontSize: 12,
                                    color: AppColors.subtext,
                                    textAlign: TextAlign.left,
                                  ),
                                  const SizedBox(height: 16),
                                  _buildTextField(
                                    "Material Cost ($currencySymbol)",
                                    materialCtrl,
                                    icon: Icons.checkroom_outlined,
                                    type: TextInputType.number,
                                    formatter: DecimalThousandsFormatter(),
                                    hint: "0.00",
                                    onChanged: (_) => setState(() {}),
                                  ),
                                  const SizedBox(height: 14),
                                  _buildTextField(
                                    "Workmanship Cost ($currencySymbol)",
                                    workCtrl,
                                    icon: Icons.design_services_outlined,
                                    type: TextInputType.number,
                                    formatter: DecimalThousandsFormatter(),
                                    hint: "0.00",
                                    onChanged: (_) => setState(() {}),
                                  ),
                                  if (getMaterialAmount() > 0 ||
                                      getWorkAmount() > 0) ...[
                                    const SizedBox(height: 16),
                                    Container(
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        color: AppColors.surfaceMuted,
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                      child: Column(
                                        children: [
                                          _buildSummaryRow(
                                            "Material",
                                            getMaterialAmount(),
                                            Icons.checkroom_outlined,
                                          ),
                                          const SizedBox(height: 10),
                                          _buildSummaryRow(
                                            "Workmanship",
                                            getWorkAmount(),
                                            Icons.design_services_outlined,
                                          ),
                                          const Padding(
                                            padding: EdgeInsets.symmetric(
                                              vertical: 10,
                                            ),
                                            child: Divider(height: 1),
                                          ),
                                          _buildSummaryRow(
                                            "Total",
                                            getTotal(),
                                            Icons.payments_outlined,
                                            isBold: true,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(height: 22),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed:
                                        isLoading
                                            ? null
                                            : () => Navigator.pop(context),
                                    style: OutlinedButton.styleFrom(
                                      minimumSize: const Size.fromHeight(54),
                                      side: const BorderSide(
                                        color: AppColors.border,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                    ),
                                    child: const Text("Cancel"),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  flex: 2,
                                  child: SizedBox(
                                    height: 54,
                                    child: ElevatedButton.icon(
                                      onPressed:
                                          isLoading
                                              ? null
                                              : () async {
                                                final comment =
                                                    commentCtrl.text.trim();
                                                final materialDisplay =
                                                    materialCtrl.text
                                                        .replaceAll(',', '')
                                                        .trim();
                                                final workDisplay =
                                                    workCtrl.text
                                                        .replaceAll(',', '')
                                                        .trim();

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

                                                final confirmed =
                                                    await _confirmAction(
                                                      context,
                                                    );
                                                if (confirmed != true) return;

                                                setState(
                                                  () => isLoading = true,
                                                );

                                                final materialNGN =
                                                    await CurrencyHelper.convertToNGN(
                                                      double.tryParse(
                                                            materialDisplay,
                                                          ) ??
                                                          0,
                                                    );
                                                final workNGN =
                                                    await CurrencyHelper.convertToNGN(
                                                      double.tryParse(
                                                            workDisplay,
                                                          ) ??
                                                          0,
                                                    );

                                                final result = await onSubmit(
                                                  comment,
                                                  materialNGN.toString(),
                                                  workNGN.toString(),
                                                );

                                                setState(
                                                  () => isLoading = false,
                                                );
                                                Navigator.pop(context, result);
                                              },
                                      icon:
                                          isLoading
                                              ? const SizedBox(
                                                width: 20,
                                                height: 20,
                                                child:
                                                    CircularProgressIndicator(
                                                      color: Colors.white,
                                                      strokeWidth: 2,
                                                    ),
                                              )
                                              : const Icon(
                                                Icons.send_rounded,
                                                color: Colors.white,
                                                size: 18,
                                              ),
                                      label: Text(
                                        "Submit Offer • $currencySymbol${NumberFormat('#,###.##').format(getTotal())}",
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.accent,
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            18,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

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
    final keyboardType =
        type ?? (maxLines > 1 ? TextInputType.multiline : TextInputType.text);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: CustomText(
            label,
            fontSize: 13,
            fontWeight: FontWeight.w700,
            textAlign: TextAlign.left,
          ),
        ),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          textCapitalization:
              maxLines > 1
                  ? TextCapitalization.sentences
                  : TextCapitalization.none,
          inputFormatters: formatter != null ? [formatter] : [],
          onChanged: onChanged,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            prefixIcon:
                icon != null
                    ? Icon(icon, color: AppColors.subtext, size: 20)
                    : null,
            hintText: hint ?? "Enter $label",
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 16,
            ),
          ),
        ),
      ],
    );
  }

  static Widget _buildSummaryRow(
    String label,
    double amount,
    IconData icon, {
    bool isBold = false,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.accent),
        const SizedBox(width: 8),
        Expanded(
          child: CustomText(
            label,
            fontSize: 13,
            color: AppColors.subtext,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
            textAlign: TextAlign.left,
          ),
        ),
        CustomText(
          "$currencySymbol${NumberFormat('#,###.##').format(amount)}",
          fontSize: isBold ? 16 : 14,
          fontWeight: isBold ? FontWeight.w800 : FontWeight.w700,
          color: isBold ? AppColors.accent : AppColors.ink,
          textAlign: TextAlign.left,
        ),
      ],
    );
  }

  static void _showSnack(
    BuildContext context,
    String msg, {
    bool isError = false,
  }) {
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
      builder:
          (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            title: const Row(
              children: [
                Icon(Icons.help_outline_rounded, color: AppColors.accent),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Confirm Submission",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            content: const Text(
              "Are you sure you want to submit this offer?",
              style: TextStyle(fontSize: 14, color: AppColors.ink),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text("Yes, Submit"),
              ),
            ],
          ),
    );
  }
}

class DecimalThousandsFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String text = newValue.text.replaceAll(',', '');

    if (text.isEmpty) return newValue;
    if (!RegExp(r'^\d*\.?\d*$').hasMatch(text)) {
      return oldValue;
    }

    final parts = text.split('.');
    String integerPart = parts[0];
    String? decimalPart = parts.length > 1 ? parts[1] : null;

    if (integerPart.isNotEmpty) {
      final formatter = NumberFormat('#,###');
      integerPart = formatter.format(int.parse(integerPart));
    }

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

class _HeaderChip extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool filled;

  const _HeaderChip({
    required this.icon,
    required this.onTap,
    this.filled = true,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: filled ? AppColors.accentSoft : AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(
          icon,
          size: 18,
          color: filled ? AppColors.accent : AppColors.ink,
        ),
      ),
    );
  }
}
