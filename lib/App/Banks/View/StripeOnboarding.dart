import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';



class StripeOnboardingPage extends StatefulWidget {
  final String onboardingUrl;
  final Function(bool success, String message) onComplete;

  const StripeOnboardingPage({
    super.key,
    required this.onboardingUrl,
    required this.onComplete,
  });

  @override
  State<StripeOnboardingPage> createState() => _StripeOnboardingPageState();
}

class _StripeOnboardingPageState extends State<StripeOnboardingPage> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            print("📍 Page started: $url");
            
            // Check if onboarding is complete
            if (url.contains('/return') || url.contains('success')) {
              _handleSuccess();
            } else if (url.contains('/refresh') || url.contains('cancel')) {
              _handleCancel();
            }
          },
          onPageFinished: (url) {
            setState(() => _isLoading = false);
          },
          onNavigationRequest: (request) {
            print("🧭 Navigation: ${request.url}");
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.onboardingUrl));
  }

  void _handleSuccess() {
    if (mounted) {
      Navigator.pop(context);
      widget.onComplete(true, "Stripe account connected successfully!");
    }
  }

  void _handleCancel() {
    if (mounted) {
      Navigator.pop(context);
      widget.onComplete(false, "Onboarding cancelled");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Connect Stripe Account",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.close, size: 18),
          ),
          onPressed: () {
            Navigator.pop(context);
            widget.onComplete(false, "Onboarding cancelled");
          },
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
              ),
            ),
        ],
      ),
    );
  }
}