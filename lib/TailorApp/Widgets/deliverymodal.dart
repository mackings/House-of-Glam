import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hog/TailorApp/Home/Api/Delivery.dart';
import 'package:hog/TailorApp/Home/Model/deliveryModel.dart';
import 'package:hog/components/Navigator.dart';
import 'package:hog/components/texts.dart';
import 'package:hog/theme/app_theme.dart';

void showDeliveryDetails(
  BuildContext context,
  TailorTracking tracking, {
  required TailorTrackingService service,
  required VoidCallback onRefresh,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder:
        (sheetContext) => DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.86,
          maxChildSize: 0.95,
          minChildSize: 0.52,
          builder:
              (_, controller) => DecoratedBox(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: ScaffoldMessenger(
                  child: Scaffold(
                    backgroundColor: Colors.transparent,
                    body: Builder(
                      builder:
                          (modalContext) => SingleChildScrollView(
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
                                    _HeaderButton(
                                      icon: Icons.arrow_back_ios_new_rounded,
                                      onPressed: () => Nav.pop(sheetContext),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const CustomText(
                                            "Tracking Details",
                                            fontSize: 20,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.ink,
                                            textAlign: TextAlign.left,
                                          ),
                                          const SizedBox(height: 2),
                                          CustomText(
                                            tracking.isDelivered
                                                ? "Review completed delivery details."
                                                : "Review active delivery details and tracking.",
                                            fontSize: 12,
                                            color: AppColors.subtext,
                                            textAlign: TextAlign.left,
                                          ),
                                        ],
                                      ),
                                    ),
                                    _HeaderButton(
                                      icon: Icons.close_rounded,
                                      onPressed: () => Nav.pop(sheetContext),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                _HeroImage(tracking: tracking),
                                const SizedBox(height: 18),
                                Wrap(
                                  spacing: 10,
                                  runSpacing: 10,
                                  children: [
                                    _InfoChip(
                                      icon: Icons.confirmation_number_outlined,
                                      label:
                                          "Tracking ID: ${tracking.trackingNumber}",
                                    ),
                                    _InfoChip(
                                      icon:
                                          tracking.isDelivered
                                              ? Icons.verified_rounded
                                              : Icons.local_shipping_outlined,
                                      label:
                                          tracking.isDelivered
                                              ? "Completed"
                                              : "In Transit",
                                      tone:
                                          tracking.isDelivered
                                              ? AppColors.success
                                              : AppColors.warning,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 18),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _SummaryTile(
                                        label: "Tracking ID",
                                        value:
                                            tracking.trackingNumber.toString(),
                                        icon: Icons.pin_outlined,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _SummaryTile(
                                        label: "Delivery Status",
                                        value:
                                            tracking.isDelivered
                                                ? "Completed"
                                                : "In Transit",
                                        icon:
                                            tracking.isDelivered
                                                ? Icons.done_all_rounded
                                                : Icons.schedule_rounded,
                                        tone:
                                            tracking.isDelivered
                                                ? AppColors.success
                                                : AppColors.warning,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 18),
                                const CustomText(
                                  "Attire Details",
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.ink,
                                  textAlign: TextAlign.left,
                                ),
                                const SizedBox(height: 10),
                                _SectionCard(
                                  children: [
                                    _DetailRow(
                                      label: "Attire",
                                      value: tracking.material.attireType,
                                    ),
                                    _DetailRow(
                                      label: "Material",
                                      value: tracking.material.clothMaterial,
                                    ),
                                    _DetailRow(
                                      label: "Colour",
                                      value: tracking.material.color,
                                    ),
                                    _DetailRow(
                                      label: "Brand",
                                      value: tracking.material.brand,
                                    ),
                                  ],
                                ),
                                if (tracking
                                    .material
                                    .sampleImage
                                    .isNotEmpty) ...[
                                  const SizedBox(height: 18),
                                  const CustomText(
                                    "Sample Images",
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.ink,
                                    textAlign: TextAlign.left,
                                  ),
                                  const SizedBox(height: 10),
                                  SizedBox(
                                    height: 132,
                                    child: ListView.separated(
                                      scrollDirection: Axis.horizontal,
                                      itemCount:
                                          tracking.material.sampleImage.length,
                                      separatorBuilder:
                                          (_, __) => const SizedBox(width: 10),
                                      itemBuilder:
                                          (_, i) => ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            child: Image.network(
                                              tracking.material.sampleImage[i],
                                              width: 132,
                                              height: 132,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (_, __, ___) => Container(
                                                    width: 132,
                                                    height: 132,
                                                    color:
                                                        AppColors.surfaceMuted,
                                                    child: const Icon(
                                                      Icons
                                                          .broken_image_outlined,
                                                      color: AppColors.subtext,
                                                    ),
                                                  ),
                                            ),
                                          ),
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 20),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceMuted,
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(color: AppColors.border),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.copy_all_rounded,
                                        size: 18,
                                        color: AppColors.accent,
                                      ),
                                      const SizedBox(width: 10),
                                      const Expanded(
                                        child: CustomText(
                                          "Copy tracking number",
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.ink,
                                          textAlign: TextAlign.left,
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Clipboard.setData(
                                            ClipboardData(
                                              text:
                                                  tracking.trackingNumber
                                                      .toString(),
                                            ),
                                          );
                                          ScaffoldMessenger.of(
                                            modalContext,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                "Tracking ID copied",
                                              ),
                                              duration: Duration(seconds: 1),
                                            ),
                                          );
                                        },
                                        child: const Text("Copy"),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                    ),
                  ),
                ),
              ),
        ),
  );
}

class _HeaderButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _HeaderButton({required this.icon, required this.onPressed});

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

class _HeroImage extends StatelessWidget {
  final TailorTracking tracking;

  const _HeroImage({required this.tracking});

  @override
  Widget build(BuildContext context) {
    final imageUrl =
        tracking.material.sampleImage.isNotEmpty
            ? tracking.material.sampleImage.first
            : "";

    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: Stack(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child:
                imageUrl.isNotEmpty
                    ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (_, __, ___) => Container(
                            color: AppColors.surfaceMuted,
                            child: const Icon(
                              Icons.broken_image_outlined,
                              color: AppColors.subtext,
                            ),
                          ),
                    )
                    : Container(
                      color: AppColors.surfaceMuted,
                      alignment: Alignment.center,
                      child: Container(
                        width: 62,
                        height: 62,
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
                    ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.08),
                    Colors.black.withValues(alpha: 0.42),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: CustomText(
              tracking.material.attireType,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              textAlign: TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color tone;

  const _InfoChip({
    required this.icon,
    required this.label,
    this.tone = AppColors.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: tone),
          const SizedBox(width: 8),
          CustomText(
            label,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: tone,
            textAlign: TextAlign.left,
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

class _SectionCard extends StatelessWidget {
  final List<Widget> children;

  const _SectionCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(children: children),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: CustomText(
              label,
              fontSize: 12,
              color: AppColors.subtext,
              textAlign: TextAlign.left,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: CustomText(
              value.isEmpty ? "N/A" : value,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
