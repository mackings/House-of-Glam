import 'package:flutter/material.dart';
import 'package:hog/App/Home/Model/TransModel.dart';
import 'package:hog/components/texts.dart';
import 'package:hog/constants/currency.dart';
import 'package:hog/theme/app_theme.dart';
import 'package:hog/utils/ui_label_formatter.dart';
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

  String getTransactionTitle() {
    if (txn.isBankTransfer) {
      return txn.title ?? "Bank Transfer";
    } else if (txn.cartItems.isNotEmpty) {
      return "Order Payment";
    } else {
      return "Transaction";
    }
  }

  String getSubtitle() {
    if (txn.isBankTransfer) {
      return "${txn.bankName ?? 'Bank'} • ${txn.accountNumber ?? ''}";
    } else if (txn.orderStatus != null) {
      return formatUiLabel(txn.orderStatus);
    } else {
      return "Payment";
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusField = txn.paymentStatus ?? txn.status ?? "pending";
    final isSuccess =
        statusField.toLowerCase() == "success" ||
        statusField.toLowerCase() == "successfull";
    final accent = isSuccess ? AppColors.success : AppColors.danger;
    final badge = isSuccess ? const Color(0xFFEAF8F1) : const Color(0xFFFFEEEE);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.border),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 18,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: badge,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                txn.isBankTransfer
                    ? (isSuccess
                        ? Icons.account_balance_outlined
                        : Icons.error_outline_rounded)
                    : (isSuccess
                        ? Icons.check_circle_outline_rounded
                        : Icons.error_outline_rounded),
                color: accent,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    "$currencySymbol${formatAmount(convertedAmount)}",
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    textAlign: TextAlign.left,
                  ),
                  const SizedBox(height: 6),
                  CustomText(
                    getTransactionTitle(),
                    color: AppColors.ink,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    textAlign: TextAlign.left,
                  ),
                  const SizedBox(height: 2),
                  CustomText(
                    getSubtitle(),
                    color: AppColors.subtext,
                    fontSize: 12,
                    textAlign: TextAlign.left,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.schedule_outlined,
                        size: 14,
                        color: AppColors.subtext,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: CustomText(
                          formatDate(txn.createdAt.toString()),
                          color: AppColors.subtext,
                          fontSize: 12,
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: badge,
                borderRadius: BorderRadius.circular(999),
              ),
              child: CustomText(
                formatUiLabel(statusField),
                color: accent,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
