import 'package:flutter/material.dart';
import 'package:hog/App/Home/Views/PuB/patronize.dart';
import 'package:hog/App/Home/Views/PuB/widgets/poolUser.dart';
import 'package:hog/App/Home/Views/PuB/widgets/pooldetail.dart';
import 'package:hog/TailorApp/Home/Model/PublishedModel.dart';
import 'package:hog/components/texts.dart';
import 'package:intl/intl.dart';

class WorkCard extends StatelessWidget {
  final TailorPublished work;

  const WorkCard({super.key, required this.work});

  void _showFullImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: const EdgeInsets.all(10),
        child: InteractiveViewer(
          clipBehavior: Clip.none,
          minScale: 0.8,
          maxScale: 4.0,
          child: Image.network(imageUrl, fit: BoxFit.contain),
        ),
      ),
    );
  }

  void _openPatronizeSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => PatronizeForm(publishedId: work.id),
    );
  }

  /// Map subscription plan name to a color
  Color getPlanColor(String? planName) {
    switch (planName?.toLowerCase()) {
      case "premium":
        return Colors.orange;
      case "enterprise":
        return Colors.green;
      case "standard":
        return Colors.blue;
      case "free":
        return Colors.grey;
      default:
        return Colors.grey; // Unknown / no plan
    }
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = "Unknown date";
    try {
      formattedDate = DateFormat("d MMMM y • h:mma").format(work.createdAt);
    } catch (_) {}

    final planName = work.user?.subscriptionPlan?.toLowerCase() ?? "free";
    final planColor = getPlanColor(planName);
    final isVerified = planName != "free"; // Free plan is not verified

    return GestureDetector(
      onTap: () => _openPatronizeSheet(context),
      child: Container(
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
              GestureDetector(
                onTap: () => _showFullImage(context, work.sampleImage.first),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: Image.network(
                    work.sampleImage.first,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header: title + verified check
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomText(
                        work.clothPublished,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple,
                      ),
                      if (planName.isNotEmpty)
                        Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: isVerified ? planColor : Colors.grey,
                              size: 20,
                            ),
                            const SizedBox(width: 4),
                            CustomText(
                              isVerified
                                  ? "Verified • ${planName[0].toUpperCase()}${planName.substring(1)}"
                                  : "Unverified",
                              fontSize: 12,
                              color: planColor,
                            ),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  WorkDetailRow(
                    icon: Icons.category,
                    label: work.attireType,
                    trailingIcon: Icons.shopping_bag,
                    trailingText: work.brand,
                  ),
                  const SizedBox(height: 6),
                  WorkDetailRow(icon: Icons.color_lens, label: work.color),
                  const SizedBox(height: 6),
                  WorkDetailRow(
                    icon: Icons.calendar_today,
                    label: formattedDate,
                    smallText: true,
                  ),
                  const SizedBox(height: 6),

                  // Show subscription plan name as a row
                  WorkDetailRow(
                    icon: Icons.star,
                    label: "Subscription Plan: ${work.user?.subscriptionPlan ?? 'Free'}",
                    smallText: true,
                  ),

                  const SizedBox(height: 10),
                  if (work.user != null)
                    GestureDetector(
                      onTap: () {
                        if (work.user!.image.toString().isNotEmpty) {
                          _showFullImage(context, work.user!.image.toString());
                        }
                      },
                      child: UserInfo(user: work.user!),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

