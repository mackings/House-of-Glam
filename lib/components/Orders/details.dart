import 'package:flutter/material.dart';
import 'package:hog/App/Home/Model/historymodel.dart';
import 'package:hog/components/texts.dart';
import 'package:hog/theme/app_theme.dart';
import 'package:intl/intl.dart';

class OrderDetailsSheet extends StatelessWidget {
  final MaterialReview material;

  const OrderDetailsSheet({super.key, required this.material});

  @override
  Widget build(BuildContext context) {
    final createdAt = DateTime.tryParse(material.createdAt);

    return DraggableScrollableSheet(
      expand: false,
      maxChildSize: 0.94,
      minChildSize: 0.56,
      initialChildSize: 0.82,
      builder: (context, controller) {
        return DecoratedBox(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: SingleChildScrollView(
            controller: controller,
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 52,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _HeaderIconButton(
                      icon: Icons.arrow_back_ios_new_rounded,
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const CustomText(
                            "Order Details",
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            textAlign: TextAlign.left,
                          ),
                          const SizedBox(height: 2),
                          CustomText(
                            createdAt == null
                                ? "Review garment details and measurements"
                                : DateFormat(
                                  "dd MMM yyyy • h:mm a",
                                ).format(createdAt),
                            fontSize: 12,
                            color: AppColors.subtext,
                            textAlign: TextAlign.left,
                          ),
                        ],
                      ),
                    ),
                    _HeaderIconButton(
                      icon: Icons.close_rounded,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _HeroImageGallery(images: material.sampleImage),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _InfoChip(
                      icon: Icons.checkroom_rounded,
                      label: material.attireType,
                    ),
                    _InfoChip(
                      icon: Icons.texture_rounded,
                      label: material.clothMaterial,
                    ),
                    _InfoChip(
                      icon: Icons.palette_outlined,
                      label: material.color,
                    ),
                    _InfoChip(
                      icon: Icons.storefront_outlined,
                      label: material.brand,
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: _SummaryTile(
                        label: "Status",
                        value: material.isDelivered ? "Delivered" : "Pending",
                        icon:
                            material.isDelivered
                                ? Icons.done_all_rounded
                                : Icons.schedule_rounded,
                        tone:
                            material.isDelivered
                                ? AppColors.success
                                : AppColors.warning,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _SummaryTile(
                        label: "Settlement",
                        value: material.settlement.toString(),
                        icon: Icons.payments_outlined,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                const CustomText(
                  "Measurements",
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 12),
                if (material.measurement.isEmpty)
                  _EmptyStateCard(
                    icon: Icons.straighten_rounded,
                    message:
                        "No measurement details were attached to this order.",
                  )
                else
                  ...material.measurement.map(
                    (measurement) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _MeasurementCard(measurement: measurement),
                    ),
                  ),
                if ((material.specialInstructions ?? '').trim().isNotEmpty) ...[
                  const SizedBox(height: 10),
                  const CustomText(
                    "Special Instructions",
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    textAlign: TextAlign.left,
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceMuted,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: CustomText(
                      material.specialInstructions!.trim(),
                      fontSize: 13,
                      color: AppColors.ink,
                      textAlign: TextAlign.left,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _HeaderIconButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(icon, size: 18, color: AppColors.ink),
      ),
    );
  }
}

class _HeroImageGallery extends StatelessWidget {
  final List<String> images;

  const _HeroImageGallery({required this.images});

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) {
      return const _EmptyStateCard(
        icon: Icons.image_not_supported_outlined,
        message: "No sample images were provided for this order.",
      );
    }

    if (images.length == 1) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: AspectRatio(
          aspectRatio: 1.3,
          child: Image.network(images.first, fit: BoxFit.cover),
        ),
      );
    }

    return SizedBox(
      height: 226,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder:
            (context, index) => ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: AspectRatio(
                aspectRatio: 1.15,
                child: Image.network(images[index], fit: BoxFit.cover),
              ),
            ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.accentSoft,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.accent),
          const SizedBox(width: 8),
          Flexible(
            child: CustomText(
              label,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.accent,
              textAlign: TextAlign.left,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color tone;

  const _SummaryTile({
    required this.label,
    required this.value,
    required this.icon,
    this.tone = AppColors.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 14,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: tone.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: tone, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  label,
                  fontSize: 11,
                  color: AppColors.subtext,
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 2),
                CustomText(
                  value,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  textAlign: TextAlign.left,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MeasurementCard extends StatelessWidget {
  final Measurement measurement;

  const _MeasurementCard({required this.measurement});

  @override
  Widget build(BuildContext context) {
    final tiles = <MapEntry<String, String>>[
      if (measurement.neck != null)
        MapEntry('Neck', measurement.neck.toString()),
      if (measurement.shoulder != null)
        MapEntry('Shoulder', measurement.shoulder.toString()),
      if (measurement.chest != null)
        MapEntry('Chest', measurement.chest.toString()),
      if (measurement.waist != null)
        MapEntry('Waist', measurement.waist.toString()),
      if (measurement.hip != null) MapEntry('Hip', measurement.hip.toString()),
      if (measurement.length != null)
        MapEntry('Length', measurement.length.toString()),
      if (measurement.armLength != null)
        MapEntry('Arm Length', measurement.armLength.toString()),
      if (measurement.sleeveLength != null)
        MapEntry('Sleeve', measurement.sleeveLength.toString()),
      if (measurement.aroundArm != null)
        MapEntry('Around Arm', measurement.aroundArm.toString()),
      if (measurement.wrist != null)
        MapEntry('Wrist', measurement.wrist.toString()),
      if (measurement.collarFront != null)
        MapEntry('Collar Front', measurement.collarFront.toString()),
      if (measurement.collarBack != null)
        MapEntry('Collar Back', measurement.collarBack.toString()),
      if ((measurement.armType ?? '').trim().isNotEmpty)
        MapEntry('Arm Type', measurement.armType!.trim()),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children:
            tiles
                .map(
                  (tile) => SizedBox(
                    width: 140,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceMuted,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            tile.key,
                            fontSize: 11,
                            color: AppColors.subtext,
                            textAlign: TextAlign.left,
                          ),
                          const SizedBox(height: 4),
                          CustomText(
                            tile.value,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            textAlign: TextAlign.left,
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                .toList(),
      ),
    );
  }
}

class _EmptyStateCard extends StatelessWidget {
  final IconData icon;
  final String message;

  const _EmptyStateCard({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, size: 22, color: AppColors.subtext),
          const SizedBox(height: 10),
          CustomText(message, fontSize: 13, color: AppColors.subtext),
        ],
      ),
    );
  }
}
