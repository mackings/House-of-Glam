import 'package:flutter/material.dart';
import 'package:hog/App/Profile/Model/DeliveryTrack.dart';
import 'package:hog/components/texts.dart';
import 'package:hog/constants/currencyHelper.dart';
import 'package:hog/theme/app_theme.dart';
import 'package:intl/intl.dart';

class TrackingCard extends StatelessWidget {
  final MarketTrackingRecord tracking;
  final VoidCallback onAccept;

  const TrackingCard({
    super.key,
    required this.tracking,
    required this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor =
        tracking.isDelivered ? AppColors.success : AppColors.warning;
    final statusBg =
        tracking.isDelivered
            ? const Color(0xFFEEF8F2)
            : const Color(0xFFFFF4DE);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        '#${tracking.trackingNumber}',
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                        textAlign: TextAlign.left,
                      ),
                      const SizedBox(height: 3),
                      CustomText(
                        tracking.reference.isEmpty
                            ? "Marketplace delivery record"
                            : tracking.reference,
                        fontSize: 11,
                        color: AppColors.subtext,
                        textAlign: TextAlign.left,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
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
                        tracking.isDelivered
                            ? Icons.check_circle_rounded
                            : Icons.schedule_rounded,
                        size: 14,
                        color: statusColor,
                      ),
                      const SizedBox(width: 6),
                      CustomText(
                        tracking.isDelivered ? 'Delivered' : 'Pending',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: statusColor,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _InfoTile(
                    icon: Icons.payments_outlined,
                    label: "Amount",
                    value: CurrencyHelper.formatAmount(
                      tracking.amount,
                      currencyCode: 'NGN',
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _InfoTile(
                    icon: Icons.calendar_today_rounded,
                    label: "Date",
                    value: DateFormat.yMMMd().format(tracking.createdAt),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                children: [
                  _PersonRow(
                    icon: Icons.person_outline_rounded,
                    label: "Buyer",
                    name: tracking.user.fullName,
                    address: tracking.user.address,
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  _PersonRow(
                    icon: Icons.storefront_outlined,
                    label: "Vendor",
                    name: tracking.vendor.fullName,
                    address: tracking.vendor.address,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.inventory_2_outlined,
                  size: 15,
                  color: AppColors.subtext,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: CustomText(
                    tracking.status,
                    fontSize: 12,
                    color: AppColors.subtext,
                    textAlign: TextAlign.left,
                  ),
                ),
              ],
            ),
            if (!tracking.isDelivered) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onAccept,
                  icon: const Icon(Icons.check_circle_outline_rounded),
                  label: const Text(
                    'Accept Order',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ],
        ),
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
        borderRadius: BorderRadius.circular(18),
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

class _PersonRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String name;
  final String address;

  const _PersonRow({
    required this.icon,
    required this.label,
    required this.name,
    required this.address,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: Colors.white,
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
                name,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
                textAlign: TextAlign.left,
              ),
              if (address.isNotEmpty)
                CustomText(
                  address,
                  fontSize: 11,
                  color: AppColors.subtext,
                  textAlign: TextAlign.left,
                ),
            ],
          ),
        ),
      ],
    );
  }
}
