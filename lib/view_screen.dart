import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:onepaydemo/create_url_paymemt.dart';
import 'package:onepaydemo/return_screen.dart';

class ViewScreen extends StatefulWidget {
  const ViewScreen(
      {
      // required this.url,
      Key? key})
      : super(key: key);
  // final String url;
  @override
  State<ViewScreen> createState() => _ViewScreenState();
}

class _ViewScreenState extends State<ViewScreen> {
  double _progress = 0;
  String _urlpaymet = '';
  String returnUrl = '';
  late InAppWebViewController webViewController;

  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  void initState() {
    _urlpaymet = makeUrl();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: const Text('OnePay', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(
              url: Uri.parse(_urlpaymet),
            ),
            onWebViewCreated: (InAppWebViewController controller) {
              webViewController = controller;
            },
            onLoadStart: (InAppWebViewController controller, Uri? url) {
              setState(() {
                returnUrl = url.toString();
              });
            },
            onLoadStop: (InAppWebViewController controller, Uri? url) {
              if ((url.toString())
                  .startsWith('https://returnonepay.herokuapp.com/')) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ReturnScreen(),
                  ),
                  (route) => route.isFirst,
                );
              }
            },
            initialOptions: InAppWebViewGroupOptions(
              crossPlatform:
                  InAppWebViewOptions(useShouldOverrideUrlLoading: true),
            ),
            onProgressChanged:
                (InAppWebViewController controller, int progress) {
              setState(() {
                _progress = progress / 100;
              });
            },
          ),
          _progress < 1
              ? SizedBox(
                  height: 3,
                  child: LinearProgressIndicator(
                    value: _progress,
                    backgroundColor: Colors.blue.withOpacity(0.2),
                  ),
                )
              : const SizedBox()
        ],
      ),
    );
  }

  String makeUrl() {
    final sortedParams = DataUrlPayment().sortParams(DataUrlPayment().params);
    final hashDataBuffer = StringBuffer();
    sortedParams.forEach((key, value) {
      hashDataBuffer.write(key);
      hashDataBuffer.write('=');
      hashDataBuffer.write(value);
      hashDataBuffer.write('&');
    });
    final hashData =
        hashDataBuffer.toString().substring(0, hashDataBuffer.length - 1);
    final query = Uri(queryParameters: sortedParams).query;
    var key = utf8.encode(DataUrlPayment().secureSecret);
    var hmacSha256 = Hmac(sha256, key);
    var bytes = utf8.encode(hashData.toString());
    dynamic vnpSecureHash = hmacSha256.convert(bytes).bytes;
    String val = base64Encode(vnpSecureHash);
    vnpSecureHash = val.toUpperCase();
    final urlPayment = DataUrlPayment().virtualPaymentClientURL +
        '?Title=' +
        DataUrlPayment().title +
        '&' +
        query +
        '&vpc_SecureHash=' +
        vnpSecureHash;
    return urlPayment;
  }
}
