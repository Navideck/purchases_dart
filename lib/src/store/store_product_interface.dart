import 'package:purchases_flutter/purchases_flutter.dart';

typedef CheckoutSessionsBuilder = Future<Map<String, dynamic>> Function(
  String stripePriceId,
  Package package,
);

abstract class StoreProductInterface {
  CustomerInfoUpdateListener? _customerInfoUpdateListener;

  Future<StoreProduct?> getStoreProducts(String productId);

  Future<List<StoreTransaction>> queryAllPurchases(String userId);

  Future purchasePackage(
    Package packageToPurchase,
    String userId,
  );

  /// call this method when [CustomerInfo] is updated
  void updateCustomerInfoListeners(CustomerInfo customerInfo) {
    _customerInfoUpdateListener?.call(customerInfo);
  }

  /// This method is called by [PurchasesDart] to set [CustomerInfoUpdateListener]
  /// do not call this method directly
  void setCustomerInfoUpdateListener(
    CustomerInfoUpdateListener listener,
  ) {
    _customerInfoUpdateListener = listener;
  }
}
