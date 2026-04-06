import 'package:flutter/material.dart';
import 'package:hog/App/Auth/Api/tracking.dart';
import 'package:hog/App/Auth/Model/trackingmodel.dart';
import 'package:hog/components/button.dart';
import 'package:hog/components/texts.dart';
import 'package:hog/theme/app_theme.dart';

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
      builder:
          (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            title: const Text("Confirm Delivery"),
            content: Text(
              "Are you sure you want to accept delivery for tracking number ${widget.record.trackingNumber}?",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                ),
                child: const Text("Confirm"),
              ),
            ],
          ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);
    final success = await TrackingService.updateMaterialThroughTracking(
      widget.record.trackingNumber,
    );
    setState(() => _isLoading = false);

    if (!mounted) return;

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? "Delivery accepted" : "Failed to update delivery",
        ),
        backgroundColor: success ? AppColors.success : AppColors.danger,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final record = widget.record;
    final images = record.material.sampleImages;
    final delivered = record.isDelivered;
    final statusColor = delivered ? AppColors.success : AppColors.warning;
    final statusBg =
        delivered ? const Color(0xFFEEF8F2) : const Color(0xFFFFF4DE);

    return FractionallySizedBox(
      heightFactor: 0.94,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: DraggableScrollableSheet(
          expand: false,
          initialChildSize: 1,
          minChildSize: 0.7,
          maxChildSize: 1,
          builder:
              (_, controller) => SingleChildScrollView(
                controller: controller,
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
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
                                "Tracking Details",
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                textAlign: TextAlign.left,
                              ),
                              const SizedBox(height: 2),
                              CustomText(
                                "Tracking ID: ${record.trackingNumber}",
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
                    const SizedBox(height: 18),
                    if (images.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: SizedBox(
                          height: 220,
                          width: double.infinity,
                          child: Image.network(images.first, fit: BoxFit.cover),
                        ),
                      )
                    else
                      Container(
                        height: 220,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceMuted,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.image_outlined,
                            size: 40,
                            color: AppColors.subtext,
                          ),
                        ),
                      ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomText(
                                record.material.attireType,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: AppColors.ink,
                                textAlign: TextAlign.left,
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
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
                                    const SizedBox(width: 6),
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
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: _InfoTile(
                            icon: Icons.texture_rounded,
                            label: "Cloth",
                            value: record.material.clothMaterial,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _InfoTile(
                            icon: Icons.palette_outlined,
                            label: "Color",
                            value: record.material.color,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _WideInfoTile(
                      icon: Icons.storefront_outlined,
                      label: "Brand",
                      value: record.material.brand,
                    ),
                    if (images.length > 1) ...[
                      const SizedBox(height: 20),
                      const CustomText(
                        "More Images",
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        textAlign: TextAlign.left,
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 96,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: images.length - 1,
                          separatorBuilder:
                              (_, __) => const SizedBox(width: 10),
                          itemBuilder:
                              (_, i) => ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: SizedBox(
                                  width: 96,
                                  child: Image.network(
                                    images[i + 1],
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                        ),
                      ),
                    ],
                    if (record.material.measurements.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      const CustomText(
                        "Measurements",
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        textAlign: TextAlign.left,
                      ),
                      const SizedBox(height: 10),
                      ...record.material.measurements.map(
                        (m) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _MeasurementCard(measurement: m),
                        ),
                      ),
                    ],
                    const SizedBox(height: 22),
                    CustomButton(
                      title: _isLoading ? "Loading..." : "Accept Delivery",
                      onPressed:
                          _isLoading || record.isDelivered
                              ? null
                              : _acceptDelivery,
                      isLoading: _isLoading,
                    ),
                  ],
                ),
              ),
        ),
      ),
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

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.accentSoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 18, color: AppColors.accent),
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
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                  textAlign: TextAlign.left,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WideInfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _WideInfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.accent),
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
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
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
    final chips = <MapEntry<String, String>>[
      MapEntry('Neck', measurement.neck.toString()),
      MapEntry('Shoulder', measurement.shoulder.toString()),
      MapEntry('Chest', measurement.chest.toString()),
      MapEntry('Waist', measurement.waist.toString()),
      MapEntry('Hip', measurement.hip.toString()),
      MapEntry('Length', measurement.length.toString()),
      MapEntry('Sleeve', measurement.sleevelength.toString()),
      MapEntry('Arm', measurement.armlength.toString()),
      MapEntry('Around Arm', measurement.aroundarm.toString()),
      MapEntry('Wrist', measurement.wrist.toString()),
      MapEntry('Collar Front', measurement.collarfront.toString()),
      MapEntry('Collar Back', measurement.collarback.toString()),
      if (measurement.armType.isNotEmpty)
        MapEntry('Arm Type', measurement.armType),
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
            chips
                .map(
                  (chip) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceMuted,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomText(
                          chip.key,
                          fontSize: 10,
                          color: AppColors.subtext,
                          textAlign: TextAlign.left,
                        ),
                        const SizedBox(height: 3),
                        CustomText(
                          chip.value,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                          textAlign: TextAlign.left,
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
      ),
    );
  }
}
