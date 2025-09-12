import 'package:flutter/material.dart';
import 'package:hog/App/Home/Api/useractivity.dart';
import 'package:hog/App/Home/Model/reviewModel.dart';
import 'package:hog/components/Orders/quotationcard.dart';
import 'package:hog/components/texts.dart';



class Quotation extends StatefulWidget {
  final String materialId; // pass it via constructor

  const Quotation({super.key, required this.materialId});

  @override
  State<Quotation> createState() => _QuotationState();
}

class _QuotationState extends State<Quotation> {
  bool isLoading = false;
  List<Review> reviews = [];

  @override
  void initState() {
    super.initState();
    fetchReviews(); // use widget.materialId directly
  }

  Future<void> fetchReviews() async {
    setState(() => isLoading = true);
    final response = await UserActivityService.getReviewsForMaterialById(widget.materialId);
    if (response != null && response.success) {
      setState(() => reviews = response.reviews);
    }
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: const CustomText("Quotations", color: Colors.white, fontSize: 18),
        backgroundColor: Colors.purple,
      ),
      body: RefreshIndicator(
        onRefresh: fetchReviews,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : reviews.isEmpty
                ? const Center(child: CustomText("No quotations found"))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                    itemCount: reviews.length,
                    itemBuilder: (context, index) {
                      return QuotationCard(review: reviews[index], onHireDesigner: () {  },);
                    },
                  ),
      ),
    );
  }
}


