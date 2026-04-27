import 'package:flutter/material.dart';
import 'package:hog/App/Auth/Api/tracking.dart';
import 'package:hog/App/Auth/Model/trackingmodel.dart';
import 'package:hog/App/Home/Views/PuB/widgets/trackingCard.dart';
import 'package:hog/App/Home/Views/PuB/widgets/tracksheet.dart';
import 'package:hog/components/customAppbar.dart';
import 'package:hog/components/texts.dart';
import 'package:hog/theme/app_theme.dart';

class TrackingDelivery extends StatefulWidget {
  const TrackingDelivery({super.key});

  @override
  State<TrackingDelivery> createState() => _TrackingDeliveryState();
}

class _TrackingDeliveryState extends State<TrackingDelivery> {
  late Future<TrackingResponse?> _futureTracking;

  @override
  void initState() {
    super.initState();
    _futureTracking = TrackingService.getAllTracking();
  }

  Future<void> _reload() async {
    final future = TrackingService.getAllTracking();
    setState(() => _futureTracking = future);
    await future;
  }

  void _showTrackingDetails(TrackingRecord record) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (_) => TrackingDetailSheet(record: record),
    ).then((_) => _reload());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: const CustomAppBar(title: "Tracking", enableAction: false),
      body: FutureBuilder<TrackingResponse?>(
        future: _futureTracking,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData ||
              snapshot.data == null ||
              snapshot.data!.data.isEmpty) {
            return RefreshIndicator(
              onRefresh: _reload,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 24),
                children: [
                  Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(
                            color: AppColors.accentSoft,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: const Icon(
                            Icons.local_shipping_outlined,
                            size: 44,
                            color: AppColors.accent,
                          ),
                        ),
                        const SizedBox(height: 22),
                        const CustomText(
                          "No Deliveries Yet",
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                        const SizedBox(height: 8),
                        const CustomText(
                          "Your orders will appear here once they are shipped.",
                          color: AppColors.subtext,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          final records = snapshot.data!.data;
          final deliveredCount =
              records.where((record) => record.isDelivered).length;

          return RefreshIndicator(
            onRefresh: _reload,
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 24),
              itemCount: records.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(26),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomText(
                              "Track every delivery in one place",
                              textAlign: TextAlign.left,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                            SizedBox(height: 6),
                            CustomText(
                              "Open any card to review fabric details, measurements, and accept completed deliveries when they arrive.",
                              textAlign: TextAlign.left,
                              color: AppColors.subtext,
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: _TrackingStat(
                              icon: Icons.inventory_2_outlined,
                              label: "Total",
                              value: records.length.toString(),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _TrackingStat(
                              icon: Icons.check_circle_outline_rounded,
                              label: "Delivered",
                              value: deliveredCount.toString(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                    ],
                  );
                }

                final record = records[index - 1];
                return TrackingCard(
                  record: record,
                  onTap: () => _showTrackingDetails(record),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _TrackingStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _TrackingStat({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
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
