import 'package:purchases_dart_stripe/purchases_dart_stripe.dart';

/// [StripeBackendInterface] is the interface that should be implemented to use stripe as a backend.
/// This interface is used by [StripeStoreProduct] to make api calls to stripe.
abstract class StripeBackendInterface {
  Future<Map<String, dynamic>?> buildCheckoutSession(Map<String, dynamic> data);

  Future<StripeProduct?> getStripeProduct(String productId);

  Future<StripePrice?> getStripePrice(String priceId);

  Future<StripeCustomer?> searchStripeCustomer(Map<String, dynamic> data);

  Future<StripeCustomer?> createStripeCustomer(Map<String, dynamic> data);

  Future<String?> getBillingSession(String userId, {String? returnUrl}) {
    throw UnimplementedError();
  }

  Future<void> expireCheckoutSession(String sessionId) {
    throw UnimplementedError();
  }
}
