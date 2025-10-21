import 'package:flutter/material.dart';
import 'package:hog/components/texts.dart';


class ChatSummaryCard extends StatelessWidget {
  final Map<String, dynamic> offer, user, vendor;
  final String currencySymbol;
  final String Function(dynamic) formatAmount;
  final String Function(String?) formatDate;

  const ChatSummaryCard({
    super.key,
    required this.offer,
    required this.user,
    required this.vendor,
    required this.currencySymbol,
    required this.formatAmount,
    required this.formatDate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: Colors.purple.shade100,
            child: Icon(Icons.person, color: Colors.purple.shade700),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(right: 40),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12.withOpacity(0.05),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    vendor["businessName"] ??
                        user["fullName"] ??
                        "Unknown User",
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.purple,
                  ),
                  const SizedBox(height: 6),
                  CustomText(
                    offer["comment"] ?? "No comment provided",
                    fontSize: 13.5,
                    color: Colors.black87,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomText(
                        "Material: $currencySymbol${formatAmount(offer["materialTotalCost"])}",
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                      CustomText(
                        "Work: $currencySymbol${formatAmount(offer["workmanshipTotalCost"])}",
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomText(
                        formatDate(offer["createdAt"]),
                        fontSize: 10.5,
                        color: Colors.black45,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.purple.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: CustomText(
                          offer["status"] ?? "-",
                          fontSize: 11,
                          color: Colors.purple.shade700,
                        ),
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
  }
}
