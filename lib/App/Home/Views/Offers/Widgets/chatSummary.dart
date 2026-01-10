import 'package:flutter/material.dart';
import 'package:hog/components/texts.dart';
import 'package:hog/constants/currency.dart';
import 'package:hog/constants/currencyHelper.dart';

class ChatSummaryCard extends StatelessWidget {
  final Map<String, dynamic> offer, user, vendor;
  final String Function(double) formatAmount;
  final String Function(String?) formatDate;

  const ChatSummaryCard({
    super.key,
    required this.offer,
    required this.user,
    required this.vendor,
    required this.formatAmount,
    required this.formatDate,
  });

  Color _statusColor(String status) {
    final s = status.toLowerCase();
    if (s.contains('accepted')) return Colors.green;
    if (s.contains('rejected')) return Colors.red;
    if (s.contains('counter')) return Colors.orange;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    final materialNGN =
        int.tryParse(offer["materialTotalCost"]?.toString() ?? "0") ?? 0;
    final workmanshipNGN =
        int.tryParse(offer["workmanshipTotalCost"]?.toString() ?? "0") ?? 0;
    final status = offer["status"]?.toString() ?? "pending";

    return FutureBuilder<Map<String, double>>(
      future: _convertAmounts(materialNGN, workmanshipNGN),
      builder: (context, snapshot) {
        final displayMaterial =
            snapshot.data?['material'] ?? materialNGN.toDouble();
        final displayWorkmanship =
            snapshot.data?['workmanship'] ?? workmanshipNGN.toDouble();

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.grey.shade50, Colors.grey.shade100],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar with gradient border
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.purple, Colors.purple.shade300],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: CircleAvatar(
                  radius: 22,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    color: Colors.purple.shade700,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Message bubble
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purple.withOpacity(0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with name and status
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Icon(
                                  Icons.store,
                                  size: 14,
                                  color: Colors.purple.shade700,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: CustomText(
                                    vendor["businessName"] ??
                                        user["fullName"] ??
                                        "Unknown User",
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.purple.shade700,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Status badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: _statusColor(status).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _statusColor(status).withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: _statusColor(status),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                CustomText(
                                  status.toUpperCase(),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: _statusColor(status),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // Comment
                      CustomText(
                        offer["comment"] ?? "No comment provided",
                        fontSize: 13.5,
                        color: Colors.black87,
                        // height: 1.4,
                      ),

                      const SizedBox(height: 12),

                      // Divider
                      Container(
                        height: 1,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.grey.shade200,
                              Colors.grey.shade100,
                              Colors.grey.shade200,
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Cost breakdown with icons
                      Row(
                        children: [
                          Expanded(
                            child: _buildCostItem(
                              icon: Icons.checkroom,
                              label: "Material",
                              amount: displayMaterial,
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: Colors.grey.shade200,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildCostItem(
                              icon: Icons.handyman,
                              label: "Workmanship",
                              amount: displayWorkmanship,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Total amount (prominent)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.purple.shade50,
                              Colors.purple.shade100.withOpacity(0.3),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.attach_money,
                                  size: 18,
                                  color: Colors.purple.shade700,
                                ),
                                const SizedBox(width: 6),
                                CustomText(
                                  "Total Amount",
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.purple.shade700,
                                ),
                              ],
                            ),
                            CustomText(
                              "$currencySymbol${formatAmount(displayMaterial + displayWorkmanship)}",
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.purple.shade700,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Timestamp
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 12,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(width: 4),
                          CustomText(
                            formatDate(offer["createdAt"]),
                            fontSize: 10.5,
                            color: Colors.grey.shade600,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCostItem({
    required IconData icon,
    required String label,
    required double amount,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: Colors.purple.shade400),
            const SizedBox(width: 6),
            CustomText(
              label,
              fontSize: 11,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ],
        ),
        const SizedBox(height: 4),
        CustomText(
          "$currencySymbol${formatAmount(amount)}",
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: Colors.black87,
        ),
      ],
    );
  }

  Future<Map<String, double>> _convertAmounts(
    int materialNGN,
    int workmanshipNGN,
  ) async {
    return {
      'material': await CurrencyHelper.convertFromNGN(materialNGN),
      'workmanship': await CurrencyHelper.convertFromNGN(workmanshipNGN),
    };
  }
}
