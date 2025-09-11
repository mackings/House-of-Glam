import 'package:flutter/material.dart';
import 'package:hog/App/Home/Api/reviewService.dart';
import 'package:hog/App/Home/Model/reviewModel.dart';
import 'package:hog/components/button.dart';
import 'package:hog/components/texts.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:intl/intl.dart' show NumberFormat;



class AllReviews extends StatefulWidget {
  const AllReviews({super.key});

  @override
  State<AllReviews> createState() => _AllReviewsState();
}

class _AllReviewsState extends State<AllReviews> {
  List<Review> reviews = [];
  bool isLoading = false;

  final NumberFormat currencyFormat = NumberFormat("#,###");

  @override
  void initState() {
    super.initState();
    fetchReviews();
  }

  Future<void> fetchReviews() async {
    setState(() => isLoading = true);
    final response = await ReviewService.getReviews();
    if (response != null && response.success) {
      setState(() => reviews = response.reviews);
    }
    setState(() => isLoading = false);
  }

  void showReviewDetails(Review review) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Close button
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, size: 28),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                CustomText("Measurements & Details", fontSize: 18, fontWeight: FontWeight.bold),
                const SizedBox(height: 12),

                // Measurements
                ...review.material.measurement.map((m) {
                  return Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.straighten, size: 20),
                              const SizedBox(width: 6),
                              CustomText("Neck: ${m.neck}"),
                            ],
                          ),
                          Row(
                            children: [
                              const Icon(Icons.straighten, size: 20),
                              const SizedBox(width: 6),
                              CustomText("Shoulder: ${m.shoulder}"),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.straighten, size: 20),
                              const SizedBox(width: 6),
                              CustomText("Chest: ${m.chest}"),
                            ],
                          ),
                          Row(
                            children: [
                              const Icon(Icons.straighten, size: 20),
                              const SizedBox(width: 6),
                              CustomText("Waist: ${m.waist}"),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.straighten, size: 20),
                              const SizedBox(width: 6),
                              CustomText("Hip: ${m.hip}"),
                            ],
                          ),
                          Row(
                            children: [
                              const Icon(Icons.straighten, size: 20),
                              const SizedBox(width: 6),
                              CustomText("Sleeve: ${m.sleeveLength}"),
                            ],
                          ),
                        ],
                      ),
                      const Divider(),
                    ],
                  );
                }).toList(),

                // Material chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      const SizedBox(width: 4),
                      ...[
                        review.material.attireType,
                        review.material.clothMaterial,
                        review.material.color,
                        review.material.brand,
                      ].map((label) => Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: Chip(
                              avatar: const Icon(Icons.check, size: 12, color: Colors.white),
                              label: CustomText(label, fontSize: 12, color: Colors.white),
                              backgroundColor: Colors.purple,
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            ),
                          )),
                    ],
                  ),
                ),

                const SizedBox(height: 16),
                CustomText("Comment:", fontWeight: FontWeight.bold),
                const SizedBox(height: 6),
                CustomText(review.comment),
                const SizedBox(height: 16),

                CustomButton(
                  title: "Hire Designer",
                  onPressed: () {
                    // Add hire designer functionality
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildReviewCard(Review review) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User & vendor
          Row(
            children: [
              const Icon(Icons.person, color: Colors.purple),
              const SizedBox(width: 8),
              Expanded(child: CustomText(review.user.fullName, fontWeight: FontWeight.bold)),
              const Icon(Icons.store, color: Colors.purple),
              const SizedBox(width: 8),
              Expanded(child: CustomText(review.vendor.businessName, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),

          // Carousel in container
          if (review.material.sampleImage.isNotEmpty)
            CarouselSlider(
              options: CarouselOptions(
                height: 100,
                autoPlay: true,
                enlargeCenterPage: true,
                viewportFraction: 0.8,
              ),
              items: review.material.sampleImage
                  .map((img) => ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(img, fit: BoxFit.cover, width: double.infinity),
                      ))
                  .toList(),
            ),
          const SizedBox(height: 10),

          // Status & total cost
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.check_circle, color: review.status == "approved" ? Colors.green : Colors.orange),
                  const SizedBox(width: 6),
                  CustomText(review.status.toUpperCase()),
                ],
              ),
              CustomText("₦${currencyFormat.format(review.totalCost)}", fontWeight: FontWeight.bold),
            ],
          ),
          const SizedBox(height: 10),

          // View more button
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => showReviewDetails(review),
              child: const Text("View More"),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const CustomText("All Reviews", color: Colors.white, fontSize: 20),
        backgroundColor: Colors.purple,
      ),
      body: RefreshIndicator(
        onRefresh: fetchReviews,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : reviews.isEmpty
                ? const Center(child: Text("No reviews found"))
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: reviews.length,
                    itemBuilder: (context, index) => buildReviewCard(reviews[index]),
                  ),
      ),
    );
  }
}

