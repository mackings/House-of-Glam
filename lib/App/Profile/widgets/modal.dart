import 'package:flutter/material.dart';
import 'package:hog/App/Profile/Api/BidPaymentService.dart';
import 'package:hog/App/Profile/Model/SellerListing.dart';
import 'package:hog/App/Profile/widgets/FullImageView.dart';
import 'package:hog/App/Profile/widgets/Payment.dart';
import 'package:hog/components/texts.dart';
import 'package:hog/constants/currency.dart';
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
      final pageController = PageController();

      return Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🖼 Slidable Product Images
              SizedBox(
                height: 220,
                child: Stack(
                  children: [
                    PageView.builder(
                      controller: pageController,
                      itemCount:
                          listing.images.isNotEmpty ? listing.images.length : 1,
                      itemBuilder: (context, index) {
                        final imageUrl =
                            listing.images.isNotEmpty
                                ? listing.images[index]
                                : '';

                        return GestureDetector(
                          onTap: () {
                            if (imageUrl.isNotEmpty) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => FullImageView(imageUrl: imageUrl),
                                ),
                              );
                            }
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              imageUrl.isNotEmpty
                                  ? imageUrl
                                  : 'https://via.placeholder.com/200',
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          ),
                        );
                      },
                    ),

                    // 🔘 Page Indicator
                    // 🔘 Page Indicator
                    Positioned(
                      bottom: 8,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(
                            listing.images.isNotEmpty
                                ? listing.images.length
                                : 1,
                            (index) => AnimatedBuilder(
                              animation: pageController,
                              builder: (context, child) {
                                double selected = 0;
                                if (pageController.hasClients) {
                                  selected =
                                      pageController.page ??
                                      pageController.initialPage.toDouble();
                                }

                                return Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 3,
                                  ),
                                  width: selected.round() == index ? 10 : 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color:
                                        selected.round() == index
                                            ? Colors.purple
                                            : Colors.grey.shade400,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
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
                listing.price == 0
                    ? "Free"
                    : "${currencySymbol}${priceFormatter.format(listing.price)}",
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
                    backgroundImage:
                        listing.user.image != null
                            ? NetworkImage(listing.user.image!)
                            : null,
                    backgroundColor: Colors.purple.withOpacity(0.2),
                    child:
                        listing.user.image == null
                            ? const Icon(
                              Icons.person,
                              color: Colors.purple,
                              size: 24,
                            )
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
                  onPressed: () async {
                    // ✅ Save a reference to the parent context
                    final parentContext = Navigator.of(context).context;

                    // ✅ Close the bottom sheet first
                    Navigator.pop(context);

                    // ✅ Call API
                    final response = await BidPaymentService.purchaseListings(
                      listingIds: [listing.id],
                      shipmentMethod: "Express",
                    );

                    if (response != null && response['success'] == true) {
                      final authUrl = response['authorizationUrl'];

                      Navigator.push(
                        parentContext,
                        MaterialPageRoute(
                          builder: (_) => PaymentWebView(paymentUrl: authUrl),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(parentContext).showSnackBar(
                        const SnackBar(content: Text("Failed to place order")),
                      );
                    }
                  },

                  child: const CustomText(
                    "Purchase",
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
