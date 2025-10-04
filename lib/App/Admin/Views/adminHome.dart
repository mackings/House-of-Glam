import 'package:flutter/material.dart';
import 'package:hog/App/Admin/Api/adminService.dart';
import 'package:hog/App/Admin/Model/PendingListing.dart';
import 'package:hog/App/Admin/Widgets/PendingCard.dart';
import 'package:hog/App/Admin/Widgets/rejectionSheet.dart';



class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  late Future<List<PendingSellerListing>> _pendingListings;

  @override
  void initState() {
    super.initState();
    _pendingListings = AdminService.getAllPendingListings();
  }

  void _refresh() {
    setState(() {
      _pendingListings = AdminService.getAllPendingListings();
    });
  }

  void _showRejectSheet(String listingId) {
    final controller = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // ✅ makes it expand with keyboard
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return RejectReasonSheet(
          controller: controller,
          onSubmit: () async {
            final reason = controller.text.trim();
            if (reason.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Please enter a rejection reason")),
              );
              return;
            }

            Navigator.pop(context); // close the sheet
            final success = await AdminService.rejectListing(listingId, reason);
            if (success) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Listing rejected")),
              );
              _refresh();
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: const Text("Admin", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<List<PendingSellerListing>>(
        future: _pendingListings,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.purple),
            );
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Error loading listings"));
          }

          final listings = snapshot.data ?? [];
          if (listings.isEmpty) {
            return const Center(child: Text("No pending listings"));
          }

          return ListView.builder(
            itemCount: listings.length,
            itemBuilder: (context, index) {
              final listing = listings[index];
              return PendingListingCard(
                listing: listing,
                onApprove: () async {
                  final success =
                      await AdminService.approveListing(listing.id);
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Listing approved")),
                    );
                    _refresh();
                  }
                },
                onReject: () => _showRejectSheet(listing.id),
              );
            },
          );
        },
      ),
    );
  }
}
