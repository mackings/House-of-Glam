import 'package:flutter/material.dart';
import 'package:hog/App/Auth/Api/secure.dart';
import 'package:hog/App/Home/Views/Offers/Api/OfferService.dart';
import 'package:hog/App/Home/Views/Offers/Model/offerThread.dart';
import 'package:hog/App/Home/Views/Offers/Widgets/offerdetail_v2.dart';
import 'package:hog/components/texts.dart';
import 'package:hog/constants/currencyHelper.dart';
import 'package:hog/theme/app_theme.dart';
import 'package:timeago/timeago.dart' as timeago;

class OfferHome extends StatefulWidget {
  const OfferHome({super.key});

  @override
  State<OfferHome> createState() => _OfferHomeState();
}

class _OfferHomeState extends State<OfferHome>
    with SingleTickerProviderStateMixin {
  List<MakeOffer> offers = [];
  String? userId;
  String? userRole;
  String _userCountry = 'Nigeria';
  bool _useUSD = false;
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

  Future<void> _loadUserData() async {
    userId = await SecurePrefs.getUserId();
    final userData = await SecurePrefs.getUserData();
    userRole = userData?["role"];
    _userCountry = userData?["country"] ?? 'Nigeria';

    if (!mounted) return;
    setState(() {
      _useUSD = _userCountry != 'Nigeria';
    });
  }

  Future<void> loadOffers() async {
    if (!mounted) return;
    setState(() => isLoading = true);
    final data = await OfferService.getAllOffers();

    final parsedOffers = <MakeOffer>[];
    for (var item in data) {
      try {
        parsedOffers.add(MakeOffer.fromJson(item as Map<String, dynamic>));
      } catch (e) {
        print("Error parsing offer: $e");
      }
    }

    if (!mounted) return;
    setState(() {
      offers = parsedOffers;
      isLoading = false;
    });

    if (mounted) {
      _animationController.forward(from: 0);
    }
  }

  bool isBuyerOffer(MakeOffer offer) {
    return offer.user.id == (userId ?? "");
  }

  Widget _buildStatusBadge(MakeOffer offer) {
    Color bgColor;
    Color iconColor;
    IconData icon;
    String label;

    if (offer.mutualConsentAchieved) {
      bgColor = AppColors.accentSoft;
      iconColor = AppColors.accent;
      icon = Icons.verified_rounded;
      label = "Agreed";
    } else if (offer.status == "accepted" && !offer.mutualConsentAchieved) {
      bgColor = const Color(0xFFFFF4DE);
      iconColor = AppColors.warning;
      icon = Icons.schedule_rounded;
      label = "Awaiting";
    } else if (offer.status == "rejected") {
      bgColor = const Color(0xFFFDECEC);
      iconColor = AppColors.danger;
      icon = Icons.cancel_rounded;
      label = "Declined";
    } else if (offer.status == "incoming") {
      bgColor = const Color(0xFFE8F3FF);
      iconColor = const Color(0xFF2563EB);
      icon = Icons.fiber_new_rounded;
      label = "New";
    } else {
      bgColor = const Color(0xFFFFF2E8);
      iconColor = const Color(0xFFEA580C);
      icon = Icons.forum_rounded;
      label = "Active";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: iconColor),
          const SizedBox(width: 6),
          CustomText(
            label,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: iconColor,
          ),
        ],
      ),
    );
  }

  Widget _buildConsentIndicators(MakeOffer offer) {
    if (offer.mutualConsentAchieved) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFEEF8F2),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: const Color(0xFFCDEDD9)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle_rounded,
              size: 14,
              color: AppColors.success,
            ),
            SizedBox(width: 6),
            CustomText(
              "Both Agreed",
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.success,
            ),
          ],
        ),
      );
    }

    Widget buildPill({
      required String label,
      required bool active,
      required IconData icon,
    }) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: active ? AppColors.accentSoft : AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: active ? AppColors.accent : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              active ? Icons.check_circle_rounded : icon,
              size: 13,
              color: active ? AppColors.accent : AppColors.subtext,
            ),
            const SizedBox(width: 5),
            CustomText(
              label,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: active ? AppColors.accent : AppColors.subtext,
            ),
          ],
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        buildPill(
          label: "Buyer",
          active: offer.buyerConsent,
          icon: Icons.person_outline_rounded,
        ),
        buildPill(
          label: "Vendor",
          active: offer.vendorConsent,
          icon: Icons.storefront_outlined,
        ),
        if (!offer.buyerConsent && !offer.vendorConsent)
          buildPill(
            label: "Awaiting response",
            active: false,
            icon: Icons.hourglass_empty_rounded,
          ),
      ],
    );
  }

  String _displayAmount(MakeOffer offer) {
    final latest = offer.latestChat;
    final agreedAmount =
        offer.finalTotalCost > 0 || offer.finalTotalCostUSD > 0
            ? (_useUSD ? offer.finalTotalCostUSD : offer.finalTotalCost)
            : (_useUSD
                ? (latest?.counterTotalCostUSD ?? 0)
                : (latest?.counterTotalCost ?? 0));

    if (agreedAmount <= 0) return "No price yet";
    return _useUSD
        ? CurrencyHelper.formatAmount(agreedAmount, currencyCode: 'USD')
        : CurrencyHelper.formatAmount(agreedAmount, currencyCode: 'NGN');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          "Price Negotiations",
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: loadOffers,
            tooltip: "Refresh",
          ),
          const SizedBox(width: 6),
        ],
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                onRefresh: loadOffers,
                child:
                    offers.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                          itemCount: offers.length + 1,
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              return _buildIntroCard();
                            }
                            return _buildOfferCard(
                              offers[index - 1],
                              index - 1,
                            );
                          },
                        ),
              ),
    );
  }

  Widget _buildIntroCard() {
    final readyCount =
        offers.where((offer) => offer.mutualConsentAchieved).length;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF9F5FF), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.accentSoft,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.handshake_outlined,
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CustomText(
                      "Track every offer clearly",
                      textAlign: TextAlign.left,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                    const SizedBox(height: 4),
                    CustomText(
                      "Review active conversations, accepted prices, and pending decisions in one place.",
                      textAlign: TextAlign.left,
                      fontSize: 13,
                      color: AppColors.subtext,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _SummaryStat(
                  label: "Total Offers",
                  value: offers.length.toString(),
                  icon: Icons.local_offer_outlined,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SummaryStat(
                  label: "Agreements",
                  value: readyCount.toString(),
                  icon: Icons.verified_outlined,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 40, 20, 24),
      children: [
        Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              Container(
                width: 108,
                height: 108,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF4EAFF), Color(0xFFECE3FF)],
                  ),
                  borderRadius: BorderRadius.circular(32),
                ),
                child: const Icon(
                  Icons.handshake_outlined,
                  size: 46,
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(height: 24),
              const CustomText(
                "No Negotiations Yet",
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
              const SizedBox(height: 10),
              CustomText(
                "When you make an offer from a quotation, the full negotiation thread will appear here.",
                fontSize: 14,
                color: AppColors.subtext,
                textAlign: TextAlign.center,
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
    final displayName =
        isBuyer ? offer.vendor.businessName : offer.user.fullName;
    final initials =
        displayName.isNotEmpty
            ? displayName
                .split(" ")
                .map((e) => e.isEmpty ? '' : e[0])
                .take(2)
                .join()
                .toUpperCase()
            : "?";

    final delay = index * 50;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 380 + delay),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 18 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: GestureDetector(
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => OfferDetailV2(offerId: offer.id)),
          );
          if (!mounted) return;
          await loadOffers();
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color:
                  offer.mutualConsentAchieved
                      ? AppColors.accent
                      : AppColors.border,
              width: offer.mutualConsentAchieved ? 1.4 : 1,
            ),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 18,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                        ),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Center(
                        child: CustomText(
                          initials,
                          fontWeight: FontWeight.w800,
                          fontSize: 17,
                          color: Colors.white,
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
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            textAlign: TextAlign.left,
                          ),
                          const SizedBox(height: 4),
                          CustomText(
                            isBuyer
                                ? "Vendor conversation"
                                : "Buyer conversation",
                            fontSize: 12,
                            color: AppColors.subtext,
                            textAlign: TextAlign.left,
                          ),
                        ],
                      ),
                    ),
                    _buildStatusBadge(offer),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.attach_money_rounded,
                          color: AppColors.accent,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const CustomText(
                              "Current amount",
                              fontSize: 11,
                              color: AppColors.subtext,
                              textAlign: TextAlign.left,
                            ),
                            const SizedBox(height: 3),
                            CustomText(
                              _displayAmount(offer),
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              textAlign: TextAlign.left,
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14,
                        color: AppColors.subtext,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                CustomText(
                  "Latest Message",
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.subtext,
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 6),
                CustomText(
                  latestComment,
                  fontSize: 14,
                  color: AppColors.ink,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 14),
                _buildConsentIndicators(offer),
                const SizedBox(height: 14),
                Row(
                  children: [
                    const Icon(
                      Icons.forum_outlined,
                      size: 15,
                      color: AppColors.subtext,
                    ),
                    const SizedBox(width: 6),
                    CustomText(
                      "${offer.chats.length} messages",
                      fontSize: 12,
                      color: AppColors.subtext,
                      textAlign: TextAlign.left,
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.access_time_rounded,
                      size: 14,
                      color: AppColors.subtext,
                    ),
                    const SizedBox(width: 6),
                    CustomText(
                      latestChat == null
                          ? "Now"
                          : timeago.format(latestChat.timestamp),
                      fontSize: 12,
                      color: AppColors.subtext,
                      textAlign: TextAlign.left,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _SummaryStat({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.accentSoft,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, size: 18, color: AppColors.accent),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  label,
                  fontSize: 11,
                  color: AppColors.subtext,
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 2),
                CustomText(
                  value,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  textAlign: TextAlign.left,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
