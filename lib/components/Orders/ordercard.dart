import 'package:flutter/material.dart';
import 'package:hog/App/Home/Model/historymodel.dart';
import 'package:hog/components/Orders/details.dart';
import 'package:hog/components/texts.dart';
import 'package:hog/theme/app_theme.dart';
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
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.accentSoft,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.checkroom_rounded,
                    color: AppColors.accent,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: CustomText(
                    "${material.attireType} - ${material.clothMaterial}",
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    textAlign: TextAlign.left,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                _StatusBadge(isDelivered: material.isDelivered),
              ],
            ),
            if (material.sampleImage.isNotEmpty) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.network(
                  material.sampleImage.first,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ],
            const SizedBox(height: 12),
            CustomText(
              DateFormat(
                "dd MMM yyyy • h:mm a",
              ).format(DateTime.parse(material.createdAt)),
              fontSize: 12,
              color: AppColors.subtext,
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.white,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(24),
                          ),
                        ),
                        builder: (_) => OrderDetailsSheet(material: material),
                      );
                    },
                    icon: const Icon(
                      Icons.receipt_long_rounded,
                      size: 18,
                      color: AppColors.accent,
                    ),
                    label: const Text(
                      "View Order",
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.accent,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.accent,
                      side: const BorderSide(color: AppColors.border),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onViewQuotations,
                    icon: const Icon(
                      Icons.description_outlined,
                      size: 18,
                      color: Colors.white,
                    ),
                    label: const Text(
                      "View Quotes",
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(48),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
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

class _StatusBadge extends StatelessWidget {
  final bool isDelivered;

  const _StatusBadge({required this.isDelivered});

  @override
  Widget build(BuildContext context) {
    final color = isDelivered ? AppColors.success : AppColors.warning;
    final background =
        isDelivered ? const Color(0xFFEAF8F1) : const Color(0xFFFFF4DE);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isDelivered ? Icons.done_all_rounded : Icons.schedule_rounded,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            isDelivered ? "Delivered" : "Pending",
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
