import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hog/App/Admin/Api/admin_invitation_service.dart';
import 'package:hog/App/Admin/Model/admin_role.dart';
import 'package:hog/App/Admin/Views/admin_invitation.dart';

void main() {
  testWidgets('admin can only invite finance, customer service, and listing manager', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: AdminInvitationPage(
          inviterRole: AdminRole.admin,
          invitationSender: _successfulSender,
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('invite_role')));
    await tester.pumpAndSettle();

    expect(find.text('Super Admin'), findsNothing);
    expect(find.text('Admin'), findsNothing);
    expect(find.text('Finance'), findsWidgets);
    expect(find.text('Customer Service'), findsWidgets);
    expect(find.text('Listing Manager'), findsWidgets);
  });

  testWidgets(
    'roles without invite permission see a blocked state instead of the form',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AdminInvitationPage(
            inviterRole: AdminRole.finance,
            invitationSender: _successfulSender,
          ),
        ),
      );

      expect(find.text('You cannot invite team members'), findsOneWidget);
      expect(find.byKey(const ValueKey('invite_role')), findsNothing);
    },
  );

  testWidgets('super admin can send invitation with responsibilities', (
    tester,
  ) async {
    String? sentName;
    String? sentEmail;
    String? sentRole;
    List<String>? sentResponsibilities;

    Future<AdminInvitationResult> sender({
      required String fullName,
      required String email,
      required String role,
      String? phoneNumber,
      String? country,
      String? address,
      List<String> responsibilities = const [],
    }) async {
      sentName = fullName;
      sentEmail = email;
      sentRole = role;
      sentResponsibilities = responsibilities;
      return const AdminInvitationResult(
        success: true,
        message: 'Admin invitation sent successfully',
        data: {
          'user': {'fullName': 'Ada Platform Manager'},
          'credentialsDeliveredByEmail': true,
        },
      );
    }

    await tester.pumpWidget(
      MaterialApp(
        home: AdminInvitationPage(
          inviterRole: AdminRole.superAdmin,
          invitationSender: sender,
        ),
      ),
    );

    await tester.enterText(
      find.byKey(const ValueKey('invite_full_name')),
      'Ada Platform Manager',
    );
    await tester.enterText(
      find.byKey(const ValueKey('invite_email')),
      'ada.admin@example.com',
    );
    await tester.tap(find.byKey(const ValueKey('invite_role')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Super Admin').last);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('add_invite_responsibility')),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const ValueKey('add_invite_responsibility')));
    await tester.pump();
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('invite_responsibility_0')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.enterText(
      find.byKey(const ValueKey('invite_responsibility_0')),
      'Review platform activity',
    );
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('send_admin_invitation')),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const ValueKey('send_admin_invitation')));
    await tester.pumpAndSettle();

    expect(sentName, 'Ada Platform Manager');
    expect(sentEmail, 'ada.admin@example.com');
    expect(sentRole, 'superAdmin');
    expect(sentResponsibilities, ['Review platform activity']);
    expect(find.text('Invitation sent'), findsOneWidget);
    expect(find.textContaining('temporary login credentials'), findsOneWidget);
  });
}

Future<AdminInvitationResult> _successfulSender({
  required String fullName,
  required String email,
  required String role,
  String? phoneNumber,
  String? country,
  String? address,
  List<String> responsibilities = const [],
}) async {
  return const AdminInvitationResult(success: true, message: 'Invitation sent');
}
