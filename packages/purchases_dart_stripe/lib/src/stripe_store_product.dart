import 'dart:developer';

import 'package:purchases_dart/purchases_dart.dart';
import 'package:purchases_dart_stripe/src/api_client/api_client.dart';
import 'package:purchases_dart_stripe/src/api_client/dio_api_client.dart';
import 'package:purchases_dart_stripe/src/backend/stripe_interface.dart';
import 'package:purchases_dart_stripe/src/models/stripe_currency.dart';
import 'package:purchases_dart_stripe/src/models/stripe_customer.dart';
import 'package:purchases_dart_stripe/src/models/stripe_price.dart';
import 'package:purchases_dart_stripe/src/models/stripe_product.dart';
import 'package:purchases_dart_stripe/src/backend/stripe_default_backend.dart';
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
/// Either pass a `stripeApiKey` or use your own `httpClient` to implement proxy or other operations
class StripeStoreProduct extends StoreProductInterface {
  final List<_StripeCustomerCache> _stripeCustomers = [];
  CheckoutSessionsBuilder? checkoutSessionsBuilder;
  CheckoutUrlGenerated? onCheckoutUrlGenerated;
  StripeCurrencyFormatter? currencyFormatter;
  StripeNewCustomerBuilder? stripeNewCustomerBuilder;
  late StripeBackendInterface _stripe;

  StripeStoreProduct({
    String? stripeApiKey,
    this.checkoutSessionsBuilder,
    this.onCheckoutUrlGenerated,
    this.currencyFormatter,
    this.stripeNewCustomerBuilder,
    ApiClient? apiClient,
    StripeBackendInterface? stripeBackendInterface,
  }) {
    if (stripeBackendInterface != null) {
      _stripe = stripeBackendInterface;
      log("StripeStoreProduct: Using custom Stripe backend");
    } else if (apiClient != null) {
      _stripe = StripeDefaultBackend(apiClient);
      log("StripeStoreProduct: Using custom httpClient");
    } else if (stripeApiKey != null) {
      _stripe = StripeDefaultBackend(
        DioApiClient(stripeApiKey),
      );
      log("StripeStoreProduct: Using default Stripe backend");
    } else {
      throw "Either httpClient or stripeApiKey must be passed";
    }
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
  Future purchasePackage(
    Package packageToPurchase,
    String userId,
  ) async {
    CheckoutSessionsBuilder? checkoutSessionsBuilder =
        this.checkoutSessionsBuilder;
    if (checkoutSessionsBuilder == null) {
      throw Exception('checkoutSessionsBuilder is null');
    }
    String? priceId = packageToPurchase
        .storeProduct.presentedOfferingContext?.offeringIdentifier;
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
    final checkoutSessionResponse = await _stripe.buildCheckoutSession(data);
    String? url = checkoutSessionResponse?['url'];
    String? sessionId = checkoutSessionResponse?['id'];
    if (url == null || sessionId == null) {
      throw Exception('Failed to generate checkout url');
    }
    onCheckoutUrlGenerated?.call(packageToPurchase, sessionId, url);
  }

  @override
  Future<List<StoreTransaction>> queryAllPurchases(String userId) async {
    throw UnimplementedError();
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
    return _stripe.getBillingSession(
      stripeCustomer.id!,
      returnUrl: returnUrl,
    );
  }

  /// Expire checkout session
  Future<void> expireCheckoutSession(String sessionId) async {
    await _stripe.expireCheckoutSession(sessionId);
  }

  /// Helpers
  ///
  /// Get StripeProduct from Stripe API
  Future<StripeProduct?> _getStripeProduct(String productId) =>
      _stripe.getStripeProduct(productId);

  /// Get StripePrice from Stripe API
  Future<StripePrice?> _getStripePrice(String priceId) =>
      _stripe.getStripePrice(priceId);

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
    StripeCustomer? stripeCustomer = await _stripe.searchStripeCustomer({
      "query": 'metadata["uid"]:"$userId"',
    });
    stripeCustomer ??= await _createStripeCustomer(userId);
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
    log('Creating new Stripe customer for $userId : $data');
    StripeCustomer? customer = await _stripe.createStripeCustomer(data);
    if (customer == null) {
      throw Exception('Failed to create Stripe customer for $userId');
    }
    return customer;
  }
}

/// Newly created customer on Stripe takes time sometimes to update on APi's
/// use cache for 1 minute to avoid creating multiple customers
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
