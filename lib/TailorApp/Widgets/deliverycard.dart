import 'package:flutter/material.dart';
import 'package:hog/TailorApp/Home/Model/deliveryModel.dart';
import 'package:hog/components/texts.dart';


class DeliveryCard extends StatelessWidget {
  final TailorTracking tracking;
  final VoidCallback onTap;

  const DeliveryCard({super.key, required this.tracking, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDelivered = tracking.isDelivered;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.purple, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              isDelivered ? Icons.check_circle : Icons.pending_actions,
              color: isDelivered ? Colors.green : Colors.purple,
              size: 30,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    "Tracking #${tracking.trackingNumber}",
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  const SizedBox(height: 4),
                  CustomText(
                    tracking.material.attireType,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                  CustomText(
                    tracking.material.brand,
                    fontSize: 13,
                    color: Colors.grey[700],
                  ),
                ],
              ),
            ),

            // 🔹 Delivery Status Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isDelivered ? Colors.green[100] : Colors.purple[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Icon(
                    isDelivered ? Icons.check : Icons.local_shipping,
                    size: 16,
                    color: isDelivered ? Colors.green : Colors.purple,
                  ),
                  const SizedBox(width: 4),
                  CustomText(
                    isDelivered ? "Delivered" : "Pending",
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDelivered ? Colors.green : Colors.purple,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
