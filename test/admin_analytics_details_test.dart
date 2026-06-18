import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hog/App/Admin/Model/AnalyticsModel.dart';
import 'package:hog/App/Admin/Views/analytics_details.dart';
import 'package:hog/App/Admin/Widgets/analyticsCard.dart';

void main() {
  testWidgets('analytics filters do not overflow on narrow screens', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: AdminUsersAnalyticsPage(
          data: _userSummary(),
          initialResult: AnalyticsUsersPage(
            summary: _userSummary(),
            records: const [],
            pagination: _pagination(),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.byType(DropdownButtonFormField<String>), findsNWidgets(2));
  });

  testWidgets('users analytics page shows dedicated user breakdowns', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: AdminUsersAnalyticsPage(
          data: UserAnalytics(
            totalUsers: 39,
            byRole: const {'user': 30, 'tailor': 7},
            bySubscriptionPlan: const {'free': 35, 'premium': 4},
            verification: const {'verified': 31, 'unverified': 8},
            accountStatus: const {'active': 38, 'blocked': 1},
            registeredLast30Days: 6,
          ),
          initialResult: AnalyticsUsersPage(
            summary: UserAnalytics(
              totalUsers: 39,
              byRole: const {'user': 30, 'tailor': 7},
              bySubscriptionPlan: const {'free': 35, 'premium': 4},
              verification: const {'verified': 31, 'unverified': 8},
              accountStatus: const {'active': 38, 'blocked': 1},
              registeredLast30Days: 6,
            ),
            records: const [
              AnalyticsUserRecord(
                id: 'user-1',
                fullName: 'Ada Designer',
                email: 'ada@example.com',
                username: 'ada',
                phoneNumber: '',
                image: '',
                role: 'tailor',
                country: 'Nigeria',
                wallet: 250000,
                subscriptionPlan: 'premium',
                subscriptionStartDate: null,
                subscriptionEndDate: null,
                billTerm: 'monthly',
                isVerified: true,
                isBlocked: false,
                isVendorEnabled: true,
                createdAt: null,
              ),
            ],
            pagination: const AnalyticsPagination(
              page: 1,
              limit: 20,
              totalRecords: 1,
              totalPages: 1,
              hasNextPage: false,
              hasPreviousPage: false,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Total users'), findsOneWidget);
    expect(find.text('Ada Designer'), findsOneWidget);
    expect(find.text('Designer'), findsOneWidget);
    expect(find.text('Premium plan'), findsOneWidget);
  });

  testWidgets('transactions page shows successful transaction details', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: AdminTransactionsAnalyticsPage(
          data: TransactionAnalytics(
            totalTransactions: 61,
            successfulTransactions: 54,
            byPaymentStatus: const {'success': 54},
            byOrderStatus: const {'completed': 40},
            byTransactionStatus: const {'success': 6},
            byTransactionType: const {'credit': 6},
            byPaymentMethod: const {'Paystack': 50},
            byCategory: const {'marketplace': 34},
            amountsByCurrency: const {
              'NGN': TransactionCurrencyAnalytics(
                transactionCount: 50,
                totalAmount: 2000000,
              ),
            },
          ),
          successfulOnly: true,
          initialResult: AnalyticsTransactionsPage(
            summary: TransactionAnalytics(
              totalTransactions: 61,
              successfulTransactions: 54,
              byPaymentStatus: const {'success': 54},
              byOrderStatus: const {'completed': 40},
              byTransactionStatus: const {'success': 6},
              byTransactionType: const {'credit': 6},
              byPaymentMethod: const {'Paystack': 50},
              byCategory: const {'marketplace': 34},
              amountsByCurrency: const {
                'NGN': TransactionCurrencyAnalytics(
                  transactionCount: 50,
                  totalAmount: 2000000,
                ),
              },
            ),
            records: const [
              AnalyticsTransactionRecord(
                id: 'transaction-1',
                userName: 'Buyer Name',
                userEmail: 'buyer@example.com',
                vendorName: 'Ada Designs',
                materialTitle: '',
                listingTitles: ['Blue Corporate Suit'],
                totalAmount: 150000,
                amountPaid: 150000,
                analyticsAmount: 150000,
                paymentMethod: 'Paystack',
                paymentReference: 'HOG-001',
                paymentStatus: 'success',
                currency: 'NGN',
                orderStatus: 'full payment',
                transactionStatus: '',
                transactionType: '',
                createdAt: null,
              ),
            ],
            pagination: const AnalyticsPagination(
              page: 1,
              limit: 20,
              totalRecords: 1,
              totalPages: 1,
              hasNextPage: false,
              hasPreviousPage: false,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Successful transactions'), findsOneWidget);
    expect(find.text('Blue Corporate Suit'), findsOneWidget);
    expect(find.text('Buyer Name'), findsOneWidget);
    expect(find.text('₦150,000'), findsOneWidget);
  });

  testWidgets('analytics card exposes drill-down action', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AnalyticsCard(
            title: 'Total Users',
            value: '39',
            icon: Icons.people_outline,
            tint: Colors.blue,
            onTap: () => tapped = true,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Total Users'));
    expect(tapped, isTrue);
    expect(find.byIcon(Icons.arrow_forward_ios_rounded), findsOneWidget);
  });
}

UserAnalytics _userSummary() {
  return UserAnalytics(
    totalUsers: 39,
    byRole: const {'user': 30, 'tailor': 7},
    bySubscriptionPlan: const {'free': 35, 'premium': 4},
    verification: const {'verified': 31, 'unverified': 8},
    accountStatus: const {'active': 38, 'blocked': 1},
    registeredLast30Days: 6,
  );
}

AnalyticsPagination _pagination() {
  return const AnalyticsPagination(
    page: 1,
    limit: 20,
    totalRecords: 0,
    totalPages: 1,
    hasNextPage: false,
    hasPreviousPage: false,
  );
}
