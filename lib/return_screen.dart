import 'package:flutter/material.dart';

class ReturnScreen extends StatelessWidget {
  const ReturnScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Return Screen'),
      ),
      body: Container(
        alignment: Alignment.center,
        child: const Text('Hoàn thành thanh toán'),
      ),
    );
  }
}
