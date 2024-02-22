import 'package:purchases_dart/src/model/raw_customer.dart';
import 'package:purchases_dart/src/networking/purchases_backend.dart';
import 'package:purchases_dart/src/parser/customer_parser.dart';
import 'package:purchases_dart/src/purchases_dart_configuration.dart';
import 'package:purchases_dart/src/store_product_interface.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

typedef CustomerInfoUpdateListener = void Function(CustomerInfo customerInfo);

class PurchasesDart {
  static PurchasesBackend? _backend;
  static CustomerInfo? _lastReceivedCustomerInfo;
  static late StoreProductInterface _storeProduct;
  static final CustomerParser _customerParser = CustomerParser();
  static final Set<CustomerInfoUpdateListener> _customerInfoUpdateListeners =
      {};

  /// Required to set [appUserId] before using any other methods
  static String? appUserId;

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
    _storeProduct.onCustomerInfoUpdate = _updateCustomerInfoListeners;
    if (configuration.appUserId != null) appUserId = configuration.appUserId;
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

  // Not Implemented
  // static Future<void> syncPurchases([String? userId]) async {
  //   _validateConfig(userId);
  //   return await _backend?.syncPurchases(userId ?? appUserId!);
  // }

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

  /// Update customerInfo listeners
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
