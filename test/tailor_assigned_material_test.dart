import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hog/TailorApp/Home/Model/AssignedMaterial.dart';
import 'package:hog/TailorApp/Widgets/tailorModalsheetdetails.dart';

void main() {
  group('TailorAssignedMaterial payment completion', () {
    test('is false when the client has not paid', () {
      final item = _material(status: 'quote', amountPaid: 0, amountToPay: 100);

      expect(item.isClientPaymentComplete, isFalse);
    });

    test('is false when the client has only made a partial payment', () {
      final item = _material(
        status: 'part payment',
        amountPaid: 40,
        amountToPay: 60,
      );

      expect(item.isClientPaymentComplete, isFalse);
    });

    test('is true when the paid amount covers the client total', () {
      final item = _material(
        status: 'accepted',
        amountPaid: 100,
        amountToPay: 0,
      );

      expect(item.isClientPaymentComplete, isTrue);
    });

    test('is true when the backend reports full payment', () {
      final item = _material(
        status: 'full payment',
        amountPaid: 0,
        amountToPay: 0,
      );

      expect(item.isClientPaymentComplete, isTrue);
    });

    testWidgets('delivery button is disabled until payment is complete', (
      tester,
    ) async {
      final item = _material(
        status: 'part payment',
        amountPaid: 40,
        amountToPay: 60,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder:
                (context) => Scaffold(
                  body: TextButton(
                    onPressed:
                        () => showTailorMaterialDetails(context, item, null),
                    child: const Text('Open'),
                  ),
                ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      final button = tester.widget<FilledButton>(
        find.byKey(const ValueKey('deliver_attire_button')),
      );
      expect(button.onPressed, isNull);
      expect(
        find.text('Full client payment is required before delivery.'),
        findsOneWidget,
      );
    });
  });
}

TailorAssignedMaterial _material({
  required String status,
  required double amountPaid,
  required double amountToPay,
}) {
  return TailorAssignedMaterial.fromJson({
    '_id': 'review-1',
    'userId': <String, dynamic>{},
    'vendorId': <String, dynamic>{},
    'materialId': {
      '_id': 'material-1',
      'sampleImage': <String>[],
      'isDelivered': false,
    },
    'totalCost': 100,
    'userPayableTotal': 100,
    'amountPaid': amountPaid,
    'amountToPay': amountToPay,
    'status': status,
    'createdAt': '2026-06-13T00:00:00.000Z',
    'updatedAt': '2026-06-13T00:00:00.000Z',
  });
}
