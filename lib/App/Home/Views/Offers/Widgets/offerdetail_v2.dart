import 'package:flutter/material.dart';
import 'package:hog/App/Auth/Api/secure.dart';
import 'package:hog/App/Home/Model/offerModel.dart';
import 'package:hog/App/Home/Views/Offers/Api/OfferService.dart';
import 'package:hog/App/Home/Views/Offers/Model/offerThread.dart';
import 'package:hog/components/texts.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

/// WhatsApp-style Offer Negotiation Screen with Mutual Consent
/// WhatsApp-style Offer Negotiation Screen with Mutual Consent
/// UPDATED: Now uses pre-calculated USD amounts from backend

class OfferDetailV2 extends StatefulWidget {
  final String offerId;

  const OfferDetailV2({super.key, required this.offerId});

  @override
  State<OfferDetailV2> createState() => _OfferDetailV2State();
}

class _OfferDetailV2State extends State<OfferDetailV2> {
  final TextEditingController _commentCtrl = TextEditingController();
  final TextEditingController _materialCtrl = TextEditingController();
  final TextEditingController _workmanshipCtrl = TextEditingController();
  final TextEditingController _totalCtrl = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  MakeOffer? _offer;
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _userRole;
  bool _showAmountFields = false;
  String _userCountry = 'Nigeria'; // Default to Nigeria
  bool _useUSD = false; // Whether to display USD instead of NGN

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    _materialCtrl.dispose();
    _workmanshipCtrl.dispose();
    _totalCtrl.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final userData = await SecurePrefs.getUserData();
    _userRole = userData?["role"];
    _userCountry = userData?["country"] ?? 'Nigeria';

    final response = await OfferService.getOfferById(widget.offerId);

    if (response != null && response["success"] == true) {
      final offer = MakeOffer.fromJson(response["data"]);

      // Determine currency based on user's country
      final shouldUseUSD = _userCountry != 'Nigeria';

      setState(() {
        _offer = offer;
        _useUSD = shouldUseUSD;
        _isLoading = false;
      });

      // Auto-scroll to bottom after loading
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    if (!mounted) return;
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
            Expanded(child: CustomText(msg, color: Colors.white, fontSize: 14)),
          ],
        ),
        backgroundColor:
            isError ? const Color(0xFFEF4444) : const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _handleAction(String action) async {
    if (_offer == null) return;

    if (_isBuyer &&
        action == "countered" &&
        _hasUserCountered()) {
      return _showSnack(
        "You can only counter once. Please accept or reject.",
        isError: true,
      );
    }

    final comment = _commentCtrl.text.trim();

    if (comment.isEmpty) {
      return _showSnack("Please add a comment", isError: true);
    }

    // For counter offers, amounts are required
    if (action == "countered") {
      if (_isBuyer) {
        if (_totalCtrl.text.trim().isEmpty) {
          return _showSnack("Please enter a total amount", isError: true);
        }
      } else {
        if (_materialCtrl.text.trim().isEmpty ||
            _workmanshipCtrl.text.trim().isEmpty) {
          return _showSnack(
            "Please enter material and workmanship costs",
            isError: true,
          );
        }
      }
    }

    // For accept action, use the latest chat amounts
    String materialCost = "0";
    String workmanshipCost = "0";

    if (action == "accepted") {
      // Use latest chat amounts (always send NGN to backend)
      final latestChat = _offer!.latestChat;
      if (latestChat != null) {
        materialCost = latestChat.counterMaterialCost.toStringAsFixed(0);
        workmanshipCost = latestChat.counterWorkmanshipCost.toStringAsFixed(0);
      }
    } else if (action == "countered") {
      if (_isBuyer) {
        final enteredTotal = _totalCtrl.text.replaceAll(',', '').trim();
        final totalValue = double.tryParse(enteredTotal);
        if (totalValue == null || totalValue <= 0) {
          return _showSnack("Please enter a valid total amount", isError: true);
        }
        final totalNgn =
            _useUSD && _offer!.exchangeRate > 0
                ? (totalValue * _offer!.exchangeRate).round()
                : totalValue.round();
        final materialSplit = (totalNgn / 2).floor();
        final workmanshipSplit = totalNgn - materialSplit;
        materialCost = materialSplit.toString();
        workmanshipCost = workmanshipSplit.toString();
      } else {
        // Vendor enters amounts in their local currency
        String enteredMaterial = _materialCtrl.text.replaceAll(',', '').trim();
        String enteredWorkmanship =
            _workmanshipCtrl.text.replaceAll(',', '').trim();

        // If vendor is international (using USD), convert to NGN before sending
        if (_useUSD && _offer!.exchangeRate > 0) {
          double materialUSD = double.parse(enteredMaterial);
          double workmanshipUSD = double.parse(enteredWorkmanship);

          // Convert USD to NGN: USD * exchangeRate = NGN
          materialCost = (materialUSD * _offer!.exchangeRate).toStringAsFixed(
            0,
          );
          workmanshipCost = (workmanshipUSD * _offer!.exchangeRate)
              .toStringAsFixed(0);
        } else {
          // Nigerian vendor - already in NGN
          materialCost = enteredMaterial;
          workmanshipCost = enteredWorkmanship;
        }
      }
    }

    setState(() => _isSubmitting = true);

    Map<String, dynamic> response;

    if (_isBuyer) {
      response = await OfferService.buyerReplyOffer(
        offerId: widget.offerId,
        comment: comment,
        counterMaterialCost: materialCost,
        counterWorkmanshipCost: workmanshipCost,
        action: action,
      );
    } else {
      response = await OfferService.vendorReplyOffer(
        offerId: widget.offerId,
        comment: comment,
        counterMaterialCost: materialCost,
        counterWorkmanshipCost: workmanshipCost,
        action: action,
      );
    }

    setState(() => _isSubmitting = false);

    if (response["success"] == true) {
      _showSnack(response["message"] ?? "Action completed successfully");

      // Clear inputs
      _commentCtrl.clear();
      _materialCtrl.clear();
      _workmanshipCtrl.clear();
      _totalCtrl.clear();
      setState(() => _showAmountFields = false);

      // Reload data
      await _loadData();
    } else {
      _showSnack(response["message"] ?? "Action failed", isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECE5DD), // WhatsApp-style background
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title:
            _offer == null
                ? const CustomText("Offer", color: Colors.white, fontSize: 18)
                : Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.white24,
                      radius: 18,
                      child: Text(
                        _isBuyer
                            ? (_offer!.vendor.businessName.isNotEmpty
                                ? _offer!.vendor.businessName[0]
                                : "V")
                            : (_offer!.user.fullName.isNotEmpty
                                ? _offer!.user.fullName[0]
                                : "U"),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            _isBuyer
                                ? _offer!.vendor.businessName
                                : _offer!.user.fullName,
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          if (_offer!.mutualConsentAchieved)
                            const CustomText(
                              "Agreement reached ✓",
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
        backgroundColor: Colors.purple,
        elevation: 0,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _offer == null
              ? const Center(child: CustomText("Offer not found"))
              : Column(
                children: [
                  // Mutual Consent Banner
                  if (_offer!.mutualConsentAchieved)
                    _buildMutualConsentBanner(),

                  // Waiting for consent banner
                  if (!_offer!.mutualConsentAchieved &&
                      (_offer!.buyerConsent || _offer!.vendorConsent))
                    _buildWaitingBanner(),

                  // Chat Messages
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _loadData,
                      color: const Color(0xFF6B21A8),
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(12),
                        itemCount: _offer!.chats.length,
                        itemBuilder: (context, index) {
                          return _buildChatBubble(_offer!.chats[index]);
                        },
                      ),
                    ),
                  ),

                  // Action Buttons Area
                  if (!_offer!.mutualConsentAchieved) _buildActionArea(),
                ],
              ),
    );
  }

  Widget _buildMutualConsentBanner() {
    final acceptedTotals = _getAcceptedTotals();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6B21A8), Color(0xFF7C3AED)],
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.white, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CustomText(
                  "Both parties agreed!",
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                CustomText(
                  "Final amount: ${_getDisplayAmount(acceptedTotals["ngn"]!, acceptedTotals["usd"]!)}",
                  color: Colors.white,
                  fontSize: 14,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaitingBanner() {
    final waitingFor = _offer!.isWaitingForBuyerConsent ? "buyer" : "vendor";
    final isUserWaiting =
        (_isBuyer && _offer!.isWaitingForBuyerConsent) ||
        (!_isBuyer && _offer!.isWaitingForVendorConsent);

    return Container(
      padding: const EdgeInsets.all(12),
      color: const Color(0xFFFEF3C7),
      child: Row(
        children: [
          const Icon(Icons.hourglass_empty, color: Color(0xFFF59E0B), size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: CustomText(
              isUserWaiting
                  ? "Please confirm the agreement to proceed"
                  : "Waiting for $waitingFor to confirm agreement",
              fontSize: 13,
              color: const Color(0xFF92400E),
            ),
          ),
          if (_offer!.buyerConsent)
            const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 18),
          const SizedBox(width: 4),
          if (_offer!.vendorConsent)
            const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 18),
        ],
      ),
    );
  }

  Widget _buildChatBubble(OfferChat chat) {
    final isCustomer = chat.senderType == "customer" ||
        chat.senderType == "user" ||
        chat.senderType == "buyer";
    final isMyMessage =
        (_isBuyer && isCustomer) ||
        (!_isBuyer && !isCustomer);
    final showBreakdown = !_isBuyer;

    return Align(
      alignment: isMyMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment:
              isMyMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isMyMessage ? const Color(0xFFDCF8C6) : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(12),
                  topRight: const Radius.circular(12),
                  bottomLeft: Radius.circular(isMyMessage ? 12 : 0),
                  bottomRight: Radius.circular(isMyMessage ? 0 : 12),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Action Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: chat.actionBadgeColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: chat.actionBadgeColor,
                        width: 1,
                      ),
                    ),
                    child: CustomText(
                      chat.actionLabel,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: chat.actionBadgeColor,
                    ),
                  ),

                  // Amounts (if applicable) - UPDATED to use pre-calculated USD
                  if (chat.showAmounts) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          if (showBreakdown) ...[
                            _buildAmountRow(
                              "Material",
                              chat.counterMaterialCost, // NGN
                              chat.counterMaterialCostUSD, // USD (pre-calculated)
                            ),
                            const SizedBox(height: 4),
                            _buildAmountRow(
                              "Workmanship",
                              chat.counterWorkmanshipCost, // NGN
                              chat.counterWorkmanshipCostUSD, // USD (pre-calculated)
                            ),
                            const Divider(height: 12),
                          ],
                          _buildAmountRow(
                            "Total",
                            chat.counterTotalCost, // NGN
                            chat.counterTotalCostUSD, // USD (pre-calculated)
                            isBold: true,
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Comment
                  if (chat.comment.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    CustomText(
                      chat.comment,
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ],

                  // Timestamp
                  const SizedBox(height: 4),
                  CustomText(
                    timeago.format(chat.timestamp, locale: 'en_short'),
                    fontSize: 10,
                    color: Colors.black45,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // UPDATED: Now uses pre-calculated amounts instead of converting
  Widget _buildAmountRow(
    String label,
    double ngnAmount,
    double usdAmount, {
    bool isBold = false,
  }) {
    // Simply display the appropriate pre-calculated amount
    final displayAmount = _useUSD ? usdAmount : ngnAmount;

    final formattedAmount =
        _useUSD
            ? '\$${displayAmount.toStringAsFixed(2)}'
            : '₦${NumberFormat('#,###.##').format(displayAmount)}';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CustomText(
          label,
          fontSize: 12,
          color: Colors.black54,
          fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
        ),
        CustomText(
          formattedAmount,
          fontSize: 12,
          fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
          color: Colors.black87,
        ),
      ],
    );
  }

  // UPDATED: Helper method to get display amount using pre-calculated values
  String _getDisplayAmount(double ngnAmount, double usdAmount) {
    if (_useUSD) {
      return '\$${usdAmount.toStringAsFixed(2)}';
    } else {
      return '₦${NumberFormat('#,###.##').format(ngnAmount)}';
    }
  }

  Map<String, double> _getAcceptedTotals() {
    if (_offer == null) {
      return {"ngn": 0, "usd": 0};
    }

    for (final chat in _offer!.chats.reversed) {
      if (chat.action == "accepted") {
        if (chat.counterTotalCost > 0 || chat.counterTotalCostUSD > 0) {
          return {
            "ngn": chat.counterTotalCost,
            "usd": chat.counterTotalCostUSD,
          };
        }
        break;
      }
    }

    final finalNgn = _offer!.finalTotalCost;
    final finalUsd = _offer!.finalTotalCostUSD;
    if (finalNgn > 0 || finalUsd > 0) {
      return {"ngn": finalNgn, "usd": finalUsd};
    }

    for (final chat in _offer!.chats.reversed) {
      if (chat.action == "countered" || chat.action == "incoming") {
        return {
          "ngn": chat.counterTotalCost,
          "usd": chat.counterTotalCostUSD,
        };
      }
    }

    return {"ngn": 0, "usd": 0};
  }

  Widget _buildActionArea() {
    final canRespond =
        (_isBuyer && _offer!.buyerCanRespond) ||
        (!_isBuyer && _offer!.vendorCanRespond);
    final hasCountered = _isBuyer ? _hasUserCountered() : false;

    if (!canRespond) {
      return Container(
        padding: const EdgeInsets.all(16),
        color: Colors.grey.shade200,
        child: const CustomText(
          "Waiting for the other party to respond...",
          fontSize: 13,
          color: Colors.black54,
          textAlign: TextAlign.center,
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Comment Field
          TextField(
            controller: _commentCtrl,
            decoration: InputDecoration(
              hintText: "Add a comment...",
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            maxLines: 2,
            enabled: !_isSubmitting,
          ),

          // Amount Fields (for counter offers)
          if (_showAmountFields) ...[
            const SizedBox(height: 12),
            if (_isBuyer)
              TextField(
                controller: _totalCtrl,
                decoration: InputDecoration(
                  labelText: "Total Amount (${_useUSD ? 'USD' : 'NGN'})",
                  labelStyle: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF6B21A8),
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                ),
                keyboardType: TextInputType.number,
                enabled: !_isSubmitting,
              )
            else
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _materialCtrl,
                      decoration: InputDecoration(
                        labelText: "Material Cost (${_useUSD ? 'USD' : 'NGN'})",
                        labelStyle: const TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF6B21A8),
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      enabled: !_isSubmitting,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _workmanshipCtrl,
                      decoration: InputDecoration(
                        labelText: "Workmanship (${_useUSD ? 'USD' : 'NGN'})",
                        labelStyle: const TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF6B21A8),
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      enabled: !_isSubmitting,
                    ),
                  ),
                ],
              ),
          ],

          const SizedBox(height: 16),

          // Action Buttons
          if (_isSubmitting)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(color: Color(0xFF6B21A8)),
              ),
            )
          else if (_showAmountFields)
            // Show Send Counter and Cancel buttons when amount fields are active
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () => _handleAction("countered"),
                    icon: const Icon(
                      Icons.send_rounded,
                      size: 20,
                      color: Colors.white,
                    ),
                    label: const CustomText(
                      "Send Counter Offer",
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6B21A8),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      setState(() => _showAmountFields = false);
                    },
                    icon: const Icon(
                      Icons.close,
                      size: 18,
                      color: Colors.black87,
                    ),
                    label: const CustomText(
                      "Cancel",
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey.shade300, width: 1.5),
                      backgroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            )
          else
            // Show Accept, Reject, Counter buttons
            Column(
              children: [
                // Primary Accept Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () => _handleAction("accepted"),
                    icon: const Icon(
                      Icons.check_circle_rounded,
                      size: 20,
                      color: Colors.white,
                    ),
                    label: const CustomText(
                      "Accept Offer",
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6B21A8),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Secondary Row: Reject and Counter
                Row(
                  children: [
                    // Reject Button (Outlined)
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: OutlinedButton.icon(
                          onPressed: () => _handleAction("rejected"),
                          icon: const Icon(
                            Icons.cancel_outlined,
                            size: 18,
                            color: Colors.black87,
                          ),
                          label: const CustomText(
                            "Reject",
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: Colors.grey.shade300,
                              width: 1.5,
                            ),
                            backgroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (!hasCountered) ...[
                      const SizedBox(width: 10),

                      // Counter Button (Filled with lighter purple)
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              setState(() => _showAmountFields = true);
                            },
                            icon: const Icon(
                              Icons.swap_horiz_rounded,
                              size: 18,
                              color: Color(0xFF6B21A8),
                            ),
                            label: const CustomText(
                              "Counter",
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF6B21A8),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF3E8FF),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                                side: const BorderSide(
                                  color: Color(0xFF6B21A8),
                                  width: 1,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (hasCountered) ...[
                  const SizedBox(height: 8),
                  const CustomText(
                    "Counter already used. You can only accept or reject.",
                    fontSize: 12,
                    color: Colors.black54,
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
        ],
      ),
    );
  }

  bool get _isBuyer =>
      _userRole == "user" || _userRole == "customer" || _userRole == "buyer";

  bool _hasUserCountered() {
    if (_offer == null) return false;
    if (!_isBuyer) return false;
    const buyerSenderTypes = {"customer", "user", "buyer"};
    return _offer!.chats.any(
      (chat) =>
          buyerSenderTypes.contains(chat.senderType) &&
          chat.action == "countered",
    );
  }
}
