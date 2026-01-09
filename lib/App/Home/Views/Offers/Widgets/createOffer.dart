import 'package:flutter/material.dart';
import 'package:hog/App/Home/Model/reviewModel.dart';
import 'package:hog/App/Home/Views/Offers/Api/OfferService.dart';
import 'package:hog/App/Home/Views/Offers/Widgets/offerdetail_v2.dart';
import 'package:hog/components/texts.dart';
import 'package:hog/constants/currencyHelper.dart';
import 'package:intl/intl.dart';

/// Modal bottom sheet for creating initial offer
class CreateOfferSheet extends StatefulWidget {
  final Review review;
  final VoidCallback? onOfferCreated;

  const CreateOfferSheet({super.key, required this.review, this.onOfferCreated});

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
    // Pre-fill with review amounts (converted to display currency)
    _initializeAmounts();
  }

  Future<void> _initializeAmounts() async {
    // Pre-fill with vendor's quoted amounts as starting point
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
        backgroundColor: isError ? const Color(0xFFEF4444) : const Color(0xFF10B981),
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
          // Close this sheet
          if (mounted) Navigator.pop(context);

          // Navigate to offer detail chat screen
          if (mounted) {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => OfferDetailV2(offerId: offerId),
              ),
            );

            // Pop back to refresh the quotations list
            if (mounted) Navigator.pop(context);
          }
        } else {
          _showSnack("Offer created but no ID returned", isError: true);
        }
      } else {
        _showSnack(response["message"] ?? "Failed to create offer", isError: true);
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      _showSnack("Error: $e", isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final total =
        double.tryParse(_totalCtrl.text.replaceAll(',', '')) ?? 0;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                            Icons.local_offer,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomText(
                                "Make Your Offer",
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1F2937),
                              ),
                              CustomText(
                                "Propose your desired pricing",
                                fontSize: 13,
                                color: Color(0xFF6B7280),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Vendor's Quote (Reference)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const CustomText(
                            "Vendor's Original Quote:",
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF6B7280),
                          ),
                          const SizedBox(height: 8),
                          CustomText(
                            CurrencyHelper.formatAmount(widget.review.totalCost, currencyCode: 'NGN'),
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Your Offer Section
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
                                  color: const Color(0xFF6B21A8).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.attach_money_rounded,
                                  size: 18,
                                  color: Color(0xFF6B21A8),
                                ),
                              ),
                              const SizedBox(width: 10),
                              const CustomText(
                                "Your Proposed Price",
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1F2937),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Total Cost
                          const CustomText(
                            "Total Amount (NGN)",
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1F2937),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _totalCtrl,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: "e.g., 75,000",
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                            ),
                            validator: (v) => v == null || v.isEmpty ? "Required" : null,
                            enabled: !_isSubmitting,
                            onChanged: (v) {
                              // Format with commas
                              final formatted = _formatNumber(v);
                              if (formatted != v) {
                                _totalCtrl.value = TextEditingValue(
                                  text: formatted,
                                  selection: TextSelection.collapsed(offset: formatted.length),
                                );
                              }
                              setState(() {}); // Update total
                            },
                          ),

                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 8),

                          // Total
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const CustomText(
                                "Total:",
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1F2937),
                              ),
                              CustomText(
                                CurrencyHelper.formatAmount(total, currencyCode: 'NGN'),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF6B21A8),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          const CustomText(
                            "We split this into material and workmanship for processing.",
                            fontSize: 11,
                            color: Color(0xFF6B7280),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Comment Field
                    const CustomText(
                      "Message to Vendor",
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _commentCtrl,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: "e.g., Can we negotiate the price a bit?",
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (v) => v == null || v.isEmpty ? "Please add a comment" : null,
                      enabled: !_isSubmitting,
                    ),

                    const SizedBox(height: 32),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: _isSubmitting ? null : _handleCreateOffer,
                        icon: _isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.send, color: Colors.white),
                        label: CustomText(
                          _isSubmitting ? "Sending..." : "Send Offer",
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6B21A8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
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

  String _formatNumber(String value) {
    if (value.isEmpty) return "";
    final number = int.tryParse(value.replaceAll(",", ""));
    if (number == null) return value;
    return NumberFormat("#,###").format(number);
  }
}
