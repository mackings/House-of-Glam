import 'package:flutter/material.dart';
import 'package:hog/App/Auth/Api/tracking.dart';
import 'package:hog/App/Auth/Model/trackingmodel.dart';
import 'package:hog/App/Home/Views/PuB/widgets/trackinforow.dart';
import 'package:hog/components/button.dart';
import 'package:hog/components/texts.dart';



class TrackingDetailSheet extends StatefulWidget {
  final TrackingRecord record;

  const TrackingDetailSheet({super.key, required this.record});

  @override
  State<TrackingDetailSheet> createState() => _TrackingDetailSheetState();
}

class _TrackingDetailSheetState extends State<TrackingDetailSheet> {
  bool _isLoading = false;

  Future<void> _acceptDelivery() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirm Delivery"),
        content: Text(
            "Are you sure you want to accept delivery for tracking number ${widget.record.trackingNumber}?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Confirm"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);

    final success = await TrackingService.updateMaterialThroughTracking(
        widget.record.trackingNumber);

    setState(() => _isLoading = false);

    if (!mounted) return;

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success
            ? "✅ Delivery Accepted"
            : "❌ Failed to update delivery"),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final record = widget.record;
    final images = record.material.sampleImages;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      builder: (_, controller) => SingleChildScrollView(
        controller: controller,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 50,
                height: 5,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            Row(
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundImage:
                      images.isNotEmpty ? NetworkImage(images.first) : null,
                  backgroundColor: Colors.purple.shade100,
                  child: images.isEmpty
                      ? const Icon(Icons.image, color: Colors.purple)
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        record.material.attireType,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      CustomText(
                        "Tracking ID: ${record.trackingNumber}",
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                      CustomText(
                        record.isDelivered
                            ? "Delivered ✅"
                            : "In Progress ⏳",
                        fontSize: 15,
                        color: record.isDelivered
                            ? Colors.green
                            : Colors.purple,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            CustomText("Material Details",
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.purple),
            const SizedBox(height: 10),
            InfoRow(title: "Cloth", value: record.material.clothMaterial),
            InfoRow(title: "Color", value: record.material.color),
            InfoRow(title: "Brand", value: record.material.brand),
            const SizedBox(height: 20),
            if (images.length > 1) ...[
              CustomText("More Images",
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple),
              const SizedBox(height: 10),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: images.length - 1,
                itemBuilder: (_, i) => ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(images[i + 1], fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: 20),
            ],
            if (record.material.measurements.isNotEmpty) ...[
              CustomText("Measurements",
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 6,
                children: record.material.measurements.map((m) {
                  return Chip(
                    backgroundColor: Colors.purple.shade50,
                    label: CustomText(
                      "Neck: ${m.neck}, Chest: ${m.chest}, Waist: ${m.waist}, Length: ${m.length}",
                      fontSize: 13,
                      color: Colors.black87,
                    ),
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 30),
            CustomButton(
              title: _isLoading ? "Loading..." : "Accept Delivery",
              onPressed: _isLoading ? null : _acceptDelivery,
            ),
          ],
        ),
      ),
    );
  }
}
