import 'package:purchases_dart/src/helper/cache_manager.dart';
import 'package:purchases_dart/src/helper/identity_manager.dart';
import 'package:purchases_dart/src/helper/logger.dart';
import 'package:purchases_dart/src/model/raw_customer.dart';
import 'package:purchases_dart/src/networking/purchases_backend.dart';
import 'package:purchases_dart/src/parser/customer_parser.dart';
import 'package:purchases_dart/src/purchases_dart_configuration.dart';
import 'package:purchases_dart/src/store_product_interface.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class PurchasesDart {
  static PurchasesBackend? _backend;
  static CustomerInfo? _lastReceivedCustomerInfo;
  static final CustomerParser _customerParser = CustomerParser();
  static final Set _customerInfoUpdateListeners = {};

  static late StoreProductInterface _storeProduct;
  static late CacheManager _cacheManager;
  static late IdentityManager _identityManager;

  /// Get the current app user id
  static String? get appUserId => _identityManager.currentAppUserID;

  /// call [configure] before calling any other methods
  static Future<void> configure(
    PurchasesDartConfiguration configuration,
  ) async {
    if (_backend != null) {
      throw Exception("PurchasesDart already configured");
    }
    _cacheManager = await CacheManager.instance;
    _backend = PurchasesBackend(
      apiKey: configuration.apiKey,
      storeProduct: configuration.storeProduct,
    );
    _identityManager = IdentityManager(
      _cacheManager,
      _backend!,
    );
    _storeProduct = configuration.storeProduct;
    _storeProduct.onCustomerInfoUpdate = _updateCustomerInfoListeners;
    _identityManager.configure(configuration.appUserId);
  }

  static void setLogLevel(LogLevel level) => Logger.logLevel = level;

  static void setLogHandler(LogHandler logHandler) =>
      Logger.logHandler = logHandler;

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
  ) {
    _customerInfoUpdateListeners.remove(customerInfoUpdateListener);
  }

  static Future<CustomerInfo?> getCustomerInfo() async {
    _validateConfig();
    return await _backend?.getCustomerInfo(appUserId!);
  }

  static Future<Offerings?> getOfferings() async {
    _validateConfig();
    return await _backend?.getOfferings(appUserId!);
  }

  static Future<LogInResult> login(String newAppUserID) async {
    _validateConfig(newAppUserID);
    return _identityManager.logIn(newAppUserID);
  }

  static Future<void> logout() => _identityManager.logOut();

  static Future purchasePackage(Package packageToPurchase) async {
    _validateConfig();
    return await _storeProduct.purchasePackage(
      packageToPurchase,
      appUserId!,
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
      throw Exception("Failed to get userId");
    }
  }
}
