import 'package:flutter/material.dart';
import 'package:hog/App/Admin/Model/PendingListing.dart';


class PendingListingCard extends StatelessWidget {
  final PendingSellerListing listing;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const PendingListingCard({
    super.key,
    required this.listing,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
     
            SizedBox(
              height: 180,
              child: PageView(
                children: listing.images
                    .map((img) => ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(img, fit: BoxFit.cover),
                        ))
                    .toList(),
              ),
            ),
            const SizedBox(height: 8),

            // Title & Price
            Text(
              listing.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            Text("₦${listing.price}",
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.purple,
                  fontWeight: FontWeight.w600,
                )),
            const SizedBox(height: 4),

            
            Text(
              "Seller: ${listing.user.fullName} (${listing.user.address})",
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
            Text("Category: ${listing.category.name}",
                style: const TextStyle(fontSize: 14, color: Colors.black54)),
            const SizedBox(height: 10),

          
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: onApprove,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                  ),
                  child: const Text("Approve",
                      style: TextStyle(color: Colors.white)),
                ),
                ElevatedButton(
                  onPressed: onReject,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                  ),
                  child:
                      const Text("Reject", style: TextStyle(color: Colors.white)),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
