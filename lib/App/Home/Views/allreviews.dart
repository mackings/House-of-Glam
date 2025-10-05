import 'package:flutter/material.dart';
import 'package:hog/App/Home/Api/reviewService.dart';
import 'package:hog/App/Home/Model/reviewModel.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:intl/intl.dart' show NumberFormat;

// class AllReviews extends StatefulWidget {
//   const AllReviews({super.key});

//   @override
//   State<AllReviews> createState() => _AllReviewsState();
// }

// class _AllReviewsState extends State<AllReviews> {
//   List<Review> reviews = [];
//   bool isLoading = false;

//   final NumberFormat currencyFormat = NumberFormat("#,###");

//   @override
//   void initState() {
//     super.initState();
//     fetchReviews();
//   }

//   Future<void> fetchReviews() async {
//     setState(() => isLoading = true);
//     final response = await ReviewService.getReviews();
//     if (response != null && response.success) {
//       setState(() => reviews = response.reviews);
//     }
//     setState(() => isLoading = false);
//   }

//   void showReviewDetails(Review review) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.white,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
//       ),
//       builder: (_) {
//         return Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//           child: SingleChildScrollView(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // drag handle
//                 Center(
//                   child: Container(
//                     height: 4,
//                     width: 40,
//                     margin: const EdgeInsets.only(bottom: 16),
//                     decoration: BoxDecoration(
//                       color: Colors.grey.shade300,
//                       borderRadius: BorderRadius.circular(4),
//                     ),
//                   ),
//                 ),

//                 Text("Measurements & Details",
//                     style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                           fontWeight: FontWeight.bold,
//                         )),
//                 const SizedBox(height: 12),

//                 // Measurements section (grid-like)
//                 Wrap(
//                   runSpacing: 10,
//                   spacing: 20,
//                   children: review.material.measurement.map((m) {
//                     return Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         _buildMeasureRow("Neck", m.neck.toString()),
//                         _buildMeasureRow("Shoulder", m.shoulder.toString()),
//                         _buildMeasureRow("Chest", m.chest.toString()),
//                         _buildMeasureRow("Waist", m.waist.toString()),
//                         _buildMeasureRow("Hip", m.hip.toString()),
//                         _buildMeasureRow("Sleeve", m.sleeveLength.toString()),
//                       ],
//                     );
//                   }).toList(),
//                 ),

//                 const SizedBox(height: 20),

//                 // Material chips
//                 Wrap(
//                   spacing: 8,
//                   runSpacing: 6,
//                   children: [
//                     review.material.attireType,
//                     review.material.clothMaterial,
//                     review.material.color,
//                     review.material.brand,
//                   ].map((label) {
//                     return Chip(
//                       label: Text(label,
//                           style: const TextStyle(
//                               color: Colors.white, fontSize: 13)),
//                       backgroundColor: Colors.purple,
//                       shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(20)),
//                     );
//                   }).toList(),
//                 ),

//                 const SizedBox(height: 20),

//                 Text("Comment",
//                     style: Theme.of(context)
//                         .textTheme
//                         .titleSmall
//                         ?.copyWith(fontWeight: FontWeight.bold)),
//                 const SizedBox(height: 6),
//                 Text(review.comment,
//                     style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                           color: Colors.black87,
//                         )),
//                 const SizedBox(height: 24),

//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.purple,
//                       shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12)),
//                       padding: const EdgeInsets.symmetric(vertical: 14),
//                     ),
//                     onPressed: () {},
//                     child: const Text("Hire Designer",
//                         style: TextStyle(color: Colors.white, fontSize: 16)),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildMeasureRow(String label, String value) {
//     return Row(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         const Icon(Icons.straighten, size: 18, color: Colors.purple),
//         const SizedBox(width: 6),
//         Text("$label: $value",
//             style:
//                 const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
//       ],
//     );
//   }

//  Widget buildReviewCard(Review review) {
//   return Container(
//     margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//     padding: const EdgeInsets.all(14),
//     decoration: BoxDecoration(
//       color: Colors.white,
//       border: Border.all(color: Colors.black, width: 0.1),
//       borderRadius: BorderRadius.circular(12),
//     ),
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // User & Vendor row
//         Row(
//           children: [
//             Row(
//               children: [
//                 const Icon(Icons.person, color: Colors.purple, size: 18),
//                 const SizedBox(width: 6),
//                 Text(
//                   review.user.fullName,
//                   style: const TextStyle(
//                       fontWeight: FontWeight.w600, fontSize: 14),
//                 ),
//               ],
//             ),
//             const Spacer(),
//             Row(
//               children: [
//                 const Icon(Icons.store, color: Colors.purple, size: 18),
//                 const SizedBox(width: 6),
//                 Text(
//                   review.vendor.businessName,
//                   style: const TextStyle(
//                       fontWeight: FontWeight.w600, fontSize: 14),
//                 ),
//               ],
//             ),
//           ],
//         ),
//         const SizedBox(height: 12),

//         // Carousel (if images exist)
//         if (review.material.sampleImage.isNotEmpty)
//           ClipRRect(
//             borderRadius: BorderRadius.circular(10),
//             child: CarouselSlider(
//               options: CarouselOptions(
//                 height: 120,
//                 autoPlay: true,
//                 enlargeCenterPage: false,
//                 viewportFraction: 1,
//               ),
//               items: review.material.sampleImage
//                   .map((img) => Image.network(
//                         img,
//                         fit: BoxFit.cover,
//                         width: double.infinity,
//                       ))
//                   .toList(),
//             ),
//           ),
//         if (review.material.sampleImage.isNotEmpty) const SizedBox(height: 12),

//         // Status & Cost
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Row(
//               children: [
//                 Icon(
//                   review.status == "approved"
//                       ? Icons.check_circle
//                       : Icons.hourglass_bottom, // pending icon
//                   color: review.status == "approved"
//                       ? Colors.green
//                       : Colors.orange,
//                   size: 18,
//                 ),
//                 const SizedBox(width: 6),
//                 Text(
//                   review.status.toUpperCase(),
//                   style: const TextStyle(
//                       fontWeight: FontWeight.w600, fontSize: 13),
//                 ),
//               ],
//             ),
//             Text(
//               "${currencySymbol}${currencyFormat.format(review.totalCost)}",
//               style: const TextStyle(
//                   fontWeight: FontWeight.bold, fontSize: 15),
//             ),
//           ],
//         ),
//         const SizedBox(height: 8),

//         // View More button
//         Align(
//           alignment: Alignment.centerRight,
//           child: TextButton(
//             onPressed: () => showReviewDetails(review),
//             style: TextButton.styleFrom(
//               foregroundColor: Colors.purple,
//               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//               minimumSize: Size.zero,
//             ),
//             child: const Text(
//               "View More",
//               style: TextStyle(fontSize: 13),
//             ),
//           ),
//         ),
//       ],
//     ),
//   );
// }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey.shade100,
//       appBar: AppBar(
//         title: const Text("All Reviews",
//             style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//         backgroundColor: Colors.purple,
//         elevation: 0,
//       ),
//       body: RefreshIndicator(
//         onRefresh: fetchReviews,
//         child: isLoading
//             ? const Center(child: CircularProgressIndicator())
//             : reviews.isEmpty
//                 ? const Center(child: Text("No reviews found"))
//                 : ListView.builder(
//                     padding: const EdgeInsets.only(bottom: 16),
//                     itemCount: reviews.length,
//                     itemBuilder: (context, index) =>
//                         buildReviewCard(reviews[index]),
//                   ),
//       ),
//     );
//   }
// }
