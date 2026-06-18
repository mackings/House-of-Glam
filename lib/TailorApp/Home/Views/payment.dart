import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hog/App/Auth/Api/secure.dart';
import 'package:hog/TailorApp/Home/Api/subservice.dart';
import 'package:hog/components/texts.dart';
import 'package:hog/theme/app_theme.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewScreen extends StatefulWidget {
  final String url;
  final String paymentReference;

  const WebViewScreen({
    super.key,
    required this.url,
    this.paymentReference = '',
  });

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController _controller;
  Timer? _verificationTimer;
  bool isLoading = true;
  bool isVerifying = false;
  bool _verificationInProgress = false;
  bool _paymentActivated = false;

  Future<void> _verifyPayment({bool silent = false}) async {
    if (widget.paymentReference.isEmpty ||
        _verificationInProgress ||
        _paymentActivated) {
      return;
    }
    _verificationInProgress = true;
    if (!silent) setState(() => isVerifying = true);
    try {
      final response = await SubscriptionService().verifySubscriptionPayment(
        widget.paymentReference,
      );
      final verifiedUser = response['user'];
      if (verifiedUser is Map<String, dynamic>) {
        final cachedUser = await SecurePrefs.getUserData() ?? {};
        await SecurePrefs.saveUserData({...cachedUser, ...verifiedUser});
      }
      if (!mounted) return;
      _paymentActivated = true;
      _verificationTimer?.cancel();
      final messenger = ScaffoldMessenger.of(context);
      setState(() => isVerifying = false);
      Navigator.pop(context, true);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            response['message']?.toString() ??
                'Subscription activated successfully',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      if (!silent) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.toString().replaceFirst('Exception: ', '')),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } finally {
      _verificationInProgress = false;
      if (mounted && !_paymentActivated) {
        if (!silent) setState(() => isVerifying = false);
      }
    }
  }

  void _startAutomaticVerification() {
    if (widget.paymentReference.isEmpty) return;
    _verificationTimer?.cancel();
    _verificationTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      _verifyPayment(silent: true);
    });
  }

  @override
  void initState() {
    super.initState();
    _controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setNavigationDelegate(
            NavigationDelegate(
              onPageStarted: (_) => setState(() => isLoading = true),
              onPageFinished: (_) => setState(() => isLoading = false),
            ),
          )
          ..loadRequest(Uri.parse(widget.url));
    _startAutomaticVerification();
  }

  @override
  void dispose() {
    _verificationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          "Complete Subscription",
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(14, 8, 14, 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.lock_outline_rounded,
                  size: 18,
                  color: AppColors.accent,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: CustomText(
                    widget.paymentReference.isEmpty
                        ? "Finish your subscription payment securely in the checkout window below."
                        : "Complete payment below. Confirmation is detected automatically.",
                    fontSize: 12,
                    color: AppColors.subtext,
                    textAlign: TextAlign.left,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                Container(
                  margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
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
                  clipBehavior: Clip.antiAlias,
                  child: WebViewWidget(controller: _controller),
                ),
                if (isLoading)
                  const Center(
                    child: CircularProgressIndicator(color: AppColors.accent),
                  ),
              ],
            ),
          ),
          if (widget.paymentReference.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed:
                      isVerifying ? null : () => _verifyPayment(silent: false),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(52),
                  ),
                  icon:
                      isVerifying
                          ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                          : const Icon(Icons.verified_rounded),
                  label: Text(
                    isVerifying ? 'Verifying Payment' : 'Verify Payment',
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
