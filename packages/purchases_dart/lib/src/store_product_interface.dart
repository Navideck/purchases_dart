import 'package:purchases_flutter/purchases_flutter.dart';

abstract class StoreProductInterface {
  /// [onCustomerInfoUpdate] subscribed by [PurchasesDart] to get customer info updates from store
  Function(CustomerInfo customerInfo)? onCustomerInfoUpdate;

  Future<StoreProduct?> getStoreProducts(String productId);

  Future<List<StoreTransaction>> queryAllPurchases(String userId);

  Future purchasePackage(
    Package packageToPurchase,
    String userId,
  );
}
