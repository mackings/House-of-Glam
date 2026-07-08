import 'package:flutter/material.dart';
import 'package:hog/App/Admin/Api/adminService.dart';
import 'package:hog/App/Admin/Model/PendingListing.dart';
import 'package:hog/App/Admin/Widgets/rejectionSheet.dart';
import 'package:hog/components/button.dart';
import 'package:hog/utils/ui_label_formatter.dart';
import 'package:intl/intl.dart';

class ModerationListingDetailSheet extends StatefulWidget {
  final String listingId;
  final bool allowModerationActions;

  const ModerationListingDetailSheet({
    super.key,
    required this.listingId,
    this.allowModerationActions = false,
  });

  @override
  State<ModerationListingDetailSheet> createState() =>
      _ModerationListingDetailSheetState();
}

class _ModerationListingDetailSheetState
    extends State<ModerationListingDetailSheet> {
  late Future<SellerModerationListing> _future;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _future = AdminService.getListingById(widget.listingId);
  }

  Future<void> _approve() async {
    setState(() => _isSubmitting = true);

    try {
      await AdminService.approveListing(widget.listingId);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Listing approved')));
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _reject() async {
    final reasons = await showRejectReasonSheet(context);
    if (reasons == null || reasons.isEmpty) {
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await AdminService.rejectListing(widget.listingId, reasons);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Listing rejected')));
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.94,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: FutureBuilder<SellerModerationListing>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return _DetailError(
                message: snapshot.error.toString().replaceFirst(
                  'Exception: ',
                  '',
                ),
                onRetry: () {
                  setState(() {
                    _future = AdminService.getListingById(widget.listingId);
                  });
                },
              );
            }

            final listing = snapshot.data;
            if (listing == null) {
              return const _DetailError(
                message: 'Listing details are unavailable.',
              );
            }

            return Column(
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 46,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              listing.title.isEmpty
                                  ? 'Untitled listing'
                                  : listing.title,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          _DetailStatusChip(status: listing.approvalStatus),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _ImageStrip(images: listing.images),
                      const SizedBox(height: 18),
                      _SectionCard(
                        title: 'Listing',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _DetailRow(
                              label: 'Price',
                              value:
                                  listing.price == 0
                                      ? 'Free'
                                      : '${listing.currency} ${NumberFormat('#,##0', 'en_US').format(listing.price)}',
                            ),
                            _DetailRow(
                              label: 'Category',
                              value:
                                  listing.category?.name.isNotEmpty == true
                                      ? listing.category!.name
                                      : 'Uncategorized',
                            ),
                            if (listing.size.isNotEmpty)
                              _DetailRow(label: 'Size', value: listing.size),
                            if (listing.condition.isNotEmpty)
                              _DetailRow(
                                label: 'Condition',
                                value: formatUiLabel(listing.condition),
                              ),
                            if (listing.status.isNotEmpty)
                              _DetailRow(
                                label: 'Availability',
                                value: formatUiLabel(listing.status),
                              ),
                            if (listing.yards.isNotEmpty)
                              _DetailRow(
                                label: 'Yards',
                                value:
                                    listing.yards
                                        .map((yard) => yard.label)
                                        .join(', '),
                              ),
                            if (listing.description.isNotEmpty)
                              _DetailRow(
                                label: 'Description',
                                value: listing.description,
                                multiline: true,
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      _SectionCard(
                        title: 'Seller',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _DetailRow(
                              label: 'Name',
                              value:
                                  listing.user.fullName.isEmpty
                                      ? 'Unknown seller'
                                      : listing.user.fullName,
                            ),
                            if (listing.user.email.isNotEmpty)
                              _DetailRow(
                                label: 'Email',
                                value: listing.user.email,
                              ),
                            if (listing.user.phoneNumber.isNotEmpty)
                              _DetailRow(
                                label: 'Phone',
                                value: listing.user.phoneNumber,
                              ),
                            if (listing.user.address.isNotEmpty)
                              _DetailRow(
                                label: 'Address',
                                value: listing.user.address,
                                multiline: true,
                              ),
                            if (listing.user.subscriptionPlan.isNotEmpty)
                              _DetailRow(
                                label: 'Plan',
                                value: formatUiLabel(
                                  listing.user.subscriptionPlan,
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      _SectionCard(
                        title: 'Moderation',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _DetailRow(
                              label: 'Approval status',
                              value: formatUiLabel(listing.approvalStatus),
                            ),
                            if (listing.approvedBy != null)
                              _DetailRow(
                                label: 'Approved by',
                                value: listing.approvedBy!.fullName,
                              ),
                            if (listing.approvedAt != null)
                              _DetailRow(
                                label: 'Approved at',
                                value: DateFormat.yMMMd().add_jm().format(
                                  listing.approvedAt!.toLocal(),
                                ),
                              ),
                            if (listing.rejectedBy != null)
                              _DetailRow(
                                label: 'Rejected by',
                                value: listing.rejectedBy!.fullName,
                              ),
                            if (listing.rejectedAt != null)
                              _DetailRow(
                                label: 'Rejected at',
                                value: DateFormat.yMMMd().add_jm().format(
                                  listing.rejectedAt!.toLocal(),
                                ),
                              ),
                            if (listing.rejectionReasons.isNotEmpty)
                              _DetailRow(
                                label: 'Rejection reasons',
                                value: listing.rejectionReasons.join(', '),
                                multiline: true,
                              ),
                          ],
                        ),
                      ),
                      if (listing.moderationHistory.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        _SectionCard(
                          title: 'History',
                          child: Column(
                            children:
                                listing.moderationHistory
                                    .map((entry) => _HistoryTile(entry: entry))
                                    .toList(),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (widget.allowModerationActions) ...[
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
                    child: Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                            title: _isSubmitting ? 'Processing...' : 'Approve',
                            isOutlined: true,
                            onPressed: _isSubmitting ? null : _approve,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CustomButton(
                            title: 'Reject',
                            onPressed: _isSubmitting ? null : _reject,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _DetailError extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const _DetailError({required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 40, color: Colors.redAccent),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(height: 1.5),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              TextButton(onPressed: onRetry, child: const Text('Retry')),
            ],
          ],
        ),
      ),
    );
  }
}

class _DetailStatusChip extends StatelessWidget {
  final String status;

  const _DetailStatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    late final Color background;
    late final Color foreground;

    switch (status.toLowerCase()) {
      case 'approved':
        background = const Color(0xFFE8F8EE);
        foreground = const Color(0xFF1B8E4B);
        break;
      case 'rejected':
        background = const Color(0xFFFDECEC);
        foreground = const Color(0xFFC62828);
        break;
      default:
        background = const Color(0xFFFFF4DE);
        foreground = const Color(0xFFB26A00);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        formatUiLabel(status),
        style: TextStyle(
          color: foreground,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _ImageStrip extends StatelessWidget {
  final List<String> images;

  const _ImageStrip({required this.images});

  @override
  Widget build(BuildContext context) {
    final items =
        images.isEmpty
            ? const ['https://via.placeholder.com/300x200.png?text=No+Image']
            : images;

    return SizedBox(
      height: 220,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Image.network(
              items[index],
              width: 260,
              fit: BoxFit.cover,
              errorBuilder:
                  (_, __, ___) => Container(
                    width: 260,
                    color: Colors.grey.shade200,
                    alignment: Alignment.center,
                    child: const Icon(Icons.broken_image_outlined, size: 42),
                  ),
            ),
          );
        },
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool multiline;

  const _DetailRow({
    required this.label,
    required this.value,
    this.multiline = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: multiline ? null : 2,
            overflow: multiline ? null : TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 14, height: 1.45),
          ),
        ],
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final ListingModerationEvent entry;

  const _HistoryTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    final when =
        entry.createdAt != null
            ? DateFormat.yMMMd().add_jm().format(entry.createdAt!.toLocal())
            : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            entry.action,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            '${entry.moderatorName.isEmpty ? 'Unknown moderator' : entry.moderatorName} (${entry.moderatorRole.isEmpty ? 'admin' : entry.moderatorRole})',
            style: TextStyle(color: Colors.grey.shade800),
          ),
          if (when != null) ...[
            const SizedBox(height: 4),
            Text(when, style: TextStyle(color: Colors.grey.shade600)),
          ],
          if (entry.reason != null && entry.reason!.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(entry.reason!, style: const TextStyle(height: 1.4)),
          ],
        ],
      ),
    );
  }
}
