import 'package:flutter/material.dart';
import 'package:hog/App/Home/Model/reviewModel.dart';
import 'package:hog/App/Home/Views/Offers/Api/OfferService.dart';
import 'package:hog/App/Home/Views/Offers/Views/OfferHome.dart';
import 'package:hog/App/Home/Views/Offers/Widgets/Offersheet.dart';
import 'package:hog/components/Navigator.dart';
import 'package:hog/components/button.dart';
import 'package:hog/components/texts.dart';
import 'package:hog/constants/currency.dart';
import 'package:intl/intl.dart';

class QuotationCard extends StatelessWidget {
  final Review review;
  final VoidCallback onHireDesigner; // ✅ keep existing
  final void Function(int amount) onCompletePayment; // ✅ new with amount

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

    // 🔹 decide amount
    int paymentAmount = 0;
    if (isPartPayment) {
      paymentAmount = review.amountToPay; // finishing balance
    } else if (isQuote) {
      paymentAmount = review.totalCost; // full cost
    }

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
          // 🔹 Avatar + Name + Status
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
                color:
                    isPartPayment
                        ? Colors.grey
                        : isFullPayment
                        ? Colors.purple
                        : Colors.green,
                size: 18,
              ),
            ],
          ),
          const SizedBox(height: 10),

          // 🔹 Delivery & Reminder
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

          // 🔹 Comment
          if (review.comment.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: CustomText(
                review.comment,
                fontSize: 13,
                overflow: TextOverflow.visible,
              ),
            ),

          // 🔹 Costs with icons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.checkroom, size: 16, color: Colors.purple),
                  const SizedBox(width: 4),
                  CustomText(
                    "${currencySymbol}${formatAmount(review.materialTotalCost)}",
                    fontSize: 12,
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.handyman, size: 16, color: Colors.purple),
                  const SizedBox(width: 4),
                  CustomText(
                    "Charge: $currencySymbol${formatAmount(review.workmanshipTotalCost)}",
                    fontSize: 12,
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(
                    Icons.attach_money,
                    size: 16,
                    color: Colors.purple,
                  ),
                  const SizedBox(width: 4),
                  CustomText(
                    "Total: $currencySymbol${formatAmount(review.totalCost)}",
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 25),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed:
                  isFullPayment
                      ? null // disabled
                      : isQuote
                      ? onHireDesigner // hire first if it's still a quote
                      : () => onCompletePayment(
                        paymentAmount,
                      ), // pay balance / full
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isFullPayment
                        ? Colors.grey
                        : isPartPayment
                        ? Colors.black
                        : Colors.purple,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: CustomText(
                isFullPayment
                    ? "Paid"
                    : isPartPayment
                    ? "Finish Payment (₦${formatAmount(review.amountToPay)})"
                    : isQuote
                    ? "Hire Designer"
                    : "Pay in Full (₦${formatAmount(review.totalCost)})",
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          SizedBox(height: 10),

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
      ),
    );
  }
}
