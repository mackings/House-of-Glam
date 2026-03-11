import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hog/App/Banks/Api/BamkService.dart';
import 'package:hog/App/Home/Api/paymentService.dart';
import 'package:hog/App/Home/Model/reviewModel.dart';
import 'package:hog/components/button.dart';
import 'package:hog/components/formfields.dart';
import 'package:hog/components/texts.dart';
import 'package:hog/constants/country_list.dart';
import 'package:hog/constants/currency.dart';
import 'package:hog/constants/currencyHelper.dart';
import 'package:intl/intl.dart';

class PaymentOptionsModal extends StatefulWidget {
  final Review review;
  final Function(String url) onCheckout;
  final String initialPaymentType;
  final bool allowPaymentTypeSwitch;

  const PaymentOptionsModal({
    super.key,
    required this.review,
    required this.onCheckout,
    this.initialPaymentType = "part",
    this.allowPaymentTypeSwitch = true,
  });

  @override
  State<PaymentOptionsModal> createState() => _PaymentOptionsModalState();
}

class _PaymentOptionsModalState extends State<PaymentOptionsModal> {
  String paymentType = "part";
  String shipment = "Regular";
  String deliveryMode = "address";

  final TextEditingController amountController = TextEditingController();
  final TextEditingController addressLine1Controller = TextEditingController();
  final TextEditingController addressLine2Controller = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController regionController = TextEditingController();
  final TextEditingController postalCodeController = TextEditingController();
  CountryOption? selectedCountry = allCountries.firstWhere(
    (country) => country.isoCode == 'NG',
    orElse: () => allCountries.first,
  );
  bool isLoading = false;
  bool isCalculatingDelivery = false;
  bool showCountryError = false;
  bool showAddressLine1Error = false;
  bool showCityError = false;
  bool showRegionError = false;
  bool showPickupCountryError = false;
  bool showPickupStateError = false;
  bool showPickupLocationError = false;
  bool isLoadingPickupHierarchy = false;

  List<PickupCountryOption> pickupCountries = [];
  PickupCountryOption? selectedPickupCountry;
  PickupStateOption? selectedPickupState;
  PickupLocationOption? selectedPickupLocation;
  Timer? _deliveryQuoteDebounce;
  String? _deliveryCostLabel;
  String? _confirmedDeliveryQuoteKey;

  bool _isUserInNigeria = true;

  String _normalizePickupKey(String value) => value.trim().toLowerCase();

  List<PickupStateOption> _getMergedPickupStates(PickupCountryOption? country) {
    if (country == null) return const [];

    final Map<String, PickupStateOption> merged = {};

    for (final state in country.states) {
      final stateKey = _normalizePickupKey(state.name);
      final existing = merged[stateKey];

      if (existing == null) {
        merged[stateKey] = PickupStateOption(
          id: state.id,
          name: state.name,
          locations: List<PickupLocationOption>.from(state.locations),
        );
        continue;
      }

      final locationKeySet =
          existing.locations
              .map(
                (l) =>
                    '${_normalizePickupKey(l.name)}|${_normalizePickupKey(l.address)}',
              )
              .toSet();

      for (final location in state.locations) {
        final key =
            '${_normalizePickupKey(location.name)}|${_normalizePickupKey(location.address)}';
        if (!locationKeySet.contains(key)) {
          existing.locations.add(location);
          locationKeySet.add(key);
        }
      }
    }

    return merged.values.toList();
  }

  @override
  void initState() {
    super.initState();
    paymentType = widget.initialPaymentType;
    _loadUserCountry();
    _loadPickupHierarchy();
    if (paymentType == "part") {
      // Auto-fill half payment amount
      _autoFillHalfPayment();
    }
  }

  Future<void> _loadPickupHierarchy() async {
    setState(() => isLoadingPickupHierarchy = true);
    final data = await PaymentService.getPickupHierarchy();
    if (!mounted) return;
    setState(() {
      pickupCountries = data;
      isLoadingPickupHierarchy = false;
    });
  }

  Future<void> _loadUserCountry() async {
    final userCountry = await CurrencyHelper.getUserCountry();
    final isNigeria =
        userCountry?.toUpperCase() == 'NIGERIA' ||
        userCountry?.toUpperCase() == 'NG';
    if (!mounted) return;
    final matchedCountry =
        allCountries.where((country) {
          final normalized = userCountry?.trim().toUpperCase() ?? '';
          return country.name.toUpperCase() == normalized ||
              country.isoCode.toUpperCase() == normalized;
        }).toList();
    setState(() {
      _isUserInNigeria = isNigeria;
      if (matchedCountry.isNotEmpty) {
        selectedCountry = matchedCountry.first;
      }
    });
    if (paymentType == "part") {
      _autoFillHalfPayment();
    }
  }

  void _autoFillHalfPayment() {
    // Calculate half of the total amount to pay
    final totalToPay =
        widget.review.isInternationalVendor
            ? widget.review.totalCostUSD
            : widget.review.totalCost;
    final halfAmount = totalToPay / 2;
    amountController.text = _formatAmount(halfAmount);
  }

  String _formatAmount(double value) {
    if (_isUserInNigeria) {
      return NumberFormat('#,###').format(value.round());
    }
    return NumberFormat('#,##0.##').format(value);
  }

  void _handleAmountChange(String value) {
    final cleaned = value.replaceAll(',', '');
    if (cleaned.isEmpty) return;
    final parsed =
        _isUserInNigeria
            ? double.tryParse(cleaned)?.roundToDouble()
            : double.tryParse(cleaned);
    if (parsed == null) return;
    final formatted = _formatAmount(parsed);
    if (formatted == value) return;
    amountController.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  void _clearDeliveryQuote() {
    _deliveryQuoteDebounce?.cancel();
    if (!mounted) return;
    setState(() {
      isCalculatingDelivery = false;
      _deliveryCostLabel = null;
      _confirmedDeliveryQuoteKey = null;
    });
  }

  bool _hasValidAddressSelection() {
    return selectedCountry != null &&
        addressLine1Controller.text.trim().isNotEmpty &&
        cityController.text.trim().isNotEmpty &&
        regionController.text.trim().isNotEmpty;
  }

  bool _hasValidPickupSelection() {
    return selectedPickupCountry != null &&
        selectedPickupState != null &&
        selectedPickupLocation != null;
  }

  String _buildAddressForQuote() {
    final selected = selectedCountry;
    if (selected == null) return '';

    final addressLine1 = addressLine1Controller.text.trim();
    final addressLine2 = addressLine2Controller.text.trim();
    final city = cityController.text.trim();
    final region = regionController.text.trim();
    final postalCode = postalCodeController.text.trim();

    return [
      addressLine1,
      if (addressLine2.isNotEmpty) addressLine2,
      city,
      region,
      if (postalCode.isNotEmpty) postalCode,
      selected.name,
    ].join(', ');
  }

  double? _extractDeliveryCost(Map<String, dynamic> payload) {
    final candidates = [
      payload['deliveryCost'],
      payload['cost'],
      payload['amount'],
      payload['fee'],
      payload['deliveryFee'],
      payload['data'] is Map<String, dynamic>
          ? (payload['data'] as Map<String, dynamic>)['deliveryCost']
          : null,
      payload['data'] is Map<String, dynamic>
          ? (payload['data'] as Map<String, dynamic>)['cost']
          : null,
      payload['data'] is Map<String, dynamic>
          ? (payload['data'] as Map<String, dynamic>)['amount']
          : null,
      payload['data'] is Map<String, dynamic>
          ? (payload['data'] as Map<String, dynamic>)['fee']
          : null,
      payload['data'] is Map<String, dynamic>
          ? (payload['data'] as Map<String, dynamic>)['deliveryFee']
          : null,
    ];

    for (final candidate in candidates) {
      if (candidate is num) return candidate.toDouble();
      if (candidate is String) {
        final parsed = double.tryParse(candidate);
        if (parsed != null) return parsed;
      }
    }
    return null;
  }

  void _scheduleDeliveryCostRefresh() {
    _deliveryQuoteDebounce?.cancel();

    final canQuote =
        deliveryMode == "pickup"
            ? _hasValidPickupSelection()
            : _hasValidAddressSelection();

    if (!canQuote) {
      _clearDeliveryQuote();
      return;
    }

    _deliveryQuoteDebounce = Timer(const Duration(milliseconds: 500), () {
      _refreshDeliveryCost();
    });
  }

  String _currentDeliveryQuoteKey() {
    if (deliveryMode == "pickup") {
      return [
        shipment,
        deliveryMode,
        selectedPickupCountry?.id ?? '',
        selectedPickupState?.id ?? '',
        selectedPickupLocation?.id ?? '',
      ].join('|');
    }

    return [
      shipment,
      deliveryMode,
      selectedCountry?.isoCode ?? '',
      addressLine1Controller.text.trim(),
      addressLine2Controller.text.trim(),
      cityController.text.trim(),
      regionController.text.trim(),
      postalCodeController.text.trim(),
    ].join('|');
  }

  Future<bool> _showDeliveryFeeSheet(String amountLabel) async {
    if (!mounted) return false;

    final result = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (sheetContext) => SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const CustomText(
                    "Delivery Fee",
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  const SizedBox(height: 8),
                  CustomText(
                    "Estimated delivery cost: $amountLabel",
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(sheetContext, false),
                          child: const Text("Close"),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomButton(
                          title: "Continue",
                          onPressed: () => Navigator.pop(sheetContext, true),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );

    return result == true;
  }

  Future<void> _refreshDeliveryCost() async {
    final canQuote =
        deliveryMode == "pickup"
            ? _hasValidPickupSelection()
            : _hasValidAddressSelection();
    if (!canQuote) {
      _clearDeliveryQuote();
      return;
    }

    if (mounted) {
      setState(() {
        isCalculatingDelivery = true;
      });
    }

    final response = await PaymentService.calculateDeliveryCost(
      reviewId: widget.review.id,
      shipmentMethod: shipment,
      address: deliveryMode == "address" ? _buildAddressForQuote() : null,
      pickupCountryId:
          deliveryMode == "pickup" ? selectedPickupCountry?.id : null,
      pickupStateId: deliveryMode == "pickup" ? selectedPickupState?.id : null,
      pickupLocationId:
          deliveryMode == "pickup" ? selectedPickupLocation?.id : null,
    );

    if (!mounted) return;

    final cost = response == null ? null : _extractDeliveryCost(response);

    setState(() {
      isCalculatingDelivery = false;
      _deliveryCostLabel =
          cost != null ? CurrencyHelper.formatAmount(cost) : null;
    });
  }

  Future<bool> _showDeliveryFeeBeforePaymentIfNeeded() async {
    final canQuote =
        deliveryMode == "pickup"
            ? _hasValidPickupSelection()
            : _hasValidAddressSelection();

    if (!canQuote) {
      return true;
    }

    final quoteKey = _currentDeliveryQuoteKey();
    if (_confirmedDeliveryQuoteKey == quoteKey && _deliveryCostLabel != null) {
      return true;
    }

    await _refreshDeliveryCost();
    if (!mounted) return false;

    if (_deliveryCostLabel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Unable to estimate delivery fee. Please try again."),
        ),
      );
      return false;
    }

    final shouldProceed = await _showDeliveryFeeSheet(_deliveryCostLabel!);
    if (!mounted || !shouldProceed) return false;

    setState(() {
      _confirmedDeliveryQuoteKey = quoteKey;
    });
    return true;
  }

  @override
  void dispose() {
    _deliveryQuoteDebounce?.cancel();
    amountController.dispose();
    addressLine1Controller.dispose();
    addressLine2Controller.dispose();
    cityController.dispose();
    regionController.dispose();
    postalCodeController.dispose();
    super.dispose();
  }

  Future<void> _makePayment() async {
    final shouldContinue = await _showDeliveryFeeBeforePaymentIfNeeded();
    if (!shouldContinue || !mounted) return;
    await _processPayment();
  }

  Future<void> _processPayment() async {
    setState(() => isLoading = true);

    try {
      print('');
      print('═══════════════════════════════════════════════════════════');
      print('🔥 PAYMENT PROCESSING STARTED');
      print('═══════════════════════════════════════════════════════════');

      final vendorCountry = widget.review.user.country?.toUpperCase() ?? '';
      final isInternationalVendor =
          vendorCountry == 'UNITED STATES' ||
          vendorCountry == 'US' ||
          vendorCountry == 'USA' ||
          vendorCountry == 'UNITED KINGDOM' ||
          vendorCountry == 'UK' ||
          vendorCountry == 'GB';

      print('📋 VENDOR INFO:');
      print('   Vendor Country: $vendorCountry');
      print('   Is International Vendor: $isInternationalVendor');
      print('   Vendor Name: ${widget.review.user.fullName}');
      print('');

      // Get user's country
      final userCountry = await CurrencyHelper.getUserCountry();
      final isUserInNigeria =
          userCountry?.toUpperCase() == 'NIGERIA' ||
          userCountry?.toUpperCase() == 'NG';

      print('👤 USER INFO:');
      print('   User Country: $userCountry');
      print('   Is User in Nigeria: $isUserInNigeria');
      print('   User Currency Symbol: $currencySymbol');
      print('');

      print('📦 REVIEW/ORDER INFO:');
      print('   Review ID: ${widget.review.id}');
      print('   Total Cost (stored): ${widget.review.totalCost}');
      print('   Amount Paid (stored): ${widget.review.amountPaid}');
      print('   Amount To Pay (stored): ${widget.review.amountToPay}');
      print(
        '   Remaining Balance: ${widget.review.totalCost - widget.review.amountPaid}',
      );
      print('');

      print('💳 PAYMENT DETAILS:');
      print('   Payment Type: $paymentType');
      print('   Shipment Method: $shipment');
      print('   Delivery Mode: $deliveryMode');
      print('');

      String addressToSend = '';
      String? pickupCountryId;
      String? pickupStateId;
      String? pickupLocationId;

      if (deliveryMode == "pickup") {
        final pickupCountry = selectedPickupCountry;
        final pickupState = selectedPickupState;
        final pickupLocation = selectedPickupLocation;

        if (pickupCountry == null ||
            pickupState == null ||
            pickupLocation == null) {
          setState(() {
            isLoading = false;
            showPickupCountryError = pickupCountry == null;
            showPickupStateError = pickupState == null;
            showPickupLocationError = pickupLocation == null;
          });
          print('❌ ERROR: Pickup fields are incomplete');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "Please select pickup country, state, and location",
              ),
            ),
          );
          return;
        }

        pickupCountryId = pickupCountry.id;
        pickupStateId = pickupState.id;
        pickupLocationId = pickupLocation.id;
        addressToSend = pickupLocation.address;

        // If duplicate states were merged in UI, resolve the actual state ID by location.
        for (final state in pickupCountry.states) {
          final hasLocation = state.locations.any(
            (l) => l.id == pickupLocation.id,
          );
          if (hasLocation) {
            pickupStateId = state.id;
            break;
          }
        }

        if (showPickupCountryError ||
            showPickupStateError ||
            showPickupLocationError) {
          setState(() {
            showPickupCountryError = false;
            showPickupStateError = false;
            showPickupLocationError = false;
          });
        }
      } else {
        final selected = selectedCountry;
        final addressLine1 = addressLine1Controller.text.trim();
        final addressLine2 = addressLine2Controller.text.trim();
        final city = cityController.text.trim();
        final region = regionController.text.trim();
        final postalCode = postalCodeController.text.trim();

        addressToSend =
            selected == null
                ? ''
                : [
                  addressLine1,
                  if (addressLine2.isNotEmpty) addressLine2,
                  city,
                  region,
                  if (postalCode.isNotEmpty) postalCode,
                  selected.name,
                ].join(', ');

        if (selected == null ||
            addressLine1.isEmpty ||
            city.isEmpty ||
            region.isEmpty) {
          setState(() {
            isLoading = false;
            showCountryError = selected == null;
            showAddressLine1Error = addressLine1.isEmpty;
            showCityError = city.isEmpty;
            showRegionError = region.isEmpty;
          });
          print('❌ ERROR: Delivery address fields are incomplete');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "Please complete country, address line 1, city and state/region",
              ),
            ),
          );
          return;
        }
        if (showCountryError ||
            showAddressLine1Error ||
            showCityError ||
            showRegionError) {
          setState(() {
            showCountryError = false;
            showAddressLine1Error = false;
            showCityError = false;
            showRegionError = false;
          });
        }
      }

      // ✅ FOR INTERNATIONAL VENDORS - Use Stripe
      if (isInternationalVendor) {
        print('🌍 INTERNATIONAL VENDOR DETECTED - Using Stripe');
        print('');

        String? amountToSend;

        // Determine vendor's target currency
        final targetCurrency =
            vendorCountry.contains('UNITED STATES') ||
                    vendorCountry == 'US' ||
                    vendorCountry == 'USA'
                ? 'USD'
                : 'GBP';

        print('💱 TARGET CURRENCY: $targetCurrency');
        print('');

        if (paymentType == "part") {
          print('📝 PART PAYMENT PROCESSING:');

          if (amountController.text.trim().isEmpty) {
            setState(() => isLoading = false);
            print('❌ ERROR: Amount field is empty');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Please enter an amount")),
            );
            return;
          }

          // ✅ NEW: User enters in THEIR currency, but BACKEND expects NGN
          final userEnteredAmount = double.parse(
            amountController.text.replaceAll(",", ""),
          );
          print('   User Entered Amount: $userEnteredAmount');
          print(
            '   User Currency: ${isUserInNigeria ? "NGN" : targetCurrency}',
          );
          print('');

          if (isUserInNigeria) {
            // ✅ Nigerian user entering NGN - send as-is, backend handles conversion
            amountToSend = userEnteredAmount.round().toString();
            print('✅ NO CONVERSION NEEDED - Backend will convert');
            print('   User entered: ₦$userEnteredAmount');
            print('   Sending to backend: $amountToSend NGN');
            print('   Backend will convert: NGN → USD for Stripe');
          } else {
            // ✅ International user entering USD/GBP - convert to NGN first
            print('🔄 CONVERSION NEEDED: $targetCurrency → NGN');
            print('   Amount to Convert: \$$userEnteredAmount');
            print('');

            final ngnAmount = await CurrencyHelper.convertToNGN(
              userEnteredAmount,
            );
            amountToSend = ngnAmount.toString();

            print('✅ CONVERSION SUCCESS');
            print('   From: \$$userEnteredAmount');
            print('   To: ₦$ngnAmount');
            print('   Sending to backend: $amountToSend NGN');
            print('   Backend will convert: NGN → USD for Stripe');
          }
          print('');
        } else {
          // ✅ Full payment - backend uses review.amountToPay, NO amount needed
          print('💰 FULL PAYMENT PROCESSING:');

          print('   Total Cost (stored): ${widget.review.totalCost}');
          print('   Amount Paid (stored): ${widget.review.amountPaid}');
          print('   Amount To Pay (stored): ${widget.review.amountToPay}');
          print('');

          if (widget.review.amountToPay <= 0) {
            setState(() => isLoading = false);
            print('❌ ERROR: No balance remaining');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("No balance left to pay")),
            );
            return;
          }

          // ✅ For full payment, send NULL - backend uses review.amountToPay
          amountToSend = null;

          print('✅ FULL PAYMENT - No amount sent');
          print('   Backend will use: review.amountToPay from database');
          print('   Delivery Address: $addressToSend');
          print('');
        }

        // Create Stripe checkout
        print('───────────────────────────────────────────────────────────');
        print('📤 SENDING TO STRIPE CHECKOUT:');
        print('   Review ID: ${widget.review.id}');
        print('   Shipment Method: $shipment');
        print('   Amount: $targetCurrency $amountToSend');
        print('   Address: $addressToSend');
        print('───────────────────────────────────────────────────────────');
        print('');

        final resp = await BankApiService.stripeCheckoutPayment(
          reviewId: widget.review.id,
          shipmentMethod: shipment,
          paymentStatus:
              paymentType == "part" ? "part payment" : "full payment",
          amount: amountToSend,
          address: addressToSend,
          pickupCountryId: pickupCountryId,
          pickupStateId: pickupStateId,
          pickupLocationId: pickupLocationId,
        );

        print('📥 STRIPE RESPONSE:');
        print('   Success: ${resp["success"]}');
        if (resp["success"] == true) {
          print('   Checkout URL: ${resp["checkoutUrl"]}');
        } else {
          print('   Error: ${resp["error"]}');
        }
        print('');

        setState(() => isLoading = false);

        if (resp["success"] == true) {
          final url = resp["checkoutUrl"];
          if (url != null) {
            print('✅ PAYMENT INITIATED SUCCESSFULLY');
            print(
              '═══════════════════════════════════════════════════════════',
            );
            print('');
            Navigator.of(context).pop();
            widget.onCheckout(url);
          }
        } else {
          print('❌ PAYMENT FAILED');
          print('═══════════════════════════════════════════════════════════');
          print('');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(resp["error"] ?? "Stripe checkout failed")),
          );
        }
        return;
      }

      // ✅ FOR NIGERIAN VENDORS - Use Paystack
      print('🇳🇬 NIGERIAN VENDOR DETECTED - Using Paystack');
      print('');

      String amountToSend;

      if (paymentType == "part") {
        print('📝 PART PAYMENT PROCESSING:');

        if (amountController.text.trim().isEmpty) {
          setState(() => isLoading = false);
          print('❌ ERROR: Amount field is empty');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Please enter an amount")),
          );
          return;
        }

        // User enters in THEIR currency
        final userEnteredAmount = double.parse(
          amountController.text.replaceAll(",", ""),
        );
        print('   User Entered Amount: $userEnteredAmount');
        print('   User Currency: ${isUserInNigeria ? "NGN" : "USD/GBP"}');
        print('');

        if (isUserInNigeria) {
          // Nigerian user entering NGN - send as-is (vendor expects NGN)
          amountToSend = userEnteredAmount.toString();
          print('✅ NO CONVERSION NEEDED');
          print('   Both user and vendor are in Nigeria');
          print('   Amount to Send to Paystack: NGN $amountToSend');
        } else {
          // International user entering USD/GBP - convert to NGN
          print('🔄 CONVERSION NEEDED: USD/GBP → NGN');
          print('   Amount to Convert: $userEnteredAmount');
          print('');

          print('📞 Calling CurrencyHelper.convertToNGN...');
          final ngnAmount = await CurrencyHelper.convertToNGN(
            userEnteredAmount,
          );
          amountToSend = ngnAmount.toString();

          print('✅ CONVERSION SUCCESS');
          print('   From: \$$userEnteredAmount');
          print('   To: ₦$ngnAmount');
          print('   Amount to Send to Paystack: NGN $amountToSend');
        }
        print('');
      } else {
        // Full payment
        print('💰 FULL PAYMENT PROCESSING:');

        // Amounts are stored in NGN (vendor currency)
        final remainingNGN = widget.review.totalCost - widget.review.amountPaid;

        print('   Total Cost (stored): ${widget.review.totalCost}');
        print('   Amount Paid (stored): ${widget.review.amountPaid}');
        print('   Remaining Balance: $remainingNGN');
        print('   Storage Currency: NGN (vendor currency)');
        print('');

        if (remainingNGN <= 0) {
          setState(() => isLoading = false);
          print('❌ ERROR: No balance remaining');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("No balance left to pay")),
          );
          return;
        }

        // Send remaining balance in NGN
        amountToSend = remainingNGN.toString();
        print('✅ FULL PAYMENT AMOUNT');
        print('   Amount to Send to Paystack: NGN $amountToSend');
        print('');
      }

      print('───────────────────────────────────────────────────────────');
      print('📤 SENDING TO PAYSTACK:');
      print('   Review ID: ${widget.review.id}');
      print('   Shipment Method: $shipment');
      print('   Amount: NGN $amountToSend');
      print('───────────────────────────────────────────────────────────');
      print('');

      final resp =
          paymentType == "part"
              ? await PaymentService.createPartPayment(
                reviewId: widget.review.id,
                amount: amountToSend,
                shipmentMethod: shipment,
                address: addressToSend,
                pickupCountryId: pickupCountryId,
                pickupStateId: pickupStateId,
                pickupLocationId: pickupLocationId,
              )
              : await PaymentService.createFullPayment(
                reviewId: widget.review.id,
                amount: amountToSend,
                shipmentMethod: shipment,
                address: addressToSend,
                pickupCountryId: pickupCountryId,
                pickupStateId: pickupStateId,
                pickupLocationId: pickupLocationId,
              );

      print('📥 PAYSTACK RESPONSE:');
      print('   Success: ${resp?["success"]}');
      if (resp?["success"] == true) {
        print('   Authorization URL: ${resp?["authorizationUrl"]}');
      }
      print('');

      setState(() => isLoading = false);

      if (resp != null && resp["success"]) {
        final url = resp["authorizationUrl"];
        if (url != null) {
          print('✅ PAYMENT INITIATED SUCCESSFULLY');
          print('═══════════════════════════════════════════════════════════');
          print('');
          Navigator.of(context).pop();
          widget.onCheckout(url);
        }
      } else {
        print('❌ PAYMENT FAILED');
        print('═══════════════════════════════════════════════════════════');
        print('');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Payment failed")));
      }
    } catch (e, stackTrace) {
      setState(() => isLoading = false);
      print('');
      print('═══════════════════════════════════════════════════════════');
      print('❌ PAYMENT ERROR');
      print('═══════════════════════════════════════════════════════════');
      print('Error: $e');
      print('Stack Trace:');
      print(stackTrace);
      print('═══════════════════════════════════════════════════════════');
      print('');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final vendorCountry = widget.review.user.country?.toUpperCase() ?? '';
    final isInternationalVendor =
        vendorCountry == 'UNITED STATES' ||
        vendorCountry == 'US' ||
        vendorCountry == 'USA' ||
        vendorCountry == 'UNITED KINGDOM' ||
        vendorCountry == 'UK' ||
        vendorCountry == 'GB';

    return Stack(
      children: [
        Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 36,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CustomText(
                  "Choose a Payment Option",
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                const SizedBox(height: 12),

                if (isInternationalVendor)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.payment,
                          color: Colors.blue.shade700,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: CustomText(
                            "International vendor - Payment via Stripe",
                            fontSize: 12,
                            color: Colors.blue.shade900,
                          ),
                        ),
                      ],
                    ),
                  ),

                if (isInternationalVendor) const SizedBox(height: 12),

                if (widget.allowPaymentTypeSwitch)
                  Row(
                    children: [
                      Radio(
                        value: "full",
                        groupValue: paymentType,
                        onChanged:
                            (val) =>
                                setState(() => paymentType = val as String),
                      ),
                      const Text("Full Payment"),
                      Radio(
                        value: "part",
                        groupValue: paymentType,
                        onChanged: (val) {
                          setState(() {
                            paymentType = val as String;
                            _autoFillHalfPayment();
                          });
                        },
                      ),
                      const Text("Part Payment"),
                    ],
                  ),

                if (paymentType == "part") ...[
                  CustomTextField(
                    title: _isUserInNigeria ? "Amount (NGN)" : "Amount (USD)",
                    fieldKey: "amount",
                    hintText:
                        _isUserInNigeria
                            ? "Enter amount e.g., 23,000"
                            : "Enter amount e.g., 120.50",
                    controller: amountController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        _isUserInNigeria
                            ? RegExp(r'^[0-9,]*$')
                            : RegExp(r'^[0-9,]*\.?\d{0,2}$'),
                      ),
                    ],
                    onChanged: _handleAmountChange,
                  ),
                  const SizedBox(height: 8),
                ],

                const SizedBox(height: 12),

                Align(
                  alignment: Alignment.centerLeft,
                  child: const CustomText("Shipment Method", fontSize: 16),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonFormField<String>(
                    value: shipment,
                    decoration: const InputDecoration(border: InputBorder.none),
                    items: const [
                      DropdownMenuItem(
                        value: "Regular",
                        child: Text("Regular (1–8 days)"),
                      ),
                      DropdownMenuItem(
                        value: "Express",
                        child: Text("Express (1–4 days)"),
                      ),
                      DropdownMenuItem(
                        value: "Cargo",
                        child: Text("Cargo (1–15 days)"),
                      ),
                    ],
                    onChanged: (val) {
                      setState(() => shipment = val!);
                      _scheduleDeliveryCostRefresh();
                    },
                  ),
                ),

                const SizedBox(height: 15),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CustomText("Delivery Option", fontSize: 16),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<String>(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            title: const Text("Address"),
                            value: "address",
                            groupValue: deliveryMode,
                            onChanged: (val) {
                              if (val == null) return;
                              setState(() => deliveryMode = val);
                              _scheduleDeliveryCostRefresh();
                            },
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            title: const Text("Pickup Location"),
                            value: "pickup",
                            groupValue: deliveryMode,
                            onChanged: (val) {
                              if (val == null) return;
                              setState(() => deliveryMode = val);
                              _scheduleDeliveryCostRefresh();
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (deliveryMode == "address") ...[
                      Align(
                        alignment: Alignment.centerLeft,
                        child: const CustomText(
                          "Delivery Address",
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color:
                                showCountryError
                                    ? Colors.redAccent
                                    : Colors.grey.shade300,
                          ),
                        ),
                        child: DropdownButtonFormField<CountryOption>(
                          value: selectedCountry,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: "Select country",
                          ),
                          items:
                              allCountries.map((country) {
                                return DropdownMenuItem<CountryOption>(
                                  value: country,
                                  child: Text(
                                    '${country.flagEmoji} ${country.name}',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedCountry = value;
                              if (showCountryError && value != null) {
                                showCountryError = false;
                              }
                            });
                            _scheduleDeliveryCostRefresh();
                          },
                        ),
                      ),
                      if (showCountryError)
                        const Padding(
                          padding: EdgeInsets.only(top: 6, left: 4),
                          child: CustomText(
                            "Country is required",
                            fontSize: 11,
                            color: Colors.redAccent,
                          ),
                        ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: addressLine1Controller,
                        decoration: InputDecoration(
                          hintText:
                              "Address line 1 (Street, House/Building No.)",
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          errorText:
                              showAddressLine1Error
                                  ? "Address line 1 is required"
                                  : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Colors.redAccent,
                            ),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Colors.redAccent,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 14,
                          ),
                        ),
                        onChanged: (value) {
                          if (showAddressLine1Error &&
                              value.trim().isNotEmpty) {
                            setState(() => showAddressLine1Error = false);
                          }
                          _scheduleDeliveryCostRefresh();
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: addressLine2Controller,
                        decoration: InputDecoration(
                          hintText:
                              "Address line 2 (Apartment, Suite, Landmark) - Optional",
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 14,
                          ),
                        ),
                        onChanged: (_) => _scheduleDeliveryCostRefresh(),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: cityController,
                        decoration: InputDecoration(
                          hintText: "City / Town",
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          errorText: showCityError ? "City is required" : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Colors.redAccent,
                            ),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Colors.redAccent,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 14,
                          ),
                        ),
                        onChanged: (value) {
                          if (showCityError && value.trim().isNotEmpty) {
                            setState(() => showCityError = false);
                          }
                          _scheduleDeliveryCostRefresh();
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: regionController,
                        decoration: InputDecoration(
                          hintText: "State / Province / Region",
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          errorText:
                              showRegionError
                                  ? "State / Province / Region is required"
                                  : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Colors.redAccent,
                            ),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Colors.redAccent,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 14,
                          ),
                        ),
                        onChanged: (value) {
                          if (showRegionError && value.trim().isNotEmpty) {
                            setState(() => showRegionError = false);
                          }
                          _scheduleDeliveryCostRefresh();
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: postalCodeController,
                        decoration: InputDecoration(
                          hintText: "Postal / ZIP code (Optional)",
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 14,
                          ),
                        ),
                        onChanged: (_) => _scheduleDeliveryCostRefresh(),
                      ),
                    ] else ...[
                      const CustomText("Pickup Location", fontSize: 16),
                      const SizedBox(height: 8),
                      if (isLoadingPickupHierarchy)
                        const Center(child: CircularProgressIndicator())
                      else if (pickupCountries.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.orange.shade200),
                          ),
                          child: const CustomText(
                            "No pickup locations configured by admin yet.",
                            fontSize: 12,
                            color: Colors.black87,
                          ),
                        )
                      else ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color:
                                  showPickupCountryError
                                      ? Colors.redAccent
                                      : Colors.grey.shade300,
                            ),
                          ),
                          child: DropdownButtonFormField<PickupCountryOption>(
                            value: selectedPickupCountry,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: "Select pickup country",
                            ),
                            items:
                                pickupCountries.map((country) {
                                  return DropdownMenuItem<PickupCountryOption>(
                                    value: country,
                                    child: Text(country.name),
                                  );
                                }).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedPickupCountry = value;
                                selectedPickupState = null;
                                selectedPickupLocation = null;
                                if (showPickupCountryError && value != null) {
                                  showPickupCountryError = false;
                                }
                              });
                              _scheduleDeliveryCostRefresh();
                            },
                          ),
                        ),
                        if (showPickupCountryError)
                          const Padding(
                            padding: EdgeInsets.only(top: 6, left: 4),
                            child: CustomText(
                              "Pickup country is required",
                              fontSize: 11,
                              color: Colors.redAccent,
                            ),
                          ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color:
                                  showPickupStateError
                                      ? Colors.redAccent
                                      : Colors.grey.shade300,
                            ),
                          ),
                          child: DropdownButtonFormField<PickupStateOption>(
                            value: selectedPickupState,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: "Select pickup state",
                            ),
                            items:
                                _getMergedPickupStates(
                                  selectedPickupCountry,
                                ).map((state) {
                                  return DropdownMenuItem<PickupStateOption>(
                                    value: state,
                                    child: Text(state.name),
                                  );
                                }).toList(),
                            onChanged:
                                selectedPickupCountry == null
                                    ? null
                                    : (value) {
                                      setState(() {
                                        selectedPickupState = value;
                                        selectedPickupLocation = null;
                                        if (showPickupStateError &&
                                            value != null) {
                                          showPickupStateError = false;
                                        }
                                      });
                                      _scheduleDeliveryCostRefresh();
                                    },
                          ),
                        ),
                        if (showPickupStateError)
                          const Padding(
                            padding: EdgeInsets.only(top: 6, left: 4),
                            child: CustomText(
                              "Pickup state is required",
                              fontSize: 11,
                              color: Colors.redAccent,
                            ),
                          ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color:
                                  showPickupLocationError
                                      ? Colors.redAccent
                                      : Colors.grey.shade300,
                            ),
                          ),
                          child: DropdownButtonFormField<PickupLocationOption>(
                            value: selectedPickupLocation,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: "Select pickup address",
                            ),
                            items:
                                (selectedPickupState?.locations ?? const [])
                                    .where((location) => location.isActive)
                                    .map((location) {
                                      final displayText =
                                          location.address.trim().isNotEmpty
                                              ? location.address
                                              : location.name;
                                      return DropdownMenuItem<
                                        PickupLocationOption
                                      >(
                                        value: location,
                                        child: Text(
                                          displayText,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      );
                                    })
                                    .toList(),
                            onChanged:
                                selectedPickupState == null
                                    ? null
                                    : (value) {
                                      setState(() {
                                        selectedPickupLocation = value;
                                        if (showPickupLocationError &&
                                            value != null) {
                                          showPickupLocationError = false;
                                        }
                                      });
                                      _scheduleDeliveryCostRefresh();
                                    },
                          ),
                        ),
                        if (showPickupLocationError)
                          const Padding(
                            padding: EdgeInsets.only(top: 6, left: 4),
                            child: CustomText(
                              "Pickup location is required",
                              fontSize: 11,
                              color: Colors.redAccent,
                            ),
                          ),
                        if (selectedPickupLocation != null) ...[
                          const SizedBox(height: 8),
                          CustomText(
                            selectedPickupLocation!.address,
                            fontSize: 11,
                            color: Colors.black54,
                          ),
                        ],
                      ],
                    ],
                    const SizedBox(height: 6),
                    CustomText(
                      deliveryMode == "pickup"
                          ? "Select admin-configured pickup destination."
                          : "Use your full home address. Country, address lines, city, state/region and postal code are sent for delivery.",
                      fontSize: 11,
                      color: Colors.black54,
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                const SizedBox(height: 12),
                CustomButton(title: "Make Payment", onPressed: _makePayment),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),

        if (isLoading)
          Container(
            color: Colors.black26,
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }
}
