import 'package:flutter/material.dart';
import 'package:hog/TailorApp/Home/Model/materialModel.dart';
import 'package:hog/TailorApp/Widgets/Quotationmodal.dart';
import 'package:hog/components/button.dart';
import 'package:hog/components/texts.dart';
import 'package:hog/constants/currency.dart';
import 'package:hog/theme/app_theme.dart';
import 'package:intl/intl.dart';

class TailorMaterialDetailSheet extends StatelessWidget {
  final TailorMaterialItem material;

  const TailorMaterialDetailSheet({super.key, required this.material});

  @override
  Widget build(BuildContext context) {
    final createdAt = DateTime.tryParse(material.createdAt);
    final updatedAt = DateTime.tryParse(material.updatedAt);
    final deliveryDate = DateTime.tryParse(material.deliveryDate ?? '');
    final reminderDate = DateTime.tryParse(material.reminderDate ?? '');
    final priceText =
        material.price != null
            ? "$currencySymbol ${NumberFormat('#,###').format(material.price)}"
            : "TBD";
    final measurements = _collectMeasurements(material.measurement);

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
                            "Attire Details",
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            textAlign: TextAlign.left,
                          ),
                          const SizedBox(height: 2),
                          CustomText(
                            createdAt == null
                                ? "Review measurements, customer info, and pricing."
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
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _SummaryTile(
                        label: "Price",
                        value: priceText,
                        icon: Icons.attach_money_rounded,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _SummaryTile(
                        label: "Customer",
                        value:
                            material.userId.fullName.isEmpty
                                ? "Unknown"
                                : material.userId.fullName,
                        icon: Icons.person_outline_rounded,
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
                if (measurements.isEmpty)
                  const _EmptyStateCard(
                    icon: Icons.straighten_rounded,
                    message:
                        "No measurement details were attached to this attire.",
                  )
                else
                  _MeasurementWrap(measurements: measurements),
                const SizedBox(height: 18),
                const CustomText(
                  "Timeline",
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 12),
                Column(
                  children: [
                    _TimelineCard(
                      label: "Posted On",
                      value: _formatDate(createdAt),
                      icon: Icons.calendar_today_outlined,
                    ),
                    const SizedBox(height: 10),
                    _TimelineCard(
                      label: "Updated",
                      value: _formatDate(updatedAt),
                      icon: Icons.update_rounded,
                    ),
                    const SizedBox(height: 10),
                    _TimelineCard(
                      label: "Delivery Date",
                      value: _formatDate(deliveryDate),
                      icon: Icons.event_available_outlined,
                    ),
                    const SizedBox(height: 10),
                    _TimelineCard(
                      label: "Reminder Date",
                      value: _formatDate(reminderDate),
                      icon: Icons.alarm_outlined,
                    ),
                  ],
                ),
                if ((material.specialInstructions ?? '').trim().isNotEmpty) ...[
                  const SizedBox(height: 18),
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
                const SizedBox(height: 24),
                CustomButton(
                  title: "Submit Quotation",
                  isOutlined: false,
                  onPressed: () {
                    Navigator.pop(context);
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),
                      builder:
                          (_) => QuotationBottomSheet(materialId: material.id),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime? value) {
    if (value == null) return "Not set";
    return DateFormat("dd MMM yyyy • h:mm a").format(value);
  }

  List<MapEntry<String, String>> _collectMeasurements(
    List<Measurement> measurements,
  ) {
    final merged = <String, dynamic>{};
    for (final measurement in measurements) {
      measurement.values.forEach((key, value) {
        if (value == null) return;
        final text = value.toString().trim();
        if (text.isEmpty) return;
        merged.putIfAbsent(key, () => value);
      });
    }

    final preferredOrder = [
      "neck",
      "shoulder",
      "chest",
      "waist",
      "hip",
      "sleevelength",
      "armlength",
      "aroundarm",
      "wrist",
      "collarfront",
      "collarback",
      "length",
      "armtype",
    ];

    final keys =
        merged.keys.toList()..sort((a, b) {
          final aIndex = preferredOrder.indexOf(a.toLowerCase());
          final bIndex = preferredOrder.indexOf(b.toLowerCase());
          if (aIndex == -1 && bIndex == -1) return a.compareTo(b);
          if (aIndex == -1) return 1;
          if (bIndex == -1) return -1;
          return aIndex.compareTo(bIndex);
        });

    return keys
        .map(
          (key) => MapEntry(
            _formatMeasurementKey(key),
            _formatMeasurementValue(merged[key]),
          ),
        )
        .toList();
  }

  String _formatMeasurementKey(String key) {
    final normalized =
        key
            .replaceAllMapped(
              RegExp(r'([a-z])([A-Z])'),
              (match) => '${match.group(1)} ${match.group(2)}',
            )
            .replaceAll('_', ' ')
            .trim();
    return normalized
        .split(' ')
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }

  String _formatMeasurementValue(dynamic value) {
    if (value == null) return "N/A";
    final text = value.toString().trim();
    return text.isEmpty ? "N/A" : text;
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

class _HeroImageGallery extends StatefulWidget {
  final List<String> images;

  const _HeroImageGallery({required this.images});

  @override
  State<_HeroImageGallery> createState() => _HeroImageGalleryState();
}

class _HeroImageGalleryState extends State<_HeroImageGallery> {
  int _activeIndex = 0;

  @override
  Widget build(BuildContext context) {
    final images = widget.images;

    if (images.isEmpty) {
      return const _EmptyStateCard(
        icon: Icons.image_not_supported_outlined,
        message: "No sample images were provided for this attire.",
      );
    }

    return Column(
      children: [
        SizedBox(
          height: images.length == 1 ? 240 : 226,
          child:
              images.length == 1
                  ? _GalleryImage(
                    imageUrl: images.first,
                    onTap: () => _openFullscreen(context, images, 0),
                  )
                  : ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: images.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder:
                        (context, index) => _GalleryImage(
                          imageUrl: images[index],
                          onTap: () {
                            setState(() {
                              _activeIndex = index;
                            });
                            _openFullscreen(context, images, index);
                          },
                        ),
                  ),
        ),
        if (images.length > 1) ...[
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              images.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _activeIndex == index ? 18 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color:
                      _activeIndex == index
                          ? AppColors.accent
                          : AppColors.border,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  void _openFullscreen(BuildContext context, List<String> images, int start) {
    showDialog(
      context: context,
      builder: (_) => _FullScreenGallery(images: images, initialIndex: start),
    );
  }
}

class _GalleryImage extends StatelessWidget {
  final String imageUrl;
  final VoidCallback onTap;

  const _GalleryImage({required this.imageUrl, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: AspectRatio(
          aspectRatio: 1.15,
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder:
                (_, __, ___) => Container(
                  color: AppColors.surfaceMuted,
                  child: const Icon(
                    Icons.broken_image_outlined,
                    color: AppColors.subtext,
                    size: 30,
                  ),
                ),
          ),
        ),
      ),
    );
  }
}

class _FullScreenGallery extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const _FullScreenGallery({required this.images, required this.initialIndex});

  @override
  State<_FullScreenGallery> createState() => _FullScreenGalleryState();
}

class _FullScreenGalleryState extends State<_FullScreenGallery> {
  late final PageController _controller;
  late int _activeIndex;

  @override
  void initState() {
    super.initState();
    _activeIndex = widget.initialIndex;
    _controller = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: widget.images.length,
            onPageChanged: (index) {
              setState(() {
                _activeIndex = index;
              });
            },
            itemBuilder:
                (context, index) => InteractiveViewer(
                  child: Center(
                    child: Image.network(
                      widget.images[index],
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
          ),
          Positioned(
            top: 56,
            right: 20,
            child: InkWell(
              onTap: () => Navigator.pop(context),
              borderRadius: BorderRadius.circular(999),
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Icon(Icons.close_rounded, color: Colors.white),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 34,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.images.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _activeIndex == index ? 18 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color:
                        _activeIndex == index
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
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

class _MeasurementWrap extends StatelessWidget {
  final List<MapEntry<String, String>> measurements;

  const _MeasurementWrap({required this.measurements});

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
      child: LayoutBuilder(
        builder: (context, constraints) {
          const spacing = 10.0;
          final width = constraints.maxWidth;
          final columns =
              width >= 540
                  ? 3
                  : width >= 320
                  ? 2
                  : 1;
          final itemWidth = (width - (spacing * (columns - 1))) / columns;

          return Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children:
                measurements
                    .map(
                      (tile) => SizedBox(
                        width: itemWidth,
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
          );
        },
      ),
    );
  }
}

class _TimelineCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _TimelineCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, size: 18, color: AppColors.accent),
          ),
          const SizedBox(width: 12),
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
