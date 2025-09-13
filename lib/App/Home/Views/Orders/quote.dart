import 'package:flutter/material.dart';
import 'package:hog/App/Home/Api/paymentService.dart';
import 'package:hog/App/Home/Api/useractivity.dart';
import 'package:hog/App/Home/Model/reviewModel.dart';
import 'package:hog/components/Orders/Hireconf.dart';
import 'package:hog/components/Orders/PaymentOp.dart';
import 'package:hog/components/Orders/quotationcard.dart';
import 'package:hog/components/texts.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Quotation extends StatefulWidget {
  final String materialId;

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
    fetchReviews();
  }

  Future<void> fetchReviews() async {
    setState(() => isLoading = true);
    final response = await UserActivityService.getReviewsForMaterialById(
      widget.materialId,
    );
    if (response != null && response.success) {
      setState(() => reviews = response.reviews);
    }
    setState(() => isLoading = false);
  }

  // Show Hire Designer Modal
  void _showHireDesignerConfirmation(Review review) {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => HireDesignerConfirmation(
            onYes: () => _showPaymentOptions(review),
          ),
    );
  }

  // Show Payment Options Modal
// Show Payment Options Modal
void _showPaymentOptions(Review review) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => PaymentOptionsModal(
      review: review,
      onCheckout: (String url) async {
        // Close the modal first
        Navigator.pop(context);
        
        // Wait for the modal to fully animate out
        await Future.delayed(const Duration(milliseconds: 350));
        
        // Now open the WebView
        if (mounted) {
          _openCheckout(url);
        }
      },
    ),
  );
}

  // Immediately call payment API, then go to WebView
  Future<void> _initiatePayment(
    Review review,
    String paymentType, {
    String? partAmount,
    String shipment = "Regular",
  }) async {
    setState(() => isLoading = true);

    try {
      String amountToSend =
          paymentType == "part"
              ? (partAmount?.replaceAll(",", "") ?? "0")
              : review.totalCost.toString();

      final resp =
          paymentType == "part"
              ? await PaymentService.createPartPayment(
                reviewId: review.id,
                amount: amountToSend,
                shipmentMethod: shipment,
              )
              : await PaymentService.createFullPayment(
                reviewId: review.id,
                amount: amountToSend,
                shipmentMethod: shipment,
              );

      if (resp != null && resp["success"] == true) {
        final authUrl = resp["authorizationUrl"];
        if (authUrl != null) {
          // Close any open modals before opening WebView
          Navigator.of(
            context,
            rootNavigator: true,
          ).popUntil((route) => route.isFirst);
          _openCheckout(authUrl);
        } else {
          print("❌ No authorization URL returned");
        }
      } else {
        print("❌ Payment failed: ${resp?["message"]}");
      }
    } catch (e) {
      print("❌ Error during payment: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  // Open Paystack checkout in WebView
  void _openCheckout(String url) {
    final controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..loadRequest(Uri.parse(url));

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => Scaffold(
              backgroundColor: Colors.purple,
              appBar: AppBar(
                 backgroundColor: Colors.purple,
                title: const CustomText("Payments",color: Colors.white,fontSize: 18,),
              iconTheme: IconThemeData(color: Colors.white),
              ),
              body: WebViewWidget(controller: controller),
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const CustomText(
          "Quotations",
          color: Colors.white,
          fontSize: 18,
        ),
        backgroundColor: Colors.purple,
      ),
      body: RefreshIndicator(
        onRefresh: fetchReviews,
        child:
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : reviews.isEmpty
                ? const Center(child: CustomText("No quotations found"))
                : ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 12,
                  ),
                  itemCount: reviews.length,
                  itemBuilder: (context, index) {
                    return QuotationCard(
                      review: reviews[index],
                      onHireDesigner:
                          () => _showHireDesignerConfirmation(reviews[index]),
                    );
                  },
                ),
      ),
    );
  }
}
