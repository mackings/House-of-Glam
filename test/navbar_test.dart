import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hog/components/navbar.dart';

void main() {
  testWidgets('user designs navigation is labeled Checkroom', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: CustomBottomNavBar(
            currentIndex: 4,
            onTap: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('Checkroom'), findsOneWidget);
    expect(find.text('My Designs'), findsNothing);
  });
}
