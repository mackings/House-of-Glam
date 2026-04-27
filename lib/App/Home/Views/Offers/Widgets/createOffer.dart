import 'package:flutter/material.dart';
import 'package:hog/App/Home/Model/reviewModel.dart';
import 'package:hog/App/Home/Views/Offers/Api/OfferService.dart';
import 'package:hog/App/Home/Views/Offers/Widgets/offerdetail_v2.dart';
import 'package:hog/components/texts.dart';
import 'package:hog/constants/currencyHelper.dart';
import 'package:hog/theme/app_theme.dart';
import 'package:intl/intl.dart';

class CreateOfferSheet extends StatefulWidget {
  final Review review;
  final VoidCallback? onOfferCreated;

  const CreateOfferSheet({
    super.key,
    required this.review,
    this.onOfferCreated,
  });

  @override
  State<CreateOfferSheet> createState() => _CreateOfferSheetState();
}

class _CreateOfferSheetState extends State<CreateOfferSheet> {
  final TextEditingController _commentCtrl = TextEditingController();
  final TextEditingController _totalCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _initializeAmounts();
  }

  Future<void> _initializeAmounts() async {
    setState(() {
      _totalCtrl.text = NumberFormat('#,###').format(widget.review.totalCost);
    });
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    _totalCtrl.dispose();
    super.dispose();
  }

  void _showSnack(String msg, {bool isError = false}) {
    if (!mounted) return;
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
            Expanded(child: CustomText(msg, color: Colors.white, fontSize: 14)),
          ],
        ),
        backgroundColor:
            isError ? const Color(0xFFEF4444) : const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _handleCreateOffer() async {
    if (!_formKey.currentState!.validate()) return;

    final comment = _commentCtrl.text.trim();
    final totalStr = _totalCtrl.text.replaceAll(',', '').trim();

    if (comment.isEmpty) {
      return _showSnack("Please add a comment", isError: true);
    }
    if (totalStr.isEmpty) {
      return _showSnack("Please enter a total amount", isError: true);
    }

    final totalAmount = int.tryParse(totalStr);
    if (totalAmount == null || totalAmount <= 0) {
      return _showSnack("Please enter a valid amount", isError: true);
    }
    final materialAmount = (totalAmount / 2).floor();
    final workmanshipAmount = totalAmount - materialAmount;

    setState(() => _isSubmitting = true);

    try {
      final response = await OfferService.makeOffer(
        reviewId: widget.review.id,
        comment: comment,
        materialTotalCost: materialAmount.toString(),
        workmanshipTotalCost: workmanshipAmount.toString(),
      );

      setState(() => _isSubmitting = false);

      if (response["success"] == true) {
        final offerId = response["data"]?["_id"];

        if (offerId != null) {
          widget.onOfferCreated?.call();
          if (mounted) Navigator.pop(context);

          if (mounted) {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => OfferDetailV2(offerId: offerId),
              ),
            );

            if (mounted) Navigator.pop(context);
          }
        } else {
          _showSnack("Offer created but no ID returned", isError: true);
        }
      } else {
        _showSnack(
          response["message"] ?? "Failed to create offer",
          isError: true,
        );
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      _showSnack("Error: $e", isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = double.tryParse(_totalCtrl.text.replaceAll(',', '')) ?? 0;
    final quotedAmount = widget.review.totalCost.toDouble();

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
                  left: 20,
                  right: 20,
                  top: 18,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _HeaderButton(
                            icon: Icons.close_rounded,
                            onTap: () => Navigator.pop(context),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomText(
                                  "Make an Offer",
                                  fontSize: 21,
                                  fontWeight: FontWeight.w800,
                                  textAlign: TextAlign.left,
                                ),
                                SizedBox(height: 2),
                                CustomText(
                                  "Enter the amount you'd like to pay for this project.",
                                  fontSize: 12,
                                  color: AppColors.subtext,
                                  textAlign: TextAlign.left,
                                ),
                              ],
                            ),
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
                                    Icons.local_offer_outlined,
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
                                        "Vendor Quote",
                                        fontSize: 12,
                                        color: AppColors.subtext,
                                        textAlign: TextAlign.left,
                                      ),
                                      const SizedBox(height: 3),
                                      CustomText(
                                        CurrencyHelper.formatAmount(
                                          quotedAmount,
                                          currencyCode: 'NGN',
                                        ),
                                        fontSize: 22,
                                        fontWeight: FontWeight.w800,
                                        textAlign: TextAlign.left,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF7ED),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(0xFFF5D08A),
                                ),
                              ),
                              child: const Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.info_outline_rounded,
                                    size: 18,
                                    color: AppColors.warning,
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: CustomText(
                                      "You can send only one initial offer for this quote.",
                                      fontSize: 12,
                                      color: AppColors.warning,
                                      textAlign: TextAlign.left,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      Container(
                        width: double.infinity,
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
                              "Your Offer",
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              textAlign: TextAlign.left,
                            ),
                            const SizedBox(height: 6),
                            CustomText(
                              "Enter your offer amount.",
                              fontSize: 12,
                              color: AppColors.subtext,
                              textAlign: TextAlign.left,
                            ),
                            const SizedBox(height: 14),
                            const CustomText(
                              "Your Offer (₦)",
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              textAlign: TextAlign.left,
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _totalCtrl,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: "e.g. 75,000",
                                prefixIcon: const Icon(
                                  Icons.payments_outlined,
                                  size: 20,
                                  color: AppColors.subtext,
                                ),
                              ),
                              validator:
                                  (v) =>
                                      v == null || v.isEmpty
                                          ? "Required"
                                          : null,
                              enabled: !_isSubmitting,
                              onChanged: (v) {
                                final formatted = _formatNumber(v);
                                if (formatted != v) {
                                  _totalCtrl.value = TextEditingValue(
                                    text: formatted,
                                    selection: TextSelection.collapsed(
                                      offset: formatted.length,
                                    ),
                                  );
                                }
                                setState(() {});
                              },
                            ),
                            const SizedBox(height: 14),
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceMuted,
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Column(
                                children: [
                                  _SummaryRow(
                                    label: "Your total",
                                    value: CurrencyHelper.formatAmount(
                                      total,
                                      currencyCode: 'NGN',
                                    ),
                                    emphasize: true,
                                  ),
                                  const SizedBox(height: 8),
                                  const CustomText(
                                    "We'll automatically split this into materials and labour.",
                                    fontSize: 11,
                                    color: AppColors.subtext,
                                    textAlign: TextAlign.left,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      const CustomText(
                        "Message to Vendor",
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        textAlign: TextAlign.left,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _commentCtrl,
                        maxLines: 4,
                        keyboardType: TextInputType.multiline,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: const InputDecoration(
                          hintText: "Add a message (optional)",
                          prefixIcon: Icon(
                            Icons.chat_bubble_outline_rounded,
                            size: 20,
                            color: AppColors.subtext,
                          ),
                          alignLabelWithHint: true,
                        ),
                        validator:
                            (v) =>
                                v == null || v.isEmpty
                                    ? "Please add a comment"
                                    : null,
                        enabled: !_isSubmitting,
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed:
                                  _isSubmitting
                                      ? null
                                      : () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size.fromHeight(54),
                                side: const BorderSide(color: AppColors.border),
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
                                    _isSubmitting ? null : _handleCreateOffer,
                                icon:
                                    _isSubmitting
                                        ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                        : const Icon(
                                          Icons.send_rounded,
                                          color: Colors.white,
                                        ),
                                label: CustomText(
                                  _isSubmitting ? "Sending..." : "Submit Offer",
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.accent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  elevation: 0,
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
            ),
          ],
        ),
      ),
    );
  }

  String _formatNumber(String value) {
    if (value.isEmpty) return "";
    final number = int.tryParse(value.replaceAll(",", ""));
    if (number == null) return value;
    return NumberFormat("#,###").format(number);
  }
}

class _HeaderButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(icon, size: 18, color: AppColors.ink),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool emphasize;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CustomText(
            label,
            fontSize: 12,
            color: AppColors.subtext,
            textAlign: TextAlign.left,
          ),
        ),
        CustomText(
          value,
          fontSize: emphasize ? 18 : 14,
          fontWeight: FontWeight.w800,
          color: emphasize ? AppColors.accent : AppColors.ink,
          textAlign: TextAlign.left,
        ),
      ],
    );
  }
}
