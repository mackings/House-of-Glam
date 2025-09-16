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
    final imgUrl = material.sampleImage.isNotEmpty
        ? material.sampleImage.first
        : "https://via.placeholder.com/150";

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Material Image
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                imgUrl,
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

            // Material Info
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(material.attireType,
                      fontSize: 16, fontWeight: FontWeight.bold),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.checkroom, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      CustomText("${material.brand} • ${material.color}",
                          fontSize: 13, color: Colors.grey),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.person, size: 16, color: Colors.black54),
                      const SizedBox(width: 4),
                      CustomText(material.userId.fullName,
                          fontSize: 13, color: Colors.black87),
                    ],
                  ),
                  const SizedBox(height: 8),


CustomText(
  timeago.format(createdAt),
  fontSize: 14,
)


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
}