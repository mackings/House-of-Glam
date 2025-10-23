import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:hog/TailorApp/Home/Model/materialModel.dart';
import 'package:hog/TailorApp/Widgets/Quotationmodal.dart';
import 'package:hog/components/button.dart';
import 'package:hog/components/texts.dart';
import 'package:hog/constants/currency.dart';
import 'package:intl/intl.dart';

class TailorMaterialDetailSheet extends StatefulWidget {
  final TailorMaterialItem material;

  const TailorMaterialDetailSheet({super.key, required this.material});

  @override
  State<TailorMaterialDetailSheet> createState() =>
      _TailorMaterialDetailSheetState();
}

class _TailorMaterialDetailSheetState extends State<TailorMaterialDetailSheet> {
  int _currentImage = 0;

  @override
  Widget build(BuildContext context) {
    final material = widget.material;
    String formattedDate = DateFormat(
      "dd MMM, yyyy",
    ).format(DateTime.parse(material.createdAt));

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

                // 🖼️ Image carousel with indicator
                if (material.sampleImage.isNotEmpty)
                  Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          _showFullScreenImage(context, material.sampleImage);
                        },
                        child: CarouselSlider.builder(
                          itemCount: material.sampleImage.length,
                          options: CarouselOptions(
                            height: 200,
                            enlargeCenterPage: true,
                            enableInfiniteScroll: false,
                            viewportFraction: 0.9,
                            onPageChanged: (index, reason) {
                              setState(() => _currentImage = index);
                            },
                          ),
                          itemBuilder: (context, index, realIndex) {
                            final img = material.sampleImage[index];
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                img,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                loadingBuilder: (context, child, progress) {
                                  if (progress == null) return child;
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return const Center(
                                    child: Icon(Icons.broken_image, size: 50),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          material.sampleImage.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4.0),
                            height: 8,
                            width: _currentImage == index ? 18 : 8,
                            decoration: BoxDecoration(
                              color:
                                  _currentImage == index
                                      ? Colors.purple
                                      : Colors.grey[400],
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
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
                _buildDetailRow(
                  Icons.texture,
                  "Material",
                  material.clothMaterial,
                ),

                Divider(height: 24, thickness: 1, color: Colors.grey[300]),

                _buildDetailRow(
                  Icons.person,
                  "Customer",
                  material.userId.fullName,
                ),

                //  _buildDetailRow(Icons.email, "Email", material.userId.email),
                Divider(height: 24, thickness: 1, color: Colors.grey[300]),

                _buildDetailRow(
                  Icons.attach_money,
                  "Price",
                  "$currencySymbol ${material.price ?? 'TBD'}",
                  valueColor: Colors.purple,
                  isBold: true,
                ),
                _buildDetailRow(
                  Icons.local_shipping,
                  "Delivered",
                  material.isDelivered ? "Yes" : "No",
                ),
                _buildDetailRow(
                  Icons.calendar_today,
                  "Posted On",
                  formattedDate,
                ),

                if (material.specialInstructions != null &&
                    material.specialInstructions!.isNotEmpty) ...[
                  Divider(height: 24, thickness: 1, color: Colors.grey[300]),
                  _buildDetailRow(
                    Icons.note,
                    "Notes",
                    material.specialInstructions!,
                  ),
                ],

                const SizedBox(height: 24),

                // Submit Quotation Button
                CustomButton(
                  title: "Submit Quotation",
                  isOutlined: false,
                  onPressed: () {
                    Navigator.pop(context);
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),
                      builder:
                          (_) => QuotationBottomSheet(materialId: material.id),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 📸 Fullscreen Image Viewer
  void _showFullScreenImage(BuildContext context, List<String> images) {
    showDialog(
      context: context,
      builder: (_) {
        PageController pageController = PageController(
          initialPage: _currentImage,
        );
        int activePage = _currentImage;

        return StatefulBuilder(
          builder: (context, setState) {
            return GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Scaffold(
                backgroundColor: Colors.black,
                body: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    PageView.builder(
                      controller: pageController,
                      itemCount: images.length,
                      onPageChanged:
                          (index) => setState(() {
                            activePage = index;
                          }),
                      itemBuilder: (context, index) {
                        return InteractiveViewer(
                          child: Center(
                            child: Image.network(
                              images[index],
                              fit: BoxFit.contain,
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) return child;
                                return const Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          images.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4.0),
                            height: 8,
                            width: activePage == index ? 18 : 8,
                            decoration: BoxDecoration(
                              color:
                                  activePage == index
                                      ? Colors.white
                                      : Colors.grey[600],
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String? value, {
    Color? valueColor,
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.purple),
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
