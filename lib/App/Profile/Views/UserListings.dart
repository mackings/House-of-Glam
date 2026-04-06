import 'package:flutter/material.dart';
import 'package:hog/App/Profile/Api/ListingService.dart';
import 'package:hog/App/Profile/Model/UploadedListings.dart';
import 'package:hog/App/Profile/widgets/uploadedListings.dart';
import 'package:hog/components/texts.dart';
import 'package:hog/theme/app_theme.dart';

class Userlistings extends StatefulWidget {
  const Userlistings({super.key});

  @override
  State<Userlistings> createState() => _UserlistingsState();
}

class _UserlistingsState extends State<Userlistings> {
  List<UserListing> listings = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchListings();
  }

  Future<void> _fetchListings() async {
    setState(() => isLoading = true);
    listings = await MarketplaceService.getSellerListings();
    setState(() => isLoading = false);
  }

  Future<void> _deleteListing(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            title: const Text("Delete Listing"),
            content: const Text(
              "Are you sure you want to delete this listing?",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.danger,
                  foregroundColor: Colors.white,
                ),
                child: const Text("Delete"),
              ),
            ],
          ),
    );

    if (confirm == true) {
      final success = await MarketplaceService.deleteSellerListing(id);
      if (!mounted) return;
      if (success) {
        setState(() {
          listings.removeWhere((l) => l.id == id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Listing deleted successfully")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to delete listing")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          "My Listings",
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : listings.isEmpty
              ? ListView(
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 24),
                children: [
                  Container(
                    padding: const EdgeInsets.all(26),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 92,
                          height: 92,
                          decoration: BoxDecoration(
                            color: AppColors.accentSoft,
                            borderRadius: BorderRadius.circular(28),
                          ),
                          child: const Icon(
                            Icons.inventory_2_outlined,
                            size: 40,
                            color: AppColors.accent,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const CustomText(
                          "No listings yet",
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                        const SizedBox(height: 8),
                        const CustomText(
                          "Your uploaded marketplace items will appear here once you create them.",
                          color: AppColors.subtext,
                        ),
                      ],
                    ),
                  ),
                ],
              )
              : RefreshIndicator(
                onRefresh: _fetchListings,
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 24),
                  itemCount: listings.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomText(
                              "Manage your marketplace listings",
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              textAlign: TextAlign.left,
                            ),
                            SizedBox(height: 4),
                            CustomText(
                              "Review your uploads, keep track of item details, and remove listings you no longer want visible.",
                              fontSize: 12,
                              color: AppColors.subtext,
                              textAlign: TextAlign.left,
                            ),
                          ],
                        ),
                      );
                    }

                    final listing = listings[index - 1];
                    return UserListingCard(
                      listing: listing,
                      onDelete: () => _deleteListing(listing.id),
                    );
                  },
                ),
              ),
    );
  }
}
