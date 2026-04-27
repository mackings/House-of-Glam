import 'package:flutter/material.dart';
import 'package:hog/TailorApp/Home/Api/TailorHomeservice.dart';
import 'package:hog/TailorApp/Home/Model/AssignedMaterial.dart';
import 'package:hog/TailorApp/Widgets/UpdateQuote.dart';
import 'package:hog/components/texts.dart';
import 'package:hog/constants/currencyHelper.dart';
import 'package:hog/theme/app_theme.dart';
import 'package:intl/intl.dart';

void showTailorMaterialDetails(
  BuildContext parentContext,
  TailorAssignedMaterial item,
  VoidCallback? onStatusChanged,
) {
  final service = TailorHomeService();

  showModalBottomSheet(
    context: parentContext,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder:
        (_) => DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.9,
          minChildSize: 0.6,
          maxChildSize: 0.95,
          builder: (sheetContext, scrollController) {
            bool isLoading = false;
            TailorAssignedMaterial currentItem = item;

            bool isRequestingStatus() => currentItem.isRequestingStatus;

            String currentActionLabel() {
              if (currentItem.isSentForDeliveryStatus) {
                return "Attire Sent for Delivery";
              }
              if (isRequestingStatus()) {
                return "Update Quotation";
              }
              return "Deliver Attire";
            }

            return StatefulBuilder(
              builder: (modalContext, setState) {
                final material = currentItem.material;
                final imageUrl =
                    material.sampleImages.isNotEmpty
                        ? material.sampleImages.first
                        : "";
                final agreedAmount = currentItem.resolvedVendorBaseTotal;
                final payableBalance = currentItem.resolvedDesignerPayableTotal;
                final outstandingUserPayment =
                    currentItem.resolvedOutstandingForUi > 0;
                final hasClientPayment =
                    currentItem.resolvedAmountPaidForUi > 0;
                final isFullyPaid =
                    currentItem.isFullPaymentStatus ||
                    (hasClientPayment && !outstandingUserPayment);
                final paymentStatusLabel =
                    isFullyPaid
                        ? "Paid in Full"
                        : hasClientPayment
                        ? "Partial payment"
                        : "Unpaid";

                Future<void> deliverAttire() async {
                  try {
                    setState(() => isLoading = true);
                    final message = await service.deliverAssignedMaterial(
                      material.id,
                    );

                    final refreshed = await service.fetchAssignedMaterials();
                    TailorAssignedMaterial? updatedItem;
                    for (final review in refreshed.reviews) {
                      if (review.id == currentItem.id ||
                          review.material.id == material.id) {
                        updatedItem = review;
                        break;
                      }
                    }

                    if (!parentContext.mounted) {
                      return;
                    }

                    setState(() {
                      isLoading = false;
                      if (updatedItem != null) {
                        currentItem = updatedItem;
                      }
                    });
                    onStatusChanged?.call();
                    if (Navigator.of(modalContext).canPop()) {
                      Navigator.of(modalContext).pop();
                    }
                    ScaffoldMessenger.of(
                      parentContext,
                    ).showSnackBar(SnackBar(content: Text(message)));
                  } catch (e) {
                    if (!parentContext.mounted) {
                      return;
                    }
                    setState(() => isLoading = false);
                    if (Navigator.of(modalContext).canPop()) {
                      Navigator.of(modalContext).pop();
                    }
                    ScaffoldMessenger.of(
                      parentContext,
                    ).showSnackBar(SnackBar(content: Text("❌ $e")));
                  }
                }

                return DecoratedBox(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(30),
                    ),
                  ),
                  child: SingleChildScrollView(
                    controller: scrollController,
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
                              onPressed: () => Navigator.pop(modalContext),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const CustomText(
                                    "Project Material",
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    textAlign: TextAlign.left,
                                  ),
                                  const SizedBox(height: 2),
                                  CustomText(
                                    _buildSubtitle(currentItem),
                                    fontSize: 12,
                                    color: AppColors.subtext,
                                    textAlign: TextAlign.left,
                                  ),
                                ],
                              ),
                            ),
                            _HeaderIconButton(
                              icon: Icons.close_rounded,
                              onPressed: () => Navigator.pop(modalContext),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Stack(
                          children: [
                            _HeroImage(imageUrl: imageUrl, material: material),
                            Positioned(
                              top: 14,
                              left: 14,
                              child: _StatusPill(status: currentItem.status),
                            ),
                          ],
                        ),
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
                                label: "Agreed Total",
                                value: CurrencyHelper.formatAmount(
                                  agreedAmount,
                                ),
                                icon: Icons.payments_outlined,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _SummaryTile(
                                label: "Production Payout",
                                value: CurrencyHelper.formatAmount(
                                  payableBalance,
                                ),
                                icon: Icons.account_balance_wallet_outlined,
                                tone: AppColors.success,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _SummaryTile(
                                label: "Payment Status",
                                value: paymentStatusLabel,
                                icon:
                                    isFullyPaid
                                        ? Icons.check_circle_outline_rounded
                                        : hasClientPayment
                                        ? Icons.payments_outlined
                                        : Icons.schedule_rounded,
                                tone:
                                    isFullyPaid
                                        ? AppColors.success
                                        : hasClientPayment
                                        ? AppColors.warning
                                        : AppColors.subtext,
                                subtitle:
                                    isFullyPaid
                                        ? "Client payment completed"
                                        : hasClientPayment
                                        ? "Client payment recorded"
                                        : "No client payment yet",
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _SummaryTile(
                                label: "Payout Status",
                                value:
                                    outstandingUserPayment
                                        ? "Pending"
                                        : "Ready",
                                icon:
                                    outstandingUserPayment
                                        ? Icons.schedule_rounded
                                        : Icons.check_circle_outline_rounded,
                                tone:
                                    outstandingUserPayment
                                        ? AppColors.warning
                                        : AppColors.success,
                                subtitle:
                                    outstandingUserPayment
                                        ? "Waiting for client settlement"
                                        : "Eligible for disbursement",
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const CustomText(
                          "People",
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          textAlign: TextAlign.left,
                        ),
                        const SizedBox(height: 10),
                        _SectionCard(
                          children: [
                            _DetailRow(
                              label: "Vendor",
                              value: currentItem.vendor.businessName,
                            ),
                            _DetailRow(
                              label: "Vendor Email",
                              value: currentItem.vendor.businessEmail,
                            ),
                            _DetailRow(
                              label: "Vendor Phone",
                              value: currentItem.vendor.businessPhone,
                            ),
                            if ((currentItem.country ?? '').isNotEmpty)
                              _DetailRow(
                                label: "Country",
                                value: currentItem.country!,
                              ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        const CustomText(
                          "Timeline",
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          textAlign: TextAlign.left,
                        ),
                        const SizedBox(height: 10),
                        _SectionCard(
                          children: [
                            _DetailRow(
                              label: "Created",
                              value: DateFormat(
                                "dd MMM yyyy",
                              ).format(currentItem.createdAt),
                            ),
                            if (currentItem.deliveryDate != null)
                              _DetailRow(
                                label: "Delivery",
                                value: DateFormat(
                                  "dd MMM yyyy",
                                ).format(currentItem.deliveryDate!),
                              ),
                            if (currentItem.reminderDate != null)
                              _DetailRow(
                                label: "Reminder",
                                value: DateFormat(
                                  "dd MMM yyyy",
                                ).format(currentItem.reminderDate!),
                              ),
                          ],
                        ),
                        if ((currentItem.comment ?? '').trim().isNotEmpty) ...[
                          const SizedBox(height: 18),
                          const CustomText(
                            "Comment",
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
                              currentItem.comment!.trim(),
                              fontSize: 13,
                              color: AppColors.ink,
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed:
                                (isLoading ||
                                        currentItem.isSentForDeliveryStatus)
                                    ? null
                                    : () {
                                      if (isRequestingStatus()) {
                                        showModalBottomSheet(
                                          context: modalContext,
                                          isScrollControlled: true,
                                          backgroundColor: Colors.transparent,
                                          builder:
                                              (_) => UpdateQuotationBottomSheet(
                                                materialId: material.id,
                                              ),
                                        );
                                      } else {
                                        deliverAttire();
                                      }
                                    },
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.accent,
                              minimumSize: const Size(double.infinity, 56),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            child:
                                isLoading
                                    ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                    : Text(currentActionLabel()),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
  );
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

class _HeroImage extends StatelessWidget {
  final String imageUrl;
  final MaterialItem material;

  const _HeroImage({required this.imageUrl, required this.material});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: AspectRatio(
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
                          size: 30,
                        ),
                      ),
                )
                : Container(
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
                      Icons.checkroom_rounded,
                      color: AppColors.accent,
                      size: 30,
                    ),
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
              label.isEmpty ? "N/A" : label,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.accent,
              textAlign: TextAlign.left,
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
  final String? subtitle;

  const _SummaryTile({
    required this.label,
    required this.value,
    required this.icon,
    this.tone = AppColors.accent,
    this.subtitle,
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
            child: Icon(icon, size: 18, color: tone),
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
                  color: tone,
                  textAlign: TextAlign.left,
                ),
                if ((subtitle ?? '').isNotEmpty) ...[
                  const SizedBox(height: 2),
                  CustomText(
                    subtitle!,
                    fontSize: 10,
                    color: AppColors.subtext,
                    textAlign: TextAlign.left,
                  ),
                ],
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

class _StatusPill extends StatelessWidget {
  final String status;

  const _StatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: CustomText(
        _formatStatus(status),
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
    );
  }
}

String _formatStatus(String status) {
  return status
      .split(' ')
      .where((word) => word.isNotEmpty)
      .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
      .join(' ');
}

String _buildSubtitle(TailorAssignedMaterial item) {
  final parts = <String>[];
  if (item.vendor.businessName.isNotEmpty) {
    parts.add(item.vendor.businessName);
  }
  return parts.isEmpty
      ? "Review quotation and delivery progress"
      : parts.join(" • ");
}
