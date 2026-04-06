import 'package:flutter/material.dart';
import 'package:hog/App/Profile/Model/SellerListing.dart';
import 'package:hog/components/texts.dart';
import 'package:hog/constants/currency.dart';
import 'package:hog/theme/app_theme.dart';
import 'package:intl/intl.dart';

class ProductCard extends StatelessWidget {
  final SellerListing listing;
  final VoidCallback onTap;

  const ProductCard({super.key, required this.listing, required this.onTap});

  String formatPrice(double price) {
    final formatter = NumberFormat('#,###');
    return "$currencySymbol${formatter.format(price)}";
  }

  String formatDate(DateTime date) {
    return DateFormat.yMMMd().format(date);
  }

  @override
  Widget build(BuildContext context) {
    final hasImage =
        listing.images.isNotEmpty && listing.images.first.isNotEmpty;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
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
                  width: 112,
                  height: 118,
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
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.accentSoft,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const CustomText(
                            "Approved",
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.accent,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    CustomText(
                      listing.price == 0 ? "Free" : formatPrice(listing.price),
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
                          icon: Icons.category_outlined,
                          label: listing.category.name,
                        ),
                        if (listing.size.isNotEmpty)
                          _MetaChip(
                            icon: Icons.straighten_rounded,
                            label: listing.size,
                          ),
                        _MetaChip(
                          icon: Icons.info_outline_rounded,
                          label: listing.condition,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    CustomText(
                      listing.description,
                      fontSize: 12,
                      color: AppColors.subtext,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.left,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundImage:
                              listing.user.image != null &&
                                      listing.user.image!.isNotEmpty
                                  ? NetworkImage(listing.user.image!)
                                  : null,
                          backgroundColor: AppColors.surfaceMuted,
                          child:
                              listing.user.image == null ||
                                      listing.user.image!.isEmpty
                                  ? const Icon(
                                    Icons.person_outline_rounded,
                                    color: AppColors.subtext,
                                    size: 18,
                                  )
                                  : null,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomText(
                                listing.user.fullName,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.ink,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.left,
                              ),
                              CustomText(
                                "Uploaded ${formatDate(listing.createdAt)}",
                                fontSize: 11,
                                color: AppColors.subtext,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.left,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceMuted,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 14,
                            color: AppColors.subtext,
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
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.surfaceMuted,
      child: const Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          size: 34,
          color: AppColors.subtext,
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
            fontWeight: FontWeight.w600,
            color: AppColors.ink,
            textAlign: TextAlign.left,
          ),
        ],
      ),
    );
  }
}
