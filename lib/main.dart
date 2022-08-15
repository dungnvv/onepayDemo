import 'dart:convert';
import 'dart:developer';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:onepaydemo/create_url_paymemt.dart';
import 'package:onepaydemo/view_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final String _paymentResultCodeCode = 'Unknown';
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          children: [
            Text('Result Code: $_paymentResultCodeCode\n'),
            ElevatedButton(
              onPressed: () {
                final sortedParams =
                    DataUrlPayment().sortParams(DataUrlPayment().params);
                final hashDataBuffer = StringBuffer();
                sortedParams.forEach((key, value) {
                  hashDataBuffer.write(key);
                  hashDataBuffer.write('=');
                  hashDataBuffer.write(value);
                  hashDataBuffer.write('&');
                });
                final hashData = hashDataBuffer
                    .toString()
                    .substring(0, hashDataBuffer.length - 1);
                final query = Uri(queryParameters: sortedParams).query;
                log('hashData = $hashData');
                log('query = $query');
                var key = utf8.encode(DataUrlPayment().secureSecret);
                var hmacSha256 = Hmac(sha256, key);
                var bytes = utf8.encode(hashData.toString());
                dynamic vnpSecureHash = hmacSha256.convert(bytes).bytes;
                String val = base64Encode(vnpSecureHash);
                vnpSecureHash = val.toUpperCase();
                log('hash: $vnpSecureHash');
                final urlPayment = DataUrlPayment().virtualPaymentClientURL +
                    '?Title=' +
                    DataUrlPayment().title +
                    '&' +
                    query +
                    '&vpc_SecureHash=' +
                    vnpSecureHash;
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ViewScreen(url: urlPayment)));
              },
              child: const Text('10.000 VND'),
            )
          ],
        ),
      ),
    );
  }
}
