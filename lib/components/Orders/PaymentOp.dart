import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hog/App/Banks/Api/BamkService.dart';
import 'package:hog/App/Home/Api/paymentService.dart';
import 'package:hog/App/Home/Model/carrierRateModel.dart';
import 'package:hog/App/Home/Model/reviewModel.dart';
import 'package:hog/components/button.dart';
import 'package:hog/components/formfields.dart';
import 'package:hog/components/texts.dart';
import 'package:hog/constants/currency.dart';
import 'package:hog/constants/currencyHelper.dart';
import 'package:hog/theme/app_theme.dart';
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
  // Sent to both the carrier-rates preview and the payment-creation
  // endpoints so the quote shown to the buyer matches what actually gets
  // charged. Matches PaymentService._defaultPackages' weight.
  static const double _shipmentWeightKg = 1.5;

  String paymentType = "part";
  String shipment = "Regular";
  String deliveryMode = "address";

  final TextEditingController amountController = TextEditingController();
  // Collected as separate fields for a clean input experience, then joined
  // into the single `address` string the payment endpoints actually take.
  // That string only labels the shipment for dispatch — Fez prices delivery
  // off the country/state already saved on the buyer's account, not these.
  final TextEditingController countryController = TextEditingController();
  final TextEditingController addressLine1Controller = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController regionController = TextEditingController();
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

  // The quote key we last actually fetched (successfully or not), separate
  // from _confirmedDeliveryQuoteKey (which only gets set once the buyer
  // explicitly accepts the fee sheet). Lets _refreshDeliveryCost short-
  // circuit when it's asked to re-fetch a quote it just fetched — e.g. the
  // debounced field-edit trigger and the "Proceed to Payment" confirmation
  // check both firing back-to-back for the same address.
  String? _lastFetchedDeliveryQuoteKey;
  bool _isFetchingDeliveryQuote = false;

  List<CarrierRate> _carrierRates = [];
  CarrierRate? _selectedCarrierRate;
  String? _carrierErrorReason;
  bool _isLoadingCarrierRates = false;

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
    setState(() {
      _isUserInNigeria = isNigeria;
      if (countryController.text.trim().isEmpty &&
          userCountry != null &&
          userCountry.trim().isNotEmpty) {
        countryController.text = userCountry;
      }
    });
    if (paymentType == "part") {
      _autoFillHalfPayment();
    }
  }

  void _autoFillHalfPayment() {
    // Gateway (and therefore currency) is resolved from the BUYER's
    // country: Nigerian buyers pay NGN via Paystack, everyone else pays USD
    // via Stripe — regardless of which country the designer is in. Use the
    // accepted offer total when available so the deposit matches the amount
    // shown on the quotation card.
    final totalToPay =
        _isUserInNigeria
            ? widget.review.userPayableTotal ?? widget.review.totalCost
            : widget.review.totalCostUSD;
    final halfAmount = totalToPay / 2;
    amountController.text = _formatAmount(halfAmount);
  }

  String _formatAmount(double value) {
    return NumberFormat('#,##0.##').format(value);
  }

  void _handleAmountChange(String value) {
    final cleaned = value.replaceAll(',', '');
    if (cleaned.isEmpty) return;
    final parsed = double.tryParse(cleaned);
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
      _lastFetchedDeliveryQuoteKey = null;
      _carrierRates = [];
      _selectedCarrierRate = null;
      _carrierErrorReason = null;
    });
  }

  bool _hasValidAddressSelection() {
    return countryController.text.trim().isNotEmpty &&
        addressLine1Controller.text.trim().isNotEmpty &&
        cityController.text.trim().isNotEmpty &&
        regionController.text.trim().isNotEmpty;
  }

  bool _hasValidPickupSelection() {
    return selectedPickupCountry != null &&
        selectedPickupState != null &&
        selectedPickupLocation != null;
  }

  // Collected as separate fields for a clean input experience, then joined
  // into the single free-text `address` string the payment endpoints take
  // (e.g. "12 Aba Road, Port Harcourt, Rivers State, Nigeria"). That string
  // only labels the shipment for dispatch — it does not price delivery.
  String _buildAddressForQuote() {
    final street = addressLine1Controller.text.trim();
    final city = cityController.text.trim();
    final region = regionController.text.trim();
    final country = countryController.text.trim();

    return [
      street,
      city,
      region,
      country,
    ].where((part) => part.isNotEmpty).join(', ');
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

  String? _extractDeliveryCurrency(Map<String, dynamic> payload) {
    final candidate =
        payload['currency'] ??
        (payload['data'] is Map<String, dynamic>
            ? (payload['data'] as Map<String, dynamic>)['currency']
            : null);
    final value = candidate?.toString().trim();
    return (value == null || value.isEmpty) ? null : value;
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
      countryController.text.trim(),
      addressLine1Controller.text.trim(),
      cityController.text.trim(),
      regionController.text.trim(),
      _selectedCarrierRate?.serviceType ?? '',
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

    final quoteKey = _currentDeliveryQuoteKey();

    // Already fetching, or already have a fresh quote for this exact
    // address/shipment/carrier combination — skip the redundant network
    // round-trip. This is what stops the debounced field-edit refresh and
    // the "Proceed to Payment" confirmation check from both hitting the
    // carrier-rates/delivery-cost endpoints back-to-back for the same quote.
    if (_isFetchingDeliveryQuote) return;
    if (quoteKey == _lastFetchedDeliveryQuoteKey && _deliveryCostLabel != null) {
      return;
    }

    // Fez Delivery handles every route where at least one party is in
    // Nigeria (domestic, export, or import — it auto-detects which from the
    // vendor/buyer country fields), so it's used for every address-mode
    // order. The distance-based estimate is reserved for pickup-point
    // orders only, which don't involve a carrier at all. If Fez can't quote
    // a route (unsupported country, missing buyer state, etc.), checkout is
    // blocked with the reason instead of silently substituting an estimate.
    final usesCarrierRates = deliveryMode == "address";

    _isFetchingDeliveryQuote = true;
    if (mounted) {
      setState(() {
        isCalculatingDelivery = true;
        _isLoadingCarrierRates = usesCarrierRates;
      });
    }

    try {
      if (usesCarrierRates) {
        final carrierResult = await PaymentService.getCarrierRates(
          reviewId: widget.review.id,
        );
        if (!mounted) return;

        if (carrierResult.hasRates) {
          final previousServiceType = _selectedCarrierRate?.serviceType;
          final chosen = carrierResult.rates.firstWhere(
            (r) => r.serviceType == previousServiceType,
            orElse: () => carrierResult.rates.first,
          );

          setState(() {
            isCalculatingDelivery = false;
            _isLoadingCarrierRates = false;
            _carrierRates = carrierResult.rates;
            _carrierErrorReason = null;
            _selectedCarrierRate = chosen;
            _deliveryCostLabel = CurrencyHelper.formatAmount(
              chosen.amount,
              currencyCode: chosen.currency,
            );
          });
          _lastFetchedDeliveryQuoteKey = quoteKey;
          return;
        }

        // Fez couldn't quote this route (unsupported country, missing
        // buyer state, both parties foreign, etc.) — block checkout with
        // the reason instead of silently substituting a non-carrier estimate.
        setState(() {
          isCalculatingDelivery = false;
          _isLoadingCarrierRates = false;
          _carrierRates = [];
          _selectedCarrierRate = null;
          _carrierErrorReason = carrierResult.displayError;
          _deliveryCostLabel = null;
        });
        _lastFetchedDeliveryQuoteKey = quoteKey;
        return;
      }

      // Pickup-point order — no carrier involved, use the distance-based
      // estimate directly.
      setState(() {
        _carrierRates = [];
        _selectedCarrierRate = null;
        _carrierErrorReason = null;
      });

      final response = await PaymentService.calculateDeliveryCost(
        reviewId: widget.review.id,
        shipmentMethod: shipment,
        address: deliveryMode == "address" ? _buildAddressForQuote() : null,
        pickupCountryId:
            deliveryMode == "pickup" ? selectedPickupCountry?.id : null,
        pickupStateId:
            deliveryMode == "pickup" ? selectedPickupState?.id : null,
        pickupLocationId:
            deliveryMode == "pickup" ? selectedPickupLocation?.id : null,
      );

      if (!mounted) return;

      final cost = response == null ? null : _extractDeliveryCost(response);
      final currency =
          response == null ? null : _extractDeliveryCurrency(response);

      setState(() {
        isCalculatingDelivery = false;
        _deliveryCostLabel =
            cost != null
                ? CurrencyHelper.formatAmount(cost, currencyCode: currency)
                : null;
      });
      _lastFetchedDeliveryQuoteKey = quoteKey;
    } finally {
      _isFetchingDeliveryQuote = false;
    }
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
    countryController.dispose();
    addressLine1Controller.dispose();
    cityController.dispose();
    regionController.dispose();
    super.dispose();
  }

  bool _validatePaymentForm() {
    FocusScope.of(context).unfocus();

    if (deliveryMode == "pickup") {
      final pickupCountry = selectedPickupCountry;
      final pickupState = selectedPickupState;
      final pickupLocation = selectedPickupLocation;
      final hasValidPickup =
          pickupCountry != null &&
          pickupState != null &&
          pickupLocation != null;

      setState(() {
        showPickupCountryError = pickupCountry == null;
        showPickupStateError = pickupState == null;
        showPickupLocationError = pickupLocation == null;
      });

      if (!hasValidPickup) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(
            const SnackBar(
              content: Text(
                "Please choose your pickup country, state, and pickup point.",
              ),
            ),
          );
        return false;
      }

      return true;
    }

    final hasValidAddress = _hasValidAddressSelection();

    setState(() {
      showCountryError = countryController.text.trim().isEmpty;
      showAddressLine1Error = addressLine1Controller.text.trim().isEmpty;
      showCityError = cityController.text.trim().isEmpty;
      showRegionError = regionController.text.trim().isEmpty;
    });

    if (!hasValidAddress) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          const SnackBar(
            content: Text(
              "Please complete your country, street address, city, and state/region.",
            ),
          ),
        );
      return false;
    }

    return true;
  }

  Future<void> _makePayment() async {
    if (!_validatePaymentForm()) return;

    final shouldContinue = await _showDeliveryFeeBeforePaymentIfNeeded();
    if (!shouldContinue || !mounted) return;
    await _processPayment();
  }

  /// The backend recomputes the delivery fee itself (in the correct payment
  /// currency, converting from whatever currency Fez quoted it in) and
  /// returns the real total in `breakdown.total`/`breakdown.currency` on a
  /// successful payment-creation response. Used only to tell the buyer what
  /// they're actually about to be charged — never to compute a request
  /// payload, since the app never does currency conversion itself.
  String? _formatBackendBreakdownTotal(dynamic breakdown) {
    if (breakdown is! Map) return null;
    final rawTotal = breakdown['total'];
    final total =
        rawTotal is num ? rawTotal.toDouble() : double.tryParse('$rawTotal');
    if (total == null) return null;
    return CurrencyHelper.formatAmount(
      total,
      currencyCode: breakdown['currency']?.toString(),
    );
  }

  Future<void> _processPayment() async {
    setState(() => isLoading = true);

    try {
      print('');
      print('═══════════════════════════════════════════════════════════');
      print('🔥 PAYMENT PROCESSING STARTED');
      print('═══════════════════════════════════════════════════════════');

      // Gateway is resolved from the BUYER's country, not the vendor's:
      // Nigeria buyers pay via Paystack/NGN, every other buyer pays via
      // Stripe/USD. Do not key this off the vendor/designer's country.
      final userCountry = await CurrencyHelper.getUserCountry();
      final isUserInNigeria =
          userCountry?.toUpperCase() == 'NIGERIA' ||
          userCountry?.toUpperCase() == 'NG';
      final useStripe = !isUserInNigeria;

      print('👤 BUYER INFO:');
      print('   Buyer Country: $userCountry');
      print('   Is Buyer in Nigeria: $isUserInNigeria');
      print('   Gateway: ${useStripe ? "Stripe (USD)" : "Paystack (NGN)"}');
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
        addressToSend = _buildAddressForQuote();

        if (!_hasValidAddressSelection()) {
          setState(() {
            isLoading = false;
            showCountryError = countryController.text.trim().isEmpty;
            showAddressLine1Error = addressLine1Controller.text.trim().isEmpty;
            showCityError = cityController.text.trim().isEmpty;
            showRegionError = regionController.text.trim().isEmpty;
          });
          print('❌ ERROR: Delivery address fields are incomplete');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "Please complete country, street address, city and state/region",
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

      // Buyer is outside Nigeria — use Stripe. Per the new contract, Stripe
      // always charges in USD regardless of which non-Nigerian country the
      // buyer is in (no GBP branch), and `amount` must be the total the
      // buyer is paying now, including delivery — sent for both full and
      // installment payments.
      if (useStripe) {
        print('🌍 BUYER OUTSIDE NIGERIA - Using Stripe (USD)');
        print('');

        String amountToSend;

        if (paymentType == "part") {
          print('📝 INSTALLMENT PROCESSING:');

          if (amountController.text.trim().isEmpty) {
            setState(() => isLoading = false);
            print('❌ ERROR: Amount field is empty');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Please enter an amount")),
            );
            return;
          }

          // Buyer is not in Nigeria, so the amount field is already labelled
          // and entered in USD — send as-is, no conversion needed.
          final userEnteredAmount = double.parse(
            amountController.text.replaceAll(",", ""),
          );
          amountToSend = userEnteredAmount.toString();
          print('   User Entered Amount: USD $userEnteredAmount');
        } else {
          print('💰 FULL PAYMENT PROCESSING:');

          final remainingUSD =
              widget.review.amountToPayUSD > 0
                  ? widget.review.amountToPayUSD
                  : (widget.review.totalCostUSD - widget.review.amountPaidUSD);

          print('   Total Cost USD (stored): ${widget.review.totalCostUSD}');
          print(
            '   Amount Paid USD (stored): ${widget.review.amountPaidUSD}',
          );
          print('   Remaining Balance USD: $remainingUSD');
          print('');

          if (remainingUSD <= 0) {
            setState(() => isLoading = false);
            print('❌ ERROR: No balance remaining');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("No balance left to pay")),
            );
            return;
          }

          // Do NOT add the delivery fee here — the currencies can genuinely
          // differ (e.g. a Fez export quote comes back in NGN even though
          // this buyer pays in USD via Stripe) and the app has no business
          // converting between them. The backend already re-derives the
          // delivery fee for this shipmentMethod/address and adds it, in
          // USD, when it builds the checkout session — that's what
          // response.data.breakdown.total reflects after this call succeeds.
          amountToSend = remainingUSD.toString();
          print('   Order Balance (USD, delivery added server-side): $amountToSend');
          print('');
        }

        // Create Stripe checkout
        print('───────────────────────────────────────────────────────────');
        print('📤 SENDING TO STRIPE CHECKOUT:');
        print('   Review ID: ${widget.review.id}');
        print('   Amount: USD $amountToSend');
        print('   Weight: $_shipmentWeightKg kg');
        print('   Address: $addressToSend');
        print('───────────────────────────────────────────────────────────');
        print('');

        final resp = await BankApiService.stripeCheckoutPayment(
          reviewId: widget.review.id,
          paymentStatus: paymentType == "part" ? "part payment" : "full payment",
          amount: amountToSend,
          address: addressToSend,
          weight: _shipmentWeightKg,
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
            final data = resp["data"];
            final confirmedTotal = _formatBackendBreakdownTotal(
              data is Map ? data["breakdown"] : null,
            );
            print('✅ PAYMENT INITIATED SUCCESSFULLY');
            if (confirmedTotal != null) {
              print('   Backend-confirmed total (incl. delivery): $confirmedTotal');
            }
            print(
              '═══════════════════════════════════════════════════════════',
            );
            print('');
            if (confirmedTotal != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("You'll be charged $confirmedTotal, including delivery"),
                  duration: const Duration(seconds: 3),
                ),
              );
            }
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

      // Buyer is in Nigeria — use Paystack (NGN). As with Stripe above, the
      // client never converts currency itself; the backend adds its own
      // delivery fee (which may have been quoted in a foreign currency for
      // an import route) in NGN when it creates the transaction.
      print('🇳🇬 BUYER IN NIGERIA - Using Paystack (NGN)');
      print('');

      String amountToSend;

      if (paymentType == "part") {
        print('📝 INSTALLMENT PROCESSING:');

        if (amountController.text.trim().isEmpty) {
          setState(() => isLoading = false);
          print('❌ ERROR: Amount field is empty');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Please enter an amount")),
          );
          return;
        }

        final userEnteredAmount = double.parse(
          amountController.text.replaceAll(",", ""),
        );
        amountToSend = userEnteredAmount.toString();
        print('   Amount to Send to Paystack: NGN $amountToSend');
        print('');
      } else {
        print('💰 FULL PAYMENT PROCESSING:');

        final remainingNGN = widget.review.totalCost - widget.review.amountPaid;

        print('   Total Cost (stored): ${widget.review.totalCost}');
        print('   Amount Paid (stored): ${widget.review.amountPaid}');
        print('   Remaining Balance: $remainingNGN');
        print('');

        if (remainingNGN <= 0) {
          setState(() => isLoading = false);
          print('❌ ERROR: No balance remaining');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("No balance left to pay")),
          );
          return;
        }

        // Do NOT add the delivery fee here — the currencies can genuinely
        // differ (e.g. a Fez import quote comes back in GBP/USD even though
        // this buyer pays in NGN via Paystack) and the app has no business
        // converting between them. The backend already re-derives the
        // delivery fee for this shipmentMethod/address and adds it, in NGN,
        // when it creates the transaction — that's what response.breakdown.total
        // reflects after this call succeeds.
        amountToSend = remainingNGN.toString();
        print('   Order Balance (NGN, delivery added server-side): $amountToSend');
        print('');
      }

      print('───────────────────────────────────────────────────────────');
      print('📤 SENDING TO PAYSTACK:');
      print('   Review ID: ${widget.review.id}');
      print('   Weight: $_shipmentWeightKg kg');
      print('   Amount: NGN $amountToSend');
      print('───────────────────────────────────────────────────────────');
      print('');

      final resp =
          paymentType == "part"
              ? await PaymentService.createPartPayment(
                reviewId: widget.review.id,
                amount: amountToSend,
                address: addressToSend,
                pickupCountryId: pickupCountryId,
                pickupStateId: pickupStateId,
                pickupLocationId: pickupLocationId,
              )
              : await PaymentService.createFullPayment(
                reviewId: widget.review.id,
                amount: amountToSend,
                weight: _shipmentWeightKg,
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
          final confirmedTotal = _formatBackendBreakdownTotal(
            resp["breakdown"],
          );
          print('✅ PAYMENT INITIATED SUCCESSFULLY');
          if (confirmedTotal != null) {
            print('   Backend-confirmed total (incl. delivery): $confirmedTotal');
          }
          print('═══════════════════════════════════════════════════════════');
          print('');
          if (confirmedTotal != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("You'll be charged $confirmedTotal, including delivery"),
                duration: const Duration(seconds: 3),
              ),
            );
          }
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
    // Gateway shown to the buyer mirrors the same buyer-country rule used
    // in _processPayment — not the vendor's country.
    final useStripe = !_isUserInNigeria;

    return Stack(
      children: [
        SafeArea(
          top: true,
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 40, 20, 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 52,
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildHeaderButton(
                        icon: Icons.arrow_back_ios_new_rounded,
                        onTap: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const CustomText(
                              "Secure Your Order",
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              textAlign: TextAlign.left,
                            ),
                            const SizedBox(height: 2),
                            CustomText(
                              "Choose your preferred payment method.",
                              fontSize: 12,
                              color: AppColors.subtext,
                              textAlign: TextAlign.left,
                            ),
                          ],
                        ),
                      ),
                      _buildHeaderButton(
                        icon: Icons.close_rounded,
                        onTap: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildSummaryCard(useStripe),
                  if (widget.allowPaymentTypeSwitch) ...[
                    const SizedBox(height: 18),
                    const CustomText(
                      "Payment Type",
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      textAlign: TextAlign.left,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _buildSelectionTile(
                            title: "Pay in full",
                            subtitle: "Pay the full amount now",
                            icon: Icons.account_balance_wallet_outlined,
                            selected: paymentType == "full",
                            onTap: () {
                              setState(() => paymentType = "full");
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildSelectionTile(
                            title: "Pay in installments",
                            subtitle: "Pay part now and the rest later",
                            icon: Icons.payments_outlined,
                            selected: paymentType == "part",
                            onTap: () {
                              setState(() {
                                paymentType = "part";
                                _autoFillHalfPayment();
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (paymentType == "part") ...[
                    const SizedBox(height: 14),
                    CustomTextField(
                      title: _isUserInNigeria ? "Amount (NGN)" : "Amount (USD)",
                      fieldKey: "amount",
                      hintText: "50% of the quotation total",
                      controller: amountController,
                      readOnly: true,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^[0-9,]*\.?\d{0,2}$'),
                        ),
                      ],
                      onChanged: _handleAmountChange,
                    ),
                  ],
                  const SizedBox(height: 18),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.border),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.shadow,
                          blurRadius: 18,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const CustomText(
                          "Delivery Option",
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          textAlign: TextAlign.left,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildSelectionTile(
                                title: "Home Delivery",
                                subtitle: "Deliver to your address",
                                icon: Icons.location_on_outlined,
                                selected: deliveryMode == "address",
                                onTap: () {
                                  setState(() => deliveryMode = "address");
                                  _scheduleDeliveryCostRefresh();
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildSelectionTile(
                                title: "Pickup Point",
                                subtitle: "Collect from a location",
                                icon: Icons.store_mall_directory_outlined,
                                selected: deliveryMode == "pickup",
                                onTap: () {
                                  setState(() => deliveryMode = "pickup");
                                  _scheduleDeliveryCostRefresh();
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        CustomText(
                          // Fez returns exactly one rate per route — there's
                          // no selectable speed tier the way FedEx had, so
                          // only label this as a "method" for pickup orders,
                          // which still use the manual distance-based
                          // estimate below.
                          deliveryMode == "pickup"
                              ? "Shipment Method"
                              : "Delivery Fee",
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          textAlign: TextAlign.left,
                        ),
                        const SizedBox(height: 10),
                        if (deliveryMode == "pickup")
                          // Pickup-point orders don't involve a carrier at
                          // all — this manual tier feeds the distance-based
                          // estimate.
                          _buildDropdownField<String>(
                            value: shipment,
                            hintText: "Select shipment method",
                            icon: Icons.local_shipping_outlined,
                            items: const [
                              DropdownMenuItem(
                                value: "Regular",
                                child: Text("Standard Delivery (1–8 days)"),
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
                              if (val == null) return;
                              setState(() => shipment = val);
                              _scheduleDeliveryCostRefresh();
                            },
                          )
                        else if (_isLoadingCarrierRates)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceMuted,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: const Row(
                              children: [
                                SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: CustomText(
                                    "Checking live Fez delivery rates...",
                                    fontSize: 12,
                                    color: AppColors.subtext,
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else if (_carrierRates.isNotEmpty)
                          Column(
                            children:
                                _carrierRates
                                    .map((rate) => _buildCarrierRateTile(rate))
                                    .toList(),
                          )
                        else if (_carrierErrorReason != null)
                          // A quote was actually attempted and Fez rejected
                          // it — this is a real error, worth surfacing.
                          _buildCarrierUnavailableCard()
                        else
                          // Nothing has been quoted yet because the address
                          // form below isn't filled in — this is the normal
                          // starting state, not a failure, so it shouldn't
                          // look like one.
                          _buildFillAddressPrompt(),
                        const SizedBox(height: 16),
                        if (deliveryMode == "address") ...[
                          // These fields are joined into the single
                          // free-text `address` string the payment endpoints
                          // take. That string only labels the shipment for
                          // dispatch — Fez prices delivery off the country
                          // and state already saved on the buyer's account,
                          // not what's typed here.
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceMuted,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.info_outline_rounded,
                                  size: 16,
                                  color: AppColors.subtext,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: CustomText(
                                    "This is where your order ships to. Your delivery fee is priced off the country and state saved on your account, not this address.",
                                    fontSize: 11,
                                    color: AppColors.subtext,
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _buildTextField(
                            controller: countryController,
                            hintText: "Country",
                            icon: Icons.public_rounded,
                            errorText:
                                showCountryError ? "Country is required" : null,
                            onChanged: (value) {
                              if (showCountryError &&
                                  value.trim().isNotEmpty) {
                                setState(() => showCountryError = false);
                              }
                              _scheduleDeliveryCostRefresh();
                            },
                          ),
                          const SizedBox(height: 12),
                          _buildTextField(
                            controller: addressLine1Controller,
                            hintText: "Street address",
                            icon: Icons.home_work_outlined,
                            errorText:
                                showAddressLine1Error
                                    ? "Street address is required"
                                    : null,
                            onChanged: (value) {
                              if (showAddressLine1Error &&
                                  value.trim().isNotEmpty) {
                                setState(() => showAddressLine1Error = false);
                              }
                              _scheduleDeliveryCostRefresh();
                            },
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  controller: cityController,
                                  hintText: "City / Town",
                                  icon: Icons.location_city_outlined,
                                  errorText:
                                      showCityError ? "City is required" : null,
                                  onChanged: (value) {
                                    if (showCityError &&
                                        value.trim().isNotEmpty) {
                                      setState(() => showCityError = false);
                                    }
                                    _scheduleDeliveryCostRefresh();
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildTextField(
                                  controller: regionController,
                                  hintText: "State / Region",
                                  icon: Icons.map_outlined,
                                  errorText:
                                      showRegionError
                                          ? "State / Region is required"
                                          : null,
                                  onChanged: (value) {
                                    if (showRegionError &&
                                        value.trim().isNotEmpty) {
                                      setState(() => showRegionError = false);
                                    }
                                    _scheduleDeliveryCostRefresh();
                                  },
                                ),
                              ),
                            ],
                          ),
                        ] else ...[
                          if (isLoadingPickupHierarchy)
                            const Center(child: CircularProgressIndicator())
                          else if (pickupCountries.isEmpty)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF4DE),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: const Color(0xFFF5D08A),
                                ),
                              ),
                              child: const CustomText(
                                "No pickup points configured by admin yet.",
                                fontSize: 12,
                                color: AppColors.warning,
                                textAlign: TextAlign.left,
                              ),
                            )
                          else ...[
                            _buildDropdownField<PickupCountryOption>(
                              value: selectedPickupCountry,
                              hintText: "Select pickup country",
                              icon: Icons.public_rounded,
                              errorText:
                                  showPickupCountryError
                                      ? "Pickup country is required"
                                      : null,
                              items:
                                  pickupCountries.map((country) {
                                    return DropdownMenuItem<
                                      PickupCountryOption
                                    >(
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
                            const SizedBox(height: 12),
                            _buildDropdownField<PickupStateOption>(
                              value: selectedPickupState,
                              hintText: "Select pickup state",
                              icon: Icons.map_outlined,
                              errorText:
                                  showPickupStateError
                                      ? "Pickup state is required"
                                      : null,
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
                            const SizedBox(height: 12),
                            _buildDropdownField<PickupLocationOption>(
                              value: selectedPickupLocation,
                              hintText: "Select pickup point",
                              icon: Icons.storefront_outlined,
                              errorText:
                                  showPickupLocationError
                                      ? "Pickup point is required"
                                      : null,
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
                            if (selectedPickupLocation != null) ...[
                              const SizedBox(height: 10),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceMuted,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(
                                      Icons.place_outlined,
                                      size: 18,
                                      color: AppColors.accent,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: CustomText(
                                        selectedPickupLocation!.address,
                                        fontSize: 12,
                                        color: AppColors.ink,
                                        textAlign: TextAlign.left,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ],
                        // For "address" mode the Fez rate tile shown above
                        // (right under the toggle) already displays the fee —
                        // this recap is only needed for pickup orders, where
                        // the section above is just a manual method picker
                        // with no amount of its own.
                        if (deliveryMode == "pickup") ...[
                          const SizedBox(height: 12),
                          if (isCalculatingDelivery)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceMuted,
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Row(
                                children: [
                                  const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: CustomText(
                                      "Estimating delivery fee...",
                                      fontSize: 12,
                                      color: AppColors.subtext,
                                      textAlign: TextAlign.left,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else if (_deliveryCostLabel != null)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppColors.accentSoft,
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.local_shipping_outlined,
                                    color: AppColors.accent,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: CustomText(
                                      "Estimated delivery fee: $_deliveryCostLabel",
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.accent,
                                      textAlign: TextAlign.left,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                        const SizedBox(height: 10),
                        CustomText(
                          deliveryMode == "pickup"
                              ? "Choose an available pickup point to continue."
                              : "Enter your full address to ensure accurate delivery and pricing.",
                          fontSize: 11,
                          color: AppColors.subtext,
                          textAlign: TextAlign.left,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: OutlinedButton.icon(
                          onPressed:
                              isLoading
                                  ? null
                                  : () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close_rounded, size: 18),
                          label: const Text("Cancel"),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(54),
                            side: const BorderSide(color: AppColors.border),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 5,
                        child: CustomButton(
                          title: "Proceed to Payment",
                          onPressed: isLoading ? null : _makePayment,
                          isLoading: isLoading,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
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

  Widget _buildHeaderButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(icon, size: 18, color: AppColors.ink),
      ),
    );
  }

  Widget _buildSummaryCard(bool useStripe) {
    final total =
        useStripe
            ? widget.review.totalCostUSD
            : widget.review.userPayableTotal ?? widget.review.totalCost;
    final subtitle =
        useStripe
            ? "Checkout will continue with Stripe"
            : "You'll complete payment securely via Paystack.";

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF7F2FF), Color(0xFFFFFFFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.accentSoft,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              useStripe
                  ? Icons.language_rounded
                  : Icons.account_balance_wallet_outlined,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  CurrencyHelper.formatAmount(total),
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 2),
                CustomText(
                  subtitle,
                  fontSize: 12,
                  color: AppColors.subtext,
                  textAlign: TextAlign.left,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCarrierUnavailableCard() {
    final reason = _carrierErrorReason ?? "This route isn't supported yet.";

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFDECEC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: AppColors.danger,
                size: 18,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: CustomText(
                  "Couldn't get a delivery quote for this address",
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.danger,
                  textAlign: TextAlign.left,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          CustomText(
            reason,
            fontSize: 11,
            color: AppColors.subtext,
            textAlign: TextAlign.left,
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () {
              _lastFetchedDeliveryQuoteKey = null;
              _scheduleDeliveryCostRefresh();
            },
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text("Try again"),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.danger,
              side: const BorderSide(color: AppColors.danger),
              minimumSize: const Size(double.infinity, 44),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Shown before the buyer has filled in a valid address — no quote has
  // been requested yet, so this must read as "nothing to show yet", not as
  // an error. Deliberately neutral styling, no retry button (there's
  // nothing to retry).
  Widget _buildFillAddressPrompt() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.local_shipping_outlined,
            size: 18,
            color: AppColors.subtext,
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: CustomText(
              "Fill in your delivery address below to see your delivery fee.",
              fontSize: 12,
              color: AppColors.subtext,
              textAlign: TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCarrierRateTile(CarrierRate rate) {
    final selected = _selectedCarrierRate?.serviceType == rate.serviceType;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedCarrierRate = rate;
            _deliveryCostLabel = CurrencyHelper.formatAmount(
              rate.amount,
              currencyCode: rate.currency,
            );
          });
        },
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: selected ? AppColors.accentSoft : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected ? AppColors.accent : AppColors.border,
              width: selected ? 1.4 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.local_shipping_outlined,
                size: 20,
                color: selected ? AppColors.accent : AppColors.subtext,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      rate.serviceName,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      textAlign: TextAlign.left,
                    ),
                    const SizedBox(height: 2),
                    CustomText(
                      "${rate.carrier.toUpperCase()} · ${rate.routeLabel}",
                      fontSize: 11,
                      color: AppColors.subtext,
                      textAlign: TextAlign.left,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              CustomText(
                CurrencyHelper.formatAmount(
                  rate.amount,
                  currencyCode: rate.currency,
                ),
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: selected ? AppColors.accent : AppColors.ink,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? AppColors.accentSoft : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? AppColors.accent : AppColors.border,
            width: selected ? 1.4 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 20,
              color: selected ? AppColors.accent : AppColors.subtext,
            ),
            const SizedBox(height: 10),
            CustomText(
              title,
              fontSize: 13,
              fontWeight: FontWeight.w800,
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 4),
            CustomText(
              subtitle,
              fontSize: 11,
              color: AppColors.subtext,
              textAlign: TextAlign.left,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownField<T>({
    required T? value,
    required String hintText,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?>? onChanged,
    required IconData icon,
    String? errorText,
  }) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      isExpanded: true,
      menuMaxHeight: 360,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(icon, size: 20, color: AppColors.subtext),
        errorText: errorText,
      ),
      items: items,
      onChanged: onChanged,
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required ValueChanged<String> onChanged,
    required IconData icon,
    String? errorText,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      onChanged: onChanged,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(icon, size: 20, color: AppColors.subtext),
        errorText: errorText,
      ),
    );
  }
}
