import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:purchases_dart/purchases_dart.dart';
import 'package:purchases_dart/src/networking/purchases_backend.dart';
import 'package:purchases_dart/src/parser/customer_parser.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

typedef CustomerInfoUpdateListener = void Function(CustomerInfo customerInfo);

class PurchasesDart {
  static PurchasesBackend? _backend;
  static final Set<CustomerInfoUpdateListener> _customerInfoUpdateListeners =
      {};
  static CustomerInfo? _lastReceivedCustomerInfo;
  static late StoreProductInterface _storeProduct;
  static final CustomerParser _customerParser = CustomerParser();

  /// Required to set [appUserId] before using any other methods
  static String? appUserId;

  /// Set cache options for requests,
  /// see https://pub.dev/packages/dio_cache_interceptor#cache-options
  /// make sure to set this before calling [setup]
  static CacheOptions? cacheOptions;

  /// call [configure] before calling any other methods
  static Future<void> configure(
    PurchasesDartConfiguration configuration,
  ) async {
    if (_backend != null) {
      throw Exception("PurchasesDart already configured");
    }
    _backend = PurchasesBackend(
      apiKey: configuration.apiKey,
      storeProduct: configuration.storeProduct,
    );
    _storeProduct = configuration.storeProduct;
    if (configuration.appUserId != null) appUserId = configuration.appUserId;
    cacheOptions = configuration.cacheOptions;
    _storeProduct.setCustomerInfoUpdateListener((customerInfo) {
      _updateCustomerInfoListeners(customerInfo);
    });
  }

  /// called from [StoreProductInterface]
  static void addCustomerInfoUpdateListener(
    CustomerInfoUpdateListener customerInfoUpdateListener,
  ) {
    _customerInfoUpdateListeners.add(customerInfoUpdateListener);
    final lastReceivedCustomerInfo = _lastReceivedCustomerInfo;
    if (lastReceivedCustomerInfo != null) {
      customerInfoUpdateListener(lastReceivedCustomerInfo);
    }
  }

  static void removeCustomerInfoUpdateListener(
    CustomerInfoUpdateListener customerInfoUpdateListener,
  ) =>
      _customerInfoUpdateListeners.remove(customerInfoUpdateListener);

  static Future<CustomerInfo?> getCustomerInfo([String? userId]) async {
    _validateConfig(userId);
    return await _backend?.getCustomerInfo(userId ?? appUserId!);
  }

  static Future<Offerings?> getOfferings([String? userId]) async {
    _validateConfig(userId);
    return await _backend?.getOfferings(userId ?? appUserId!);
  }

  static Future<void> syncPurchases([String? userId]) async {
    _validateConfig(userId);
    return await _backend?.syncPurchases(userId ?? appUserId!);
  }

  static Future purchasePackage(Package packageToPurchase,
      [String? userId]) async {
    _validateConfig(userId);
    return await _storeProduct.purchasePackage(
      packageToPurchase,
      userId ?? appUserId!,
    );
  }

  static CustomerInfo? createCustomer(Map<String, dynamic> json) =>
      _customerParser.createCustomer(RawCustomer.fromJson(json));

  static void _updateCustomerInfoListeners(CustomerInfo customerInfo) async {
    _lastReceivedCustomerInfo = customerInfo;
    for (final listener in _customerInfoUpdateListeners) {
      listener(customerInfo);
    }
  }

  static _validateConfig([String? userId]) {
    if (_backend == null) {
      throw Exception(
          "PurchasesDart.setup() must be called before calling any other methods");
    }
    if (userId == null && appUserId == null) {
      throw Exception(
        "Either set PurchasesDart.appUserId or pass userId to method",
      );
    }
  }
}
