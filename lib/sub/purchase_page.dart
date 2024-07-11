import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PurchaseApp extends StatefulWidget {
  const PurchaseApp({super.key});

  @override
  State<PurchaseApp> createState() => _PurchaseAppState();
}

class _PurchaseAppState extends State<PurchaseApp> {
  WebViewController? _webViewController;

  @override
  void initState() {
    _webViewController = WebViewController()
      ..loadRequest(Uri.parse(
          'https://static.chabyulhwa.com/market/assets/note/pages/purchase-order/index.html'))
      ..setJavaScriptMode(JavaScriptMode.unrestricted);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(237, 238, 252, 1.0),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0), // 위 아래 여백 설정
          child: AspectRatio(
            aspectRatio: 964 / 636, // 비율 설정
            child: WebViewWidget(
              controller: _webViewController!,
            ),
          ),
        ),
      ),
    );
  }
}
