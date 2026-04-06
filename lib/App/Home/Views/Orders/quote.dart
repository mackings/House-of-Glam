import 'package:flutter/material.dart';
import 'package:hog/App/Home/Api/useractivity.dart';
import 'package:hog/App/Home/Model/reviewModel.dart';
import 'package:hog/App/Home/Views/Offers/Views/OfferHome.dart';
import 'package:hog/App/Home/Views/Offers/Widgets/createOffer.dart';
import 'package:hog/components/Navigator.dart';
import 'package:hog/components/Orders/Hireconf.dart';
import 'package:hog/components/Orders/PaymentOp.dart';
import 'package:hog/components/Orders/quotationcard.dart';
import 'package:hog/components/customAppbar.dart';
import 'package:hog/components/texts.dart';
import 'package:hog/theme/app_theme.dart';
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
  final Set<String> _submittedOfferReviewIds = {};

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

  void _showHireDesignerConfirmation(Review review) {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => HireDesignerConfirmation(
            onYes: () => _showPaymentOptions(review),
          ),
    );
  }

  void _showPaymentOptions(
    Review review, {
    String initialPaymentType = "part",
    bool allowPaymentTypeSwitch = true,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder:
          (context) => PaymentOptionsModal(
            review: review,
            initialPaymentType: initialPaymentType,
            allowPaymentTypeSwitch: allowPaymentTypeSwitch,
            onCheckout: (String url) async {
              await Future.delayed(const Duration(milliseconds: 250));
              if (mounted) _openCheckout(url);
            },
          ),
    );
  }

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
              backgroundColor: AppColors.canvas,
              appBar: const CustomAppBar(title: "Payments", enableAction: false),
              body: WebViewWidget(controller: controller),
            ),
      ),
    ).then((_) {
      controller.clearCache();
      fetchReviews();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          "Quotations",
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Nav.push(context, OfferHome());
            },
            icon: const Icon(Icons.local_offer_outlined),
            tooltip: "Offers",
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: fetchReviews,
        child:
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : reviews.isEmpty
                ? ListView(
                    children: const [
                      SizedBox(height: 220),
                      Center(child: CustomText("No quotations found")),
                    ],
                  )
                : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(14, 8, 14, 24),
                  itemCount: reviews.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomText(
                              "Review tailor quotations, accept the right fit, or negotiate with offers before payment.",
                              textAlign: TextAlign.left,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                            SizedBox(height: 6),
                            CustomText(
                              "Use the offer flow when you want to negotiate, or hire directly when the quote already works for you.",
                              textAlign: TextAlign.left,
                              color: AppColors.subtext,
                            ),
                          ],
                        ),
                      );
                    }

                    final review = reviews[index - 1];
                    return QuotationCard(
                      review: review,
                      onRefresh: fetchReviews,
                      hasSubmittedOffer: _submittedOfferReviewIds.contains(
                        review.id,
                      ),
                      onHireDesigner: () {
                        _showHireDesignerConfirmation(review);
                      },
                      onMakeOffer: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder:
                              (context) => CreateOfferSheet(
                                review: review,
                                onOfferCreated: () {
                                  setState(() {
                                    _submittedOfferReviewIds.add(review.id);
                                  });
                                },
                              ),
                        ).then((_) {
                          fetchReviews();
                        });
                      },
                      onCompletePayment: (_) {
                        if (review.status == "part payment") {
                          _showPaymentOptions(
                            review,
                            initialPaymentType: "full",
                            allowPaymentTypeSwitch: false,
                          );
                        } else {
                          _showPaymentOptions(
                            review,
                            initialPaymentType: "full",
                            allowPaymentTypeSwitch: false,
                          );
                        }
                      },
                    );
                  },
                ),
      ),
    );
  }
}
