# Purchases Dart Stripe

This is a Stripe store implementation for the `purchases_dart` plugin, enabling seamless integration of Stripe's payment processing capabilities with your Dart applications.

## Getting Started

To use this with the `purchases_dart` plugin, start by creating a Stripe store product interface:

```dart
StoreProductInterface storeProduct = StripeStoreProduct(
  stripeApi: 'STRIPE_API_KEY',
  // Build a checkout session for Stripe. This is called when using the [PurchasesDart.purchasePackage] API to build the checkout URL for a Stripe product.
  // Returns a map or [StripeCheckoutUrlBuilder.build()], with available params detailed at: https://docs.stripe.com/api/checkout/sessions/object
  checkoutSessionsBuilder: (Package package, String stripePriceId) async {
    return StripeCheckoutUrlBuilder(
      successUrl: 'https://example.com/success',
      cancelUrl: 'https://example.com/cancel',
      mode: package.packageType == PackageType.lifetime
          ? StripePaymentMode.payment
          : StripePaymentMode.subscription,
      lineItems: [
        StripeCheckoutLineItem(
          priceId: stripePriceId,
          quantity: 1,
        ),
      ],
    ).build();
  },
  // Launch the Stripe checkout URL in a browser or webView. This is called after generating the URL using params from `checkoutSessionsBuilder`.
  onCheckoutUrlGenerated: (Package package, String sessionId, String url) {
     launchUrlString(url),
  },
  // Optionally, set a customer builder. This is called whenever a new appUserID from RevenueCat is used on Stripe.
  // Stripe will create a new customer for that appUserID. Use this callback to add more parameters to the new customer.
  // Returns a map, with available params at: https://docs.stripe.com/api/customers/create
  stripeNewCustomerBuilder: (userId) async {
    return StripeCustomerBuilder(
        email: 'user@gmail.com',
    ).build();
   },
);
```

Configure `PurchasesDart` with this interface:

```dart
await PurchasesDart.configure(
  PurchasesDartConfiguration(
    apiKey: env.revenueCatApiKey,
    appUserId: userId,
    storeProduct: storeProduct,
  ),
);
```

## Note

This implementation uses Stripe APIs to create new customers and identifies them using metadata to store the `appUserId` from RevenueCat in Stripe. This allows querying these users on Stripe with `"query": 'metadata["uid"]:"APP_USER_ID"'`. The `appUserId` serves as the source of truth between RevenueCat and Stripe, ensuring consistent user identification across mobile and other platforms.