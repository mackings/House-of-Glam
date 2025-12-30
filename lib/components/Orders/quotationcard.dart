import 'package:flutter/material.dart';
import 'package:hog/App/Home/Model/reviewModel.dart';
import 'package:hog/App/Home/Views/Offers/Api/OfferService.dart';
import 'package:hog/App/Home/Views/Offers/Widgets/Offersheet.dart';
import 'package:hog/components/Orders/PaymentOp.dart';
import 'package:hog/components/button.dart';
import 'package:hog/components/texts.dart';
import 'package:hog/constants/currencyHelper.dart';
import 'package:intl/intl.dart';
import 'package:webview_flutter/webview_flutter.dart';




class QuotationCard extends StatelessWidget {
  final Review review;
  final VoidCallback onHireDesigner;
  final void Function(int amount) onCompletePayment;

  const QuotationCard({
    super.key,
    required this.review,
    required this.onHireDesigner,
    required this.onCompletePayment,
  });

  String formatAmount(int amount) {
    final formatter = NumberFormat('#,###');
    return formatter.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final bool isPartPayment = review.status == "part payment";
    final bool isFullPayment = review.status == "full payment";
    final bool isQuote = review.status == "quote";

    int paymentAmount = 0;
    if (isPartPayment) {
      paymentAmount = review.amountToPay;
    } else if (isQuote) {
      paymentAmount = review.totalCost;
    }

    return FutureBuilder<Map<String, double>>(
      future: _convertPrices(),
      builder: (context, snapshot) {
        final displayTotal = snapshot.data?['total'] ?? review.totalCost.toDouble();
        final displayMaterial = snapshot.data?['material'] ?? review.materialTotalCost.toDouble();
        final displayWorkmanship = snapshot.data?['workmanship'] ?? review.workmanshipTotalCost.toDouble();
        final displayAmountToPay = snapshot.data?['amountToPay'] ?? review.amountToPay.toDouble();

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

              // Costs
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.checkroom, size: 16, color: Colors.purple),
                      const SizedBox(width: 4),
                      CustomText(
                        CurrencyHelper.formatAmount(displayMaterial),
                        fontSize: 12,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.handyman, size: 16, color: Colors.purple),
                      const SizedBox(width: 4),
                      CustomText(
                        "Charge: ${CurrencyHelper.formatAmount(displayWorkmanship)}",
                        fontSize: 12,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.attach_money, size: 16, color: Colors.purple),
                      const SizedBox(width: 4),
                      CustomText(
                        "Total: ${CurrencyHelper.formatAmount(displayTotal)}",
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ],
                  ),
                ],
              ),
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
                              "Balance: ${CurrencyHelper.formatAmount(displayAmountToPay)}",
                              fontSize: 11,
                              color: Colors.orange.shade700,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              // Payment Buttons
              if (isQuote)
                // Show "Make Offer" button for quotes (offer not yet accepted)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onHireDesigner,
                    icon: const Icon(Icons.handshake, size: 18, color: Colors.white),
                    label: const CustomText(
                      "Hire",
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
                )
              else if (isFullPayment)
                // Show "Paid" button (disabled)
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
                )
              else
                // Show both "Pay in Full" and "Part Payment" buttons
                Column(
                  children: [
                    // Pay in Full button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => onCompletePayment(paymentAmount),
                        icon: const Icon(Icons.payment, size: 18, color: Colors.white),
                        label: CustomText(
                          isPartPayment
                              ? "Complete Payment (${CurrencyHelper.formatAmount(displayAmountToPay)})"
                              : "Pay in Full (${CurrencyHelper.formatAmount(displayTotal)})",
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
                    
                    // ✅ Part Payment button - opens modal
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
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
                                  // Close modal first
                                  Navigator.of(ctx).pop();
                                  // Wait a bit for modal to close
                                  await Future.delayed(
                                    const Duration(milliseconds: 250),
                                  );
                                  // Then navigate to checkout
                                  if (context.mounted) {
                                    _openCheckout(context, url);
                                  }
                                },
                              );
                            },
                          );
                        },
                        icon: Icon(Icons.payments, size: 18, color: Colors.purple.shade700),
                        label: CustomText(
                          "Make Part Payment",
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

              // Make Offer button (only for quotes)
              if (isQuote) ...[
                const SizedBox(height: 10),
                CustomButton(
                  title: "Make Offer",
                  onPressed: () async {
                    final result = await ReusableOfferSheet.show(
                      context,
                      onSubmit: (comment, material, work) async {
                        final res = await OfferService.makeOffer(
                          reviewId: review.id,
                          comment: comment,
                          materialTotalCost: material,
                          workmanshipTotalCost: work,
                        );
                        return res;
                      },
                    );

                    if (result?["success"] == true) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Offer submitted successfully!"),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
                  isOutlined: true,
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  // ✅ Helper method to open checkout WebView
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

  Future<Map<String, double>> _convertPrices() async {
    return {
      'total': await CurrencyHelper.convertFromNGN(review.totalCost),
      'material': await CurrencyHelper.convertFromNGN(review.materialTotalCost),
      'workmanship': await CurrencyHelper.convertFromNGN(review.workmanshipTotalCost),
      'amountToPay': await CurrencyHelper.convertFromNGN(review.amountToPay),
    };
  }
}



// class QuotationCard extends StatelessWidget {
//   final Review review;
//   final VoidCallback onHireDesigner; // ✅ keep existing
//   final void Function(int amount) onCompletePayment; // ✅ new with amount

//   const QuotationCard({
//     super.key,
//     required this.review,
//     required this.onHireDesigner,
//     required this.onCompletePayment,
//   });

//   String formatAmount(int amount) {
//     final formatter = NumberFormat('#,###');
//     return formatter.format(amount);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final bool isPartPayment = review.status == "part payment";
//     final bool isFullPayment = review.status == "full payment";
//     final bool isQuote = review.status == "quote";

//     // 🔹 decide amount
//     int paymentAmount = 0;
//     if (isPartPayment) {
//       paymentAmount = review.amountToPay; // finishing balance
//     } else if (isQuote) {
//       paymentAmount = review.totalCost; // full cost
//     }

//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(14),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black12.withOpacity(0.05),
//             blurRadius: 8,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // 🔹 Avatar + Name + Status
//           Row(
//             children: [
//               CircleAvatar(
//                 backgroundColor: Colors.purple.shade100,
//                 child: Text(
//                   review.user.fullName.isNotEmpty
//                       ? review.user.fullName[0].toUpperCase()
//                       : "?",
//                   style: const TextStyle(
//                     color: Colors.purple,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 10),
//               Expanded(
//                 child: CustomText(
//                   review.user.fullName,
//                   fontSize: 14,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//               Icon(
//                 isQuote
//                     ? Icons.schedule
//                     : isPartPayment
//                     ? Icons.check_circle_outline
//                     : Icons.check_circle,
//                 color:
//                     isPartPayment
//                         ? Colors.grey
//                         : isFullPayment
//                         ? Colors.purple
//                         : Colors.green,
//                 size: 18,
//               ),
//             ],
//           ),
//           const SizedBox(height: 10),

//           // 🔹 Delivery & Reminder
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               CustomText(
//                 "Delivery: ${DateFormat("dd MMM yyyy").format(review.deliveryDate)}",
//                 fontSize: 12,
//                 color: Colors.black54,
//               ),
//               CustomText(
//                 "Reminder: ${DateFormat("dd MMM yyyy").format(review.reminderDate)}",
//                 fontSize: 12,
//                 color: Colors.black54,
//               ),
//             ],
//           ),

//           const SizedBox(height: 10),

//           // 🔹 Comment
//           if (review.comment.isNotEmpty)
//             Padding(
//               padding: const EdgeInsets.only(bottom: 12),
//               child: CustomText(
//                 review.comment,
//                 fontSize: 13,
//                 overflow: TextOverflow.visible,
//               ),
//             ),

//           // 🔹 Costs with icons
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Row(
//                 children: [
//                   const Icon(Icons.checkroom, size: 16, color: Colors.purple),
//                   const SizedBox(width: 4),
//                   CustomText(
//                     "${currencySymbol}${formatAmount(review.materialTotalCost)}",
//                     fontSize: 12,
//                   ),
//                 ],
//               ),
//               Row(
//                 children: [
//                   const Icon(Icons.handyman, size: 16, color: Colors.purple),
//                   const SizedBox(width: 4),
//                   CustomText(
//                     "Charge: $currencySymbol${formatAmount(review.workmanshipTotalCost)}",
//                     fontSize: 12,
//                   ),
//                 ],
//               ),
//               Row(
//                 children: [
//                   const Icon(
//                     Icons.attach_money,
//                     size: 16,
//                     color: Colors.purple,
//                   ),
//                   const SizedBox(width: 4),
//                   CustomText(
//                     "Total: $currencySymbol${formatAmount(review.totalCost)}",
//                     fontSize: 12,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ],
//               ),
//             ],
//           ),
//           const SizedBox(height: 25),

//           SizedBox(
//             width: double.infinity,
//             child: ElevatedButton(
//               onPressed:
//                   isFullPayment
//                       ? null // disabled
//                       : isQuote
//                       ? onHireDesigner // hire first if it's still a quote
//                       : () => onCompletePayment(
//                         paymentAmount,
//                       ), // pay balance / full
//               style: ElevatedButton.styleFrom(
//                 backgroundColor:
//                     isFullPayment
//                         ? Colors.grey
//                         : isPartPayment
//                         ? Colors.black
//                         : Colors.purple,
//                 padding: const EdgeInsets.symmetric(vertical: 10),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//               child: CustomText(
//                 isFullPayment
//                     ? "Paid"
//                     : isPartPayment
//                     ? "Finish Payment (₦${formatAmount(review.amountToPay)})"
//                     : isQuote
//                     ? "Hire Designer"
//                     : "Pay in Full (₦${formatAmount(review.totalCost)})",
//                 fontSize: 14,
//                 color: Colors.white,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),

//           SizedBox(height: 10),

//           CustomButton(
//             title: "Make Offer",
//             onPressed: () async {
//               final result = await ReusableOfferSheet.show(
//                 context,
//                 onSubmit: (comment, material, work) async {
//                   final res = await OfferService.makeOffer(
//                     reviewId: review.id,
//                     comment: comment,
//                     materialTotalCost: material,
//                     workmanshipTotalCost: work,
//                   );
//                   return res;
//                 },
//               );

//               if (result?["success"] == true) {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(
//                     content: Text("Offer submitted successfully!"),
//                     backgroundColor: Colors.green,
//                   ),
//                 );
//               }
//             },

//             isOutlined: true,
//           ),
//         ],
//       ),
//     );
//   }
// }
