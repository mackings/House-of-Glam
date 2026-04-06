import 'package:flutter/material.dart';
import 'package:hog/App/Profile/Model/UploadedListings.dart';
import 'package:hog/components/texts.dart';
import 'package:hog/constants/currency.dart';
import 'package:hog/theme/app_theme.dart';
import 'package:intl/intl.dart';

class UserListingCard extends StatelessWidget {
  final UserListing listing;
  final VoidCallback onDelete;

  const UserListingCard({
    super.key,
    required this.listing,
    required this.onDelete,
  });

  String formatPrice(double price) {
    if (price == 0) return "Free";
    final formatter = NumberFormat('#,###');
    return "$currencySymbol${formatter.format(price)}";
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = listing.images.isNotEmpty;

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
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: SizedBox(
                width: 108,
                height: 116,
                child:
                    hasImage
                        ? Image.network(
                          listing.images.first,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildPlaceholder(),
                        )
                        : _buildPlaceholder(),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: CustomText(
                          listing.title,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.ink,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.left,
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () => _showDeleteDialog(context),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFDECEC),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.delete_outline_rounded,
                            size: 18,
                            color: AppColors.danger,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  CustomText(
                    formatPrice(listing.price),
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.accent,
                    textAlign: TextAlign.left,
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _MetaChip(
                        icon: Icons.straighten_rounded,
                        label: "Size ${listing.size}",
                      ),
                      _MetaChip(
                        icon: Icons.info_outline_rounded,
                        label: listing.condition,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_rounded,
                        size: 14,
                        color: AppColors.subtext,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: CustomText(
                          "Uploaded ${DateFormat.yMMMd().format(listing.createdAt)}",
                          fontSize: 11,
                          color: AppColors.subtext,
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            title: const Text("Delete Listing"),
            content: Text(
              "Are you sure you want to delete '${listing.title}'?",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.danger,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  Navigator.pop(context);
                  onDelete();
                },
                child: const Text("Delete"),
              ),
            ],
          ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.surfaceMuted,
      child: const Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          color: AppColors.subtext,
          size: 34,
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.subtext),
          const SizedBox(width: 6),
          CustomText(
            label,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
            textAlign: TextAlign.left,
          ),
        ],
      ),
    );
  }
}
