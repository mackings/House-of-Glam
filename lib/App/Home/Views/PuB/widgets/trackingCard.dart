import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hog/App/Auth/Model/trackingmodel.dart';
import 'package:hog/components/texts.dart';
import 'package:hog/theme/app_theme.dart';
import 'package:intl/intl.dart';

class TrackingCard extends StatelessWidget {
  final TrackingRecord record;
  final VoidCallback onTap;

  const TrackingCard({super.key, required this.record, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final images = record.material.sampleImages;
    final delivered = record.isDelivered;
    final statusColor = delivered ? AppColors.success : AppColors.warning;
    final statusBg =
        delivered ? const Color(0xFFEEF8F2) : const Color(0xFFFFF4DE);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.border),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 16,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child:
                  images.isNotEmpty
                      ? Image.network(
                        images.first,
                        width: 88,
                        height: 106,
                        fit: BoxFit.cover,
                      )
                      : Container(
                        width: 88,
                        height: 106,
                        color: AppColors.accentSoft,
                        child: const Icon(
                          Icons.image_outlined,
                          color: AppColors.accent,
                          size: 28,
                        ),
                      ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: CustomText(
                          record.material.attireType,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.ink,
                          textAlign: TextAlign.left,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: statusBg,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              delivered
                                  ? Icons.check_circle_rounded
                                  : Icons.local_shipping_rounded,
                              size: 14,
                              color: statusColor,
                            ),
                            const SizedBox(width: 5),
                            CustomText(
                              delivered ? "Delivered" : "In Transit",
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: statusColor,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  CustomText(
                    record.material.clothMaterial,
                    fontSize: 13,
                    color: AppColors.subtext,
                    textAlign: TextAlign.left,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceMuted,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const CustomText(
                                "Tracking ID",
                                fontSize: 10,
                                color: AppColors.subtext,
                                textAlign: TextAlign.left,
                              ),
                              const SizedBox(height: 3),
                              CustomText(
                                record.trackingNumber.toString(),
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: AppColors.ink,
                                textAlign: TextAlign.left,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Clipboard.setData(
                              ClipboardData(
                                text: record.trackingNumber.toString(),
                              ),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Tracking ID copied"),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.copy_rounded,
                              size: 16,
                              color: AppColors.accent,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_rounded,
                        size: 14,
                        color: AppColors.subtext,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: CustomText(
                          DateFormat("dd MMM yyyy").format(record.createdAt),
                          fontSize: 11,
                          color: AppColors.subtext,
                          textAlign: TextAlign.left,
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14,
                        color: AppColors.subtext,
                      ),
                    ],
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
