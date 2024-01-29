import 'package:purchases_flutter/models/store_product_wrapper.dart';
import 'package:purchases_flutter/models/store_transaction.dart';

abstract class StoreProductInterface {
  Future<StoreProduct?> getStoreProducts(String productId);

  Future<List<StoreTransaction>> queryAllPurchases(String userId);
}
