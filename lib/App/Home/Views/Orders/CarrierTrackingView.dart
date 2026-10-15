import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hog/App/Home/Api/paymentService.dart';
import 'package:hog/App/Home/Model/carrierTrackingModel.dart';
import 'package:hog/components/customAppbar.dart';
import 'package:hog/components/texts.dart';
import 'package:hog/theme/app_theme.dart';
import 'package:intl/intl.dart';

/// Live tracking for a real Fez shipment, shared between the buyer and the
/// designer — both can call GET /tracking/carrier/:carrierTrackingNumber.
class CarrierTrackingView extends StatefulWidget {
  final String carrierTrackingNumber;
  final String carrier;

  const CarrierTrackingView({
    super.key,
    required this.carrierTrackingNumber,
    this.carrier = "fez",
  });

  @override
  State<CarrierTrackingView> createState() => _CarrierTrackingViewState();
}

class _CarrierTrackingViewState extends State<CarrierTrackingView> {
  late Future<CarrierTrackingResult> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _future = PaymentService.trackCarrierShipment(
      carrierTrackingNumber: widget.carrierTrackingNumber,
      carrier: widget.carrier,
    );
  }

  Future<void> _reload() async {
    setState(_load);
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: const CustomAppBar(title: "Live Tracking", enableAction: false),
      body: SafeArea(
        child: FutureBuilder<CarrierTrackingResult>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.accent),
              );
            }

            final result = snapshot.data;
            if (result == null || !result.hasInfo) {
              return _ErrorState(
                message:
                    result?.errorMessage ??
                    "Unable to fetch tracking info. Please try again.",
                onRetry: _reload,
              );
            }

            return RefreshIndicator(
              onRefresh: _reload,
              color: AppColors.accent,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                children: [
                  _WaybillCard(
                    waybillNumber: widget.carrierTrackingNumber,
                    info: result.info!,
                  ),
                  const SizedBox(height: 16),
                  const CustomText(
                    "Shipment Progress",
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    textAlign: TextAlign.left,
                  ),
                  const SizedBox(height: 10),
                  if (result.info!.events.isEmpty)
                    _EmptyEventsCard(status: result.info!.displayStatus)
                  else
                    _EventTimeline(events: result.info!.events),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _WaybillCard extends StatelessWidget {
  final String waybillNumber;
  final CarrierTrackingInfo info;

  const _WaybillCard({required this.waybillNumber, required this.info});

  @override
  Widget build(BuildContext context) {
    final delivered = info.isDelivered;
    final statusColor = delivered ? AppColors.success : AppColors.warning;
    final statusBg = delivered ? const Color(0xFFEEF8F2) : const Color(0xFFFFF4DE);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF8F3FF), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CustomText(
                      "Waybill Number",
                      fontSize: 11,
                      color: AppColors.subtext,
                      textAlign: TextAlign.left,
                    ),
                    const SizedBox(height: 3),
                    CustomText(
                      waybillNumber,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      textAlign: TextAlign.left,
                    ),
                  ],
                ),
              ),
              InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () {
                  Clipboard.setData(ClipboardData(text: waybillNumber));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Waybill number copied"),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Icon(
                    Icons.copy_rounded,
                    size: 16,
                    color: AppColors.accent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: statusBg,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  delivered
                      ? Icons.check_circle_rounded
                      : Icons.local_shipping_rounded,
                  size: 14,
                  color: statusColor,
                ),
                const SizedBox(width: 6),
                CustomText(
                  info.displayStatus,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: statusColor,
                ),
              ],
            ),
          ),
          if (info.recipientName != null || info.recipientAddress != null) ...[
            const SizedBox(height: 16),
            const Divider(color: AppColors.border, height: 1),
            const SizedBox(height: 14),
            if (info.recipientName != null)
              _DetailRow(label: "Recipient", value: info.recipientName!),
            if (info.recipientAddress != null)
              _DetailRow(
                label: "Delivery Address",
                value: info.recipientAddress!,
              ),
          ],
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: CustomText(
              label,
              fontSize: 12,
              color: AppColors.subtext,
              textAlign: TextAlign.left,
            ),
          ),
          Expanded(
            child: CustomText(
              value,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
              textAlign: TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }
}

class _EventTimeline extends StatelessWidget {
  final List<CarrierTrackingEvent> events;

  const _EventTimeline({required this.events});

  @override
  Widget build(BuildContext context) {
    // Fez returns events oldest-first; show newest-first so the buyer/
    // designer sees the current status without scrolling.
    final ordered = events.reversed.toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          for (var i = 0; i < ordered.length; i++)
            _TimelineTile(
              event: ordered[i],
              isFirst: i == 0,
              isLast: i == ordered.length - 1,
            ),
        ],
      ),
    );
  }
}

class _TimelineTile extends StatelessWidget {
  final CarrierTrackingEvent event;
  final bool isFirst;
  final bool isLast;

  const _TimelineTile({
    required this.event,
    required this.isFirst,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final dotColor = isFirst ? AppColors.accent : AppColors.border;
    final formattedTime =
        event.timestamp != null
            ? DateFormat('MMM d, y • h:mm a').format(event.timestamp!)
            : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                    border:
                        isFirst
                            ? null
                            : Border.all(color: AppColors.border, width: 2),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: AppColors.border,
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      event.description.isNotEmpty
                          ? event.description
                          : event.status,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                      textAlign: TextAlign.left,
                    ),
                    if (formattedTime != null) ...[
                      const SizedBox(height: 2),
                      CustomText(
                        formattedTime,
                        fontSize: 11,
                        color: AppColors.subtext,
                        textAlign: TextAlign.left,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyEventsCard extends StatelessWidget {
  final String status;

  const _EmptyEventsCard({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.hourglass_empty_rounded,
            color: AppColors.subtext,
            size: 32,
          ),
          const SizedBox(height: 10),
          CustomText(
            "Current status: $status",
            fontSize: 13,
            fontWeight: FontWeight.w700,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          const CustomText(
            "No tracking events yet — check back soon.",
            fontSize: 12,
            color: AppColors.subtext,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.wifi_off_rounded,
              size: 40,
              color: AppColors.subtext,
            ),
            const SizedBox(height: 12),
            const CustomText(
              "Couldn't load tracking info",
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
            const SizedBox(height: 6),
            CustomText(
              message,
              fontSize: 12,
              color: AppColors.subtext,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onRetry,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.accent,
              ),
              child: const Text("Retry"),
            ),
          ],
        ),
      ),
    );
  }
}
