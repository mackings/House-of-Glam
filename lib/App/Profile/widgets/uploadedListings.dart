import 'package:flutter/material.dart';
import 'package:hog/App/Profile/Model/UploadedListings.dart';
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
    return "₦${formatter.format(price)}";
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 4,
      shadowColor: Colors.purple.withOpacity(0.2),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 📷 Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                listing.images.isNotEmpty
                    ? listing.images.first
                    : 'https://via.placeholder.com/80',
                width: 90,
                height: 90,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),

            // 📝 Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    listing.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 4),

                  // Price
                  Text(
                    formatPrice(listing.price),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.purple,
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Size & Condition
                  Row(
                    children: [
                      Icon(Icons.checkroom, size: 14, color: Colors.grey[700]),
                      const SizedBox(width: 4),
                      Text(
                        "Size: ${listing.size}",
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.info_outline,
                        size: 14,
                        color: Colors.grey[700],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        listing.condition,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  // Date Uploaded
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: Colors.grey[700],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "Uploaded: ${DateFormat.yMMMd().format(listing.createdAt)}",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 🗑️ Delete Button
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                showDialog(
                  context: context,
                  builder:
                      (_) => AlertDialog(
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
                              backgroundColor: Colors.red,
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
              },
            ),
          ],
        ),
      ),
    );
  }
}
