import 'package:flutter/material.dart';
import 'package:hog/App/Auth/Api/tracking.dart';
import 'package:hog/App/Auth/Model/trackingmodel.dart';
import 'package:hog/App/Home/Views/PuB/widgets/trackingCard.dart';
import 'package:hog/App/Home/Views/PuB/widgets/tracksheet.dart';
import 'package:hog/components/texts.dart';



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

  void _showTrackingDetails(TrackingRecord record) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (_) => TrackingDetailSheet(record: record),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.purple,
        title: CustomText("Tracking", color: Colors.white, fontSize: 18),
      ),
      body: FutureBuilder<TrackingResponse?>(
        future: _futureTracking,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: Colors.purple));
          }

          if (!snapshot.hasData ||
              snapshot.data == null ||
              snapshot.data!.data.isEmpty) {
            return const Center(
                child: CustomText("No tracking records found",
                    color: Colors.black54));
          }

          final records = snapshot.data!.data;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: records.length,
            itemBuilder: (context, index) {
              final record = records[index];
              return TrackingCard(
                record: record,
                onTap: () => _showTrackingDetails(record),
              );
            },
          );
        },
      ),
    );
  }
}

