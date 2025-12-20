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
          onPageStarted: (String url) {
            print('DEBUG WEBVIEW STARTED: $url');
          },
          onPageFinished: (String url) {},
          onWebResourceError: (WebResourceError error) {
            // Handle web resource errors.
            // Example: Navigator.pop(context, 'failed');
          },
          onNavigationRequest: (NavigationRequest request) {
            print('DEBUG WEBVIEW REQUEST: ${request.url}');
            final uri = Uri.parse(request.url);

            // Midtrans success indicators
            final isSettlement =
                uri.queryParameters['transaction_status'] == 'settlement';
            final isCapture =
                uri.queryParameters['transaction_status'] == 'capture';
            final isStatusCode200 = uri.queryParameters['status_code'] == '200';
            final isStatusCode201 = uri.queryParameters['status_code'] == '201';
            final isFinishPath = uri.path.contains('/finish');

            if (isSettlement ||
                isCapture ||
                isStatusCode200 ||
                isStatusCode201 ||
                isFinishPath) {
              context.pop('success');
              return NavigationDecision.prevent;
            }

            // Midtrans failure/cancellation indicators
            final isCancel =
                uri.queryParameters['transaction_status'] == 'cancel';
            final isDeny = uri.queryParameters['transaction_status'] == 'deny';
            final isExpire =
                uri.queryParameters['transaction_status'] == 'expire';
            final isErrorPath = uri.path.contains('/error');
            final isUnfinishPath = uri.path.contains('/unfinish');

            if (isCancel ||
                isDeny ||
                isExpire ||
                isErrorPath ||
                isUnfinishPath) {
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
      onPopInvokedWithResult: (didPop, result) {
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
