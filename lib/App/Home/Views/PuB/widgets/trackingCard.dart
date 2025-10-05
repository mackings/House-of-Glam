import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hog/App/Auth/Model/trackingmodel.dart';
import 'package:hog/components/texts.dart';

class TrackingCard extends StatelessWidget {
  final TrackingRecord record;
  final VoidCallback onTap;

  const TrackingCard({super.key, required this.record, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final images = record.material.sampleImages;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child:
                  images.isNotEmpty
                      ? Image.network(
                        images.first,
                        width: 55,
                        height: 55,
                        fit: BoxFit.cover,
                      )
                      : Container(
                        width: 55,
                        height: 55,
                        color: Colors.purple.shade50,
                        child: const Icon(
                          Icons.image_outlined,
                          color: Colors.purple,
                        ),
                      ),
            ),
            const SizedBox(width: 12),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tracking ID row with copy
                  Row(
                    children: [
                      Flexible(
                        child: CustomText(
                          "ID: ${record.trackingNumber}",
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(
                            ClipboardData(
                              text: record.trackingNumber.toString(),
                            ),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("📋 Tracking ID copied"),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                        child: const Icon(
                          Icons.copy,
                          size: 14,
                          color: Colors.purple,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  // Cloth
                  CustomText(
                    record.material.attireType,
                    fontSize: 13,
                    color: Colors.black87,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 6),

                  // Status
                  Row(
                    children: [
                      Icon(
                        record.isDelivered
                            ? Icons.check_circle_rounded
                            : Icons.local_shipping_rounded,
                        size: 16,
                        color:
                            record.isDelivered ? Colors.green : Colors.purple,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: CustomText(
                          record.isDelivered ? "Delivered" : "In Progress",
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color:
                              record.isDelivered ? Colors.green : Colors.purple,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Arrow
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.black26,
            ),
          ],
        ),
      ),
    );
  }
}
