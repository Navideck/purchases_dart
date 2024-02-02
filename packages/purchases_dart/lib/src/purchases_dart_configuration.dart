import 'package:purchases_dart/src/store_product_interface.dart';

/// required to pass [storeProduct],
/// use [StripeStoreProduct] for Stripe integrations
class PurchasesDartConfiguration {
  final String apiKey;
  final StoreProductInterface storeProduct;
  final String? appUserId;

  PurchasesDartConfiguration({
    required this.apiKey,
    required this.storeProduct,
    this.appUserId,
  });
}
