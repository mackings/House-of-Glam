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
    final formattedCreatedAt = _formatDate(material.createdAt);
    final formattedUpdatedAt = _formatDate(material.updatedAt);
    final formattedDeliveryDate = _formatDate(material.deliveryDate);
    final formattedReminderDate = _formatDate(material.reminderDate);
    final priceText =
        material.price != null
            ? "$currencySymbol ${NumberFormat('#,###').format(material.price)}"
            : "TBD";

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
                  textAlign: TextAlign.left,
                ),

                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildTag(material.brand),
                    _buildTag(material.color),
                    _buildTag(material.clothMaterial),
                  ],
                ),

                const SizedBox(height: 20),

                _buildSectionCard(
                  title: "Customer",
                  children: [
                    _buildDetailRow(
                      Icons.person,
                      "Name",
                      material.userId.fullName,
                    ),
                    // _buildDetailRow(
                    //   Icons.email,
                    //   "Email",
                    //   material.userId.email.isNotEmpty
                    //       ? material.userId.email
                    //       : "N/A",
                    // ),
                  ],
                ),

                const SizedBox(height: 16),

                _buildSectionCard(
                  title: "Attire Details",
                  children: [
                    _buildDetailRow(Icons.store, "Brand", material.brand),
                    _buildDetailRow(Icons.color_lens, "Color", material.color),
                    _buildDetailRow(
                      Icons.texture,
                      "Material",
                      material.clothMaterial,
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                _buildSectionCard(
                  title: "Measurements",
                  children: [_buildMeasurements(material.measurement)],
                ),

                const SizedBox(height: 16),

                _buildSectionCard(
                  title: "Pricing & Status",
                  children: [
                    _buildDetailRow(
                      Icons.attach_money,
                      "Price",
                      priceText,
                      valueColor: Colors.purple,
                      isBold: true,
                    ),
                    _buildDetailRow(
                      Icons.local_shipping,
                      "Delivered",
                      material.isDelivered ? "Yes" : "No",
                    ),
                    _buildDetailRow(
                      Icons.account_balance_wallet,
                      "Settlement",
                      material.settlement.toString(),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                _buildSectionCard(
                  title: "Timeline",
                  children: [
                    _buildDetailRow(
                      Icons.calendar_today,
                      "Posted On",
                      formattedCreatedAt,
                    ),
                    _buildDetailRow(
                      Icons.update,
                      "Updated",
                      formattedUpdatedAt,
                    ),
                    _buildDetailRow(
                      Icons.event_available,
                      "Delivery Date",
                      formattedDeliveryDate,
                    ),
                    _buildDetailRow(
                      Icons.alarm,
                      "Reminder Date",
                      formattedReminderDate,
                    ),
                  ],
                ),

                if (material.specialInstructions != null &&
                    material.specialInstructions!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildSectionCard(
                    title: "Notes",
                    children: [
                      _buildDetailRow(
                        Icons.note,
                        "Instructions",
                        material.specialInstructions!,
                      ),
                    ],
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
              textAlign: TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            title,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            textAlign: TextAlign.left,
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }

  Widget _buildMeasurements(List<Measurement> measurements) {
    final merged = <String, dynamic>{};
    for (final measurement in measurements) {
      measurement.values.forEach((key, value) {
        if (value == null) return;
        final text = value.toString();
        if (text.trim().isEmpty) return;
        merged.putIfAbsent(key, () => value);
      });
    }

    if (merged.isEmpty) {
      return CustomText(
        "No measurements provided",
        fontSize: 13,
        color: Colors.grey[700],
        textAlign: TextAlign.left,
      );
    }

    final preferredOrder = [
      "neck",
      "shoulder",
      "chest",
      "waist",
      "hip",
      "sleevelength",
      "armlength",
      "aroundarm",
      "wrist",
      "collarfront",
      "collarback",
      "length",
      "armType",
    ];

    final keys =
        merged.keys.toList()..sort((a, b) {
          final indexA = preferredOrder.indexOf(a);
          final indexB = preferredOrder.indexOf(b);
          if (indexA == -1 && indexB == -1) {
            return a.compareTo(b);
          }
          if (indexA == -1) return 1;
          if (indexB == -1) return -1;
          return indexA.compareTo(indexB);
        });

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final key in keys)
          _buildMeasurementChip(
            _formatMeasurementKey(key),
            _formatMeasurementValue(merged[key]),
          ),
      ],
    );
  }

  Widget _buildMeasurementChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: CustomText(
        "$label: $value",
        fontSize: 12,
        color: Colors.grey[800],
        textAlign: TextAlign.left,
      ),
    );
  }

  Widget _buildTag(String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.purple.shade100),
      ),
      child: CustomText(
        value.isNotEmpty ? value : "N/A",
        fontSize: 12,
        color: Colors.purple.shade700,
        textAlign: TextAlign.left,
      ),
    );
  }

  String _formatDate(String? value) {
    if (value == null || value.isEmpty) return "N/A";
    final parsed = DateTime.tryParse(value);
    if (parsed == null) return value;
    return DateFormat("dd MMM, yyyy").format(parsed);
  }

  String _formatMeasurementKey(String key) {
    switch (key) {
      case "sleevelength":
        return "Sleeve Length";
      case "armlength":
        return "Arm Length";
      case "aroundarm":
        return "Around Arm";
      case "collarfront":
        return "Collar Front";
      case "collarback":
        return "Collar Back";
      case "armType":
        return "Arm Type";
      default:
        final spaced = key.replaceAllMapped(
          RegExp(r"([a-z])([A-Z])"),
          (match) => "${match.group(1)} ${match.group(2)}",
        );
        return spaced
            .split(RegExp(r"[_\s]+"))
            .map((part) {
              if (part.isEmpty) return part;
              return part[0].toUpperCase() + part.substring(1);
            })
            .join(" ");
    }
  }

  String _formatMeasurementValue(dynamic value) {
    if (value is num) {
      if (value % 1 == 0) {
        return value.toInt().toString();
      }
      return value.toString();
    }
    return value?.toString() ?? "N/A";
  }
}
