class DataUrlPayment {
  static const String secureSecret = "A3EFDFABA8653DF2342E8DAC29B51AF0";
  static const virtualPaymentClientURL =
      'https://mtf.onepay.vn/onecomm-pay/vpc.op';
  static const title = 'VPC+3-Party';

  static final params = <String, dynamic>{
    'vpc_Merchant': 'ONEPAY',
    'vpc_AccessCode': 'D67342C2',
    // unique id for a merchant include 24 length string of number
    'vpc_MerchTxnRef': '',
    'vpc_OrderInfo': 'JSECURETEST01',
    'vpc_Amount': '100',
    'vpc_ReturnURL': 'https://returnonepay.herokuapp.com/',
    'vpc_Version': '2',
    'vpc_Command': 'Pay',
    'vpc_Locale': 'vn',
    'vpc_Currency': 'VND',
    'vpc_TicketNo': '::1',
    'vpc_Customer_Email': 'support@onepay.vn',
    'vpc_Customer_Id': 'thanhvt',
    'vpc_Customer_Phone': '840904280949',
    'vpc_SHIP_Street01': '39A Ngo Quyen',
    'vpc_SHIP_Provice': 'Hoan Kiem',
    'vpc_SHIP_Country': 'Viet Nam',
    'vpc_SHIP_City': 'Ha Noi'
  };
  Map<String, dynamic> sortParams(Map<String, dynamic> params) {
    final sortedParams = <String, dynamic>{};
    final keys = params.keys.toList()..sort();
    for (String key in keys) {
      sortedParams[key] = params[key];
    }
    return sortedParams;
  }
}
