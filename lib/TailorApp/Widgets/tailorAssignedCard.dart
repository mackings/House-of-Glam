import 'package:flutter/material.dart';
import 'package:hog/TailorApp/Home/Model/AssignedMaterial.dart';
import 'package:hog/components/texts.dart';
import 'package:hog/constants/currencyHelper.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

class TailorAssignedCard extends StatelessWidget {
  final TailorAssignedMaterial item;
  final VoidCallback onTap;

  TailorAssignedCard({super.key, required this.item, required this.onTap});

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case "full payment":
        return Colors.purple;
      case "part payment":
        return Colors.grey;
      case "pending":
        return Colors.black;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final material = item.material;
    final createdAgo = timeago.format(item.createdAt);
    final deliveryDate =
        item.deliveryDate != null
            ? DateFormat("dd MMM").format(item.deliveryDate!)
            : "N/A";

    return FutureBuilder<Map<String, double>>(
      // ✅ Convert amounts once
      future: _convertAmounts(),
      builder: (context, snapshot) {
        final displayAmountPaid = snapshot.data?['amountPaid'] ?? 
            (item.amountPaid ?? 0).toDouble();
        final displayAmountToPay = snapshot.data?['amountToPay'] ?? 
            (item.amountToPay ?? 0).toDouble();

        return InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(14),
            margin: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.black12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row with image, title, and status
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        material.sampleImages.isNotEmpty
                            ? material.sampleImages.first
                            : "https://via.placeholder.com/120",
                        height: 80,
                        width: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            material.attireType,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.person,
                                size: 16,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: CustomText(
                                  item.user.fullName,
                                  fontSize: 13,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              const Icon(
                                Icons.business,
                                size: 16,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: CustomText(
                                  item.vendor.businessName,
                                  fontSize: 13,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Chip(
                      label: Text(
                        item.status,
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      backgroundColor: _statusColor(item.status),
                    ),
                  ],
                ),

                const Divider(height: 20),

                // ✅ Payment info with converted amounts
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomText(
                      "💰 Paid: ${CurrencyHelper.formatAmount(displayAmountPaid)}",
                      fontSize: 13,
                      color: Colors.black,
                    ),
                    CustomText(
                      "Balance: ${CurrencyHelper.formatAmount(displayAmountToPay)}",
                      fontSize: 13,
                      color: Colors.purple,
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Dates
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomText(
                      "📦 Delivery: $deliveryDate",
                      fontSize: 13,
                      color: Colors.black,
                    ),
                    CustomText(
                      "⏳ $createdAgo",
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ✅ No conversion needed - vendors see amounts in their own currency
  Future<Map<String, double>> _convertAmounts() async {
    // ✅ Vendors always see amounts in their own currency without conversion
    // Amounts are already stored in the correct currency (NGN for Nigerian vendors, USD for US/UK vendors)
    return {
      'amountPaid': (item.amountPaid ?? 0).toDouble(),
      'amountToPay': (item.amountToPay ?? 0).toDouble(),
    };
  }
}
