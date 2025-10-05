import 'package:flutter/material.dart';
import 'package:hog/App/Auth/Model/trackingmodel.dart';
import 'package:hog/App/Profile/Api/MarketDelivery.dart';
import 'package:hog/App/Profile/Model/DeliveryTrack.dart';
import 'package:hog/App/Profile/widgets/DeliveryTrackPad.dart';
import 'package:hog/App/Profile/widgets/OTPdeliverysheet.dart';
import 'package:hog/components/texts.dart';

class MarketDelivery extends StatefulWidget {
  const MarketDelivery({super.key});

  @override
  State<MarketDelivery> createState() => _MarketDeliveryState();
}

class _MarketDeliveryState extends State<MarketDelivery> {
  // ✅ Remove old constructor-based service; now using static methods
  List<MarketTrackingRecord> _records = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchRecords();
  }

  /// 🔹 Fetch delivery records
  Future<void> _fetchRecords() async {
    setState(() => _loading = true);
    try {
      final data = await MarketPlaceDeliveryService.getAllTracking();
      setState(() {
        _records = data;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('❌ Error: $e')));
    }
  }

  /// 🔹 Accept order
  Future<void> _acceptOrder(String trackingNumber) async {
    final success = await MarketPlaceDeliveryService.acceptOrder(
      trackingNumber,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('✅ Order accepted!')));
      _fetchRecords(); // refresh list
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Failed to accept order')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: CustomText("Deliverables", color: Colors.white, fontSize: 18),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.purple,
      ),
      body: SafeArea(
        child:
            _loading
                ? const Center(
                  child: CircularProgressIndicator(color: Colors.purple),
                )
                : _records.isEmpty
                ? const Center(child: CustomText("No Delivery records yet."))
                : ListView.builder(
                  itemCount: _records.length,
                  itemBuilder: (context, index) {
                    final tracking = _records[index];

                    return TrackingCard(
                      tracking: tracking,
                      onAccept: () {
                        showAcceptOrderModal(context, (enteredTracking) {
                          _acceptOrder(enteredTracking);
                        });
                      },
                    );
                  },
                ),
      ),
    );
  }
}
