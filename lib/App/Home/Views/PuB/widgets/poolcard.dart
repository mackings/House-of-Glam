import 'package:flutter/material.dart';
import 'package:hog/App/Home/Views/PuB/widgets/poolUser.dart';
import 'package:hog/App/Home/Views/PuB/widgets/pooldetail.dart';
import 'package:hog/TailorApp/Home/Model/PublishedModel.dart';
import 'package:hog/components/texts.dart';
import 'package:intl/intl.dart';

class WorkCard extends StatelessWidget {
  final TailorPublished work;

  const WorkCard({super.key, required this.work});

  @override
  Widget build(BuildContext context) {
    // ✅ Format published date
    String formattedDate = "Unknown date";
    try {
      formattedDate = DateFormat("d MMMM y • h:mma").format(work.createdAt);
    } catch (_) {}

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (work.sampleImage.isNotEmpty)
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(
                work.sampleImage.first,
                height: 140,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🏷 Title + Check
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomText(
                      work.clothPublished,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple,
                    ),
                    const Icon(Icons.check_circle,
                        color: Colors.purple, size: 20),
                  ],
                ),
                const SizedBox(height: 6),

                // 🛠 Attire & Brand
                WorkDetailRow(
                  icon: Icons.category,
                  label: work.attireType,
                  trailingIcon: Icons.shopping_bag,
                  trailingText: work.brand,
                ),
                const SizedBox(height: 6),

                // 🎨 Color
                WorkDetailRow(
                  icon: Icons.color_lens,
                  label: work.color,
                ),
                const SizedBox(height: 6),

                // 📅 Date
                WorkDetailRow(
                  icon: Icons.calendar_today,
                  label: formattedDate,
                  smallText: true,
                ),
                const SizedBox(height: 10),

                // 👤 User info
                if (work.user != null) UserInfo(user: work.user!),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
