import 'package:dio/dio.dart';
import 'package:purchases_dart/src/helper/log_helper.dart';
import 'package:purchases_dart/src/model/stripe_customer.dart';
import 'package:purchases_dart/src/networking/api_service.dart';
import 'package:purchases_dart/src/model/stripe_currency.dart';
import 'package:purchases_dart/src/model/stripe_price.dart';
import 'package:purchases_dart/src/model/stripe_product.dart';
import 'package:purchases_dart/src/store/store_product_interface.dart';
import 'package:purchases_flutter/models/package_wrapper.dart';
import 'package:purchases_flutter/models/store_product_wrapper.dart';
import 'package:purchases_flutter/models/store_transaction.dart';

typedef CheckoutSessionsBuilder = Future<Map<String, dynamic>> Function(
  String stripePriceId,
  Package package,
);

class StripeStoreProduct extends StoreProductInterface {
  late Dio _httpClient;
  StripeCurrencyFormatter? currencyFormatter;
  final Map<String, StripeCustomer> _stripeCustomers = {};
  CheckoutSessionsBuilder? checkoutSessionsBuilder;
  Function(String url)? onCheckoutUrlGenerated;

  StripeStoreProduct({
    required String stripeApi,
    this.checkoutSessionsBuilder,
    this.currencyFormatter,
    this.onCheckoutUrlGenerated,
  }) {
    _httpClient = ApiService.getStripeHttpClient(stripeApi);
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
    logSuccess(subscriptionData);
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
    if (url == null) {
      throw Exception('Failed to generate checkout url');
    }
    onCheckoutUrlGenerated?.call(url);
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
    if (_stripeCustomers.containsKey(userId)) {
      return _stripeCustomers[userId];
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
      logInfo('Creating new StripeCustomer for $userId');
      stripeCustomer = await _createStripeCustomer(userId);
    } else {
      if (customersData.length > 1) {
        logError('Multiple customers found for $userId');
      }
      stripeCustomer = StripeCustomer.fromJson(customersData.first);
    }
    _stripeCustomers[userId] = stripeCustomer;
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
