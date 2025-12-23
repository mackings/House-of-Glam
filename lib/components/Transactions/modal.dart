import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hog/App/Home/Model/TransModel.dart';
import 'package:hog/components/texts.dart';
import 'package:hog/constants/currency.dart';
import 'package:intl/intl.dart';




class TransactionDetailsModal extends StatelessWidget {
  final TransactionResponse txn;
  final double convertedAmount;

  const TransactionDetailsModal({
    super.key,
    required this.txn,
    required this.convertedAmount,
  });

  void copyReference(BuildContext context, String reference) {
    Clipboard.setData(ClipboardData(text: reference));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Reference copied to clipboard")),
    );
  }

  String formatAmount(double amount) {
    final formatter = NumberFormat("#,###.##");
    return formatter.format(amount);
  }

  String formatDate(String date) {
    return DateFormat('MMM d, yyyy • h:mm a').format(DateTime.parse(date));
  }

  @override
  Widget build(BuildContext context) {
    final isBankTransfer = txn.isBankTransfer;
    final statusField = txn.paymentStatus ?? txn.status ?? "pending";
    final isSuccess = statusField.toLowerCase() == "success" || 
                      statusField.toLowerCase() == "successful";

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          controller: controller,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              // Header with Amount
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.purple.shade700, Colors.purple.shade500],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Transaction Amount",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isSuccess
                                ? Colors.green.withOpacity(0.2)
                                : Colors.red.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            statusField,
                            style: TextStyle(
                              color: isSuccess ? Colors.greenAccent : Colors.redAccent,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "$currencySymbol${formatAmount(convertedAmount)}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        formatDate(txn.createdAt ?? ''),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Transaction Type Header
              CustomText(
                isBankTransfer ? "Bank Transfer Details" : "Order Details",
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              const SizedBox(height: 16),

              // Details Card
              if (isBankTransfer) ...[
                // ✅ Bank Transfer Details
                _buildDetailCard([
                  _DetailRow(
                    icon: Icons.title,
                    label: "Title",
                    value: txn.title ?? "N/A",
                  ),
                  _DetailRow(
                    icon: Icons.account_balance,
                    label: "Bank Name",
                    value: txn.bankName ?? "N/A",
                  ),
                  _DetailRow(
                    icon: Icons.person,
                    label: "Account Name",
                    value: txn.accountName ?? "N/A",
                  ),
                  _DetailRow(
                    icon: Icons.numbers,
                    label: "Account Number",
                    value: txn.accountNumber ?? "N/A",
                  ),
                  _DetailRow(
                    icon: Icons.tag,
                    label: "Reference",
                    value: txn.paymentReference ?? "N/A",
                    copyable: true,
                    onCopy: () => copyReference(
                      context,
                      txn.paymentReference ?? '',
                    ),
                  ),
                  if (txn.sessionId != null)
                    _DetailRow(
                      icon: Icons.confirmation_number,
                      label: "Session ID",
                      value: txn.sessionId!,
                    ),
                ]),
              ] else ...[
                // ✅ Order Details
                _buildDetailCard([
                  _DetailRow(
                    icon: Icons.tag,
                    label: "Reference",
                    value: txn.paymentReference ?? "N/A",
                    copyable: true,
                    onCopy: () => copyReference(
                      context,
                      txn.paymentReference ?? '',
                    ),
                  ),
                  _DetailRow(
                    icon: Icons.assignment_turned_in,
                    label: "Order Status",
                    value: txn.orderStatus ?? "N/A",
                  ),
                  _DetailRow(
                    icon: Icons.credit_card,
                    label: "Payment Method",
                    value: txn.paymentMethod ?? "N/A",
                  ),
                  _DetailRow(
                    icon: Icons.location_on,
                    label: "Delivery Address",
                    value: txn.deliveryAddress ?? "N/A",
                  ),
                ]),

                const SizedBox(height: 24),

                // Cart Items (only for orders)
                if (txn.cartItems.isNotEmpty) ...[
                  CustomText(
                    "Cart Items",
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  const SizedBox(height: 12),
                  ...txn.cartItems.map(
                    (item) => Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.purple.shade50,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.shopping_bag,
                            color: Colors.purple,
                            size: 24,
                          ),
                        ),
                        title: CustomText(
                          item.attireType ?? item.title ?? "Item",
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                        subtitle: CustomText(
                          "${item.color ?? ''} ${item.brand ?? item.clothMaterial ?? ''}".trim(),
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Sample Images
                  if (txn.cartItems.any((item) => item.sampleImage.isNotEmpty)) ...[
                    CustomText(
                      "Sample Images",
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 120,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: txn.cartItems.expand((item) {
                          return item.sampleImage.map(
                            (img) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  img,
                                  width: 120,
                                  height: 120,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    width: 120,
                                    height: 120,
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.image_not_supported),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ],
              ],

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailCard(List<_DetailRow> rows) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          for (int i = 0; i < rows.length; i++) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(
                    rows[i].icon,
                    color: Colors.purple,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          rows[i].label,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          rows[i].value,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (rows[i].copyable) ...[
                    IconButton(
                      icon: const Icon(Icons.copy, size: 18),
                      onPressed: rows[i].onCopy,
                      color: Colors.purple,
                    ),
                  ],
                ],
              ),
            ),
            if (i < rows.length - 1)
              Divider(height: 1, color: Colors.grey.shade300),
          ],
        ],
      ),
    );
  }
}

class _DetailRow {
  final IconData icon;
  final String label;
  final String value;
  final bool copyable;
  final VoidCallback? onCopy;

  _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.copyable = false,
    this.onCopy,
  });
}