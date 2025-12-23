import 'package:flutter/material.dart';
import 'package:hog/App/Auth/Api/secure.dart';
import 'package:hog/App/Home/Views/Offers/Api/OfferService.dart';
import 'package:hog/App/Home/Views/Offers/Widgets/offerdetail.dart';
import 'package:hog/components/texts.dart';
import 'package:hog/constants/currency.dart';
import 'package:hog/constants/currencyHelper.dart';
import 'package:intl/intl.dart';

class OfferHome extends StatefulWidget {
  const OfferHome({super.key});

  @override
  State<OfferHome> createState() => _OfferHomeState();
}

class _OfferHomeState extends State<OfferHome> {
  List<dynamic> offers = [];
  String? userId;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadOffers();
  }

  Future<void> loadOffers() async {
    setState(() => isLoading = true);
    userId = await SecurePrefs.getUserId();
    final data = await OfferService.getAllOffers();
    setState(() {
      offers = data;
      isLoading = false;
    });
  }

  bool isBuyerOffer(Map<String, dynamic> offer) {
    final u = offer["userId"];
    if (u == null) return false;
    return (u["_id"]?.toString() ?? "") == (userId ?? "");
  }

  String formatDate(String raw) {
    try {
      final dt = DateTime.parse(raw);
      return DateFormat('dd MMM yyyy • hh:mm a').format(dt.toLocal());
    } catch (_) {
      return raw ?? '';
    }
  }

  String formatAmount(double amount) { // ✅ Changed from dynamic to double
    try {
      final f = NumberFormat('#,###.##'); // ✅ Allow decimals
      return f.format(amount);
    } catch (e) {
      return amount.toString();
    }
  }

  Widget _statusChip(String status) {
    final s = status.toLowerCase();
    Color bg;
    Color text;
    if (s.contains('accepted')) {
      bg = Colors.green.shade100;
      text = Colors.green.shade800;
    } else if (s.contains('rejected')) {
      bg = Colors.red.shade100;
      text = Colors.red.shade800;
    } else if (s.contains('counter')) {
      bg = Colors.orange.shade100;
      text = Colors.orange.shade800;
    } else {
      bg = Colors.grey.shade100;
      text = Colors.black87;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: CustomText(
        status.toString().toUpperCase(),
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: const CustomText("Offers", fontSize: 18, color: Colors.white),
        backgroundColor: Colors.purple,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: loadOffers,
            tooltip: "Refresh",
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: loadOffers,
              child: offers.isEmpty
                  ? ListView(
                      children: const [
                        SizedBox(height: 180),
                        Center(
                          child: CustomText(
                            "No offers yet",
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(12),
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemCount: offers.length,
                      itemBuilder: (context, index) {
                        final offer = offers[index] as Map<String, dynamic>;
                        final isBuyer = isBuyerOffer(offer);

                        final title = (offer["comment"] ?? "").toString();
                        final materialNGN = int.tryParse(
                              offer["materialTotalCost"]?.toString() ?? "0",
                            ) ??
                            0;
                        final workmanshipNGN = int.tryParse(
                              offer["workmanshipTotalCost"]?.toString() ?? "0",
                            ) ??
                            0;
                        final status = offer["status"]?.toString() ?? "-";
                        final createdAt = offer["createdAt"]?.toString() ?? "";

                        final user = offer["userId"] as Map<String, dynamic>?;
                        final vendor =
                            offer["vendorId"] as Map<String, dynamic>?;

                        final avatarUrl = isBuyer
                            ? (user?["image"] as String?)
                            : (vendor?["nepaBill"] as String?);
                        final name = isBuyer
                            ? (user?["fullName"] ?? "You")
                            : (vendor?["businessName"] ?? "Vendor");

                        // avatar fallback initials
                        String initials = "?";
                        if (name != null && name.toString().trim().isNotEmpty) {
                          initials = name
                              .toString()
                              .trim()
                              .split(" ")
                              .map((e) => e.isEmpty ? '' : e[0])
                              .take(2)
                              .join()
                              .toUpperCase();
                        }

                        // ✅ Convert amounts for this offer
                        return FutureBuilder<Map<String, double>>(
                          future: _convertOfferAmounts(
                            materialNGN,
                            workmanshipNGN,
                          ),
                          builder: (context, snapshot) {
                            final displayMaterial = snapshot.data?['material'] ??
                                materialNGN.toDouble();
                            final displayWorkmanship =
                                snapshot.data?['workmanship'] ??
                                    workmanshipNGN.toDouble();

                            return GestureDetector(
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => OfferDetail(offer: offer),
                                  ),
                                );
                                await loadOffers();
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12.withOpacity(0.04),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 28,
                                      backgroundColor: Colors.purple.shade50,
                                      backgroundImage: avatarUrl != null
                                          ? NetworkImage(avatarUrl)
                                          : null,
                                      child: avatarUrl == null
                                          ? CustomText(
                                              initials,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.purple,
                                            )
                                          : null,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: CustomText(
                                                  title.isNotEmpty
                                                      ? title
                                                      : (isBuyer
                                                          ? "Your offer"
                                                          : "New vendor reply"),
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              _statusChip(status),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.checkroom,
                                                size: 16,
                                                color: Colors.purple,
                                              ),
                                              const SizedBox(width: 6),
                                              CustomText(
                                                "$currencySymbol${formatAmount(displayMaterial)}", // ✅ Use converted
                                                fontSize: 13,
                                              ),
                                              const SizedBox(width: 14),
                                              const Icon(
                                                Icons.handyman,
                                                size: 16,
                                                color: Colors.purple,
                                              ),
                                              const SizedBox(width: 6),
                                              CustomText(
                                                "$currencySymbol${formatAmount(displayWorkmanship)}", // ✅ Use converted
                                                fontSize: 13,
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              CustomText(
                                                name.toString(),
                                                fontSize: 12,
                                                color: Colors.black54,
                                              ),
                                              CustomText(
                                                formatDate(createdAt),
                                                fontSize: 11,
                                                color: Colors.black45,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(
                                      Icons.chevron_right,
                                      color: Colors.black38,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
    );
  }

  // ✅ Helper to convert offer amounts
  Future<Map<String, double>> _convertOfferAmounts(
    int materialNGN,
    int workmanshipNGN,
  ) async {
    return {
      'material': await CurrencyHelper.convertFromNGN(materialNGN),
      'workmanship': await CurrencyHelper.convertFromNGN(workmanshipNGN),
    };
  }
}