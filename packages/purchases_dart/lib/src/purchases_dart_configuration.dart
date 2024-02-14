import 'package:purchases_dart/src/store_product_interface.dart';

/// required to pass [storeProduct],
/// use [StoreProductInterface] for store product implementation
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
