import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hog/TailorApp/Home/Api/Delivery.dart';
import 'package:hog/TailorApp/Home/Model/deliveryModel.dart';
import 'package:hog/TailorApp/Widgets/deliverymodal.dart';

void main() {
  testWidgets('copy feedback appears inside tracking sheet', (tester) async {
    final tracking = TailorTracking(
      id: 'tracking-1',
      userId: 'user-1',
      vendorId: 'vendor-1',
      material: MaterialDetails(
        id: 'material-1',
        attireType: 'Senator Wear',
        clothMaterial: 'Lace',
        color: 'Black',
        brand: 'Lacious',
        sampleImage: const [],
      ),
      trackingNumber: 161034,
      isDelivered: true,
      createdAt: DateTime(2026, 6, 13),
      updatedAt: DateTime(2026, 6, 13),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder:
              (context) => Scaffold(
                body: TextButton(
                  onPressed:
                      () => showDeliveryDetails(
                        context,
                        tracking,
                        service: TailorTrackingService(),
                        onRefresh: () {},
                      ),
                  child: const Text('Open tracking'),
                ),
              ),
        ),
      ),
    );

    await tester.tap(find.text('Open tracking'));
    await tester.pumpAndSettle();

    expect(find.text('Tracking Details'), findsOneWidget);
    expect(find.text('Continue'), findsNothing);

    await tester.ensureVisible(find.text('Copy'));
    await tester.tap(find.text('Copy'));
    await tester.pump();

    expect(find.text('Tracking ID copied'), findsOneWidget);
    expect(find.text('Tracking Details'), findsOneWidget);
  });
}
