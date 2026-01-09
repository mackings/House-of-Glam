import 'package:flutter/material.dart';
import 'package:hog/App/Home/Model/reviewModel.dart';
import 'package:hog/components/Orders/PaymentOp.dart';
import 'package:hog/components/texts.dart';
import 'package:hog/constants/currencyHelper.dart';
import 'package:intl/intl.dart';
import 'package:webview_flutter/webview_flutter.dart';



class QuotationCard extends StatelessWidget {
  final Review review;
  final VoidCallback onHireDesigner;
  final VoidCallback? onMakeOffer;
  final void Function(int amount) onCompletePayment;
  final VoidCallback? onRefresh;
  final bool hasSubmittedOffer;

  const QuotationCard({
    super.key,
    required this.review,
    required this.onHireDesigner,
    this.onMakeOffer,
    required this.onCompletePayment,
    this.onRefresh,
    this.hasSubmittedOffer = false,
  });

  String formatAmount(int amount) {
    final formatter = NumberFormat('#,###');
    return formatter.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Payment status flags
    final bool isPartPayment = review.status == "part payment";
    final bool isFullPayment = review.status == "full payment";
    final bool isQuote = review.status == "quote";

    // ✅ Check if offer has been accepted
    final bool hasAcceptedOffer = review.hasAcceptedOffer;

    // ✅ Check if user has made any payment
    final bool hasPartPayment = review.amountPaid > 0 && review.amountToPay > 0;

    // 🔥 FIX: Use final negotiated prices if offer was accepted, otherwise use original quote
    final displayTotal = hasAcceptedOffer && review.finalTotalCost != null
        ? review.finalTotalCost!
        : review.totalCost;
    
    // 🔥 FIX: Properly calculate amount to pay
    final displayAmountToPay = review.amountToPay;

    // ✅ Determine currency code
    final currencyCode = 'NGN';

    // ✅ Get USD amounts for display
    final displayTotalUSD = hasAcceptedOffer && review.finalTotalCostUSD != null
        ? review.finalTotalCostUSD!
        : review.totalCostUSD;

    // ✅ Show original USD amounts if international vendor (for reference)
    final showOriginalUSD = review.isInternationalVendor && displayTotalUSD > 0;

    // 🔥 DEBUG: Print values to console
    print('\n📋 QUOTATION CARD DEBUG:');
    print('   Review ID: ${review.id}');
    print('   Has Accepted Offer: $hasAcceptedOffer');
    print('   Accepted Offer ID: ${review.acceptedOfferId ?? 'None'}');
    print('   Status: ${review.status}');
    if (hasAcceptedOffer && review.finalTotalCost != null) {
      print('   ✅ Using Final Negotiated Prices:');
      print('   Final Material Cost: ₦${review.finalMaterialCost}');
      print('   Final Workmanship Cost: ₦${review.finalWorkmanshipCost}');
      print('   Final Total Cost: ₦${review.finalTotalCost}');
    } else {
      print('   ⚠️ Using Original Quote Prices:');
      print('   Material Cost: ₦${review.materialTotalCost}');
      print('   Workmanship Cost: ₦${review.workmanshipTotalCost}');
      print('   Total Cost: ₦${review.totalCost}');
    }
    print('   Display Total: ₦$displayTotal');
    print('   Amount Paid: ₦${review.amountPaid}');
    print('   Amount To Pay: ₦$displayAmountToPay');
    print('   Is Part Payment: $isPartPayment');
    print('   Is Full Payment: $isFullPayment');
    print('   Has Part Payment: $hasPartPayment');

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar + Name + Status
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.purple.shade100,
                child: Text(
                  review.user.fullName.isNotEmpty
                      ? review.user.fullName[0].toUpperCase()
                      : "?",
                  style: const TextStyle(
                    color: Colors.purple,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: CustomText(
                  review.user.fullName,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Icon(
                isQuote
                    ? Icons.schedule
                    : isPartPayment
                        ? Icons.check_circle_outline
                        : Icons.check_circle,
                color: isPartPayment
                    ? Colors.grey
                    : isFullPayment
                        ? Colors.purple
                        : Colors.green,
                size: 18,
              ),
            ],
          ),
          const SizedBox(height: 10),


          // Delivery & Reminder
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomText(
                "Delivery: ${DateFormat("dd MMM yyyy").format(review.deliveryDate)}",
                fontSize: 12,
                color: Colors.black54,
              ),
              CustomText(
                "Reminder: ${DateFormat("dd MMM yyyy").format(review.reminderDate)}",
                fontSize: 12,
                color: Colors.black54,
              ),
            ],
          ),


          const SizedBox(height: 10),

          if (review.comment.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: CustomText(
                review.comment,
                fontSize: 13,
                overflow: TextOverflow.visible,
              ),
            ),

          // 🔥 Show badge if price was negotiated
          if (hasAcceptedOffer && review.finalTotalCost != null && 
              review.finalTotalCost! < review.totalCost) ...[

          ],


          // Display total cost only
          _buildTotalCost(displayTotal, currencyCode: currencyCode),
          const SizedBox(height: 6),
          CustomText(
            "Excluding VAT",
            fontSize: 11,
            color: Colors.black54,
          ),

          // Show USD conversion info if international vendor
          if (showOriginalUSD) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.info_outline, size: 14, color: Colors.blue.shade700),
                  const SizedBox(width: 6),
                  CustomText(
                    "USD: ${CurrencyHelper.formatAmount(displayTotalUSD, currencyCode: 'USD')}",
                    fontSize: 11,
                    color: Colors.blue.shade900,
                  ),
                  const SizedBox(width: 4),
                  CustomText(
                    "• Rate: ₦${review.exchangeRate.toStringAsFixed(2)}",
                    fontSize: 10,
                    color: Colors.blue.shade700,
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 20),

          // Payment Status Info (for part payment)
          if (isPartPayment)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange.shade700, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          "Partial Payment Made",
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.orange.shade900,
                        ),
                        const SizedBox(height: 2),
                        CustomText(
                          "Balance: ${CurrencyHelper.formatAmount(displayAmountToPay, currencyCode: currencyCode)}",
                          fontSize: 11,
                          color: Colors.orange.shade700,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // 🔥 BUTTON LOGIC
          if (isFullPayment) ...[
            // Fully Paid - Show disabled button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: null,
                icon: const Icon(Icons.check_circle, size: 18),
                label: const CustomText(
                  "Paid",
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ] else if (hasPartPayment) ...[
            // Has made partial payment - show "Pay Balance" button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => onCompletePayment(displayAmountToPay.round()),
                icon: const Icon(Icons.payment, size: 18, color: Colors.white),
                label: CustomText(
                  "Pay Balance (${CurrencyHelper.formatAmount(displayAmountToPay, currencyCode: currencyCode)})",
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ] else if (hasAcceptedOffer) ...[
            // 🔥 Offer accepted but not yet paid - show payment options
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      print('💳 Full Payment Button Pressed');
                      print('   Amount: ₦${displayTotal.round()}');
                      onCompletePayment(displayTotal.round());
                    },
                    icon: const Icon(Icons.payment, size: 18, color: Colors.white),
                    label: CustomText(
                      "Pay in Full (${CurrencyHelper.formatAmount(displayTotal, currencyCode: currencyCode)})",
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      print('💰 Part Payment Button Pressed');
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.white,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                        ),
                        builder: (BuildContext ctx) {
                          return PaymentOptionsModal(
                            review: review,
                            onCheckout: (String url) async {
                              Navigator.of(ctx).pop();
                              await Future.delayed(
                                const Duration(milliseconds: 250),
                              );
                              if (context.mounted) {
                                _openCheckout(context, url);
                              }
                            },
                          );
                        },
                      );
                    },
                    icon: Icon(Icons.payments_outlined, size: 18, color: Colors.purple.shade700),
                    label: CustomText(
                      "Pay Half (Part Payment)",
                      fontSize: 14,
                      color: Colors.purple.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: Colors.purple.shade300, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            // Initial quote - show Hire Designer and Make Offer
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onHireDesigner,
                    icon: const Icon(Icons.person_add, size: 18, color: Colors.white),
                    label: CustomText(
                      "Hire Designer (${CurrencyHelper.formatAmount(displayTotal, currencyCode: currencyCode)})",
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: hasSubmittedOffer ? null : onMakeOffer,
                    icon: Icon(
                      Icons.local_offer_outlined,
                      size: 18,
                      color:
                          hasSubmittedOffer
                              ? Colors.grey.shade500
                              : Colors.purple.shade700,
                    ),
                    label: CustomText(
                      hasSubmittedOffer ? "Offer Submitted" : "Make Offer",
                      fontSize: 14,
                      color:
                          hasSubmittedOffer
                              ? Colors.grey.shade500
                              : Colors.purple.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(
                        color:
                            hasSubmittedOffer
                                ? Colors.grey.shade300
                                : Colors.purple.shade300,
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTotalCost(double total, {required String currencyCode}) {
    return Row(
      children: [
        const Icon(Icons.attach_money, size: 16, color: Colors.purple),
        const SizedBox(width: 6),
        CustomText(
          "Total: ${CurrencyHelper.formatAmount(total, currencyCode: currencyCode)}",
          fontSize: 13,
          fontWeight: FontWeight.w600,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  void _openCheckout(BuildContext context, String url) {
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(url));

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.purple,
            title: const CustomText(
              "Payments",
              color: Colors.white,
              fontSize: 18,
            ),
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: WebViewWidget(controller: controller),
        ),
      ),
    ).then((_) {
      controller.clearCache();
    });
  }
}
