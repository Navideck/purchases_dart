import 'package:purchases_flutter/purchases_flutter.dart';

/// Interface for communicating with the underlying store.
abstract class StoreProductInterface {
  /// [onCustomerInfoUpdate] subscribed by [PurchasesDart] to get customer info updates from store,
  /// and then notify all listeners, do not set this in store, instead call from store when customer info is updated.
  Function(CustomerInfo customerInfo)? onCustomerInfoUpdate;

  /// Fetches the product information from the store.
  Future<StoreProduct?> getStoreProducts(String productId);

  /// Fetches the transaction information from the store.
  Future<List<StoreTransaction>> queryAllPurchases(String userId);

  /// Processes the purchase of a package.
  Future<void> purchasePackage(Package packageToPurchase, String userId);
}
