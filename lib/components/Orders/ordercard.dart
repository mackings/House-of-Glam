import 'package:flutter/material.dart';
import 'package:hog/App/Home/Model/historymodel.dart';
import 'package:hog/components/Orders/details.dart';
import 'package:hog/components/texts.dart';
import 'package:intl/intl.dart';

class OrderCard extends StatelessWidget {
  final MaterialReview material;
  final VoidCallback onViewQuotations;

  const OrderCard({
    super.key,
    required this.material,
    required this.onViewQuotations,
  });

  @override
  Widget build(BuildContext context) {
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
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Icon + Title + Status Icon
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.checkroom, color: Colors.purple, size: 20),
                    SizedBox(width: 5,),
                    CustomText(
                    "${material.attireType} - ${material.clothMaterial}",
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                    
                  ],
                ),

                Icon(
                  material.isDelivered ? Icons.done_all : Icons.schedule,
                  size: 18,
                  color: material.isDelivered ? Colors.green : Colors.orange,
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Image Preview
            if (material.sampleImage.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  material.sampleImage.first,
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 8),

            // Date
            CustomText(
              DateFormat("dd MMM yyyy • h:mm a")
                  .format(DateTime.parse(material.createdAt)),
              fontSize: 12,
              color: Colors.black54,
            ),

            const SizedBox(height: 8),

            // Actions Row (View More + View Quotations)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.white,
                      shape: const RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      builder: (_) => OrderDetailsSheet(material: material),
                    );
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(60, 30),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const CustomText(
                    "View Order",
                    fontSize: 12,
                    color: Colors.purple,
                  ),
                ),
                ElevatedButton(
                  onPressed: onViewQuotations,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const CustomText(
                    "View Quotations",
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

