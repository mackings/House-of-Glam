import 'package:flutter/material.dart';
import 'package:hog/TailorApp/Home/Model/materialModel.dart';
import 'package:hog/components/texts.dart';

class TailorMaterialDetailSheet extends StatelessWidget {
  final TailorMaterialItem material;

  const TailorMaterialDetailSheet({super.key, required this.material});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      builder: (context, scrollController) => SingleChildScrollView(
        controller: scrollController,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 5,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            CustomText(material.attireType,
                fontSize: 18, fontWeight: FontWeight.bold),
            const SizedBox(height: 8),
            CustomText("Brand: ${material.brand}", fontSize: 14),
            CustomText("Color: ${material.color}", fontSize: 14),
            CustomText("Material: ${material.clothMaterial}", fontSize: 14),
            const SizedBox(height: 8),
            CustomText("👤 Customer: ${material.userId.fullName}",
                fontSize: 14),
            CustomText("📧 Email: ${material.userId.email}", fontSize: 14),
            const SizedBox(height: 8),
            CustomText("💰 Price: ₦${material.price ?? 'N/A'}",
                fontSize: 14, color: Colors.purple),
            const SizedBox(height: 8),
            CustomText("📦 Delivered: ${material.isDelivered ? 'Yes' : 'No'}",
                fontSize: 14),
            const SizedBox(height: 12),
            if (material.specialInstructions != null)
              CustomText("📝 Notes: ${material.specialInstructions!}",
                  fontSize: 14),
          ],
        ),
      ),
    );
  }
}
