import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hog/App/Admin/Views/admin_profile.dart';
import 'package:hog/App/Home/Model/vendor.dart';
import 'package:hog/App/NewestFeatures/Api/newest_feature_service.dart';
import 'package:hog/App/NewestFeatures/Views/designer_growth_hub.dart';
import 'package:hog/App/NewestFeatures/Views/designer_profile_detail.dart';
import 'package:hog/App/NewestFeatures/Views/escrow_workspace.dart';

void main() {
  test('Vendor rating response uses backend average rating', () {
    final vendor = Vendor.fromJson({
      '_id': 'vendor-1',
      'averageRating': 4,
      'ratingSum': 4,
      'totalRatings': 1,
    });

    expect(vendor.rate, 4);
    expect(vendor.totalRatings, 1);
  });

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
    expect(find.widgetWithText(Tab, 'Media'), findsNothing);
    expect(find.text('Other'), findsNothing);
    expect(find.text('Your portfolio'), findsOneWidget);
    expect(find.text('Update portfolio'), findsOneWidget);
    expect(find.text('Choose portfolio images'), findsOneWidget);
    expect(
      find.text('Select up to 10 images from your camera roll'),
      findsOneWidget,
    );

    await tester.tap(find.byType(DropdownButtonFormField<String>).first);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Other').last);
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Specify work section'), findsOneWidget);

    await tester.tap(find.widgetWithText(Tab, 'Measurements'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Customer measurements'), findsOneWidget);
    expect(find.text('Request more measurements'), findsNothing);
    expect(find.text('Send request'), findsNothing);

    await tester.tap(find.widgetWithText(Tab, 'Workflow'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Production workflows'), findsOneWidget);
    expect(find.text('Add new workflow'), findsOneWidget);
    expect(find.text('Choose agreed order'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('add_designer_workflow')));
    await tester.pump();

    expect(find.text('Add production workflow'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('workflow_customer_name')),
      findsOneWidget,
    );
  });

  testWidgets('Public designer profile reveals portfolio on request', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: DesignerProfileDetail(
          designerId: 'designer-1',
          initialData: {
            'businessName': 'Test Designer',
            'portfolioGallery': [
              {
                '_id': 'portfolio-1',
                'imageUrl': 'https://example.com/portfolio.jpg',
                'caption': 'Bridal work',
                'isVisible': true,
              },
            ],
          },
        ),
      ),
    );

    expect(find.text('View portfolio'), findsOneWidget);
    expect(find.text('Portfolio Gallery'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('view_designer_portfolio')));
    await tester.pump();

    expect(find.text('Hide portfolio'), findsOneWidget);
    expect(find.text('Portfolio Gallery'), findsOneWidget);
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
