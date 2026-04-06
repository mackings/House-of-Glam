import 'package:flutter/material.dart';
import 'package:hog/App/Profile/Api/ListingService.dart';
import 'package:hog/App/Profile/Model/SellerListing.dart';
import 'package:hog/App/Profile/Views/UploadListing.dart';
import 'package:hog/App/Profile/widgets/modal.dart';
import 'package:hog/App/Profile/widgets/productCard.dart';
import 'package:hog/components/Navigator.dart';
import 'package:hog/components/formfields.dart';
import 'package:hog/components/texts.dart';
import 'package:hog/theme/app_theme.dart';

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
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          "Market Place",
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Nav.push(context, Uploadlisting());
            },
            icon: const Icon(Icons.add_business_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: FutureBuilder<SellerListingResponse?>(
          future: _futureListings,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(
                child: CustomText(
                  "Something went wrong!",
                  fontSize: 16,
                  color: Colors.black,
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.data.isEmpty) {
              return const Center(
                child: CustomText(
                  "No products available",
                  fontSize: 16,
                  color: Colors.black,
                ),
              );
            }

            if (_allListings.isEmpty) {
              _allListings = snapshot.data!.data;
            }

            final filteredListings =
                _searchQuery.isEmpty
                    ? _allListings
                    : _allListings.where((listing) {
                      return listing.title.toLowerCase().contains(
                            _searchQuery,
                          ) ||
                          listing.description.toLowerCase().contains(
                            _searchQuery,
                          ) ||
                          listing.category.name.toLowerCase().contains(
                            _searchQuery,
                          );
                    }).toList();

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 6, 14, 4),
                  child: CustomTextField(
                    title: "",
                    hintText: "Search marketplace",
                    fieldKey: "marketplace_search",
                    prefixIcon: Icons.search_rounded,
                    controller: _searchController,
                    isCompact: true,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.fromLTRB(14, 4, 14, 8),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        "Browse approved listings",
                        textAlign: TextAlign.left,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                      SizedBox(height: 4),
                      CustomText(
                        "Search by title, description, or category and open any item for details.",
                        textAlign: TextAlign.left,
                        fontSize: 12,
                        color: AppColors.subtext,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child:
                      filteredListings.isEmpty
                          ? const Center(child: Text('No products found'))
                          : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(14, 6, 14, 24),
                            itemCount: filteredListings.length,
                            itemBuilder: (context, index) {
                              final product = filteredListings[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: ProductCard(
                                  listing: product,
                                  onTap:
                                      () =>
                                          showProductDetails(context, product),
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
