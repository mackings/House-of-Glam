import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hog/TailorApp/Home/Api/Delivery.dart';
import 'package:hog/TailorApp/Home/Model/deliveryModel.dart';
import 'package:hog/components/Navigator.dart';
import 'package:hog/components/button.dart';
import 'package:hog/components/texts.dart';

void showDeliveryDetails(
  BuildContext context,
  TailorTracking tracking, {
  required TailorTrackingService service,
  required VoidCallback onRefresh, // callback to refresh list
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) {
      bool isLoading = false;

      return StatefulBuilder(
        builder:
            (context, setState) => DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.85,
              maxChildSize: 0.95,
              minChildSize: 0.5,
              builder:
                  (_, controller) => Padding(
                    padding: const EdgeInsets.all(16),
                    child: SingleChildScrollView(
                      controller: controller,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Drag handle
                          Center(
                            child: Container(
                              width: 50,
                              height: 5,
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: Colors.grey[400],
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),

                          // Title
                          CustomText(
                            "Tracking Details",
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple,
                          ),
                          const SizedBox(height: 16),

                          // Tracking Number (copyable)
                          Card(
                            elevation: 1,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.confirmation_number,
                                    color: Colors.purple,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: CustomText(
                                      "Tracking #: ${tracking.trackingNumber}",
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.copy,
                                      color: Colors.black54,
                                    ),
                                    onPressed: () {
                                      Clipboard.setData(
                                        ClipboardData(
                                          text:
                                              tracking.trackingNumber
                                                  .toString(),
                                        ),
                                      );
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text("Tracking ID copied"),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Delivery status
                          Row(
                            children: [
                              Icon(
                                tracking.isDelivered
                                    ? Icons.check_circle
                                    : Icons.local_shipping,
                                color:
                                    tracking.isDelivered
                                        ? Colors.green
                                        : Colors.orange,
                              ),
                              const SizedBox(width: 8),
                              CustomText(
                                "Delivered: ${tracking.isDelivered ? 'Yes' : 'No'}",
                                color: Colors.black87,
                              ),
                            ],
                          ),

                          const Divider(height: 32, thickness: 1),

                          // Material details
                          CustomText(
                            "Material Details",
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                          const SizedBox(height: 12),

                          _infoRow(
                            Icons.checkroom,
                            "Attire",
                            tracking.material.attireType,
                          ),
                          _infoRow(
                            Icons.layers,
                            "Material",
                            tracking.material.clothMaterial,
                          ),
                          _infoRow(
                            Icons.color_lens,
                            "Color",
                            tracking.material.color,
                          ),
                          _infoRow(
                            Icons.branding_watermark,
                            "Brand",
                            tracking.material.brand,
                          ),

                          const SizedBox(height: 16),

                          // Sample images
                          if (tracking.material.sampleImage.isNotEmpty)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomText(
                                  "Sample Images",
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  height: 120,
                                  child: ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    itemCount:
                                        tracking.material.sampleImage.length,
                                    separatorBuilder:
                                        (_, __) => const SizedBox(width: 8),
                                    itemBuilder:
                                        (_, i) => ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          child: Image.network(
                                            tracking.material.sampleImage[i],
                                            width: 120,
                                            height: 120,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                  ),
                                ),
                              ],
                            ),

                          const SizedBox(height: 34),

                          CustomButton(
                            title: "Contine",
                            onPressed: () {
                              Nav.pop(context);
                            },
                          ),

                          // Deliver button
                          // if (!tracking.isDelivered)
                          //   CustomButton(
                          //     title: isLoading ? "Delivering..." : "Deliver Now",
                          //     onPressed: isLoading
                          //         ? null
                          //         : () async {
                          //             setState(() => isLoading = true);

                          //             try {
                          //               final msg = await service
                          //                   .deliverAttire(tracking.material.id);
                          //               ScaffoldMessenger.of(context).showSnackBar(
                          //                 SnackBar(content: Text(msg)),
                          //               );
                          //               Navigator.pop(context); // close modal
                          //               onRefresh(); // refresh parent list
                          //             } catch (e) {
                          //               ScaffoldMessenger.of(context).showSnackBar(
                          //                 SnackBar(
                          //                     content: Text(
                          //                         "❌ Delivery failed: ${e.toString()}")),
                          //               );
                          //             } finally {
                          //               setState(() => isLoading = false);
                          //             }
                          //           },
                          //   ),
                        ],
                      ),
                    ),
                  ),
            ),
      );
    },
  );
}

Widget _infoRow(IconData icon, String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Icon(icon, color: Colors.purple, size: 20),
        const SizedBox(width: 8),
        Expanded(child: CustomText("$label: $value", color: Colors.black87)),
      ],
    ),
  );
}
