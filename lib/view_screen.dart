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
  //Backup url payment:
  //'https://mtf.onepay.vn/onecomm-pay/vpc.op?Title=VPC+3-Party&vpc_AccessCode=D67342C2&vpc_Amount=10000000&vpc_Command=pay&vpc_Currency=VND&vpc_Customer_Email=support%40onepay.vn&vpc_Customer_Id=thanhvt&vpc_Customer_Phone=840904280949&vpc_Locale=vn&vpc_MerchTxnRef=20220815153732950830333&vpc_Merchant=ONEPAY&vpc_OrderInfo=JSECURETEST01&vpc_ReturnURL=https%3A%2F%2Freturnonepay.herokuapp.com%2F&vpc_SHIP_City=Ha+Noi&vpc_SHIP_Country=Viet+Nam&vpc_SHIP_Provice=Hoan+Kiem&vpc_SHIP_Street01=39A+Ngo+Quyen&vpc_TicketNo=%3A%3A1&vpc_Version=2&vpc_SecureHash=996704C872B13A9A47369D81C3BA9E68D2C3C6F399C812E159190E0E60DD906A'
  //'https://mtf.onepay.vn/onecomm-pay/vpc.op?Title=VPC+3-Party&vpc_AccessCode=D67342C2&vpc_Amount=100000000&vpc_Command=pay&vpc_Currency=VND&vpc_Customer_Email=support%40onepay.vn&vpc_Customer_Id=thanhvt&vpc_Customer_Phone=840904280949&vpc_Locale=vn&vpc_MerchTxnRef=20220815153732950830333&vpc_Merchant=ONEPAY&vpc_OrderInfo=JSECURETEST01&vpc_ReturnURL=https%3A%2F%2Freturnonepay.herokuapp.com%2F&vpc_SHIP_City=Ha+Noi&vpc_SHIP_Country=Viet+Nam&vpc_SHIP_Provice=Hoan+Kiem&vpc_SHIP_Street01=39A+Ngo+Quyen&vpc_TicketNo=%3A%3A1&vpc_Version=2&vpc_SecureHash=7818450616D42D2B11B20881A4D5A61946858ABB32A34C70405DB36FBCE3DA2E'
  //'https://mtf.onepay.vn/onecomm-pay/vpc.op?Title=VPC+3-Party&vpc_AccessCode=D67342C2&vpc_Amount=10000000&vpc_Command=pay&vpc_Currency=VND&vpc_Customer_Email=support%40onepay.vn&vpc_Customer_Id=thanhvt&vpc_Customer_Phone=840904280949&vpc_Locale=vn&vpc_MerchTxnRef=202208151538591011333303&vpc_Merchant=ONEPAY&vpc_OrderInfo=JSECURETEST01&vpc_ReturnURL=https%3A%2F%2Freturnonepay.herokuapp.com%2F&vpc_SHIP_City=Ha+Noi&vpc_SHIP_Country=Viet+Nam&vpc_SHIP_Provice=Hoan+Kiem&vpc_SHIP_Street01=39A+Ngo+Quyen&vpc_TicketNo=%3A%3A1&vpc_Version=2&vpc_SecureHash=DA6D730429A5D9394E89A2664E510D7B4E1B748BCF0E631DBAD71F51C843FBCC'
  //'https://mtf.onepay.vn/onecomm-pay/vpc.op?Title=VPC+3-Party&vpc_AccessCode=D67342C2&vpc_Amount=10000000&vpc_Command=pay&vpc_Currency=VND&vpc_Customer_Email=support%40onepay.vn&vpc_Customer_Id=thanhvt&vpc_Customer_Phone=840904280949&vpc_Locale=vn&vpc_MerchTxnRef=202208151539481828025037&vpc_Merchant=ONEPAY&vpc_OrderInfo=JSECURETEST01&vpc_ReturnURL=https%3A%2F%2Freturnonepay.herokuapp.com%2F&vpc_SHIP_City=Ha+Noi&vpc_SHIP_Country=Viet+Nam&vpc_SHIP_Provice=Hoan+Kiem&vpc_SHIP_Street01=39A+Ngo+Quyen&vpc_TicketNo=%3A%3A1&vpc_Version=2&vpc_SecureHash=19FEB2B779CBDFD18E05697027D106836D49D7291A34383F446077566860E2EA'
  //'https://mtf.onepay.vn/onecomm-pay/vpc.op?Title=VPC+3-Party&vpc_AccessCode=D67342C2&vpc_Amount=10000000&vpc_Command=pay&vpc_Currency=VND&vpc_Customer_Email=support%40onepay.vn&vpc_Customer_Id=thanhvt&vpc_Customer_Phone=840904280949&vpc_Locale=vn&vpc_MerchTxnRef=202208151540251829188109&vpc_Merchant=ONEPAY&vpc_OrderInfo=JSECURETEST01&vpc_ReturnURL=https%3A%2F%2Freturnonepay.herokuapp.com%2F&vpc_SHIP_City=Ha+Noi&vpc_SHIP_Country=Viet+Nam&vpc_SHIP_Provice=Hoan+Kiem&vpc_SHIP_Street01=39A+Ngo+Quyen&vpc_TicketNo=%3A%3A1&vpc_Version=2&vpc_SecureHash=F04C85225BCB6B01F278C178CAB177859E0D0304EA0EDEBEE2C4D211C4D46FC6'
}
