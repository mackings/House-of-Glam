import 'package:flutter/material.dart';
import 'package:hog/App/Home/Model/reviewModel.dart';
import 'package:hog/components/texts.dart';
import 'package:intl/intl.dart';



class QuotationCard extends StatelessWidget {
  final Review review;
  final VoidCallback onHireDesigner;

  const QuotationCard({
    super.key,
    required this.review,
    required this.onHireDesigner,
  });

  String formatAmount(int amount) {
    final formatter = NumberFormat('#,###');
    return formatter.format(amount);
  }

  @override
  Widget build(BuildContext context) {
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
          // Top Row: Avatar + Name + Status
          Row(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.purple.shade100,
                    child: Text(
                      review.user.fullName.isNotEmpty
                          ? review.user.fullName[0].toUpperCase()
                          : "?",
                      style: const TextStyle(color: Colors.purple, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
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
                review.status == "pending"
                    ? Icons.schedule
                    : review.status == "quote"
                        ? Icons.request_quote
                        : Icons.check_circle,
                color: review.status == "pending"
                    ? Colors.orange
                    : review.status == "quote"
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

          // Comment in ListTile
          if (review.comment.isNotEmpty)
Row(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    const Icon(Icons.comment, color: Colors.purple, size: 18),
    const SizedBox(width: 8),
    Expanded(
      child: CustomText(
        review.comment,
        fontSize: 13,
       // softWrap: true,
        overflow: TextOverflow.visible,
      ),
    ),
  ],
),

          const SizedBox(height: 12),

          // Costs with icons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.checkroom, size: 16, color: Colors.purple),
                  const SizedBox(width: 4),
                  CustomText(
                    "₦${formatAmount(review.materialTotalCost)}",
                    fontSize: 12,
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.handyman, size: 16, color: Colors.purple),
                  const SizedBox(width: 4),
                  CustomText(
                    "Charge: ₦${formatAmount(review.workmanshipTotalCost)}",
                    fontSize: 12,
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.attach_money, size: 16, color: Colors.purple),
                  const SizedBox(width: 4),
                  CustomText(
                    "Total: ₦${formatAmount(review.totalCost)}",
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 25),

          // Hire Designer Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onHireDesigner,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const CustomText(
                "Hire Designer",
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

