import 'package:flutter/material.dart';
import 'package:hog/App/Auth/Api/secure.dart';
import 'package:hog/App/Home/Model/offerModel.dart';
import 'package:hog/App/Home/Views/Offers/Api/OfferService.dart';
import 'package:hog/App/Home/Views/Offers/Model/offerThread.dart';
import 'package:hog/App/Home/Views/Offers/Widgets/offerdetail_v2.dart';
import 'package:hog/components/texts.dart';
import 'package:hog/constants/currencyHelper.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;



class OfferHome extends StatefulWidget {
  const OfferHome({super.key});

  @override
  State<OfferHome> createState() => _OfferHomeState();
}

class _OfferHomeState extends State<OfferHome> with SingleTickerProviderStateMixin {
  List<MakeOffer> offers = [];
  String? userId;
  String? userRole;
  String _userCountry = 'Nigeria'; // 🆕 Add user country tracking
  bool _useUSD = false; // 🆕 Add currency preference
  bool isLoading = true;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _loadUserData();
    loadOffers();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // 🆕 Updated to load user country
  Future<void> _loadUserData() async {
    userId = await SecurePrefs.getUserId();
    final userData = await SecurePrefs.getUserData();
    userRole = userData?["role"];
    _userCountry = userData?["country"] ?? 'Nigeria'; // 🆕 Get user country
    
    // 🆕 Determine if user should see USD
    setState(() {
      _useUSD = _userCountry != 'Nigeria';
    });
  }

  Future<void> loadOffers() async {
    setState(() => isLoading = true);
    final data = await OfferService.getAllOffers();

    // Parse offers using the new model
    final parsedOffers = <MakeOffer>[];
    for (var item in data) {
      try {
        parsedOffers.add(MakeOffer.fromJson(item as Map<String, dynamic>));
      } catch (e) {
        print("Error parsing offer: $e");
      }
    }

    setState(() {
      offers = parsedOffers;
      isLoading = false;
    });

    _animationController.forward();
  }

  bool isBuyerOffer(MakeOffer offer) {
    return offer.user.id == (userId ?? "");
  }

  String formatDate(DateTime dateTime) {
    return DateFormat('dd MMM yyyy • hh:mm a').format(dateTime.toLocal());
  }

  // 🆕 Helper method to get display amount based on user's location
  String _getDisplayAmount(MakeOffer offer, double ngnAmount, double usdAmount) {
    // If offer is not international, always show NGN
    if (!offer.isInternationalVendor) {
      return CurrencyHelper.formatAmount(ngnAmount, currencyCode: 'NGN');
    }
    
    // If international offer, show based on user preference
    if (_useUSD) {
      return '\$${usdAmount.toStringAsFixed(2)}';
    } else {
      return CurrencyHelper.formatAmount(ngnAmount, currencyCode: 'NGN');
    }
  }

  Widget _buildStatusBadge(MakeOffer offer) {
    Color bgColor;
    Color borderColor;
    IconData icon;
    String label;

    if (offer.mutualConsentAchieved) {
      bgColor = const Color(0xFFD1FAE5);
      borderColor = const Color(0xFF10B981);
      icon = Icons.check_circle_rounded;
      label = "Ready";
    } else if (offer.status == "accepted" && !offer.mutualConsentAchieved) {
      bgColor = const Color(0xFFFEF3C7);
      borderColor = const Color(0xFFF59E0B);
      icon = Icons.schedule_rounded;
      label = "Pending";
    } else if (offer.status == "rejected") {
      bgColor = const Color(0xFFFEE2E2);
      borderColor = const Color(0xFFEF4444);
      icon = Icons.cancel_rounded;
      label = "Declined";
    } else if (offer.status == "incoming") {
      bgColor = const Color(0xFFDCEDFD);
      borderColor = const Color(0xFF3B82F6);
      icon = Icons.fiber_new_rounded;
      label = "New";
    } else {
      bgColor = const Color(0xFFFED7AA);
      borderColor = const Color(0xFFF97316);
      icon = Icons.chat_bubble_rounded;
      label = "Active";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: borderColor),
          const SizedBox(width: 4),
          CustomText(
            label,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: borderColor,
          ),
        ],
      ),
    );
  }

  Widget _buildConsentIndicators(MakeOffer offer) {
    if (offer.mutualConsentAchieved) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF10B981), Color(0xFF059669)],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.verified, size: 14, color: Colors.white),
            SizedBox(width: 4),
            CustomText(
              "Both Agreed",
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ],
        ),
      );
    }

    return Row(
      children: [
        if (offer.buyerConsent) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFD1FAE5),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF10B981), width: 1),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, size: 12, color: Color(0xFF10B981)),
                SizedBox(width: 3),
                CustomText("Buyer", fontSize: 9, fontWeight: FontWeight.w600, color: Color(0xFF10B981)),
              ],
            ),
          ),
          const SizedBox(width: 6),
        ],
        if (offer.vendorConsent) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFD1FAE5),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF10B981), width: 1),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, size: 12, color: Color(0xFF10B981)),
                SizedBox(width: 3),
                CustomText("Vendor", fontSize: 9, fontWeight: FontWeight.w600, color: Color(0xFF10B981)),
              ],
            ),
          ),
        ],
        if (!offer.buyerConsent && !offer.vendorConsent)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.pending_outlined, size: 12, color: Colors.black38),
                SizedBox(width: 3),
                CustomText("Awaiting", fontSize: 9, color: Colors.black38),
              ],
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const CustomText(
          "Price Negotiations",
          fontSize: 19,
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
        backgroundColor: Colors.purple,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purple, Colors.purple.shade700],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: loadOffers,
            tooltip: "Refresh",
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.purple))
          : RefreshIndicator(
              onRefresh: loadOffers,
              color: Colors.purple,
              child: offers.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: offers.length,
                      itemBuilder: (context, index) {
                        return _buildOfferCard(offers[index], index);
                      },
                    ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      children: [
        const SizedBox(height: 100),
        Center(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.purple.shade50,
                      Colors.purple.shade100.withOpacity(0.5),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.handshake_outlined,
                  size: 90,
                  color: Colors.purple.shade400,
                ),
              ),
              const SizedBox(height: 32),
              const CustomText(
                "No Negotiations Yet",
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              const SizedBox(height: 12),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 60),
                child: CustomText(
                  "Start making offers on quotations to negotiate prices with vendors",
                  fontSize: 15,
                  color: Colors.black54,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.purple, Colors.purple.shade700],
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.local_offer_rounded, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    CustomText(
                      "Browse Quotations",
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOfferCard(MakeOffer offer, int index) {
    final isBuyer = isBuyerOffer(offer);
    final latestChat = offer.latestChat;
    final latestComment = latestChat?.comment ?? "No messages yet";
    final displayName = isBuyer ? offer.vendor.businessName : offer.user.fullName;

    final initials = displayName.isNotEmpty
        ? displayName.split(" ").map((e) => e.isEmpty ? '' : e[0]).take(2).join().toUpperCase()
        : "?";

    // 🆕 Get the appropriate amounts based on mutual consent
    final displayNGN = offer.mutualConsentAchieved
        ? offer.finalTotalCost
        : (latestChat?.counterTotalCost ?? 0.0);
    
    final displayUSD = offer.mutualConsentAchieved
        ? offer.finalTotalCostUSD
        : (latestChat?.counterTotalCostUSD ?? 0.0);

    final delay = index * 50;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + delay),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OfferDetailV2(offerId: offer.id),
            ),
          );
          await loadOffers();
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: offer.mutualConsentAchieved
                ? Border.all(color: const Color(0xFF10B981), width: 2.5)
                : null,
            boxShadow: [
              BoxShadow(
                color: offer.mutualConsentAchieved
                    ? const Color(0xFF10B981).withOpacity(0.15)
                    : Colors.black.withOpacity(0.08),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: offer.mutualConsentAchieved
                        ? [const Color(0xFFF0FDF4), Colors.white]
                        : [Colors.purple.shade50.withOpacity(0.3), Colors.white],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Colors.purple.shade400, Colors.purple.shade600],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.purple.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.transparent,
                        child: CustomText(
                          initials,
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            displayName,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Icon(
                                isBuyer ? Icons.shopping_bag_outlined : Icons.store_outlined,
                                size: 13,
                                color: Colors.black45,
                              ),
                              const SizedBox(width: 4),
                              CustomText(
                                isBuyer ? "You're buying" : "You're selling",
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    _buildStatusBadge(offer),
                  ],
                ),
              ),

              const Divider(height: 1, thickness: 1),

              // Content Section
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Latest Message
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FA),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.purple.shade50,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.chat_bubble_rounded,
                              size: 18,
                              color: Colors.purple.shade400,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const CustomText(
                                  "Latest Message",
                                  fontSize: 10,
                                  color: Colors.black45,
                                  fontWeight: FontWeight.w600,
                                ),
                                const SizedBox(height: 2),
                                CustomText(
                                  latestComment,
                                  fontSize: 13,
                                  color: Colors.black87,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Amount & Consent Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Amount - 🆕 UPDATED TO USE HELPER METHOD
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: offer.mutualConsentAchieved
                                    ? [const Color(0xFFD1FAE5), const Color(0xFFA7F3D0)]
                                    : [Colors.purple.shade50, Colors.purple.shade100],
                              ),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.payments_rounded,
                                      size: 14,
                                      color: offer.mutualConsentAchieved
                                          ? const Color(0xFF10B981)
                                          : Colors.purple.shade700,
                                    ),
                                    const SizedBox(width: 5),
                                    CustomText(
                                      "Current Amount",
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: offer.mutualConsentAchieved
                                          ? const Color(0xFF10B981)
                                          : Colors.purple.shade700,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                // 🆕 USE THE HELPER METHOD
                                CustomText(
                                  _getDisplayAmount(offer, displayNGN, displayUSD),
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: offer.mutualConsentAchieved
                                      ? const Color(0xFF059669)
                                      : Colors.purple.shade900,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Consent
                        _buildConsentIndicators(offer),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // Footer Info
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.forum_rounded, size: 14, color: Colors.black38),
                            const SizedBox(width: 5),
                            CustomText(
                              "${offer.chats.length} messages",
                              fontSize: 12,
                              color: Colors.black54,
                              fontWeight: FontWeight.w500,
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(Icons.access_time_rounded, size: 13, color: Colors.black38),
                            const SizedBox(width: 4),
                            CustomText(
                              timeago.format(offer.updatedAt, locale: 'en_short'),
                              fontSize: 11,
                              color: Colors.black45,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Mutual Consent Footer
              if (offer.mutualConsentAchieved)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF10B981), Color(0xFF059669)],
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.verified_rounded, color: Colors.white, size: 18),
                      const SizedBox(width: 8),
                      const CustomText(
                        "Agreement Reached • Ready for Payment",
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
