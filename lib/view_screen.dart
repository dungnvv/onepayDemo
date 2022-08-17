import 'dart:convert';
import 'dart:math';

import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:onepaydemo/create_url_paymemt.dart';
import 'package:onepaydemo/return_screen.dart';

class ViewScreen extends StatefulWidget {
  const ViewScreen({Key? key}) : super(key: key);

  @override
  State<ViewScreen> createState() => _ViewScreenState();
}

class _ViewScreenState extends State<ViewScreen> {
  static const callBackUrl = 'https://returnonepay.herokuapp.com/';
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
      appBar: AppBar(title: const Text('OnePay')),
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
              final isCallbackSuccessUrl =
                  (url.toString()).startsWith(callBackUrl);

              if (!isCallbackSuccessUrl) {
                return;
              }

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => const ReturnScreen(),
                ),
                (route) => route.isFirst,
              );
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
    const _chars = '0123456789';
    Random _rnd = Random();

    String getRandomString(int length) =>
        String.fromCharCodes(Iterable.generate(
            length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

    final params = DataUrlPayment.params;
    params['vpc_MerchTxnRef'] = getRandomString(24);
    final sortedParams = DataUrlPayment().sortParams(params);
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
    final vnpSecureHash = _createSecureHash(hashData);

    final urlPayment = DataUrlPayment.virtualPaymentClientURL +
        '?Title=' +
        DataUrlPayment.title +
        '&' +
        query +
        '&vpc_SecureHash=' +
        vnpSecureHash;

    return urlPayment;
  }

  String _createSecureHash(String message) {
    final List<int> messageBytes = utf8.encode(message);
    final hexKey = hex.decode(DataUrlPayment.secureSecret);
    final Hmac hmac = Hmac(sha256, hexKey);
    final Digest digest = hmac.convert(messageBytes);
    final String hexHash = hex.encode(digest.bytes);

    return hexHash.toUpperCase();
  }
}
