import 'package:flutter/material.dart';
import 'package:hog/App/Profile/Model/SellerListing.dart';
import 'package:hog/components/texts.dart';
import 'package:intl/intl.dart';
class ProductCard extends StatelessWidget {
  final SellerListing listing;
  final VoidCallback onTap;

  const ProductCard({
    super.key,
    required this.listing,
    required this.onTap,
  });

  String formatPrice(double price) {
    final formatter = NumberFormat('#,###');
    return "₦${formatter.format(price)}";
  }

  String formatDate(DateTime date) {
    return DateFormat.yMMMd().format(date); // e.g. Oct 2, 2025
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14), // space between cards
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.purple.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // =========================
            // 🖼 PRODUCT IMAGE
            // =========================
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  listing.images.isNotEmpty ? listing.images[0] : '',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      child: const Center(
                        child: Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
                      ),
                    );
                  },
                ),
              ),
            ),

            // =========================
            // 📦 DETAILS
            // =========================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // TITLE
                  CustomText(
                    listing.title,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),

                  // PRICE
 CustomText(
  listing.price == 0
      ? "Free"
      : "${formatPrice(listing.price)}",
  fontSize: 15,
  fontWeight: FontWeight.w600,
  color: Colors.purple,
),

                  const SizedBox(height: 6),

                  // SIZE
                  if (listing.size.isNotEmpty) ...[
                    Row(
                      children: [
                        Icon(Icons.straighten, size: 16, color: Colors.purple.shade400),
                        const SizedBox(width: 4),
                        CustomText(
                          "Size: ${listing.size}",
                          fontSize: 13,
                          color: Colors.black87,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],

                  // =========================
                  // 👤 SELLER INFO
                  // =========================
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundImage: listing.user.image != null
                            ? NetworkImage(listing.user.image!)
                            : null,
                        backgroundColor: Colors.purple.withOpacity(0.15),
                        child: listing.user.image == null
                            ? const Icon(Icons.person, color: Colors.purple, size: 18)
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
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            CustomText(
                              "Uploaded: ${formatDate(listing.createdAt)}",
                              fontSize: 11,
                              color: Colors.black54,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
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
}
