import 'package:flutter/material.dart';
import 'package:hog/App/Profile/Model/DeliveryTrack.dart';
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
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.grey.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ✅ Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '#${tracking.trackingNumber}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.purple.shade700,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color:
                          tracking.isDelivered
                              ? Colors.green.shade600
                              : Colors.orange.shade600,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      tracking.isDelivered ? 'Delivered' : 'Pending',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // ✅ Buyer & Vendor info
              Row(
                children: [
                  const Icon(
                    Icons.person_outline,
                    size: 18,
                    color: Colors.purple,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Buyer: ${tracking.user.fullName}',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(
                    Icons.store_mall_directory_outlined,
                    size: 18,
                    color: Colors.purple,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Vendor: ${tracking.vendor.fullName}',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),
              Divider(color: Colors.grey.shade300, thickness: 1),

              // ✅ Amount, Status & Date
              const SizedBox(height: 12),
              _buildInfoRow(
                'Amount:',
                '₦${tracking.amount.toStringAsFixed(2)}',
                Colors.purple,
              ),
              const SizedBox(height: 4),
              _buildInfoRow('Status:', tracking.status, Colors.grey.shade700),
              const SizedBox(height: 4),
              _buildInfoRow(
                'Date:',
                DateFormat.yMMMd().format(tracking.createdAt),
                Colors.grey.shade700,
              ),

              const SizedBox(height: 16),

              // ✅ Action Button
              if (!tracking.isDelivered)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onAccept,
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Accept Order'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// 🔹 Reusable Info Row
  Widget _buildInfoRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade600,
          ),
        ),
        Text(
          value,
          style: TextStyle(fontWeight: FontWeight.w600, color: color),
        ),
      ],
    );
  }
}
