import 'package:flutter/material.dart';
import 'package:hog/App/Home/Views/PuB/patronize.dart';
import 'package:hog/App/Home/Views/PuB/widgets/poolUser.dart';
import 'package:hog/App/Home/Views/PuB/widgets/pooldetail.dart';
import 'package:hog/TailorApp/Home/Model/PublishedModel.dart';
import 'package:hog/components/texts.dart';
import 'package:hog/theme/app_theme.dart';
import 'package:intl/intl.dart';

class WorkCard extends StatelessWidget {
  final TailorPublished work;

  const WorkCard({super.key, required this.work});

  void _showFullImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder:
          (_) => Dialog(
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

  Color getPlanColor(String? planName) {
    switch (planName?.toLowerCase()) {
      case "premium":
        return AppColors.warning;
      case "enterprise":
        return AppColors.accentDeep;
      case "standard":
        return AppColors.accent;
      case "free":
        return Colors.grey;
      default:
        return Colors.grey;
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
    final isVerified = planName != "free";

    return GestureDetector(
      onTap: () => _openPatronizeSheet(context),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.border),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 18,
              offset: Offset(0, 10),
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
                    top: Radius.circular(22),
                  ),
                  child: Image.network(
                    work.sampleImage.first,
                    height: 168,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: CustomText(
                          work.clothPublished,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                          textAlign: TextAlign.left,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color:
                              isVerified
                                  ? planColor.withValues(alpha: 0.14)
                                  : AppColors.surfaceMuted,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.verified_rounded,
                              color: isVerified ? planColor : Colors.grey,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            CustomText(
                              isVerified
                                  ? "${planName[0].toUpperCase()}${planName.substring(1)}"
                                  : "Free",
                              fontSize: 11,
                              color: isVerified ? planColor : Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  WorkDetailRow(
                    icon: Icons.category_outlined,
                    label: work.attireType,
                    trailingIcon: Icons.shopping_bag_outlined,
                    trailingText: work.brand,
                  ),
                  const SizedBox(height: 6),
                  WorkDetailRow(
                    icon: Icons.palette_outlined,
                    label: work.color,
                  ),
                  const SizedBox(height: 6),
                  WorkDetailRow(
                    icon: Icons.schedule_outlined,
                    label: formattedDate,
                    smallText: true,
                  ),
                  const SizedBox(height: 12),
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
