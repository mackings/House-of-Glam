import 'package:flutter/material.dart';
import 'package:hog/components/customAppbar.dart';
import 'package:hog/components/texts.dart';
import 'package:hog/theme/app_theme.dart';
import 'package:webview_flutter/webview_flutter.dart';

const String _tawkPropertyId = '6a54a01aa0425d1d54b24b1f';
const String _tawkWidgetId = '1jtd92q4u';

/// Live support chat, backed by Tawk.to's direct chat link — the officially
/// supported way to embed Tawk in a native app (the JS embed snippet is for
/// websites and renders as a floating bubble, not a full chat screen).
class LiveChatPage extends StatefulWidget {
  final String? visitorName;
  final String? visitorEmail;

  const LiveChatPage({super.key, this.visitorName, this.visitorEmail});

  @override
  State<LiveChatPage> createState() => _LiveChatPageState();
}

class _LiveChatPageState extends State<LiveChatPage> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setBackgroundColor(Colors.white)
          ..setNavigationDelegate(
            NavigationDelegate(
              onPageStarted: (_) {
                if (!mounted) return;
                setState(() {
                  _isLoading = true;
                  _hasError = false;
                });
              },
              onPageFinished: (_) {
                if (!mounted) return;
                setState(() => _isLoading = false);
              },
              onWebResourceError: (error) {
                // Tawk's chat page loads trackers, websockets, and other
                // sub-resources that can fail independently of the page
                // itself. Only treat a main-frame failure as a real error,
                // otherwise a single blocked tracker would incorrectly show
                // the "couldn't load" screen over a perfectly working chat.
                if (error.isForMainFrame != true) return;
                if (!mounted) return;
                setState(() {
                  _isLoading = false;
                  _hasError = true;
                });
              },
            ),
          )
          ..loadRequest(_buildChatUri());
  }

  Uri _buildChatUri() {
    final params = <String, String>{};
    final name = widget.visitorName?.trim();
    final email = widget.visitorEmail?.trim();
    if (name != null && name.isNotEmpty) params['name'] = name;
    if (email != null && email.isNotEmpty) params['email'] = email;

    return Uri.https(
      'tawk.to',
      '/chat/$_tawkPropertyId/$_tawkWidgetId',
      params.isEmpty ? null : params,
    );
  }

  void _retry() {
    setState(() {
      _hasError = false;
      _isLoading = true;
    });
    _controller.loadRequest(_buildChatUri());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: const CustomAppBar(title: 'Live Chat', enableAction: false),
      body: SafeArea(
        child: Stack(
          children: [
            if (!_hasError) WebViewWidget(controller: _controller),
            if (_isLoading && !_hasError)
              const Center(
                child: CircularProgressIndicator(color: AppColors.accent),
              ),
            if (_hasError)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.wifi_off_rounded,
                        size: 40,
                        color: AppColors.subtext,
                      ),
                      const SizedBox(height: 12),
                      const CustomText(
                        "Couldn't load live chat",
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                      const SizedBox(height: 6),
                      const CustomText(
                        'Check your connection and try again.',
                        fontSize: 12,
                        color: AppColors.subtext,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: _retry,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.accent,
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
