import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:hog/App/Home/Api/useractivity.dart';
import 'package:hog/App/Home/Model/historymodel.dart';
import 'package:intl/intl.dart';
import 'package:carousel_slider/carousel_slider.dart';



class OrderHistory extends StatefulWidget {
  const OrderHistory({super.key});

  @override
  State<OrderHistory> createState() => _OrderHistoryState();
}

class _OrderHistoryState extends State<OrderHistory> {
  bool isLoading = false;
  List<MaterialReview> materials = [];
  final NumberFormat currencyFormat = NumberFormat("#,###");

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    setState(() => isLoading = true);
    final response = await UserActivityService.getAllMaterialsForReview();
    if (response != null && response.success) {
      setState(() => materials = response.materials);
    }
    setState(() => isLoading = false);
  }

void showOrderDetails(MaterialReview material) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) {
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
                    const Text(
                      "Order Details",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                    items: material.sampleImage
                        .map((img) => ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.network(img, fit: BoxFit.cover),
                            ))
                        .toList(),
                  ),
                const SizedBox(height: 20),

                // Info Chips
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _buildChip(material.attireType),
                    _buildChip(material.clothMaterial),
                    _buildChip(material.color),
                    _buildChip(material.brand),
                  ],
                ),

                const SizedBox(height: 20),

                // Measurements
                _sectionHeader("Measurements", Icons.straighten),
                const SizedBox(height: 8),
                ...material.measurement.map((m) {
                  return Card(
                    elevation: 0,
                    color: Colors.grey[100],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Chest: ${m.chest ?? "-"}"),
                              Text("Waist: ${m.waist ?? "-"}"),
                              Text("Hip: ${m.hip ?? "-"}"),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Shoulder: ${m.shoulder ?? "-"}"),
                              Text("Arm: ${m.armLength ?? "-"}"),
                              Text("Sleeve: ${m.sleeveLength ?? "-"}"),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Neck: ${m.neck ?? "-"}"),
                              Text("Wrist: ${m.wrist ?? "-"}"),
                              Text("Length: ${m.length ?? "-"}"),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }),

                if (material.specialInstructions != null) ...[
                  const SizedBox(height: 20),
                  _sectionHeader("Special Instructions", Icons.note_alt),
                  const SizedBox(height: 6),
                  Text(material.specialInstructions ?? ""),
                ],

                const SizedBox(height: 24),

                // Action Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 3,
                    ),
                    onPressed: () {},
                    icon: const Icon(Icons.check_circle, color: Colors.white),
                    label: const Text("Hire Designer", style: TextStyle(color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      );
    },
  );
}

// Helper widgets
Widget _buildChip(String text) {
  return Chip(
    label: Text(text),
    backgroundColor: Colors.purple.shade50,
    labelStyle: const TextStyle(color: Colors.purple),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  );
}

Widget _sectionHeader(String title, IconData icon) {
  return Row(
    children: [
      Icon(icon, size: 18, color: Colors.purple),
      const SizedBox(width: 6),
      Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
    ],
  );
}





Widget buildOrderCard(MaterialReview material) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: Colors.black12),
      borderRadius: BorderRadius.circular(10),
      boxShadow: [
        BoxShadow(
          color: Colors.black12.withOpacity(0.05),
          blurRadius: 6,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
    child: Padding(
      padding: const EdgeInsets.all(12), // smaller padding
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Attire & Material
          Row(
            children: [
              const Icon(Icons.checkroom, color: Colors.purple, size: 20),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  "${material.attireType} - ${material.clothMaterial}",
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Smaller preview
          if (material.sampleImage.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                material.sampleImage.first,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          const SizedBox(height: 8),

          // Status & Date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    material.isDelivered ? Icons.done_all : Icons.schedule,
                    size: 16,
                    color: material.isDelivered ? Colors.green : Colors.orange,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    material.isDelivered ? "Delivered" : "Pending",
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
              Text(
                DateFormat("dd MMM yyyy").format(DateTime.parse(material.createdAt)),
                style: const TextStyle(color: Colors.black54, fontSize: 11),
              ),
            ],
          ),

          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => showOrderDetails(material),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(60, 30),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text("View More", style: TextStyle(fontSize: 12)),
            ),
          ),
        ],
      ),
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Order History", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.purple,
      ),
      body: RefreshIndicator(
        onRefresh: fetchOrders,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : materials.isEmpty
                ? const Center(child: Text("No orders found"))
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: materials.length,
                    itemBuilder: (context, index) => buildOrderCard(materials[index]),
                  ),
      ),
    );
  }
}
