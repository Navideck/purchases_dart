import 'package:dio/dio.dart';

/// Header for Purchases, use to override default headers.
class PurchasesHeader {
  String? platform;
  String? apiKey;
  Map<String, dynamic>? extra;

  PurchasesHeader({
    this.platform,
    this.apiKey,
    this.extra,
  });

  Options? get dioOptions {
    Map<String, dynamic> headers = {
      if (platform != null) 'X-Platform': platform,
      if (apiKey != null) 'Authorization': 'Bearer $apiKey',
    };
    if (extra != null) headers.addAll(extra!);
    if (headers.isEmpty) return null;
    return Options(headers: headers);
  }
}
