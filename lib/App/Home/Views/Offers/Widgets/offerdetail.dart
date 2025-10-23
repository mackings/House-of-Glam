import 'package:flutter/material.dart';
import 'package:hog/App/Auth/Api/secure.dart';
import 'package:hog/App/Home/Views/Offers/Api/OfferService.dart';
import 'package:hog/App/Home/Views/Offers/Widgets/chatSection.dart';
import 'package:hog/App/Home/Views/Offers/Widgets/chatSummary.dart';
import 'package:hog/components/texts.dart';
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
  final String currencySymbol = '₦';

  Map<String, dynamic> get offer => widget.offer;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
    _materialCtrl.text = offer["materialTotalCost"]?.toString() ?? "";
    _workmanshipCtrl.text = offer["workmanshipTotalCost"]?.toString() ?? "";
  }

  Future<void> _loadUserRole() async {
    final userData = await SecurePrefs.getUserData();
    setState(() => _userRole = userData?["role"]);
  }

  String formatAmount(dynamic amount) {
    final n = int.tryParse(amount?.toString() ?? '') ?? 0;
    return NumberFormat('#,###').format(n);
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

  void _showSnack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: CustomText(msg)));

  Future<void> _makeOffer() async {
    if (_userRole != "user") return _showSnack("Only buyers can make offers.");

    final reviewId = offer["reviewId"]?["_id"];
    if (reviewId == null) return _showSnack("Missing review ID");

    final comment = _commentCtrl.text.trim();
    final mat = _materialCtrl.text.trim();
    final work = _workmanshipCtrl.text.trim();

    if (comment.isEmpty || mat.isEmpty || work.isEmpty) {
      return _showSnack("Please fill all fields");
    }

    setState(() => _isSubmitting = true);
    final res = await OfferService.makeOffer(
      reviewId: reviewId,
      comment: comment,
      materialTotalCost: mat,
      workmanshipTotalCost: work,
    );
    setState(() => _isSubmitting = false);

    final ok = (res["success"] == true);
    _showSnack(res["message"] ?? (ok ? "Offer created" : "Failed"));
    if (ok) Navigator.pop(context);
  }


  Future<void> _replyOffer(String action) async {
  final offerId = offer["_id"];
  if (offerId == null) return _showSnack("Missing offer ID");

  final comment = _commentCtrl.text.trim();
  final counterMat = _materialCtrl.text.trim();
  final counterWork = _workmanshipCtrl.text.trim();

  // ✅ Validation: Comment is required
  if (comment.isEmpty) return _showSnack("Please add a comment");

  // ✅ Validation: When accepting, ensure amounts are entered
  if (action == "accepted" && (counterMat.isEmpty || counterWork.isEmpty)) {
    return _showSnack("Please enter material and workmanship amounts before accepting.");
  }

  setState(() => _isSubmitting = true);
  Map<String, dynamic> res;

  if (_userRole == "user") {
    res = await OfferService.buyerReplyOffer(
      offerId: offerId,
      comment: comment,
      counterMaterialCost: counterMat.isEmpty ? "0" : counterMat,
      counterWorkmanshipCost: counterWork.isEmpty ? "0" : counterWork,
      action: action,
    );
  } else {
    res = await OfferService.vendorReplyOffer(
      offerId: offerId,
      comment: comment,
      counterMaterialCost: counterMat.isEmpty ? "0" : counterMat,
      counterWorkmanshipCost: counterWork.isEmpty ? "0" : counterWork,
      action: action,
    );
  }

  setState(() => _isSubmitting = false);

  final ok = (res["success"] == true);
  _showSnack(res["message"] ?? (ok ? "Reply sent" : "Failed"));
  if (ok) Navigator.pop(context);
}


  @override
  Widget build(BuildContext context) {
    final user = offer["userId"] ?? {};
    final vendor = offer["vendorId"] ?? {};

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: CustomText(
          vendor["businessName"] ?? user["fullName"] ?? "Offer Detail",
          color: Colors.white,
          fontSize: 16,
        ),
        backgroundColor: Colors.purple,
      ),
      body: _userRole == null
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    ChatSummaryCard(
                      offer: offer,
                      user: user,
                      vendor: vendor,
                      currencySymbol: currencySymbol,
                      formatAmount: formatAmount,
                      formatDate: formatDate,
                    ),
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
    );
  }
}
