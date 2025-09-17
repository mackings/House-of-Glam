import 'package:flutter/material.dart';
import 'package:hog/TailorApp/Home/Api/TailorHomeservice.dart';
import 'package:hog/TailorApp/Home/Model/AssignedMaterial.dart';
import 'package:hog/components/button.dart';
import 'package:hog/components/texts.dart';
import 'package:intl/intl.dart';



void showTailorMaterialDetails(
  BuildContext context,
  TailorAssignedMaterial item,
) {
  final material = item.material;
  final formatter = NumberFormat("#,##0", "en_US");
  final service = TailorHomeService();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.9,
      minChildSize: 0.6,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return StatefulBuilder(
          builder: (context, setState) {
            bool isLoading = false;

            Future<void> _deliverAttire() async {
              try {
                setState(() => isLoading = true);
                await service.deliverAttire(material.id);
                Navigator.pop(context); // ✅ close modal on success
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Attire delivered successfully!")),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("❌ Failed: $e")),
                );
              } finally {
                setState(() => isLoading = false);
              }
            }

            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // drag handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  // Sample images
                  if (material.sampleImages.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        material.sampleImages.first,
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ),

                  const SizedBox(height: 20),

                  // Title + status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomText(
                        material.attireType,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple,
                      ),
                      Chip(
                        label: Text(
                          item.status,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                        backgroundColor: _statusColor(item.status),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  _buildSectionTitle("Material Details"),
                  _buildInfoRow("Cloth", material.clothMaterial),
                  _buildInfoRow("Color", material.color),
                  _buildInfoRow("Brand", material.brand),
                  _buildInfoRow("Delivered", material.isDelivered ? "Yes" : "No"),
                  const Divider(),

                  _buildSectionTitle("Customer"),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundImage: item.user.image != null
                            ? NetworkImage(item.user.image!)
                            : null,
                        child: item.user.image == null
                            ? Text(
                                item.user.fullName.isNotEmpty
                                    ? item.user.fullName[0].toUpperCase()
                                    : "?",
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomText(
                              item.user.fullName,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                            CustomText(
                              item.user.email,
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(),

                  _buildSectionTitle("Vendor"),
                  _buildInfoRow("Name", item.vendor.businessName),
                  _buildInfoRow("Email", item.vendor.businessEmail),
                  _buildInfoRow("Phone", item.vendor.businessPhone),
                  const Divider(),

                  _buildSectionTitle("Costs & Payments"),
                  _buildInfoRow("Material Cost", "₦${formatter.format(item.materialTotalCost)}"),
                  _buildInfoRow("Workmanship", "₦${formatter.format(item.workmanshipTotalCost)}"),
                  _buildInfoRow("Total", "₦${formatter.format(item.totalCost)}", bold: true, color: Colors.purple),
                  _buildInfoRow("Paid", "₦${formatter.format(item.amountPaid ?? 0)}"),
                  _buildInfoRow("Balance", "₦${formatter.format(item.amountToPay ?? 0)}", color: Colors.redAccent),
                  const Divider(),

                  _buildSectionTitle("Dates"),
                  _buildInfoRow("Created", DateFormat("dd MMM, yyyy").format(item.createdAt)),
                  if (item.deliveryDate != null)
                    _buildInfoRow("Delivery", DateFormat("dd MMM, yyyy").format(item.deliveryDate!)),
                  if (item.reminderDate != null)
                    _buildInfoRow("Reminder", DateFormat("dd MMM, yyyy").format(item.reminderDate!)),
                  const Divider(),

                  if (item.comment != null && item.comment!.isNotEmpty) ...[
                    _buildSectionTitle("Comment"),
                    CustomText(item.comment!, fontSize: 14, color: Colors.black87),
                    const Divider(),
                  ],

                  const SizedBox(height: 20),

CustomButton(
  title: isLoading ? "Loading.." : "Send for Delivery",
  onPressed: () {
    if (!isLoading) _deliverAttire();
  },
),




                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    ),
  );
}





Widget _buildSectionTitle(String title) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: CustomText(
      title,
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: Colors.purple,
    ),
  );
}

Widget _buildInfoRow(
  String label,
  String value, {
  bool bold = false,
  Color? color,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CustomText(label, fontSize: 14, color: Colors.grey[700]),
        CustomText(
          value,
          fontSize: 14,
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          color: color ?? Colors.black,
        ),
      ],
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
