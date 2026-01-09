import 'package:flutter/material.dart';
import 'package:hog/TailorApp/Home/Model/materialModel.dart';
import 'package:hog/components/texts.dart';
import 'package:timeago/timeago.dart' as timeago;

class TailorMaterialCard extends StatelessWidget {
  final TailorMaterialItem material;
  final VoidCallback onTap;

  const TailorMaterialCard({
    super.key,
    required this.material,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final createdAt = DateTime.parse(material.createdAt);
    final imgUrl =
        material.sampleImage.isNotEmpty
            ? material.sampleImage.first
            : "https://via.placeholder.com/150";
    final customerName =
        material.userId.fullName.isNotEmpty
            ? material.userId.fullName
            : "Unknown Customer";
    final measurementCount = material.measurement.isNotEmpty
        ? material.measurement.first.values.length
        : 0;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Material Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.network(
                      imgUrl,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: _StatusChip(isDelivered: material.isDelivered),
                  ),
                ],
              ),
            ),

            // Material Info
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    material.attireType,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    textAlign: TextAlign.left,
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _InfoChip(text: material.brand),
                      _InfoChip(text: material.color),
                      _InfoChip(text: material.clothMaterial),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.person, size: 16, color: Colors.black54),
                      const SizedBox(width: 6),
                      Expanded(
                        child: CustomText(
                          customerName,
                          fontSize: 13,
                          color: Colors.black87,
                          textAlign: TextAlign.left,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.straighten,
                        size: 16,
                        color: Colors.black54,
                      ),
                      const SizedBox(width: 6),
                      CustomText(
                        "$measurementCount measurements",
                        fontSize: 13,
                        color: Colors.black87,
                        textAlign: TextAlign.left,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  CustomText(
                    timeago.format(createdAt),
                    fontSize: 12,
                    color: Colors.grey[600],
                    textAlign: TextAlign.left,
                  ),

                  // CustomText(
                  //   material.price != null ? "₦${material.price}" : "No price",
                  //   fontSize: 15,
                  //   fontWeight: FontWeight.bold,
                  //   color: Colors.purple,
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _InfoChip({required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: CustomText(
        text.isNotEmpty ? text : "N/A",
        fontSize: 11,
        color: Colors.grey[700],
        textAlign: TextAlign.left,
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final bool isDelivered;

  const _StatusChip({required this.isDelivered});

  @override
  Widget build(BuildContext context) {
    final bg = isDelivered ? Colors.green.shade50 : Colors.orange.shade50;
    final border = isDelivered ? Colors.green.shade200 : Colors.orange.shade200;
    final fg = isDelivered ? Colors.green.shade700 : Colors.orange.shade700;
    final label = isDelivered ? "Delivered" : "Pending";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      child: CustomText(
        label,
        fontSize: 11,
        color: fg,
        fontWeight: FontWeight.w600,
        textAlign: TextAlign.left,
      ),
    );
  }
}
