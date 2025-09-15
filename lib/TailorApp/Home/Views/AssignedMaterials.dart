import 'package:flutter/material.dart';
import 'package:hog/TailorApp/Home/Api/TailorHomeservice.dart';
import 'package:hog/TailorApp/Home/Model/AssignedMaterial.dart';
import 'package:hog/components/texts.dart';
import 'package:intl/intl.dart';

class AssignedMaterials extends StatefulWidget {
  const AssignedMaterials({super.key});

  @override
  State<AssignedMaterials> createState() => _AssignedMaterialsState();
}

class _AssignedMaterialsState extends State<AssignedMaterials> {
  late Future<TailorAssignedMaterialsResponse> _futureAssignedMaterials;
  final TailorHomeService _service = TailorHomeService();

  @override
  void initState() {
    super.initState();
    _futureAssignedMaterials = _service.fetchAssignedMaterials();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const CustomText("Assigned Materials",
            fontSize: 18, color: Colors.white),
        backgroundColor: Colors.purple,
        elevation: 0,
      ),
      body: SafeArea(
        child: FutureBuilder<TailorAssignedMaterialsResponse>(
          future: _futureAssignedMaterials,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.purple),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: CustomText("❌ Error: ${snapshot.error}",
                    color: Colors.red),
              );
            } else if (!snapshot.hasData || snapshot.data!.reviews.isEmpty) {
              return const Center(
                child: CustomText("No assigned materials found",
                    fontSize: 16, color: Colors.grey),
              );
            }

            final materials = snapshot.data!.reviews;

            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: materials.length,
              itemBuilder: (context, index) {
                final item = materials[index];
                final material = item.material;

                final formattedDate =
                    DateFormat("dd MMM, yyyy").format(item.createdAt);

                final deliveryDate = item.deliveryDate != null
                    ? DateFormat("dd MMM").format(item.deliveryDate!)
                    : "N/A";

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 3,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      // TODO: Open bottom sheet or details page
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top row with image, title, and status
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  material.sampleImages.isNotEmpty
                                      ? material.sampleImages.first
                                      : "https://via.placeholder.com/120",
                                  height: 80,
                                  width: 80,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CustomText(
                                      material.attireType,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.person,
                                            size: 16, color: Colors.grey),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: CustomText(
                                            item.user.fullName,
                                            fontSize: 13,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        const Icon(Icons.business,
                                            size: 16, color: Colors.grey),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: CustomText(
                                            item.vendor.businessName,
                                            fontSize: 13,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Chip(
                                label: Text(item.status,
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 12)),
                                backgroundColor: _statusColor(item.status),
                              ),
                            ],
                          ),

                          const Divider(height: 20),

                          // Payment info
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CustomText(
                                "💰 Paid: ₦${item.amountPaid ?? 0}",
                                fontSize: 13,
                              ),
                              CustomText(
                                "Balance: ₦${item.amountToPay ?? 0}",
                                fontSize: 13,
                                color: Colors.redAccent,
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          // Dates
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CustomText(
                                "📦 Delivery: $deliveryDate",
                                fontSize: 13,
                              ),
                              CustomText(
                                "📅 Created: $formattedDate",
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case "full payment":
        return Colors.green;
      case "part payment":
        return Colors.orange;
      case "pending":
        return Colors.blueGrey;
      default:
        return Colors.grey;
    }
  }
}
