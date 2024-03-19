import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:purchases_dart/purchases_dart.dart';
import 'package:purchases_dart_stripe/src/models/stripe_currency.dart';
import 'package:purchases_dart_stripe/src/models/stripe_customer.dart';
import 'package:purchases_dart_stripe/src/models/stripe_price.dart';
import 'package:purchases_dart_stripe/src/models/stripe_product.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

/// Setup [CheckoutSessionsBuilder] to generate checkout session data for an item or use [StripeCheckoutUrlBuilder] for basic implementation
/// available params: https://docs.stripe.com/api/checkout/sessions/object
///
/// Setup [CheckoutUrlGenerated] to get checkout url after generating checkout session, launch this url in browser to complete the purchase
///
/// Setup [StripeCurrencyFormatter] to format currency as per your requirement, default formatter: [StripeCurrency.defaultCurrencyFormatter]
/// supported currencies: https://docs.stripe.com/currencies
///
/// Setup [StripeNewCustomerBuilder] to add extra data for a new stripe customer
/// available params: https://docs.stripe.com/api/customers/create
///
class StripeStoreProduct extends StoreProductInterface {
  late Dio _httpClient;
  final List<_StripeCustomerCache> _stripeCustomers = [];

  CheckoutSessionsBuilder? checkoutSessionsBuilder;
  CheckoutUrlGenerated? onCheckoutUrlGenerated;
  StripeCurrencyFormatter? currencyFormatter;
  StripeNewCustomerBuilder? stripeNewCustomerBuilder;

  StripeStoreProduct({
    required String stripeApi,
    this.checkoutSessionsBuilder,
    this.onCheckoutUrlGenerated,
    this.currencyFormatter,
    this.stripeNewCustomerBuilder,
  }) {
    _httpClient = Dio(
      BaseOptions(
        baseUrl: 'https://api.stripe.com/v1',
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': 'Bearer $stripeApi'
        },
      ),
    );
    _httpClient.interceptors.add(_ErrorInterceptor());
  }

  @override
  Future<StoreProduct?> getStoreProducts(String productId) async {
    // Fetch product
    StripeProduct? stripeProduct = await _getStripeProduct(productId);
    if (stripeProduct == null) return null;

    // Fetch price
    StripePrice? stripePrice =
        await _getStripePrice(stripeProduct.defaultPrice);
    if (stripePrice == null) return null;

    // Format currency
    StripeCurrency stripeCurrency =
        StripeCurrency.fromStripePrice(stripePrice, currencyFormatter);

    // Return StoreProduct
    return StoreProduct(
      stripeProduct.id,
      stripeProduct.description,
      stripeProduct.name,
      stripeCurrency.amount,
      stripeCurrency.formattedPrice,
      stripeCurrency.currency,
      presentedOfferingContext: PresentedOfferingContext(
        stripeProduct.defaultPrice,
        null,
        null,
      ),
    );
  }

  @override
  Future<List<StoreTransaction>> queryAllPurchases(String userId) async {
    StripeCustomer? stripeCustomer = await _getStripeCustomer(userId);
    if (stripeCustomer == null) return [];
    final subscriptionsResponse =
        await _httpClient.get('/subscriptions?customer=${stripeCustomer.id}');
    var subscriptionsJson = subscriptionsResponse.data;
    if (subscriptionsJson == null) return [];
    var subscriptionData = subscriptionsJson['data'];
    if (subscriptionData == null || subscriptionData is! List) return [];
    // TODO: covert subscriptionData to StoreTransaction
    throw UnimplementedError();
  }

  @override
  Future purchasePackage(
    Package packageToPurchase,
    String userId,
  ) async {
    CheckoutSessionsBuilder? checkoutSessionsBuilder =
        this.checkoutSessionsBuilder;
    if (checkoutSessionsBuilder == null) {
      throw Exception('checkoutSessionsBuilder is null');
    }
    String? priceId =
        packageToPurchase.storeProduct.presentedOfferingIdentifier;
    if (priceId == null) {
      throw Exception('Stripe priceId not found');
    }
    StripeCustomer? stripeCustomer = await _getStripeCustomer(userId);
    if (stripeCustomer == null) {
      throw Exception('StripeCustomer not found for $userId');
    }
    Map<String, dynamic> data = await checkoutSessionsBuilder(
      packageToPurchase,
      priceId,
    );
    data['customer'] = stripeCustomer.id;
    data['client_reference_id'] = userId;
    final checkoutSessionResponse = await _httpClient.post(
      '/checkout/sessions',
      data: data,
    );

    String? url = checkoutSessionResponse.data?['url'];
    String? sessionId = checkoutSessionResponse.data?['id'];
    if (url == null || sessionId == null) {
      throw Exception('Failed to generate checkout url');
    }
    onCheckoutUrlGenerated?.call(packageToPurchase, sessionId, url);
  }

  Future<bool> purchasedPackages(String userId) async {
    StripeCustomer? stripeCustomer = await _getStripeCustomer(userId);
    if (stripeCustomer == null) {
      throw Exception('StripeCustomer not found for $userId');
    }
    final subscriptionsResponse =
        await _httpClient.get('/subscriptions?customer=${stripeCustomer.id}');
    var subscriptionsJson = subscriptionsResponse.data;
    if (subscriptionsJson == null) return false;
    var subscriptionData = subscriptionsJson['data'];
    if (subscriptionData == null || subscriptionData is! List) return false;
    return true;
  }

  /// Update customerInfo listeners from [PurchasesDart]
  void updateCustomerInfoListeners(CustomerInfo customerInfo) {
    onCustomerInfoUpdate?.call(customerInfo);
  }

  /// Get Stripe billing session url, to open billing portal for the user
  Future<String?> getBillingSession(
    String userId, {
    String? returnUrl,
  }) async {
    StripeCustomer? stripeCustomer = await _getStripeCustomer(userId);
    if (stripeCustomer == null) {
      throw Exception('StripeCustomer not found for $userId');
    }
    final response = await _httpClient.post('/billing_portal/sessions', data: {
      "customer": stripeCustomer.id,
      "return_url": returnUrl,
    });
    return response.data['url'];
  }

  /// Expire checkout session
  Future<void> expireCheckoutSession(String sessionId) async {
    await _httpClient.post('/checkout/sessions/$sessionId/expire');
  }

  /// Helpers
  ///
  /// Get StripeProduct from Stripe API
  Future<StripeProduct?> _getStripeProduct(String productId) async {
    final productResponse = await _httpClient.get('/products/$productId');
    var productsJson = productResponse.data;
    if (productsJson == null) return null;
    return StripeProduct.fromJson(productsJson);
  }

  /// Get StripePrice from Stripe API
  Future<StripePrice?> _getStripePrice(String priceId) async {
    final priceResponse = await _httpClient.get('/prices/$priceId');
    var priceJson = priceResponse.data;
    if (priceJson == null) return null;
    return StripePrice.fromJson(priceJson);
  }

  /// Get StripeCustomer from Stripe API linked with [userId]
  Future<StripeCustomer?> _getStripeCustomer(String userId) async {
    _StripeCustomerCache? cacheCustomer = _stripeCustomers
        .firstWhereOrNull((element) => element.userId == userId);
    if (cacheCustomer != null && !cacheCustomer.isExpired()) {
      return cacheCustomer.stripeCustomer;
    }
    if (cacheCustomer?.isExpired() == true) {
      _stripeCustomers.remove(cacheCustomer);
    }

    final customers = await _httpClient.get(
      '/customers/search',
      data: {
        "query": 'metadata["uid"]:"$userId"',
      },
    );

    var customersData = customers.data?['data'];
    if (customersData == null || customersData is! List) return null;
    StripeCustomer stripeCustomer;
    if (customersData.isEmpty) {
      stripeCustomer = await _createStripeCustomer(userId);
    } else {
      if (customersData.length > 1) {
        log('Multiple customers found for $userId');
      }
      stripeCustomer = StripeCustomer.fromJson(customersData.first);
    }
    _stripeCustomers.add(_StripeCustomerCache(userId, stripeCustomer));
    return stripeCustomer;
  }

  /// Create StripeCustomer from Stripe API linked with [userId]
  Future<StripeCustomer> _createStripeCustomer(String userId) async {
    Map<String, dynamic> data = {
      "metadata": {"uid": userId},
    };
    var customerExtraData = await stripeNewCustomerBuilder?.call(userId);
    customerExtraData?.forEach((key, value) {
      if (value != null) data[key] = value;
    });
    log('Creating new stripe customer for $userId : $data');
    final response = await _httpClient.post('/customers', data: data);
    return StripeCustomer.fromJson(response.data);
  }
}

class _StripeCustomerCache {
  String userId;
  StripeCustomer? stripeCustomer;
  late DateTime createdAt;
  _StripeCustomerCache(this.userId, this.stripeCustomer) {
    createdAt = DateTime.now();
  }

  // Expire cache after 1 minute
  bool isExpired() {
    return DateTime.now().difference(createdAt).inMinutes > 1;
  }
}

extension IterableExtension<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T element) test) {
    for (var element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}

/// Custom types
typedef CheckoutSessionsBuilder = Future<Map<String, dynamic>> Function(
  Package package,
  String stripePriceId,
);

typedef StripeNewCustomerBuilder = Future<Map<String, dynamic>> Function(
  String userId,
);

typedef CheckoutUrlGenerated = Function(
  Package package,
  String sessionId,
  String url,
);

typedef StripeCurrencyFormatter = StripeCurrency Function(
  int amount,
  String currency,
);

class _ErrorInterceptor extends Interceptor {
  _ErrorInterceptor();

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
        throw "Connection Timeout";
      case DioExceptionType.sendTimeout:
        throw "Send Timeout";
      case DioExceptionType.receiveTimeout:
        throw "Receive Timeout";
      case DioExceptionType.badResponse:
        var responseData = err.response?.data;
        if (responseData != null) {
          throw Exception(responseData.toString());
        } else if (err.message != null) {
          throw Exception(err.message);
        }
        throw Exception("Bad Response");
      case DioExceptionType.cancel:
        break;
      case DioExceptionType.unknown:
      default:
        if (err.error.toString().contains('SocketException')) {
          throw "Please check your internet connection";
        } else if (err.error.toString().contains('CERTIFICATE_VERIFY_FAILED')) {
          throw "Certificate verification failed";
        } else {
          throw Exception(err.error);
        }
    }
    if (err.type == DioExceptionType.cancel) {
      return;
    }
    return handler.next(err);
  }
}
