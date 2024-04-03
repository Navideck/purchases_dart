import 'dart:developer';

import 'package:purchases_dart_stripe/src/api_client/api_client.dart';
import 'package:purchases_dart_stripe/src/backend/stripe_interface.dart';
import 'package:purchases_dart_stripe/src/models/stripe_customer.dart';
import 'package:purchases_dart_stripe/src/models/stripe_price.dart';
import 'package:purchases_dart_stripe/src/models/stripe_product.dart';

/// [StripeDefaultBackend] is the default implementation of [StripeBackendInterface].
/// This implementation uses [ApiClient] to make api calls to stripe on client side.
/// This should not be used in production, instead use a server side api client.
class StripeDefaultBackend implements StripeBackendInterface {
  final ApiClient _httpClient;
  final String _baseUrl = 'https://api.stripe.com/v1';
  StripeDefaultBackend(this._httpClient);

  @override
  Future<Map<String, dynamic>?> buildCheckoutSession(
    Map<String, dynamic> data,
  ) async {
    return await _httpClient.post(
      '$_baseUrl/checkout/sessions',
      data: data,
    );
  }

  @override
  Future<StripePrice?> getStripePrice(String priceId) async {
    final priceResponse = await _httpClient.get('$_baseUrl/prices/$priceId');
    if (priceResponse == null) return null;
    return StripePrice.fromJson(priceResponse);
  }

  @override
  Future<StripeProduct?> getStripeProduct(String productId) async {
    final productResponse = await _httpClient.get(
      '$_baseUrl/products/$productId',
    );
    if (productResponse == null) return null;
    return StripeProduct.fromJson(productResponse);
  }

  @override
  Future<StripeCustomer?> searchStripeCustomer(
    Map<String, dynamic> data,
  ) async {
    final customers = await _httpClient.get(
      '$_baseUrl/customers/search',
      data: data,
    );
    var customersData = customers?['data'];
    if (customersData == null || customersData is! List) return null;
    if (customersData.isEmpty) return null;
    if (customersData.length > 1) {
      log('Multiple customers found for $data');
    }
    return StripeCustomer.fromJson(customersData.first);
  }

  @override
  Future<StripeCustomer?> createStripeCustomer(
    Map<String, dynamic> data,
  ) async {
    final response = await _httpClient.post(
      '$_baseUrl/customers',
      data: data,
    );
    if (response == null) return null;
    return StripeCustomer.fromJson(response);
  }

  @override
  Future<void> expireCheckoutSession(String sessionId) async {
    await _httpClient.post(
      '$_baseUrl/checkout/sessions/$sessionId/expire',
    );
  }

  @override
  Future<String?> getBillingSession(
    String customerId, {
    String? returnUrl,
  }) async {
    final response = await _httpClient.post(
      '$_baseUrl/billing_portal/sessions',
      data: {
        "customer": customerId,
        "return_url": returnUrl,
      },
    );
    return response?['url'];
  }
}
