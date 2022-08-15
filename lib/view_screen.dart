import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:onepaydemo/return_screen.dart';

class ViewScreen extends StatefulWidget {
  const ViewScreen({required this.url, Key? key}) : super(key: key);
  final String url;
  @override
  State<ViewScreen> createState() => _ViewScreenState();
}

class _ViewScreenState extends State<ViewScreen> {
  double _progress = 0;

  String returnUrl = '';
  late InAppWebViewController webViewController;

  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
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
              url: Uri.parse(
                  'https://mtf.onepay.vn/onecomm-pay/vpc.op?Title=VPC+3-Party&vpc_AccessCode=D67342C2&vpc_Amount=100&vpc_Command=pay&vpc_Currency=VND&vpc_Customer_Email=support%40onepay.vn&vpc_Customer_Id=thanhvt&vpc_Customer_Phone=840904280949&vpc_Locale=vn&vpc_MerchTxnRef=202207211044141795171067&vpc_Merchant=ONEPAY&vpc_OrderInfo=JSECURETEST01&vpc_ReturnURL=https%3A%2F%2Freturnonepay.herokuapp.com%2F&vpc_SHIP_City=Ha+Noi&vpc_SHIP_Country=Viet+Nam&vpc_SHIP_Provice=Hoan+Kiem&vpc_SHIP_Street01=39A+Ngo+Quyen&vpc_TicketNo=%3A%3A1&vpc_Version=2&vpc_SecureHash=F13E1584227B3C68BE8F776E5B12696AF3C1F4A0C959FE44907F30577241A35D'),
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
}
