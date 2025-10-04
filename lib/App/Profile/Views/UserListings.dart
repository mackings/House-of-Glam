import 'package:flutter/material.dart';
import 'package:hog/App/Profile/Api/ListingService.dart';
import 'package:hog/App/Profile/Model/UploadedListings.dart';
import 'package:hog/App/Profile/widgets/uploadedListings.dart';


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
      builder: (context) => AlertDialog(
        title: const Text("Delete Listing"),
        content: const Text("Are you sure you want to delete this listing?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel")),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Delete", style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      final success = await MarketplaceService.deleteSellerListing(id);
      if (success) {
        setState(() {
          listings.removeWhere((l) => l!.id == id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Listing deleted successfully")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("❌ Failed to delete listing")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "My Listings",
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
        backgroundColor: Colors.purple,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : listings.isEmpty
              ? const Center(
                  child: Text(
                    "No listings yet.",
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchListings,
                  child: ListView.builder(
                    itemCount: listings.length,
                    itemBuilder: (context, index) {
                      final listing = listings[index];
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