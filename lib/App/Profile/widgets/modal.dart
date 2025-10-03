import 'package:flutter/material.dart';
import 'package:hog/App/Profile/Model/SellerListing.dart';
import 'package:hog/App/Profile/widgets/FullImageView.dart';
import 'package:hog/components/texts.dart';
import 'package:intl/intl.dart';

void showProductDetails(BuildContext context, SellerListing listing) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    isScrollControlled: true,
    builder: (context) {
      final priceFormatter = NumberFormat('#,###');

      return Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🖼 Product Image (Tappable)
              GestureDetector(
                onTap: () {
                  if (listing.images.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FullImageView(
                          imageUrl: listing.images[0],
                        ),
                      ),
                    );
                  }
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    listing.images.isNotEmpty ? listing.images[0] : '',
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title
              CustomText(
                listing.title,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              const SizedBox(height: 6),

              // Price
              CustomText(
                "₦${priceFormatter.format(listing.price)}",
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
              const SizedBox(height: 16),

              // Condition
              CustomText(
                "Condition: ${listing.condition}",
                fontSize: 14,
                color: Colors.black87,
              ),
              const SizedBox(height: 8),

              // Size
              CustomText(
                "Size: ${listing.size}",
                fontSize: 14,
                color: Colors.black87,
              ),
              const SizedBox(height: 8),

              // Description
              CustomText(
                listing.description,
                fontSize: 14,
                color: Colors.black54,
              ),
              const SizedBox(height: 16),

              // Seller info
              Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundImage: listing.user.image != null
                        ? NetworkImage(listing.user.image!)
                        : null,
                    backgroundColor: Colors.purple.withOpacity(0.2),
                    child: listing.user.image == null
                        ? const Icon(Icons.person, color: Colors.purple, size: 24)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        listing.user.fullName,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      CustomText(
                        listing.user.address,
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Date
              CustomText(
                "Uploaded on ${DateFormat.yMMMd().format(listing.createdAt)}",
                fontSize: 13,
                color: Colors.black45,
              ),
              const SizedBox(height: 20),

              // Contact Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    // 🟢 Contact seller logic
                  },
                  child: const CustomText(
                    "Contact Seller",
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
