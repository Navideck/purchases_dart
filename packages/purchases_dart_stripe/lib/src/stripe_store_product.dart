import 'package:dio/dio.dart';
import 'package:purchases_dart/purchases_dart.dart';
import 'package:purchases_dart_stripe/src/models/stripe_currency.dart';
import 'package:purchases_dart_stripe/src/models/stripe_customer.dart';
import 'package:purchases_dart_stripe/src/models/stripe_price.dart';
import 'package:purchases_dart_stripe/src/models/stripe_product.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

typedef CheckoutSessionsBuilder = Future<Map<String, dynamic>> Function(
  String stripePriceId,
  Package package,
);

class StripeStoreProduct extends StoreProductInterface {
  late Dio _httpClient;
  StripeCurrencyFormatter? currencyFormatter;
  final List<_StripeCustomerCache> _stripeCustomers = [];
  CheckoutSessionsBuilder? checkoutSessionsBuilder;
  Function(String sessionId, String url)? onCheckoutUrlGenerated;

  StripeStoreProduct({
    required String stripeApi,
    this.checkoutSessionsBuilder,
    this.currencyFormatter,
    this.onCheckoutUrlGenerated,
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
      presentedOfferingIdentifier: stripeProduct.defaultPrice,
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
    return [];
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
      priceId,
      packageToPurchase,
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
    onCheckoutUrlGenerated?.call(sessionId, url);
  }

  /// Update customerInfo listeners from [PurchasesDart]
  void _updateCustomerInfoListeners(CustomerInfo customerInfo) {
    onCustomerInfoUpdate?.call(customerInfo);
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
      if (customersData.length > 1) {}
      stripeCustomer = StripeCustomer.fromJson(customersData.first);
    }
    _stripeCustomers.add(_StripeCustomerCache(userId, stripeCustomer));
    return stripeCustomer;
  }

  /// Create StripeCustomer from Stripe API linked with [userId]
  Future<StripeCustomer> _createStripeCustomer(String userId) async {
    final response = await _httpClient.post('/customers', data: {
      "metadata": {"uid": userId}
    });
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
