import 'package:flutter/material.dart';
import 'package:hog/App/Profile/Api/MarketDelivery.dart';
import 'package:hog/App/Profile/Model/DeliveryTrack.dart';
import 'package:hog/App/Profile/widgets/DeliveryTrackPad.dart';
import 'package:hog/components/texts.dart';

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

  /// 🔹 Fetch SELLER delivery records
  Future<void> _fetchRecords() async {
    setState(() => _loading = true);
    try {
      final data = await MarketPlaceDeliveryService.getAllSellerTracking();
      setState(() {
        _records = data;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const CustomText(
          "Your SendOuts",
          color: Colors.white,
          fontSize: 18,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.purple,
      ),
      body: SafeArea(
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.purple),
              )
            : _records.isEmpty
                ? const Center(
                    child: CustomText("No delivery records yet."),
                  )
                : ListView.builder(
                    itemCount: _records.length,
                    itemBuilder: (context, index) {
                      final tracking = _records[index];
                      return TrackingCard(
                        tracking: tracking,
                        onAccept: () {},
                      );
                    },
                  ),
      ),
    );
  }
}
