import 'package:flutter/material.dart';
import 'package:hog/TailorApp/Home/Model/deliveryModel.dart';
import 'package:hog/components/texts.dart';
import 'package:hog/theme/app_theme.dart';

class DeliveryCard extends StatelessWidget {
  final TailorTracking tracking;
  final VoidCallback onTap;

  const DeliveryCard({super.key, required this.tracking, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDelivered = tracking.isDelivered;
    final imageUrl =
        tracking.material.sampleImage.isNotEmpty
            ? tracking.material.sampleImage.first
            : "";

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.border),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 18,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              child: AspectRatio(
                aspectRatio: 16 / 7,
                child:
                    imageUrl.isNotEmpty
                        ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (context, error, stackTrace) =>
                                  _buildFallbackImage(),
                        )
                        : _buildFallbackImage(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomText(
                              tracking.material.attireType,
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: AppColors.ink,
                              textAlign: TextAlign.left,
                            ),
                            const SizedBox(height: 4),
                            CustomText(
                              "Tracking #${tracking.trackingNumber}",
                              fontSize: 13,
                              color: AppColors.subtext,
                              textAlign: TextAlign.left,
                            ),
                          ],
                        ),
                      ),
                      _StatusPill(isDelivered: isDelivered),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _MetaPill(
                        icon: Icons.sell_outlined,
                        label: tracking.material.brand,
                      ),
                      _MetaPill(
                        icon: Icons.palette_outlined,
                        label: tracking.material.color,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.accentSoft,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          isDelivered
                              ? Icons.verified_rounded
                              : Icons.local_shipping_outlined,
                          color:
                              isDelivered
                                  ? AppColors.success
                                  : AppColors.accent,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: CustomText(
                          isDelivered
                              ? "Delivery has been completed successfully."
                              : "Open to review delivery details and confirm status.",
                          fontSize: 12,
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

  Widget _buildFallbackImage() {
    return Container(
      color: AppColors.surfaceMuted,
      alignment: Alignment.center,
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(
          Icons.inventory_2_outlined,
          color: AppColors.accent,
          size: 28,
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final bool isDelivered;

  const _StatusPill({required this.isDelivered});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDelivered ? const Color(0xFFE9F7F0) : AppColors.accentSoft,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isDelivered ? Icons.check_rounded : Icons.timelapse_rounded,
            size: 15,
            color: isDelivered ? AppColors.success : AppColors.accent,
          ),
          const SizedBox(width: 6),
          CustomText(
            isDelivered ? "Delivered" : "Pending",
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: isDelivered ? AppColors.success : AppColors.accent,
            textAlign: TextAlign.left,
          ),
        ],
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: AppColors.subtext),
          const SizedBox(width: 6),
          CustomText(
            label.isEmpty ? "N/A" : label,
            fontSize: 11,
            color: AppColors.subtext,
            textAlign: TextAlign.left,
          ),
        ],
      ),
    );
  }
}
