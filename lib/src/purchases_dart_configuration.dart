import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:purchases_dart/purchases_dart.dart';

/// required to pass [storeProduct],
/// use [StripeStoreProduct] for Stripe integrations
class PurchasesDartConfiguration {
  final String apiKey;
  final StoreProductInterface storeProduct;
  final String? appUserId;
  final CacheOptions? cacheOptions;

  PurchasesDartConfiguration({
    required this.apiKey,
    required this.storeProduct,
    this.appUserId,
    this.cacheOptions,
  });
}
