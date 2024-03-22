import 'package:purchases_dart/src/store_product_interface.dart';

/// Used when calling [configure] to configure the PurchasesDart plugin
class PurchasesDartConfiguration {
  /// RevenueCat API Key.
  final String apiKey;

  /// Store product interface for communicating with the underlying store.
  final StoreProductInterface storeProduct;

  /// An optional unique id for identifying the user.
  final String? appUserId;

  PurchasesDartConfiguration({
    required this.apiKey,
    required this.storeProduct,
    this.appUserId,
  });
}
