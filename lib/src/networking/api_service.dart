import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:purchases_dart/purchases_dart.dart';
import 'package:purchases_dart/src/helper/log_helper.dart';
import 'package:purchases_dart/src/networking/error_interceptor.dart';

class ApiService {
  /// Returns a Dio instance with the RevenueCat API headers
  static Dio getRevenueCatHttpClient(String apiKey) {
    Dio dio = Dio(
      BaseOptions(
        baseUrl: 'https://api.revenuecat.com/v1',
        headers: {
          'X-Platform': 'stripe',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey'
        },
      ),
    );
    dio.interceptors.addAll(_baseInterceptors(dio));
    return dio;
  }

  /// Returns a Dio instance with the Stripe API headers
  static Dio getStripeHttpClient(String apiKey) {
    Dio dio = Dio(
      BaseOptions(
        baseUrl: 'https://api.stripe.com/v1',
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': 'Bearer $apiKey'
        },
      ),
    );
    dio.interceptors.addAll(_baseInterceptors(dio));
    return dio;
  }

  static List<Interceptor> _baseInterceptors(Dio dio) {
    List<Interceptor> interceptors = [];

    // Logs interceptors
    // interceptors.add(LogInterceptor());

    // Retry interceptor
    interceptors.add(
      RetryInterceptor(
        dio: dio,
        logPrint: logInfo,
        retries: 2,
        retryDelays: const [
          Duration(seconds: 1),
        ],
      ),
    );

    // Error interceptor
    interceptors.add(
      ErrorInterceptor(),
    );

    // Cache interceptor
    if (PurchasesDart.cacheOptions != null) {
      interceptors.add(
        DioCacheInterceptor(
          options: PurchasesDart.cacheOptions!,
        ),
      );
    }

    return interceptors;
  }
}
