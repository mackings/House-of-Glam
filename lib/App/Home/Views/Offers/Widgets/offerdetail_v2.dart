import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hog/App/Auth/Api/secure.dart';
import 'package:hog/App/Home/Views/Offers/Api/OfferService.dart';
import 'package:hog/App/Home/Views/Offers/Model/offerThread.dart';
import 'package:hog/components/thousandformat.dart';
import 'package:hog/components/texts.dart';
import 'package:hog/theme/app_theme.dart';
import 'package:intl/intl.dart';
import 'dart:async';
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
  final ScrollController _scrollController = ScrollController();
  final PageController _actionPageController = PageController(
    viewportFraction: 0.86,
  );

  MakeOffer? _offer;
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _userRole;
  String _userCountry = 'Nigeria'; // Default to Nigeria
  bool _useUSD = false; // Whether to display USD instead of NGN
  Timer? _pollTimer;
  int _actionPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
    _startPolling();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _scrollController.dispose();
    _actionPageController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final userData = await SecurePrefs.getUserData();
      _userRole = userData?["role"];
      _userCountry = userData?["country"] ?? 'Nigeria';

      final response = await OfferService.getOfferById(widget.offerId);

      if (!mounted) return;

      if (response != null && response["success"] == true) {
        final offer = MakeOffer.fromJson(response["data"]);
        final shouldUseUSD = _userCountry != 'Nigeria';

        setState(() {
          _offer = offer;
          _useUSD = shouldUseUSD;
          _isLoading = false;
        });

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.jumpTo(
              _scrollController.position.maxScrollExtent,
            );
          }
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _refreshOfferSilently() async {
    try {
      final response = await OfferService.getOfferById(widget.offerId);
      if (response != null && response["success"] == true) {
        final offer = MakeOffer.fromJson(response["data"]);
        if (!mounted) return;
        setState(() {
          _offer = offer;
        });
      }
    } catch (_) {
      // Ignore polling failures and preserve the current state.
    }
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!_isSubmitting) {
        _refreshOfferSilently();
      }
    });
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

  Future<Map<String, dynamic>> _handleAction(
    String action, {
    required String comment,
    String amountDisplay = '',
  }) async {
    if (_offer == null) {
      return {"success": false, "message": "Offer not found"};
    }

    if (action == "countered") {
      if (!_canVendorCounter) {
        _showSnack(
          "You can only counter once. Please accept or reject.",
          isError: true,
        );
        return {"success": false, "message": "Counter offer unavailable"};
      }
    }

    if (comment.isEmpty) {
      _showSnack("Please add a comment", isError: true);
      return {"success": false, "message": "Please add a comment"};
    }

    // For accept action, use the latest chat amounts
    String materialCost = "0";
    String workmanshipCost = "0";

    if (action == "countered") {
      if (amountDisplay.isEmpty) {
        _showSnack("Please enter an amount.", isError: true);
        return {"success": false, "message": "Please enter an amount"};
      }

      final normalized =
          amountDisplay
              .toUpperCase()
              .replaceAll(',', '')
              .replaceAll('\$', '')
              .replaceAll('USD', '')
              .replaceAll('NGN', '')
              .replaceAll('₦', '')
              .trim();
      final totalAmount = (double.tryParse(normalized) ?? 0).toStringAsFixed(0);
      final totalAsInt = int.tryParse(totalAmount) ?? 0;
      final splitMaterial = (totalAsInt / 2).floor();
      final splitWorkmanship = totalAsInt - splitMaterial;

      materialCost = splitMaterial.toString();
      workmanshipCost = splitWorkmanship.toString();
    }

    if (action == "accepted") {
      // Use latest chat amounts (always send NGN to backend)
      final latestChat = _offer!.latestChat;
      if (latestChat != null) {
        materialCost = latestChat.counterMaterialCost.toStringAsFixed(0);
        workmanshipCost = latestChat.counterWorkmanshipCost.toStringAsFixed(0);
      }
    }

    if (!mounted) {
      return {"success": false, "message": "Screen is no longer active"};
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

    if (!mounted) {
      return {"success": false, "message": "Screen is no longer active"};
    }
    setState(() => _isSubmitting = false);

    if (response["success"] == true) {
      return {
        "success": true,
        "message": response["message"] ?? "Action completed successfully",
      };
    } else {
      _showSnack(response["message"] ?? "Action failed", isError: true);
      return {
        "success": false,
        "message": response["message"] ?? "Action failed",
      };
    }
  }

  Future<void> _openActionComposer({
    required String action,
    required String title,
    required String buttonText,
    required Color accent,
    bool requiresAmount = false,
  }) async {
    final commentCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    bool isSheetSubmitting = false;

    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            Future<void> submit() async {
              if (isSheetSubmitting) return;
              setSheetState(() => isSheetSubmitting = true);
              final result = await _handleAction(
                action,
                comment: commentCtrl.text.trim(),
                amountDisplay: amountCtrl.text.trim(),
              );
              if (!sheetContext.mounted) return;
              if (result["success"] == true) {
                Navigator.of(sheetContext).pop(result);
                return;
              }
              setSheetState(() => isSheetSubmitting = false);
            }

            return SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
                ),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 52,
                          height: 5,
                          decoration: BoxDecoration(
                            color: AppColors.border,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: accent.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              _iconForAction(action),
                              color: accent,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomText(
                                  title,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  textAlign: TextAlign.left,
                                ),
                                const SizedBox(height: 3),
                                CustomText(
                                  requiresAmount
                                      ? "Add your comment and counter amount before sending."
                                      : "Add a short comment before continuing.",
                                  fontSize: 12,
                                  color: AppColors.subtext,
                                  textAlign: TextAlign.left,
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed:
                                isSheetSubmitting
                                    ? null
                                    : () => Navigator.of(sheetContext).pop(),
                            icon: const Icon(Icons.close_rounded),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: commentCtrl,
                        keyboardType: TextInputType.multiline,
                        textCapitalization: TextCapitalization.sentences,
                        minLines: 2,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          hintText: "Add a comment...",
                          prefixIcon: Icon(
                            Icons.chat_bubble_outline_rounded,
                            size: 20,
                            color: AppColors.subtext,
                          ),
                          alignLabelWithHint: true,
                        ),
                      ),
                      if (requiresAmount) ...[
                        const SizedBox(height: 14),
                        TextField(
                          controller: amountCtrl,
                          keyboardType:
                              _useUSD
                                  ? const TextInputType.numberWithOptions(
                                    decimal: true,
                                  )
                                  : TextInputType.number,
                          inputFormatters:
                              _useUSD
                                  ? null
                                  : <TextInputFormatter>[ThousandsFormatter()],
                          decoration: InputDecoration(
                            hintText:
                                _useUSD
                                    ? "Enter amount (e.g. 12 USD)"
                                    : "Enter amount (e.g. 23,000)",
                            prefixIcon: const Icon(
                              Icons.payments_outlined,
                              size: 20,
                              color: AppColors.subtext,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: isSheetSubmitting ? null : submit,
                          icon:
                              isSheetSubmitting
                                  ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : Icon(
                                    _iconForAction(action),
                                    size: 18,
                                    color: Colors.white,
                                  ),
                          label: CustomText(
                            isSheetSubmitting ? "Please wait..." : buttonText,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accent,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    if (result?["success"] == true && mounted) {
      await Future<void>.delayed(Duration.zero);
      if (!mounted) return;
      _showSnack(result?["message"] ?? "Action completed successfully");
      await _loadData();
    }

    commentCtrl.dispose();
    amountCtrl.dispose();
  }

  IconData _iconForAction(String action) {
    switch (action) {
      case "accepted":
        return Icons.check_circle_rounded;
      case "rejected":
        return Icons.cancel_rounded;
      case "countered":
        return Icons.swap_horiz_rounded;
      default:
        return Icons.local_offer_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayName =
        _offer == null
            ? "Offer"
            : (_isBuyer ? _offer!.vendor.businessName : _offer!.user.fullName);
    final initials =
        displayName.isNotEmpty
            ? displayName
                .split(' ')
                .map((part) => part.isEmpty ? '' : part[0])
                .take(2)
                .join()
                .toUpperCase()
            : "?";

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: CustomText(
                  initials,
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    displayName,
                    color: AppColors.ink,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    textAlign: TextAlign.left,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  CustomText(
                    _offer?.mutualConsentAchieved == true
                        ? "Agreement reached"
                        : "Live negotiation",
                    color: AppColors.subtext,
                    fontSize: 12,
                    textAlign: TextAlign.left,
                  ),
                ],
              ),
            ),
          ],
        ),
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

                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                    child: _buildThreadSummaryCard(),
                  ),

                  // Chat Messages
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _loadData,
                      color: AppColors.accent,
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.fromLTRB(12, 12, 12, 20),
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
      decoration: const BoxDecoration(color: AppColors.accent),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded, color: Colors.white, size: 28),
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
                  textAlign: TextAlign.left,
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
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4DE),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF5D08A)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.hourglass_empty_rounded,
            color: AppColors.warning,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: CustomText(
              isUserWaiting
                  ? "Please confirm the agreement to proceed"
                  : "Waiting for $waitingFor to confirm agreement",
              fontSize: 13,
              color: AppColors.warning,
              textAlign: TextAlign.left,
            ),
          ),
          if (_offer!.buyerConsent)
            const Icon(Icons.check_circle, color: AppColors.success, size: 18),
          const SizedBox(width: 4),
          if (_offer!.vendorConsent)
            const Icon(Icons.check_circle, color: AppColors.success, size: 18),
        ],
      ),
    );
  }

  Widget _buildThreadSummaryCard() {
    final acceptedTotals = _getAcceptedTotals();
    final amount = _getDisplayAmount(
      acceptedTotals["ngn"]!,
      acceptedTotals["usd"]!,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 16,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.accentSoft,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.payments_outlined, color: AppColors.accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CustomText(
                  "Current negotiation amount",
                  fontSize: 11,
                  color: AppColors.subtext,
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 2),
                CustomText(
                  amount,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  textAlign: TextAlign.left,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color:
                  _offer!.mutualConsentAchieved
                      ? const Color(0xFFEEF8F2)
                      : AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(999),
            ),
            child: CustomText(
              _offer!.mutualConsentAchieved ? "Locked" : "Open",
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color:
                  _offer!.mutualConsentAchieved
                      ? AppColors.success
                      : AppColors.subtext,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatBubble(OfferChat chat) {
    final isCustomer =
        chat.senderType == "customer" ||
        chat.senderType == "user" ||
        chat.senderType == "buyer";
    final isMyMessage = (_isBuyer && isCustomer) || (!_isBuyer && !isCustomer);

    return Align(
      alignment: isMyMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.82,
        ),
        child: Column(
          crossAxisAlignment:
              isMyMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isMyMessage ? const Color(0xFFF3ECFF) : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isMyMessage ? 18 : 6),
                  bottomRight: Radius.circular(isMyMessage ? 6 : 18),
                ),
                border: Border.all(
                  color:
                      isMyMessage ? const Color(0xFFE6DBFF) : AppColors.border,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 10,
                    offset: Offset(0, 5),
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
                      color: chat.actionBadgeColor.withValues(alpha: 0.15),
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
                      textAlign: TextAlign.left,
                    ),
                  ),

                  // Amounts (if applicable) - UPDATED to use pre-calculated USD
                  if (chat.showAmounts) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceMuted,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        children: [
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
                      color: AppColors.ink,
                      textAlign: TextAlign.left,
                    ),
                  ],

                  // Timestamp
                  const SizedBox(height: 8),
                  CustomText(
                    timeago.format(chat.timestamp, locale: 'en_short'),
                    fontSize: 10,
                    color: AppColors.subtext,
                    textAlign: TextAlign.left,
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
          color: AppColors.subtext,
          fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
          textAlign: TextAlign.left,
        ),
        CustomText(
          formattedAmount,
          fontSize: 12,
          fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
          color: AppColors.ink,
          textAlign: TextAlign.left,
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
        return {"ngn": chat.counterTotalCost, "usd": chat.counterTotalCostUSD};
      }
    }

    return {"ngn": 0, "usd": 0};
  }

  Widget _buildActionArea() {
    final canRespond =
        (_isBuyer && _offer!.buyerCanRespond) ||
        (!_isBuyer && _offer!.vendorCanRespond);
    final counterAvailable = canRespond && _canVendorCounter;
    final actionCount = counterAvailable ? 3 : 2;
    final currentActionIndex =
        _actionPageIndex >= actionCount ? actionCount - 1 : _actionPageIndex;
    const actionCarouselHeight = 158.0;

    if (!canRespond) {
      return Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: const CustomText(
          "Waiting for the other party to respond...",
          fontSize: 13,
          color: AppColors.subtext,
          textAlign: TextAlign.center,
        ),
      );
    }

    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: EdgeInsets.fromLTRB(14, 14, 14, 14 + bottomInset),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.accentSoft,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.mode_comment_outlined,
                  color: AppColors.accent,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      "Choose an action",
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      textAlign: TextAlign.left,
                    ),
                    SizedBox(height: 2),
                    CustomText(
                      "Swipe to accept, reject, or counter.",
                      fontSize: 11,
                      color: AppColors.subtext,
                      textAlign: TextAlign.left,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          if (_isSubmitting)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(color: AppColors.accent),
              ),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const CustomText(
                      "Swipe for actions",
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      textAlign: TextAlign.left,
                    ),
                    const Spacer(),
                    CustomText(
                      "${currentActionIndex + 1}/$actionCount",
                      fontSize: 11,
                      color: AppColors.subtext,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: actionCarouselHeight,
                  child: PageView(
                    controller: _actionPageController,
                    onPageChanged: (index) {
                      setState(() => _actionPageIndex = index);
                    },
                    children: [
                      _buildActionCard(
                        icon: Icons.check_circle_rounded,
                        title: "Accept Offer",
                        accent: AppColors.accent,
                        buttonText: "Add Comment",
                        buttonStyle: _ActionButtonStyle.outlined,
                        onPressed:
                            () => _openActionComposer(
                              action: "accepted",
                              title: "Accept Offer",
                              buttonText: "Accept Current Offer",
                              accent: AppColors.accent,
                            ),
                      ),
                      _buildActionCard(
                        icon: Icons.cancel_rounded,
                        title: "Reject Offer",
                        accent: AppColors.danger,
                        buttonText: "Add Comment",
                        buttonStyle: _ActionButtonStyle.outlined,
                        onPressed:
                            () => _openActionComposer(
                              action: "rejected",
                              title: "Reject Offer",
                              buttonText: "Reject This Offer",
                              accent: AppColors.danger,
                            ),
                      ),
                      if (counterAvailable)
                        _buildActionCard(
                          icon: Icons.swap_horiz_rounded,
                          title: "Counter Offer",
                          accent: AppColors.accent,
                          buttonText: "Add Details",
                          buttonStyle: _ActionButtonStyle.filled,
                          onPressed:
                              () => _openActionComposer(
                                action: "countered",
                                title: "Counter Offer",
                                buttonText: "Send Counter Offer",
                                accent: AppColors.accent,
                                requiresAmount: true,
                              ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    actionCount,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: currentActionIndex == index ? 18 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color:
                            currentActionIndex == index
                                ? AppColors.accent
                                : AppColors.border,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required Color accent,
    required String buttonText,
    required VoidCallback onPressed,
    required _ActionButtonStyle buttonStyle,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.border),
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon, color: accent, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          title,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          textAlign: TextAlign.left,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 50,
                child:
                    buttonStyle == _ActionButtonStyle.filled
                        ? ElevatedButton.icon(
                          onPressed: onPressed,
                          icon: Icon(icon, size: 18, color: Colors.white),
                          label: CustomText(
                            buttonText,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accent,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        )
                        : OutlinedButton.icon(
                          onPressed: onPressed,
                          icon: Icon(icon, size: 18, color: accent),
                          label: CustomText(
                            buttonText,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: accent,
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: accent, width: 1.4),
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool get _canVendorCounter {
    if (_offer == null || _isBuyer) return false;
    for (final chat in _offer!.chats) {
      final isCustomer =
          chat.senderType == "customer" ||
          chat.senderType == "user" ||
          chat.senderType == "buyer";
      if (!isCustomer && chat.action == "countered") {
        return false;
      }
    }
    return true;
  }

  bool get _isBuyer =>
      _userRole == "user" || _userRole == "customer" || _userRole == "buyer";
}

enum _ActionButtonStyle { filled, outlined }
