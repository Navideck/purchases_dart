import 'package:purchases_flutter/purchases_flutter.dart';

abstract class StoreProductInterface {
  Future<StoreProduct?> getStoreProducts(String productId);

  Future<List<StoreTransaction>> queryAllPurchases(String userId);

  Future purchasePackage(
    Package packageToPurchase,
    String userId,
  );
}
