import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hog/App/Admin/Views/admin_profile.dart';
import 'package:hog/App/NewestFeatures/Api/newest_feature_service.dart';
import 'package:hog/App/NewestFeatures/Views/designer_growth_hub.dart';
import 'package:hog/App/NewestFeatures/Views/escrow_workspace.dart';

void main() {
  test('API list parser supports messaging response envelopes', () {
    expect(
      apiList({
        'conversations': [
          {'_id': 'conversation-1'},
        ],
      }),
      hasLength(1),
    );
    expect(
      apiList({
        'messages': [
          {'_id': 'message-1'},
        ],
      }),
      hasLength(1),
    );
  });

  testWidgets('Designer Tools omits Quotes and supports another work section', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: DesignerGrowthHub())),
    );

    expect(find.text('Quotes'), findsNothing);
    expect(find.text('Other'), findsNothing);

    await tester.tap(find.byType(DropdownButtonFormField<String>).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Other').last);
    await tester.pumpAndSettle();

    expect(find.text('Specify work section'), findsOneWidget);
  });

  testWidgets('Protection copy does not expose payment provider references', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: EscrowWorkspace()));
    await tester.pump();

    expect(find.textContaining('Paystack'), findsNothing);
    expect(find.textContaining('escrow ID'), findsNothing);
    expect(find.textContaining('Payments stay protected'), findsOneWidget);
  });

  testWidgets('Admin profile exposes logout', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: AdminProfile()));
    await tester.pump();

    expect(find.text('Admin Profile'), findsOneWidget);
    expect(find.text('Log Out'), findsOneWidget);
  });
}
