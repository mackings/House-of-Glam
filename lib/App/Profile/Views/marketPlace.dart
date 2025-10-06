import 'package:flutter/material.dart';
import 'package:hog/App/Profile/Api/ListingService.dart';
import 'package:hog/App/Profile/Model/SellerListing.dart';
import 'package:hog/App/Profile/Views/UploadListing.dart';
import 'package:hog/App/Profile/widgets/modal.dart';
import 'package:hog/App/Profile/widgets/productCard.dart';
import 'package:hog/components/Navigator.dart';
import 'package:hog/components/formfields.dart';
import 'package:hog/components/texts.dart';

class MarketPlace extends StatefulWidget {
  const MarketPlace({super.key});

  @override
  State<MarketPlace> createState() => _MarketPlaceState();
}

class _MarketPlaceState extends State<MarketPlace> {
  late Future<SellerListingResponse?> _futureListings;
  List<SellerListing> _allListings = [];
  String _searchQuery = '';

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _futureListings = MarketplaceService.getAllSellerListings();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: const CustomText("Market Place", fontSize: 18, color: Colors.white),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: () {
              Nav.push(context, Uploadlisting());
            },
            icon: const Icon(Icons.upload_file),
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
                child: CustomText("Something went wrong!", fontSize: 16, color: Colors.black),
              );
            } else if (!snapshot.hasData || snapshot.data!.data.isEmpty) {
              return Center(
                child: CustomText("No products available", fontSize: 16, color: Colors.black),
              );
            }

            // Save data if not yet saved
            if (_allListings.isEmpty) {
              _allListings = snapshot.data!.data;
            }

            // Apply search filter
            final filteredListings = _searchQuery.isEmpty
                ? _allListings
                : _allListings.where((listing) {
                    return listing.title.toLowerCase().contains(_searchQuery) ||
                           listing.description.toLowerCase().contains(_searchQuery) ||
                           listing.category.name.toLowerCase().contains(_searchQuery);
                  }).toList();

            return Column(
              children: [

                Padding(
                  padding: const EdgeInsets.only(left: 15,right: 15),
                  child: CustomTextField(title: "", hintText: "Search Marketplace", fieldKey: "",prefixIcon: Icons.search_sharp,controller: _searchController,),
                ),
           

                // 🛍️ Product List
                Expanded(
                  child: filteredListings.isEmpty
                      ? const Center(child: Text('No products found'))
                      : ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: filteredListings.length,
                          itemBuilder: (context, index) {
                            final product = filteredListings[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: ProductCard(
                                listing: product,
                                onTap: () => showProductDetails(context, product),
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
