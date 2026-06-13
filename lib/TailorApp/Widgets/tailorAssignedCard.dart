import 'package:flutter/material.dart';
import 'package:hog/TailorApp/Home/Model/AssignedMaterial.dart';
import 'package:hog/components/texts.dart';
import 'package:hog/constants/currencyHelper.dart';
import 'package:hog/theme/app_theme.dart';

class TailorAssignedCard extends StatelessWidget {
  final TailorAssignedMaterial item;
  final VoidCallback onTap;

  const TailorAssignedCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final material = item.material;
    final imageUrl =
        material.sampleImages.isNotEmpty ? material.sampleImages.first : "";
    final payableBalance = item.resolvedDesignerPayableTotal;
    final outstandingUserPayment = item.resolvedOutstandingForUi > 0;
    final hasClientPayment = item.resolvedAmountPaidForUi > 0;
    final isFullyPaid = item.isClientPaymentComplete;
    final paymentStatusLabel =
        isFullyPaid
            ? "Paid in Full"
            : hasClientPayment
            ? "Partial payment"
            : "Unpaid";
    final paymentStatusTone =
        isFullyPaid
            ? AppColors.success
            : hasClientPayment
            ? AppColors.warning
            : AppColors.subtext;
    final paymentStatusIcon =
        isFullyPaid
            ? Icons.check_circle_rounded
            : hasClientPayment
            ? Icons.payments_rounded
            : Icons.schedule_rounded;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(26),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: AppColors.border),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(26),
                ),
                child: Stack(
                  children: [
                    AspectRatio(
                      aspectRatio: 16 / 8,
                      child:
                          imageUrl.isNotEmpty
                              ? Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (_, __, ___) => _AssignedFallbackImage(
                                      material: material,
                                    ),
                              )
                              : _AssignedFallbackImage(material: material),
                    ),
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.08),
                              Colors.black.withValues(alpha: 0.46),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 14,
                      left: 14,
                      child: _StatusPill(status: item.status),
                    ),
                    Positioned(
                      top: 14,
                      right: 14,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.18),
                          ),
                        ),
                        child: const Icon(
                          Icons.arrow_outward_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            material.attireType,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            textAlign: TextAlign.left,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _HeroChip(
                                icon: Icons.texture_rounded,
                                label: material.clothMaterial,
                              ),
                              _HeroChip(
                                icon: Icons.palette_outlined,
                                label: material.color,
                              ),
                            ],
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
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.surface, AppColors.surfaceMuted],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _PaymentMiniTile(
                                  label: "Payment Status",
                                  value: paymentStatusLabel,
                                  tone: paymentStatusTone,
                                  icon: paymentStatusIcon,
                                  subtitle:
                                      isFullyPaid
                                          ? "Client payment completed"
                                          : hasClientPayment
                                          ? "Client payment recorded"
                                          : "No client payment yet",
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _PaymentMiniTile(
                                  label: "Production Payout",
                                  value: CurrencyHelper.formatAmount(
                                    payableBalance,
                                  ),
                                  tone:
                                      outstandingUserPayment
                                          ? AppColors.warning
                                          : AppColors.accent,
                                  icon:
                                      isFullyPaid
                                          ? Icons.check_circle_rounded
                                          : Icons.schedule_rounded,
                                  subtitle:
                                      outstandingUserPayment
                                          ? hasClientPayment
                                              ? "Awaiting full settlement"
                                              : "Awaiting client payment"
                                          : "Ready for Disbursement",
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (outstandingUserPayment) ...[
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.secondarySoft,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: AppColors.warning),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.info_outline_rounded,
                              color: AppColors.warning,
                              size: 18,
                            ),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: CustomText(
                                "Client payment is still pending, so payout is not ready yet.",
                                fontSize: 12,
                                color: AppColors.secondaryDeep,
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AssignedFallbackImage extends StatelessWidget {
  final MaterialItem material;

  const _AssignedFallbackImage({required this.material});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surfaceMuted,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.white,
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
              material.brand.isEmpty ? material.attireType : material.brand,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _HeroChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 6),
          CustomText(
            label.isEmpty ? "N/A" : label,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            textAlign: TextAlign.left,
          ),
        ],
      ),
    );
  }
}

class _PaymentMiniTile extends StatelessWidget {
  final String label;
  final String value;
  final Color tone;
  final IconData icon;
  final String subtitle;

  const _PaymentMiniTile({
    required this.label,
    required this.value,
    required this.tone,
    required this.icon,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: tone.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 14, color: tone),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  label,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.subtext,
                  textAlign: TextAlign.left,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                CustomText(
                  value,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: tone,
                  textAlign: TextAlign.left,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                CustomText(
                  subtitle,
                  fontSize: 9,
                  color: AppColors.subtext,
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

class _StatusPill extends StatelessWidget {
  final String status;

  const _StatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    final tone = _statusTone(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: CustomText(
        _formatStatus(status),
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: Colors.white,
        textAlign: TextAlign.left,
      ),
    );
  }
}

Color _statusTone(String status) {
  switch (status.toLowerCase()) {
    case "full payment":
    case "sent for delivery":
    case "attire sent for delivery":
    case "for delivery":
    case "delivery":
    case "delivered":
      return AppColors.success;
    case "part payment":
      return AppColors.warning;
    case "requesting":
      return const Color(0xFF2563EB);
    default:
      return AppColors.subtext;
  }
}

String _formatStatus(String status) {
  return status
      .split(' ')
      .where((word) => word.isNotEmpty)
      .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
      .join(' ');
}
