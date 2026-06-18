import 'package:flutter/material.dart';
import 'package:hog/TailorApp/Home/Model/materialModel.dart';
import 'package:hog/components/texts.dart';
import 'package:hog/theme/app_theme.dart';
import 'package:timeago/timeago.dart' as timeago;


class TailorMaterialCard extends StatelessWidget {
  
  final TailorMaterialItem material;
  final VoidCallback onTap;

  const TailorMaterialCard({
    super.key,
    required this.material,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final createdAt = DateTime.parse(material.createdAt);
    final imgUrl =
        material.sampleImage.isNotEmpty ? material.sampleImage.first : "";
    final customerName =
        material.userId.fullName.isNotEmpty
            ? material.userId.fullName
            : "Unknown Customer";
    final measurementCount =
        material.measurement.isNotEmpty
            ? material.measurement.first.values.length
            : 0;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
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
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              child: Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 10,
                    child:
                        imgUrl.isNotEmpty
                            ? Image.network(
                              imgUrl,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (context, error, stackTrace) =>
                                      _FallbackImage(
                                        attireType: material.attireType,
                                      ),
                            )
                            : _FallbackImage(attireType: material.attireType),
                  ),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.06),
                            Colors.black.withValues(alpha: 0.34),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: _StatusChip(isDelivered: material.isDelivered),
                  ),
                  Positioned(
                    left: 12,
                    right: 12,
                    bottom: 12,
                    child: Row(
                      children: [
                        Expanded(
                          child: CustomText(
                            material.attireType,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            textAlign: TextAlign.left,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.22),
                            ),
                          ),
                          child: const Icon(
                            Icons.arrow_outward_rounded,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _InfoChip(text: material.brand),
                      _InfoChip(text: material.color),
                      _InfoChip(text: material.clothMaterial),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: AppColors.accentSoft,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.person_outline_rounded,
                          size: 18,
                          color: AppColors.accent,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: CustomText(
                          customerName,
                          fontSize: 13,
                          color: AppColors.ink,
                          textAlign: TextAlign.left,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F6F0),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.straighten_rounded,
                          size: 18,
                          color: AppColors.success,
                        ),
                      ),
                      const SizedBox(width: 6),
                      CustomText(
                        "$measurementCount measurements",
                        fontSize: 13,
                        color: AppColors.ink,
                        textAlign: TextAlign.left,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceMuted,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.schedule_rounded,
                          size: 16,
                          color: AppColors.subtext,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: CustomText(
                            timeago.format(createdAt),
                            fontSize: 12,
                            color: AppColors.subtext,
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _InfoChip({required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border),
      ),
      child: CustomText(
        text.isNotEmpty ? text : "N/A",
        fontSize: 11,
        color: AppColors.subtext,
        textAlign: TextAlign.left,
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final bool isDelivered;

  const _StatusChip({required this.isDelivered});

  @override
  Widget build(BuildContext context) {
    final bg = isDelivered ? const Color(0xFFE9F7F0) : const Color(0xFFFFF3E4);
    final border =
        isDelivered ? const Color(0xFFB8E2C8) : const Color(0xFFF8D3A1);
    final fg = isDelivered ? AppColors.success : AppColors.warning;
    final label = isDelivered ? "Completed" : "Awaiting Action";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: border),
      ),
      child: CustomText(
        label,
        fontSize: 11,
        color: fg,
        fontWeight: FontWeight.w600,
        textAlign: TextAlign.left,
      ),
    );
  }
}

class _FallbackImage extends StatelessWidget {
  final String attireType;

  const _FallbackImage({required this.attireType});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFEADDFE), Color(0xFFF7F2FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.84),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.checkroom_rounded,
              color: AppColors.accent,
              size: 28,
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: CustomText(
              attireType.isEmpty ? "Project material" : attireType,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
