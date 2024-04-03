import 'package:dio/dio.dart';
import 'package:purchases_dart_stripe/purchases_dart_stripe.dart';

/// [ProxyApiClient] can be used to make stripe api calls through a proxy server.
class ProxyApiClient extends ApiClient {
  late Dio _httpClient;
  final String proxyUrl;
  ProxyApiClient(this.proxyUrl) {
    _httpClient = Dio();
    _httpClient.interceptors.add(StripeDioErrorInterceptor());
  }

  @override
  Future<Map<String, dynamic>?> get(
    String path, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    var response = await _httpClient.post(
      "$proxyUrl/get/",
      queryParameters: queryParameters,
      data: {
        "url": path,
        "data": data,
      },
    );
    return response.data;
  }

  @override
  Future<Map<String, dynamic>?> post<T>(
    String path, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    var response = await _httpClient.post(
      "$proxyUrl/post/",
      queryParameters: queryParameters,
      data: {
        "url": path,
        "data": data,
      },
    );
    return response.data;
  }
}
