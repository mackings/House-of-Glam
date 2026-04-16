import 'package:flutter/material.dart';
import 'package:hog/App/Admin/Model/PendingListing.dart';
import 'package:hog/components/button.dart';
import 'package:hog/components/texts.dart';
import 'package:hog/theme/app_theme.dart';
import 'package:intl/intl.dart';

class ModerationListingCard extends StatefulWidget {
  final SellerModerationListing listing;
  final VoidCallback onTap;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;
  final bool isBusy;

  const ModerationListingCard({
    super.key,
    required this.listing,
    required this.onTap,
    this.onApprove,
    this.onReject,
    this.isBusy = false,
  });

  @override
  State<ModerationListingCard> createState() => _ModerationListingCardState();
}

class _ModerationListingCardState extends State<ModerationListingCard> {
  final NumberFormat _priceFormatter = NumberFormat('#,##0', 'en_US');
  int _currentImageIndex = 0;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final listing = widget.listing;
    final images =
        listing.images.isNotEmpty
            ? listing.images
            : const ['https://via.placeholder.com/300x200.png?text=No+Image'];

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: widget.onTap,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImages(images),
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          listing.title,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          textAlign: TextAlign.left,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        CustomText(
                          _formatPrice(listing),
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.accent,
                          textAlign: TextAlign.left,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  _StatusChip(status: listing.approvalStatus),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _MetaPill(
                    icon: Icons.category_outlined,
                    label:
                        listing.category?.name.isNotEmpty == true
                            ? listing.category!.name
                            : 'Uncategorized',
                  ),
                  if (listing.condition.isNotEmpty)
                    _MetaPill(
                      icon: Icons.verified_outlined,
                      label: listing.condition,
                    ),
                  if (listing.size.isNotEmpty)
                    _MetaPill(icon: Icons.straighten, label: listing.size),
                  if (listing.createdAt != null)
                    _MetaPill(
                      icon: Icons.schedule,
                      label: DateFormat.yMMMd().format(
                        listing.createdAt!.toLocal(),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              _SellerSection(user: listing.user),
              if (listing.rejectionReasons.isNotEmpty) ...[
                const SizedBox(height: 12),
                _InfoBlock(
                  title: 'Rejection Reasons',
                  value: listing.rejectionReasons.join(', '),
                  valueColor: Colors.red.shade700,
                ),
              ],
              if (listing.approvedBy != null || listing.rejectedBy != null) ...[
                const SizedBox(height: 12),
                _ModerationSummary(listing: listing),
              ],
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: widget.onTap,
                      icon: const Icon(Icons.visibility_outlined),
                      label: const Text('Review'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.accent,
                        side: const BorderSide(color: AppColors.accent),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (widget.onApprove != null && widget.onReject != null) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        title: widget.isBusy ? 'Processing...' : 'Approve',
                        isOutlined: true,
                        onPressed: widget.isBusy ? null : widget.onApprove,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomButton(
                        title: 'Reject',
                        onPressed: widget.isBusy ? null : widget.onReject,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImages(List<String> images) {
    return SizedBox(
      height: 210,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: PageView.builder(
              controller: _pageController,
              itemCount: images.length,
              onPageChanged: (index) {
                setState(() => _currentImageIndex = index);
              },
              itemBuilder: (context, index) {
                return Image.network(
                  images[index],
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (_, __, ___) => Container(
                        color: Colors.grey.shade200,
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.broken_image_outlined,
                          size: 42,
                        ),
                      ),
                );
              },
            ),
          ),
          if (images.length > 1)
            Positioned(
              right: 12,
              bottom: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  '${_currentImageIndex + 1}/${images.length}',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatPrice(SellerModerationListing listing) {
    if (listing.price == 0) {
      return 'Free';
    }

    final currency = listing.currency.isEmpty ? 'NGN' : listing.currency;
    return '$currency ${_priceFormatter.format(listing.price)}';
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

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
        status.isEmpty ? 'unknown' : status,
        style: TextStyle(
          color: foreground,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey.shade700),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(color: Colors.grey.shade800, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _SellerSection extends StatelessWidget {
  final SellerUser user;

  const _SellerSection({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.grey.shade300,
            backgroundImage:
                user.image != null && user.image!.isNotEmpty
                    ? NetworkImage(user.image!)
                    : null,
            child:
                user.image == null || user.image!.isEmpty
                    ? const Icon(Icons.person, color: Colors.white)
                    : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  user.fullName.isEmpty ? 'Unknown seller' : user.fullName,
                  fontWeight: FontWeight.w600,
                  textAlign: TextAlign.left,
                ),
                if (user.address.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: CustomText(
                      user.address,
                      color: Colors.black54,
                      textAlign: TextAlign.left,
                    ),
                  ),
                if (user.email.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: CustomText(
                      user.email,
                      color: Colors.black54,
                      textAlign: TextAlign.left,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ModerationSummary extends StatelessWidget {
  final SellerModerationListing listing;

  const _ModerationSummary({required this.listing});

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat.yMMMd().add_jm();
    final approvedMeta =
        listing.approvedBy != null && listing.approvedAt != null
            ? 'Approved by ${listing.approvedBy!.fullName} on ${formatter.format(listing.approvedAt!.toLocal())}'
            : null;
    final rejectedMeta =
        listing.rejectedBy != null && listing.rejectedAt != null
            ? 'Rejected by ${listing.rejectedBy!.fullName} on ${formatter.format(listing.rejectedAt!.toLocal())}'
            : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (approvedMeta != null)
          _InfoBlock(title: 'Approval', value: approvedMeta),
        if (rejectedMeta != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: _InfoBlock(
              title: 'Rejection',
              value: rejectedMeta,
              valueColor: Colors.red.shade700,
            ),
          ),
      ],
    );
  }
}

class _InfoBlock extends StatelessWidget {
  final String title;
  final String value;
  final Color? valueColor;

  const _InfoBlock({required this.title, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            height: 1.4,
            color: valueColor ?? Colors.black87,
          ),
        ),
      ],
    );
  }
}
