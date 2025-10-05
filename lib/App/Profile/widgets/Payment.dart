import 'package:flutter/material.dart';
import 'package:hog/components/texts.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentWebView extends StatelessWidget {
  final String paymentUrl;

  const PaymentWebView({super.key, required this.paymentUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const CustomText(
          "Complete Payment",
          color: Colors.white,
          fontSize: 18,
        ),
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.purple,
      ),
      body: WebViewWidget(
        controller:
            WebViewController()
              ..setJavaScriptMode(JavaScriptMode.unrestricted)
              ..loadRequest(Uri.parse(paymentUrl)),
      ),
    );
  }
}
