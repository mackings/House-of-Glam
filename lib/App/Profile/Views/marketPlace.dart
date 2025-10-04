import 'package:flutter/material.dart';
import 'package:hog/App/Profile/Api/ListingService.dart';
import 'package:hog/App/Profile/Model/SellerListing.dart';
import 'package:hog/App/Profile/Views/UploadListing.dart';
import 'package:hog/App/Profile/widgets/modal.dart';
import 'package:hog/App/Profile/widgets/productCard.dart';
import 'package:hog/components/Navigator.dart';
import 'package:hog/components/texts.dart';

class MarketPlace extends StatefulWidget {
  const MarketPlace({super.key});

  @override
  State<MarketPlace> createState() => _MarketPlaceState();
}

class _MarketPlaceState extends State<MarketPlace> {
  late Future<SellerListingResponse?> _futureListings;

  @override
  void initState() {
    super.initState();
    _futureListings = MarketplaceService.getAllSellerListings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: CustomText("Market Place", fontSize: 18, color: Colors.white),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: () {
              Nav.push(context, Uploadlisting());
            },
            icon: Icon(Icons.upload_file),
          ),
        ],
      ),
      body: SafeArea(
        child: FutureBuilder<SellerListingResponse?>(
          future: _futureListings,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.purple),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: CustomText(
                  "Something went wrong!",
                  fontSize: 16,
                  color: Colors.black,
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.data.isEmpty) {
              return Center(
                child: CustomText(
                  "No products available",
                  fontSize: 16,
                  color: Colors.black,
                ),
              );
            }

            final listings = snapshot.data!.data;

            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: listings.length,
              itemBuilder: (context, index) {
                final product = listings[index];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ProductCard(
                    listing: product,
                    onTap: () {
                      showProductDetails(context, product);
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
