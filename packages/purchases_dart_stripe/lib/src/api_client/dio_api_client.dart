import 'package:dio/dio.dart';
import 'package:purchases_dart/purchases_dart.dart';
import 'package:purchases_dart_stripe/src/api_client/api_client.dart';

/// [DioApiClient] used to make api calls using dio.
/// This makes api calls on client side, so it should not be used in production, instead use a server side api client.
/// or a proxy server, check [ProxyApiClient]
class DioApiClient extends ApiClient {
  late Dio _httpClient;

  DioApiClient(String stripeApi) {
    _httpClient = Dio(
      BaseOptions(
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': 'Bearer $stripeApi'
        },
      ),
    );
    _httpClient.interceptors.add(ErrorInterceptor());
  }

  @override
  Future<Map<String, dynamic>?> get(
    String path, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    Response response = await _httpClient.get(
      path,
      data: data,
      queryParameters: queryParameters,
    );
    return response.data;
  }

  @override
  Future<Map<String, dynamic>?> post<T>(
    String path, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    Response response = await _httpClient.post(
      path,
      data: data,
      queryParameters: queryParameters,
    );
    return response.data;
  }
}
