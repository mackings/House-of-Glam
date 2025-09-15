import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:hog/TailorApp/Home/Model/materialModel.dart';
import 'package:hog/components/button.dart';
import 'package:hog/components/texts.dart';
import 'package:intl/intl.dart';



class TailorMaterialDetailSheet extends StatelessWidget {
  final TailorMaterialItem material;

  const TailorMaterialDetailSheet({super.key, required this.material});

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat("dd MMM, yyyy").format(
  DateTime.parse(material.createdAt),
);


    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      minChildSize: 0.6,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // drag handle
                Center(
                  child: Container(
                    width: 50,
                    height: 6,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                // image carousel
                if (material.sampleImage.isNotEmpty)
                  CarouselSlider(
                    options: CarouselOptions(
                      height: 200,
                      enlargeCenterPage: true,
                      enableInfiniteScroll: false,
                      viewportFraction: 0.9,
                    ),
                    items: material.sampleImage.map((img) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          img,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      );
                    }).toList(),
                  )
                else
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      "https://via.placeholder.com/300",
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),

                const SizedBox(height: 16),

                // Title
                CustomText(
                  material.attireType,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),

                Divider(height: 24, thickness: 1, color: Colors.grey[300]),

                // Details with icons
                _buildDetailRow(Icons.store, "Brand", material.brand),
                _buildDetailRow(Icons.color_lens, "Color", material.color),
                _buildDetailRow(Icons.texture, "Material", material.clothMaterial),

                Divider(height: 24, thickness: 1, color: Colors.grey[300]),

                _buildDetailRow(Icons.person, "Customer", material.userId.fullName),
                _buildDetailRow(Icons.email, "Email", material.userId.email),

                Divider(height: 24, thickness: 1, color: Colors.grey[300]),

                _buildDetailRow(Icons.attach_money, "Price", "₦${material.price ?? 'N/A'}",
                    valueColor: Colors.purple, isBold: true),
                _buildDetailRow(
                  Icons.local_shipping,
                  "Delivered",
                  material.isDelivered ? "Yes" : "No",
                ),
                _buildDetailRow(Icons.calendar_today, "Posted On", formattedDate),

                if (material.specialInstructions != null &&
                    material.specialInstructions!.isNotEmpty) ...[
                  Divider(height: 24, thickness: 1, color: Colors.grey[300]),
                  _buildDetailRow(Icons.note, "Notes", material.specialInstructions!),
                ],

                const SizedBox(height: 24),

                // Submit Quotation Button
                CustomButton(
                  title: "Submit Quotation",
                  isOutlined: false,
                  onPressed: () {
                    Navigator.pop(context); // close sheet
                    // TODO: handle submit quotation logic here
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  Widget _buildDetailRow(IconData icon, String label, String? value,
      {Color? valueColor, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.purple),
         // const SizedBox(width: 10),
          Expanded(
            child: CustomText(
              "$label: ${value ?? 'N/A'}",
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}