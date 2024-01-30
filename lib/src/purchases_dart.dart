import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:purchases_dart/src/networking/purchases_backend.dart';
import 'package:purchases_dart/src/store/store_product_interface.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class PurchasesDart {
  static PurchasesBackend? _backend;
  static final Set<CustomerInfoUpdateListener> _customerInfoUpdateListeners =
      {};
  static CustomerInfo? _lastReceivedCustomerInfo;
  static late StoreProductInterface _storeProduct;

  /// Set cache options for requests,
  /// see https://pub.dev/packages/dio_cache_interceptor#cache-options
  /// make sure to set this before calling [setup]
  static CacheOptions? cacheOptions;

  /// call [setup] before calling any other methods
  /// required to pass [storeProduct],
  /// use [StripeStoreProduct] for Stripe integrations
  static Future<void> setup({
    required String apiKey,
    required StoreProductInterface storeProduct,
  }) async {
    if (_backend != null) {
      throw Exception("PurchasesDart.setup() can only be called once");
    }
    _backend = PurchasesBackend(
      apiKey: apiKey,
      storeProduct: storeProduct,
    );
    _storeProduct = storeProduct;
  }

  /// Not implemented yet
  void addCustomerInfoUpdateListener(
    CustomerInfoUpdateListener customerInfoUpdateListener,
  ) {
    _customerInfoUpdateListeners.add(customerInfoUpdateListener);
    final lastReceivedCustomerInfo = _lastReceivedCustomerInfo;
    if (lastReceivedCustomerInfo != null) {
      customerInfoUpdateListener(lastReceivedCustomerInfo);
    }
  }

  /// Not implemented yet
  void removeCustomerInfoUpdateListener(
    CustomerInfoUpdateListener customerInfoUpdateListener,
  ) =>
      _customerInfoUpdateListeners.remove(customerInfoUpdateListener);

  static Future<CustomerInfo?> getCustomerInfo(String userId) async {
    _validateSetup();
    return await _backend?.getCustomerInfo(userId);
  }

  static Future<Offerings?> getOfferings(String userId) async {
    _validateSetup();
    return await _backend?.getOfferings(userId);
  }

  static Future<void> syncPurchases(String userId) async {
    _validateSetup();
    return await _backend?.syncPurchases(userId);
  }

  static Future purchasePackage(
    Package packageToPurchase,
    String userId,
  ) async {
    _validateSetup();
    return await _storeProduct.purchasePackage(packageToPurchase, userId);
  }

  /// TODO: implement this
  void _updateCustomerInfoListeners(CustomerInfo customerInfo) async {
    _lastReceivedCustomerInfo = customerInfo;
    for (final listener in _customerInfoUpdateListeners) {
      listener(customerInfo);
    }
  }

  static _validateSetup() {
    if (_backend == null) {
      throw Exception(
          "PurchasesDart.setup() must be called before calling any other methods");
    }
  }
}
