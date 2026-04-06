import 'package:flutter/material.dart';
import 'package:hog/App/Admin/Model/PendingListing.dart';
import 'package:intl/intl.dart';

class ModerationHistoryCard extends StatelessWidget {
  final ListingModerationFeedItem item;

  const ModerationHistoryCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final isRejected = item.action.toLowerCase() == 'rejected';
    final accent = isRejected ? Colors.red.shade700 : Colors.green.shade700;
    final background =
        isRejected ? const Color(0xFFFFF0F0) : const Color(0xFFF1FBF4);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: background,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  item.action,
                  style: TextStyle(
                    color: accent,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
              const Spacer(),
              if (item.moderatedAt != null)
                Text(
                  DateFormat.yMMMd().add_jm().format(item.moderatedAt!.toLocal()),
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            item.listingTitle.isEmpty ? 'Untitled listing' : item.listingTitle,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          ),
          const SizedBox(height: 8),
          Text(
            'Moderator: ${item.moderatorName.isEmpty ? 'Unknown' : item.moderatorName} (${item.moderatorRole.isEmpty ? 'admin' : item.moderatorRole})',
            style: TextStyle(color: Colors.grey.shade800),
          ),
          const SizedBox(height: 4),
          Text(
            'Current status: ${item.currentStatus}',
            style: TextStyle(color: Colors.grey.shade800),
          ),
          if (item.reason != null && item.reason!.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              item.reason!,
              style: TextStyle(color: Colors.grey.shade700, height: 1.4),
            ),
          ],
        ],
      ),
    );
  }
}
