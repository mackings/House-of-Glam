import 'package:flutter/material.dart';
import 'package:hog/App/Auth/Api/secure.dart';
import 'package:hog/App/Home/Views/Offers/Api/OfferService.dart';
import 'package:hog/App/Home/Views/Offers/Widgets/chatSection.dart';
import 'package:hog/App/Home/Views/Offers/Widgets/chatSummary.dart';
import 'package:hog/components/texts.dart';
import 'package:hog/constants/currency.dart';
import 'package:hog/constants/currencyHelper.dart';
import 'package:intl/intl.dart';

class OfferDetail extends StatefulWidget {
  final Map<String, dynamic> offer;

  const OfferDetail({super.key, required this.offer});

  @override
  State<OfferDetail> createState() => _OfferDetailState();
}

class _OfferDetailState extends State<OfferDetail> {
  final TextEditingController _commentCtrl = TextEditingController();
  final TextEditingController _materialCtrl = TextEditingController();
  final TextEditingController _workmanshipCtrl = TextEditingController();

  bool _isSubmitting = false;
  String? _userRole;

  Map<String, dynamic> get offer => widget.offer;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
    _initializeAmounts();
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    _materialCtrl.dispose();
    _workmanshipCtrl.dispose();
    super.dispose();
  }

  Future<void> _initializeAmounts() async {
    final materialNGN =
        int.tryParse(offer["materialTotalCost"]?.toString() ?? "0") ?? 0;
    final workmanshipNGN =
        int.tryParse(offer["workmanshipTotalCost"]?.toString() ?? "0") ?? 0;

    // ✅ Convert to user's currency for display
    final convertedMaterial = await CurrencyHelper.convertFromNGN(materialNGN);
    final convertedWorkmanship = await CurrencyHelper.convertFromNGN(
      workmanshipNGN,
    );

    setState(() {
      _materialCtrl.text = convertedMaterial.toStringAsFixed(2);
      _workmanshipCtrl.text = convertedWorkmanship.toStringAsFixed(2);
    });
  }

  Future<void> _loadUserRole() async {
    final userData = await SecurePrefs.getUserData();
    setState(() => _userRole = userData?["role"]);
  }

  String formatAmount(double amount) {
    return NumberFormat('#,###.##').format(amount);
  }

  String formatDate(String? raw) {
    if (raw == null || raw.isEmpty) return '-';
    try {
      final dt = DateTime.parse(raw);
      return DateFormat('dd MMM yyyy • hh:mm a').format(dt.toLocal());
    } catch (_) {
      return raw;
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(child: CustomText(msg, color: Colors.white)),
          ],
        ),
        backgroundColor: isError ? Colors.red.shade600 : Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _makeOffer() async {
    if (_userRole != "user") {
      return _showSnack("Only buyers can make offers.", isError: true);
    }

    final reviewId = offer["reviewId"]?["_id"];
    if (reviewId == null) {
      return _showSnack("Missing review ID", isError: true);
    }

    final comment = _commentCtrl.text.trim();
    final matDisplay = _materialCtrl.text.trim();
    final workDisplay = _workmanshipCtrl.text.trim();

    if (comment.isEmpty || matDisplay.isEmpty || workDisplay.isEmpty) {
      return _showSnack("Please fill all fields", isError: true);
    }

    // ✅ Convert back to NGN before sending to API
    final matNGN = await CurrencyHelper.convertToNGN(
      double.tryParse(matDisplay.replaceAll(',', '')) ?? 0,
    );
    final workNGN = await CurrencyHelper.convertToNGN(
      double.tryParse(workDisplay.replaceAll(',', '')) ?? 0,
    );

    setState(() => _isSubmitting = true);
    final res = await OfferService.makeOffer(
      reviewId: reviewId,
      comment: comment,
      materialTotalCost: matNGN.toString(),
      workmanshipTotalCost: workNGN.toString(),
    );
    setState(() => _isSubmitting = false);

    final ok = (res["success"] == true);
    _showSnack(
      res["message"] ??
          (ok ? "Offer created successfully" : "Failed to create offer"),
      isError: !ok,
    );
    if (ok) Navigator.pop(context);
  }

  Future<void> _replyOffer(String action) async {
    final offerId = offer["_id"];
    if (offerId == null) {
      return _showSnack("Missing offer ID", isError: true);
    }

    final comment = _commentCtrl.text.trim();
    final counterMatDisplay = _materialCtrl.text.trim();
    final counterWorkDisplay = _workmanshipCtrl.text.trim();

    if (comment.isEmpty) {
      return _showSnack("Please add a comment", isError: true);
    }

    if (action == "accepted" &&
        (counterMatDisplay.isEmpty || counterWorkDisplay.isEmpty)) {
      return _showSnack(
        "Please enter amounts before accepting.",
        isError: true,
      );
    }

    // ✅ Convert back to NGN
    final counterMatNGN =
        counterMatDisplay.isEmpty
            ? 0
            : await CurrencyHelper.convertToNGN(
              double.tryParse(counterMatDisplay.replaceAll(',', '')) ?? 0,
            );
    final counterWorkNGN =
        counterWorkDisplay.isEmpty
            ? 0
            : await CurrencyHelper.convertToNGN(
              double.tryParse(counterWorkDisplay.replaceAll(',', '')) ?? 0,
            );

    setState(() => _isSubmitting = true);
    Map<String, dynamic> res;

    if (_userRole == "user") {
      res = await OfferService.buyerReplyOffer(
        offerId: offerId,
        comment: comment,
        counterMaterialCost: counterMatNGN.toString(),
        counterWorkmanshipCost: counterWorkNGN.toString(),
        action: action,
      );
    } else {
      res = await OfferService.vendorReplyOffer(
        offerId: offerId,
        comment: comment,
        counterMaterialCost: counterMatNGN.toString(),
        counterWorkmanshipCost: counterWorkNGN.toString(),
        action: action,
      );
    }

    setState(() => _isSubmitting = false);

    final ok = (res["success"] == true);
    _showSnack(
      res["message"] ??
          (ok ? "Reply sent successfully" : "Failed to send reply"),
      isError: !ok,
    );
    if (ok) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final user = offer["userId"] ?? {};
    final vendor = offer["vendorId"] ?? {};

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: CustomText(
          vendor["businessName"] ?? user["fullName"] ?? "Offer Detail",
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        backgroundColor: Colors.purple,
        elevation: 0,
      ),
      body:
          _userRole == null
              ? const Center(child: CircularProgressIndicator())
              : SafeArea(
                child: Column(
                  children: [
                    // ✅ Fintech-style gradient header
                    // Container(
                    //   width: double.infinity,
                    //   decoration: BoxDecoration(
                    //     gradient: LinearGradient(
                    //       colors: [Colors.purple, Colors.purple.shade700],
                    //       begin: Alignment.topLeft,
                    //       end: Alignment.bottomRight,
                    //     ),
                    //   ),
                    //   padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    //   child: FutureBuilder<Map<String, double>>(
                    //     future: _convertHeaderAmounts(),
                    //     builder: (context, snapshot) {
                    //       final displayMaterial = snapshot.data?['material'] ?? 0.0;
                    //       final displayWorkmanship = snapshot.data?['workmanship'] ?? 0.0;
                    //       final displayTotal = displayMaterial + displayWorkmanship;

                    //       return Column(
                    //         children: [
                    //           // Total amount
                    //           CustomText(
                    //             "Offer Amount",
                    //             fontSize: 13,
                    //             color: Colors.white70,
                    //           ),
                    //           const SizedBox(height: 4),
                    //           CustomText(
                    //             "$currencySymbol${formatAmount(displayTotal)}",
                    //             fontSize: 32,
                    //             fontWeight: FontWeight.bold,
                    //             color: Colors.white,
                    //           ),
                    //           const SizedBox(height: 16),

                    //           // Breakdown
                    //           Container(
                    //             padding: const EdgeInsets.all(16),
                    //             decoration: BoxDecoration(
                    //               color: Colors.white.withOpacity(0.15),
                    //               borderRadius: BorderRadius.circular(12),
                    //               border: Border.all(
                    //                 color: Colors.white.withOpacity(0.3),
                    //                 width: 1,
                    //               ),
                    //             ),
                    //             child: Row(
                    //               mainAxisAlignment: MainAxisAlignment.spaceAround,
                    //               children: [
                    //                 _buildBreakdownItem(
                    //                   "Material",
                    //                   displayMaterial,
                    //                   Icons.checkroom,
                    //                 ),
                    //                 Container(
                    //                   width: 1,
                    //                   height: 40,
                    //                   color: Colors.white.withOpacity(0.3),
                    //                 ),
                    //                 _buildBreakdownItem(
                    //                   "Workmanship",
                    //                   displayWorkmanship,
                    //                   Icons.handyman,
                    //                 ),
                    //               ],
                    //             ),
                    //           ),
                    //         ],
                    //       );
                    //     },
                    //   ),
                    // ),

                    // Content
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: [
                            // ✅ Fintech-style summary card
                            // ChatSummaryCard(
                            //   offer: offer,
                            //   user: user,
                            //   vendor: vendor,
                            //   formatAmount: formatAmount,
                            //   formatDate: formatDate,
                            // ),
                            const SizedBox(height: 12),

                            Expanded(
                              child: ChatSection(
                                offer: offer,
                                userRole: _userRole!,
                                commentCtrl: _commentCtrl,
                                materialCtrl: _materialCtrl,
                                workmanshipCtrl: _workmanshipCtrl,
                                isSubmitting: _isSubmitting,
                                onReply: _replyOffer,
                                onMakeOffer: _makeOffer,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildBreakdownItem(String label, double amount, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(height: 8),
        CustomText(label, fontSize: 11, color: Colors.white70),
        const SizedBox(height: 4),
        CustomText(
          "$currencySymbol${formatAmount(amount)}",
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ],
    );
  }

  Future<Map<String, double>> _convertHeaderAmounts() async {
    final materialNGN =
        int.tryParse(offer["materialTotalCost"]?.toString() ?? "0") ?? 0;
    final workmanshipNGN =
        int.tryParse(offer["workmanshipTotalCost"]?.toString() ?? "0") ?? 0;

    return {
      'material': await CurrencyHelper.convertFromNGN(materialNGN),
      'workmanship': await CurrencyHelper.convertFromNGN(workmanshipNGN),
    };
  }
}
