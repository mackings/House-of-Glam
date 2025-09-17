import 'package:flutter/material.dart';
import 'package:hog/TailorApp/Home/Api/Delivery.dart';
import 'package:hog/TailorApp/Home/Model/deliveryModel.dart';
import 'package:hog/TailorApp/Widgets/deliverycard.dart';
import 'package:hog/TailorApp/Widgets/deliverymodal.dart';
import 'package:hog/components/texts.dart';

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
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: CustomText("Deliverables", color: Colors.white, fontSize: 18),
      ),
      body: SafeArea(
        child: FutureBuilder<TailorTrackingResponse>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.purple),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: CustomText(
                  "Error: ${snapshot.error}",
                  color: Colors.red,
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.data.isEmpty) {
              return Center(
                child: CustomText("No deliveries found", color: Colors.black),
              );
            }

            final deliveries = snapshot.data!.data;

            return ListView.builder(
              itemCount: deliveries.length,
              itemBuilder: (_, index) {
                final tracking = deliveries[index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DeliveryCard(
                    tracking: tracking,
                    onTap:
                        () => showDeliveryDetails(
                          context,
                          tracking,
                          service: _service,
                          onRefresh:
                              _fetchDeliveries, // refresh list after delivery
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
}
