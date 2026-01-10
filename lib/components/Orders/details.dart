import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:hog/App/Home/Model/historymodel.dart';
import 'package:hog/components/texts.dart';

class OrderDetailsSheet extends StatelessWidget {
  final MaterialReview material;

  const OrderDetailsSheet({super.key, required this.material});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      maxChildSize: 0.9,
      minChildSize: 0.5,
      builder: (context, controller) {
        return SingleChildScrollView(
          controller: controller,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const CustomText(
                    "Order Details",
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Carousel
              if (material.sampleImage.isNotEmpty)
                CarouselSlider(
                  options: CarouselOptions(
                    height: 220,
                    enlargeCenterPage: true,
                    autoPlay: true,
                  ),
                  items:
                      material.sampleImage
                          .map(
                            (img) => ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.network(img, fit: BoxFit.cover),
                            ),
                          )
                          .toList(),
                ),
              const SizedBox(height: 20),

              // Chips
              Wrap(
                spacing: 8,
                children: [
                  _chip(material.attireType),
                  _chip(material.clothMaterial),
                  _chip(material.color),
                  _chip(material.brand),
                ],
              ),
              const Divider(height: 24),

              // Measurements
              const CustomText("Measurements", fontWeight: FontWeight.bold),
              const SizedBox(height: 8),
              ...material.measurement.map(
                (m) => Card(
                  color: Colors.grey[100],
                  margin: const EdgeInsets.only(bottom: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomText("Chest: ${m.chest ?? "-"}"),
                            CustomText("Waist: ${m.waist ?? "-"}"),
                            CustomText("Hip: ${m.hip ?? "-"}"),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomText("Shoulder: ${m.shoulder ?? "-"}"),
                            CustomText("Arm: ${m.armLength ?? "-"}"),
                            CustomText("Sleeve: ${m.sleeveLength ?? "-"}"),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              if (material.specialInstructions != null) ...[
                const SizedBox(height: 16),
                const CustomText(
                  "Special Instructions",
                  fontWeight: FontWeight.bold,
                ),
                const SizedBox(height: 6),
                CustomText(material.specialInstructions ?? ""),
              ],

              const SizedBox(height: 20),
              // ElevatedButton.icon(
              //   style: ElevatedButton.styleFrom(
              //     backgroundColor: Colors.purple,
              //     minimumSize: const Size(double.infinity, 50),
              //     shape: RoundedRectangleBorder(
              //       borderRadius: BorderRadius.circular(12),
              //     ),
              //   ),
              //   onPressed: () {},
              //   icon: const Icon(Icons.check_circle, color: Colors.white),
              //   label: const CustomText("Hire Designer", color: Colors.white),
              // ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _chip(String text) {
    return Chip(
      label: CustomText(text, color: Colors.purple, fontSize: 12),
      backgroundColor: Colors.purple.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}
