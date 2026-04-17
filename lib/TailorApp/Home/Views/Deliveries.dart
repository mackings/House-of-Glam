import 'package:flutter/material.dart';
import 'package:hog/TailorApp/Home/Api/Delivery.dart';
import 'package:hog/TailorApp/Home/Model/deliveryModel.dart';
import 'package:hog/TailorApp/Widgets/deliverycard.dart';
import 'package:hog/TailorApp/Widgets/deliverymodal.dart';
import 'package:hog/components/texts.dart';
import 'package:hog/theme/app_theme.dart';

class TailorDeliveries extends StatefulWidget {
  const TailorDeliveries({super.key});

  @override
  State<TailorDeliveries> createState() => _TailorDeliveriesState();
}

class _TailorDeliveriesState extends State<TailorDeliveries> {
  final _service = TailorTrackingService();
  late Future<TailorTrackingResponse> _future;

  @override
  void initState() {
    super.initState();
    _fetchDeliveries();
  }

  void _fetchDeliveries() {
    setState(() {
      _future = _service.fetchTrackingRecords();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.canvas,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: AppColors.ink),
        title: const CustomText(
          "Logistics",
          color: AppColors.ink,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      body: SafeArea(
        child: FutureBuilder<TailorTrackingResponse>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.accent),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: CustomText(
                  "Error: ${snapshot.error}",
                  color: AppColors.danger,
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.data.isEmpty) {
              return RefreshIndicator(
                onRefresh: () async => _fetchDeliveries(),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  children: const [
                    _DeliveryHeader(
                      title: "No live logistics yet",
                      subtitle:
                          "Completed or pending dispatch jobs will appear here for quick tracking and confirmation.",
                      total: "0",
                      delivered: "0",
                    ),
                  ],
                ),
              );
            }

            final deliveries = snapshot.data!.data;
            final deliveredCount =
                deliveries.where((tracking) => tracking.isDelivered).length;

            return RefreshIndicator(
              onRefresh: () async => _fetchDeliveries(),
              color: AppColors.accent,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                children: [
                  _DeliveryHeader(
                    title: "Delivery Management",
                    subtitle:
                        "Track shipments, review materials, and finalize delivery cycles efficiently.",
                    total: "${deliveries.length}",
                    delivered: "$deliveredCount",
                  ),
                  const SizedBox(height: 14),
                  ...deliveries.map((tracking) {
                    return DeliveryCard(
                      tracking: tracking,
                      onTap:
                          () => showDeliveryDetails(
                            context,
                            tracking,
                            service: _service,
                            onRefresh: _fetchDeliveries,
                          ),
                    );
                  }),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _DeliveryHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final String total;
  final String delivered;

  const _DeliveryHeader({
    required this.title,
    required this.subtitle,
    required this.total,
    required this.delivered,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFFFFF), Color(0xFFF1F7FF)],
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
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.local_shipping_outlined,
                  color: Color(0xFF2563EB),
                ),
              ),
              const Spacer(),
              _DeliveryStat(label: "Total", value: total),
              const SizedBox(width: 8),
              _DeliveryStat(label: "Completed", value: delivered),
            ],
          ),
          const SizedBox(height: 18),
          CustomText(
            title,
            fontSize: 21,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
            textAlign: TextAlign.left,
          ),
          const SizedBox(height: 8),
          CustomText(
            subtitle,
            fontSize: 13,
            color: AppColors.subtext,
            textAlign: TextAlign.left,
          ),
        ],
      ),
    );
  }
}

class _DeliveryStat extends StatelessWidget {
  final String label;
  final String value;

  const _DeliveryStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          CustomText(
            value,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
          ),
          CustomText(label, fontSize: 11, color: AppColors.subtext),
        ],
      ),
    );
  }
}
