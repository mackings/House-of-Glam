import 'package:flutter_test/flutter_test.dart';
import 'package:hog/TailorApp/Home/Model/submodel.dart';
import 'package:hog/TailorApp/Home/Model/subpay.dart';

void main() {
  test('parses localized subscription plan fields and ordered benefits', () {
    final response = SubscriptionPlanResponse.fromJson({
      'success': true,
      'message': 'Subscription plans retrieved successfully',
      'data': [
        {
          '_id': 'plan-1',
          'name': 'Premium',
          'amount': 30000,
          'duration': 'monthly',
          'description': 'Premium tools',
          'benefits': ['Unlimited listings', 'Priority support'],
          'benefitCount': 2,
          'baseCurrency': 'NGN',
          'displayCurrency': 'USD',
          'displayAmount': 20,
          'exchangeRate': 1500,
          'paymentProvider': 'stripe',
        },
      ],
    });

    final plan = response.data.single;
    expect(plan.benefits, ['Unlimited listings', 'Priority support']);
    expect(plan.benefitCount, 2);
    expect(plan.displayCurrency, 'USD');
    expect(plan.displayAmount, 20);
    expect(plan.exchangeRate, 1500);
    expect(plan.paymentProvider, 'stripe');
  });

  test('parses payment plan and benefit snapshot', () {
    final response = SubscriptionPaymentResponse.fromJson({
      'success': true,
      'provider': 'paystack',
      'message': 'Subscription payment initialized successfully',
      'authorizationUrl': 'https://checkout.example',
      'data': {
        'paymentMethod': 'Paystack',
        'paymentReference': 'payment-reference',
        'plan': 'Premium',
        'planId': 'plan-1',
        'planBenefits': ['Unlimited listings', 'Priority support'],
        'amountPaid': 30000,
      },
      'breakdown': {
        'plan': 'Premium',
        'billTerm': 'monthly',
        'benefits': ['Unlimited listings', 'Priority support'],
        'amountNGN': 30000,
        'currency': 'NGN',
      },
    });

    expect(response.provider, 'paystack');
    expect(response.data.planId, 'plan-1');
    expect(response.data.planBenefits, [
      'Unlimited listings',
      'Priority support',
    ]);
    expect(response.data.amountPaid, 30000);
    expect(response.breakdown.currency, 'NGN');
    expect(response.breakdown.benefits, [
      'Unlimited listings',
      'Priority support',
    ]);
  });
}
