import 'package:flutter_test/flutter_test.dart';
import 'package:hog/App/Admin/Model/AnalyticsModel.dart';

void main() {
  test('parses consolidated admin analytics response', () {
    final response = AdminAnalyticsResponse.fromJson({
      'success': true,
      'message': 'Admin analytics fetched successfully',
      'data': {
        'users': {
          'totalUsers': 39,
          'byRole': {'admin': 1, 'user': 30},
          'bySubscriptionPlan': {'free': 35, 'premium': 4},
          'verification': {'verified': 31, 'unverified': 8},
          'accountStatus': {'active': 38, 'blocked': 1},
          'registeredLast30Days': 6,
        },
        'listings': {
          'totalListings': 4,
          'freeListings': 0,
          'paidListings': 4,
          'unpricedListings': 0,
          'byApprovalStatus': {'approved': 3, 'pending': 1},
          'byAvailability': {'available': 3, 'sold': 1},
          'featured': {'featured': 1, 'standard': 3},
          'listedValue': {'total': 450000, 'average': 112500},
        },
        'earnings': {
          'totalEarnings': 1355958.84,
          'currency': 'NGN',
          'basis': 'current_admin_wallet_balance',
          'derivation': {
            'recordedCommission': 200000,
            'recordedTax': 550000,
            'otherWalletCredits': 605958.84,
          },
        },
        'transactions': {
          'totalTransactions': 61,
          'successfulTransactions': 54,
          'byPaymentMethod': {'Paystack': 50, 'Stripe': 11},
          'byCategory': {'marketplace': 34},
          'amountsByCurrency': {
            'NGN': {'transactionCount': 50, 'totalAmount': 2000000},
            'USD': {'transactionCount': 11, 'totalAmount': 1200},
          },
        },
        'generatedAt': '2026-06-14T10:55:00.000Z',
      },
    });

    expect(response.success, isTrue);
    expect(response.data.users.totalUsers, 39);
    expect(response.data.listings.paidListings, 4);
    expect(response.data.earnings.totalEarnings, 1355958.84);
    expect(response.data.transactions.successfulTransactions, 54);
    expect(
      response.data.transactions.amountsByCurrency['USD']?.totalAmount,
      1200,
    );
    expect(response.data.generatedAt, isNotNull);
  });

  test('parses paginated user and transaction records', () {
    final users = AnalyticsUsersPage.fromJson({
      'data': {
        'summary': {'totalUsers': 1},
        'records': [
          {
            '_id': 'user-1',
            'fullName': 'Ada Designer',
            'email': 'ada@example.com',
            'role': 'tailor',
            'wallet': 250000,
            'subscriptionPlan': 'premium',
            'isVerified': true,
            'isBlocked': false,
          },
        ],
        'pagination': {
          'page': 1,
          'limit': 20,
          'totalRecords': 1,
          'totalPages': 1,
        },
      },
    });
    final transactions = AnalyticsTransactionsPage.fromJson({
      'data': {
        'summary': {'totalTransactions': 1, 'successfulTransactions': 1},
        'records': [
          {
            '_id': 'transaction-1',
            'userId': {'fullName': 'Buyer Name', 'email': 'buyer@example.com'},
            'listingId': [
              {'title': 'Blue Corporate Suit'},
            ],
            'analyticsAmount': 150000,
            'paymentCurrency': 'NGN',
            'paymentStatus': 'success',
            'paymentMethod': 'Paystack',
          },
        ],
        'pagination': {
          'page': 1,
          'limit': 20,
          'totalRecords': 1,
          'totalPages': 1,
        },
      },
    });

    expect(users.records.single.fullName, 'Ada Designer');
    expect(users.records.single.wallet, 250000);
    expect(transactions.records.single.userName, 'Buyer Name');
    expect(transactions.records.single.listingTitles, ['Blue Corporate Suit']);
    expect(transactions.records.single.analyticsAmount, 150000);
  });
}
