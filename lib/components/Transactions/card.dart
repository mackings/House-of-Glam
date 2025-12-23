import 'package:flutter/material.dart';
import 'package:hog/App/Home/Model/TransModel.dart';
import 'package:hog/components/texts.dart';
import 'package:hog/constants/currency.dart';
import 'package:intl/intl.dart';





class TransactionCard extends StatelessWidget {
  final TransactionResponse txn;
  final double convertedAmount;
  final VoidCallback onTap;

  const TransactionCard({
    super.key,
    required this.txn,
    required this.convertedAmount,
    required this.onTap,
  });

  String formatAmount(double amount) {
    final formatter = NumberFormat("#,###.##");
    return formatter.format(amount);
  }

  String formatDate(String date) {
    return DateFormat('MMM d, h:mm a').format(DateTime.parse(date));
  }

  // ✅ Get transaction title based on type
  String getTransactionTitle() {
    if (txn.isBankTransfer) {
      return txn.title ?? "Bank Transfer";
    } else if (txn.cartItems.isNotEmpty) {
      return "Order Payment";
    } else {
      return "Transaction";
    }
  }

  // ✅ Get subtitle based on transaction type
  String getSubtitle() {
    if (txn.isBankTransfer) {
      return "${txn.bankName ?? 'Bank'} • ${txn.accountNumber ?? ''}";
    } else if (txn.orderStatus != null) {
      return txn.orderStatus!;
    } else {
      return "Payment";
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Handle both paymentStatus and status fields
    final statusField = txn.paymentStatus ?? txn.status ?? "pending";
    final isSuccess = statusField.toLowerCase() == "success" || 
                      statusField.toLowerCase() == "successfull";

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
            // Status Icon - different for bank transfers
            CircleAvatar(
              backgroundColor: isSuccess ? Colors.purple[50] : Colors.red[50],
              child: Icon(
                txn.isBankTransfer
                    ? (isSuccess ? Icons.account_balance : Icons.error)
                    : (isSuccess ? Icons.check_circle : Icons.error),
                color: isSuccess ? Colors.purple : Colors.red,
              ),
            ),
            const SizedBox(width: 14),

            // Transaction details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ✅ Amount in user's currency
                  CustomText(
                    "$currencySymbol${formatAmount(convertedAmount)}",
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  const SizedBox(height: 6),
                  
                  // ✅ Transaction title
                  CustomText(
                    getTransactionTitle(),
                    color: Colors.black87,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  const SizedBox(height: 2),
                  
                  // ✅ Subtitle
                  CustomText(
                    getSubtitle(),
                    color: Colors.grey[600],
                    fontSize: 12,
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
                statusField,
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
