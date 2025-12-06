import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentPage extends StatefulWidget {
  final String paymentUrl;

  const PaymentPage({super.key, required this.paymentUrl});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onWebResourceError: (WebResourceError error) {
            // Handle web resource errors.
            // Example: Navigator.pop(context, 'failed');
          },
          onNavigationRequest: (NavigationRequest request) {
            final uri = Uri.parse(request.url);

            // Intercept specific URLs to determine payment status
            if (uri.queryParameters.containsKey('transaction_status') &&
                uri.queryParameters['transaction_status'] == 'settlement') {
              context.pop('success');
              return NavigationDecision.prevent;
            } else if (uri.path.contains('/finish')) {
              context.pop('success');
              return NavigationDecision.prevent;
            } else if (uri.queryParameters.containsKey('transaction_status') &&
                (uri.queryParameters['transaction_status'] == 'cancel' ||
                    uri.queryParameters['transaction_status'] == 'deny' ||
                    uri.queryParameters['transaction_status'] == 'expire')) {
              context.pop('failed');
              return NavigationDecision.prevent;
            } else if (uri.path.contains('/error') ||
                uri.path.contains('/unfinish')) {
              context.pop('failed');
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Prevent default back behavior
      onPopInvoked: (didPop) {
        if (didPop) return;
        context.pop('cancelled'); // Return 'cancelled' on back button press
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Payment'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () =>
                context.pop('cancelled'), // Return 'cancelled' on close
          ),
        ),
        body: WebViewWidget(controller: controller),
      ),
    );
  }
}
