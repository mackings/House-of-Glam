import 'package:flutter/material.dart';
import 'package:hog/App/Admin/Model/PendingListing.dart';
import 'package:hog/components/button.dart';
import 'package:hog/components/texts.dart';



class PendingListingCard extends StatefulWidget {
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
  State<PendingListingCard> createState() => _PendingListingCardState();
}

class _PendingListingCardState extends State<PendingListingCard> {
  int _currentImageIndex = 0;
  late PageController _pageController;

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
    final images = listing.images.isNotEmpty
        ? listing.images
        : ['https://via.placeholder.com/300x200.png?text=No+Image'];

    // Get screen width for responsive sizing
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    final isMediumScreen = screenWidth >= 600 && screenWidth < 900;

    // Responsive sizing
    final imageHeight = isSmallScreen ? 180.0 : (isMediumScreen ? 220.0 : 250.0);
    final cardPadding = isSmallScreen ? 10.0 : 12.0;
    final cardMargin = isSmallScreen ? 8.0 : 12.0;
    final titleFontSize = isSmallScreen ? 16.0 : 18.0;
    final priceFontSize = isSmallScreen ? 14.0 : 16.0;
    final avatarRadius = isSmallScreen ? 18.0 : 22.0;

    return Card(
      margin: EdgeInsets.symmetric(vertical: cardMargin / 2, horizontal: cardMargin),
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(cardPadding),
        child: Column(
          children: [
            /// 🖼️ Image Carousel
            SizedBox(
              height: imageHeight,
              child: Stack(
                children: [
PageView.builder(
  controller: _pageController,
  itemCount: images.length,
  onPageChanged: (index) {
    setState(() => _currentImageIndex = index);
  },
  itemBuilder: (context, index) {
    return GestureDetector(
      onTap: () {
        // Open full-screen viewer
        showDialog(
          context: context,
          builder: (_) {
            return Dialog(
              insetPadding: EdgeInsets.zero,
              backgroundColor: Colors.black,
              child: Stack(
                children: [
                  PageView.builder(
                    itemCount: images.length,
                    controller: PageController(initialPage: index),
                    itemBuilder: (context, i) {
                      return InteractiveViewer(
                        child: Image.network(
                          images[i],
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => Center(
                            child: Icon(Icons.broken_image,
                                color: Colors.white70, size: 60),
                          ),
                        ),
                      );
                    },
                  ),
                  Positioned(
                    top: 40,
                    right: 20,
                    child: IconButton(
                      icon: const Icon(Icons.close,
                          color: Colors.white, size: 30),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          images[index],
          fit: BoxFit.cover,
          width: double.infinity,
          errorBuilder: (_, __, ___) => Container(
            color: Colors.grey.shade200,
            alignment: Alignment.center,
            child: const Icon(Icons.broken_image, size: 50),
          ),
        ),
      ),
    );
  },
),


                  /// 🔘 Page Indicators
                  if (images.length > 1)
                    Positioned(
                      bottom: 8,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          images.length,
                          (index) => Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: _currentImageIndex == index ? 10 : 6,
                            height: _currentImageIndex == index ? 10 : 6,
                            decoration: BoxDecoration(
                              color: _currentImageIndex == index
                                  ? Colors.purple
                                  : Colors.grey.shade400,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            SizedBox(height: isSmallScreen ? 8 : 12),

            /// 🟣 Title & Price Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
             // crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  listing.title,
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                const SizedBox(width: 8),
                CustomText(
                  "₦${listing.price.toStringAsFixed(2)}",
                  fontSize: priceFontSize,
                  fontWeight: FontWeight.w600,
                  color: Colors.purple,
                ),
              ],
            ),

            SizedBox(height: isSmallScreen ? 8 : 12),

            /// 🔥 Seller Info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Condition
                Flexible(
                  child: CustomText(
                    listing.condition,
                    fontSize: isSmallScreen ? 12 : 13,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(width: 8),

                // Seller Details
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      /// Avatar
                      CircleAvatar(
                        radius: avatarRadius,
                        backgroundImage: (listing.user.image != null &&
                                listing.user.image!.isNotEmpty)
                            ? NetworkImage(listing.user.image!)
                            : null,
                        backgroundColor: Colors.grey.shade300,
                        child: (listing.user.image == null ||
                                listing.user.image!.isEmpty)
                            ? Icon(
                                Icons.person,
                                color: Colors.white,
                                size: avatarRadius,
                              )
                            : null,
                      ),
                      const SizedBox(height: 6),

                      /// Seller Name
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.person,
                            size: isSmallScreen ? 14 : 16,
                            color: Colors.purple,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: CustomText(
                              listing.user.fullName.isNotEmpty
                                  ? listing.user.fullName
                                  : "Unknown Seller",
                              fontSize: isSmallScreen ? 12 : 14,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      /// Seller Location
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.location_on,
                            size: isSmallScreen ? 14 : 16,
                            color: Colors.purple,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: CustomText(
                              listing.user.address.isNotEmpty
                                  ? listing.user.address
                                  : "No address provided",
                              fontSize: isSmallScreen ? 11 : 13,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: isSmallScreen ? 12 : 16),

            /// ✅ Approve & Reject Buttons
            /// 
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    title: "Approve",
                    onPressed: widget.onApprove,
                    isOutlined: true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomButton(
                    title: "Reject",
                    onPressed: widget.onReject,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}