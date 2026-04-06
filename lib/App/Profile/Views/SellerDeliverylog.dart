import 'package:flutter/material.dart';
import 'package:hog/App/Profile/Api/MarketDelivery.dart';
import 'package:hog/App/Profile/Model/DeliveryTrack.dart';
import 'package:hog/App/Profile/widgets/DeliveryTrackPad.dart';
import 'package:hog/components/texts.dart';
import 'package:hog/theme/app_theme.dart';

class SellerDelivery extends StatefulWidget {
  const SellerDelivery({super.key});

  @override
  State<SellerDelivery> createState() => _SellerDeliveryState();
}

class _SellerDeliveryState extends State<SellerDelivery> {
  List<MarketTrackingRecord> _records = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchRecords();
  }

  Future<void> _fetchRecords() async {
    setState(() => _loading = true);
    try {
      final data = await MarketPlaceDeliveryService.getAllSellerTracking();
      if (!mounted) return;
      setState(() {
        _records = data;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          "Your SendOuts",
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child:
            _loading
                ? const Center(child: CircularProgressIndicator())
                : _records.isEmpty
                ? ListView(
                  padding: const EdgeInsets.fromLTRB(20, 40, 20, 24),
                  children: const [
                    _EmptyDeliveryState(title: "No send-outs yet"),
                  ],
                )
                : RefreshIndicator(
                  onRefresh: _fetchRecords,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(14, 10, 14, 24),
                    itemCount: _records.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return const _HeaderCard(
                          title: "Track every send-out",
                          subtitle:
                              "See marketplace orders you’ve sent out and monitor their delivery status at a glance.",
                        );
                      }
                      final tracking = _records[index - 1];
                      return TrackingCard(tracking: tracking, onAccept: () {});
                    },
                  ),
                ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final String title;
  final String subtitle;

  const _HeaderCard({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            title,
            fontSize: 18,
            fontWeight: FontWeight.w800,
            textAlign: TextAlign.left,
          ),
          const SizedBox(height: 4),
          CustomText(
            subtitle,
            fontSize: 12,
            color: AppColors.subtext,
            textAlign: TextAlign.left,
          ),
        ],
      ),
    );
  }
}

class _EmptyDeliveryState extends StatelessWidget {
  final String title;

  const _EmptyDeliveryState({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            width: 92,
            height: 92,
            decoration: BoxDecoration(
              color: AppColors.accentSoft,
              borderRadius: BorderRadius.circular(28),
            ),
            child: const Icon(
              Icons.local_shipping_outlined,
              size: 40,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(height: 20),
          CustomText(title, fontSize: 22, fontWeight: FontWeight.w800),
          const SizedBox(height: 8),
          const CustomText(
            "Marketplace delivery records will appear here once orders start moving.",
            color: AppColors.subtext,
          ),
        ],
      ),
    );
  }
}
