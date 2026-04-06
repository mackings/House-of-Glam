import 'package:flutter/material.dart';
import 'package:hog/App/Profile/Api/BidPaymentService.dart';
import 'package:hog/App/Profile/Model/SellerListing.dart';
import 'package:hog/App/Profile/widgets/FullImageView.dart';
import 'package:hog/App/Profile/widgets/Payment.dart';
import 'package:hog/components/texts.dart';
import 'package:hog/constants/currency.dart';
import 'package:hog/theme/app_theme.dart';
import 'package:intl/intl.dart';

void showProductDetails(BuildContext context, SellerListing listing) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    isScrollControlled: true,
    builder: (context) {
      final priceFormatter = NumberFormat('#,###');
      final pageController = PageController();

      Future<void> handlePurchase() async {
        final navigator = Navigator.of(context);
        final messenger = ScaffoldMessenger.of(context);
        Navigator.pop(context);

        final response = await BidPaymentService.purchaseListings(
          listingIds: [listing.id],
          shipmentMethod: "Express",
        );

        if (response != null && response['success'] == true) {
          final authUrl = response['authorizationUrl'];

          navigator.push(
            MaterialPageRoute(
              builder: (_) => PaymentWebView(paymentUrl: authUrl),
            ),
          );
        } else {
          messenger.showSnackBar(
            const SnackBar(content: Text("Failed to place order")),
          );
        }
      }

      return SafeArea(
        top: true,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            18,
            14,
            18,
            MediaQuery.of(context).viewInsets.bottom + 26,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 52,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _HeaderButton(
                    icon: Icons.arrow_back_ios_new_rounded,
                    onTap: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          "Listing Details",
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          textAlign: TextAlign.left,
                        ),
                        SizedBox(height: 2),
                        CustomText(
                          "Browse the approved item details before purchase.",
                          fontSize: 12,
                          color: AppColors.subtext,
                          textAlign: TextAlign.left,
                        ),
                      ],
                    ),
                  ),
                  _HeaderButton(
                    icon: Icons.close_rounded,
                    onTap: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              SizedBox(
                height: 250,
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
                            borderRadius: BorderRadius.circular(24),
                            child:
                                imageUrl.isNotEmpty
                                    ? Image.network(
                                      imageUrl,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                    )
                                    : Container(
                                      color: AppColors.surfaceMuted,
                                      child: const Center(
                                        child: Icon(
                                          Icons.image_not_supported_outlined,
                                          size: 42,
                                          color: AppColors.subtext,
                                        ),
                                      ),
                                    ),
                          ),
                        );
                      },
                    ),
                    Positioned(
                      top: 14,
                      right: 14,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: CustomText(
                          listing.price == 0
                              ? "Free"
                              : "$currencySymbol${priceFormatter.format(listing.price)}",
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: AppColors.accent,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 12,
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
                                  width: selected.round() == index ? 20 : 7,
                                  height: 7,
                                  decoration: BoxDecoration(
                                    color:
                                        selected.round() == index
                                            ? Colors.white
                                            : Colors.white.withValues(
                                              alpha: 0.45,
                                            ),
                                    borderRadius: BorderRadius.circular(999),
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
              const SizedBox(height: 18),
              CustomText(
                listing.title,
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _MetaChip(
                    icon: Icons.category_outlined,
                    label: listing.category.name,
                  ),
                  _MetaChip(
                    icon: Icons.info_outline_rounded,
                    label: listing.condition,
                  ),
                  if (listing.size.isNotEmpty)
                    _MetaChip(
                      icon: Icons.straighten_rounded,
                      label: listing.size,
                    ),
                ],
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CustomText(
                      "Description",
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      textAlign: TextAlign.left,
                    ),
                    const SizedBox(height: 8),
                    CustomText(
                      listing.description,
                      fontSize: 13,
                      color: AppColors.subtext,
                      textAlign: TextAlign.left,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.border),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 18,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundImage:
                          listing.user.image != null &&
                                  listing.user.image!.isNotEmpty
                              ? NetworkImage(listing.user.image!)
                              : null,
                      backgroundColor: AppColors.accentSoft,
                      child:
                          listing.user.image == null ||
                                  listing.user.image!.isEmpty
                              ? const Icon(
                                Icons.person_outline_rounded,
                                color: AppColors.accent,
                                size: 22,
                              )
                              : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            listing.user.fullName,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.ink,
                            textAlign: TextAlign.left,
                          ),
                          if (listing.user.address.isNotEmpty)
                            CustomText(
                              listing.user.address,
                              fontSize: 12,
                              color: AppColors.subtext,
                              textAlign: TextAlign.left,
                            ),
                          const SizedBox(height: 4),
                          CustomText(
                            "Uploaded ${DateFormat.yMMMd().format(listing.createdAt)}",
                            fontSize: 11,
                            color: AppColors.subtext,
                            textAlign: TextAlign.left,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  onPressed: handlePurchase,
                  icon: const Icon(Icons.shopping_bag_outlined, size: 18),
                  label: const Text(
                    "Purchase Listing",
                    style: TextStyle(fontWeight: FontWeight.w700),
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

class _HeaderButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(icon, size: 18, color: AppColors.ink),
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
