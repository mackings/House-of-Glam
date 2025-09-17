import 'package:flutter/material.dart';
import 'package:hog/App/Home/Model/TransModel.dart';
import 'package:hog/components/texts.dart';
import 'package:intl/intl.dart';

class TransactionCard extends StatelessWidget {
  final TransactionResponse txn;
  final VoidCallback onTap;

  const TransactionCard({super.key, required this.txn, required this.onTap});

  String formatAmount(int amount) {
    final formatter = NumberFormat("#,###");
    return formatter.format(amount);
  }

  String formatDate(String date) {
    return DateFormat('MMM d, h:mm a').format(DateTime.parse(date));
  }

  @override
  Widget build(BuildContext context) {
    final isSuccess = txn.paymentStatus!.toLowerCase() == "success";

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade400, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Status Icon
            CircleAvatar(
              backgroundColor: isSuccess ? Colors.purple[50] : Colors.red[50],
              child: Icon(
                isSuccess ? Icons.check_circle : Icons.error,
                color: isSuccess ? Colors.purple : Colors.red,
              ),
            ),
            const SizedBox(width: 14),

            // Transaction details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    "₦${formatAmount(txn.amountPaid!.toInt())}",
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),

                  const SizedBox(height: 6),
                  CustomText(
                    txn.orderStatus.toString(),
                    color: Colors.black87,
                    fontSize: 13,
                  ),
                  const SizedBox(height: 4),

                  // Date with icon
                  Row(
                    children: [
                      const Icon(
                        Icons.date_range,
                        size: 14,
                        color: Colors.purple,
                      ),
                      const SizedBox(width: 4),
                      CustomText(
                        formatDate(txn.createdAt.toString()),
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Status Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isSuccess ? Colors.purple[50] : Colors.red[50],
                borderRadius: BorderRadius.circular(20),
              ),
              child: CustomText(
                txn.paymentStatus.toString(),
                color: isSuccess ? Colors.purple : Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
