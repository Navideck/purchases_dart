# Purchases Dart Stripe

This is a Stripe implementation as a payment gateway for `purchases_dart`, enabling seamless integration of Stripe's payment processing capabilities with your Dart applications while using RevenueCat as the source of truth for unlocked purchases.

## Getting Started

To use this with the [purchases_dart](https://pub.dev/packages/purchases_dart) package, start by creating a StripeStoreProduct interface.

Use Stripe's Secret API Key for testing only. In production, use [apiClient] to proxy requests without exposing your Stripe secret key or implement [StripeBackendInterface] for custom integration.

```dart
// 
StoreProductInterface storeProduct = StripeStoreProduct(
  stripeApiKey: 'STRIPE_API_KEY',
  // Build a checkout session for Stripe. This is called when using the [PurchasesDart.purchasePackage] API to build the checkout URL for a Stripe product.
  // Returns a map or [StripeCheckoutUrlBuilder.build()], with available params detailed at: https://docs.stripe.com/api/checkout/sessions/object
  checkoutSessionsBuilder: (Package package, String stripePriceId) async {
    return StripeCheckoutUrlBuilder(
      successUrl: 'https://example.com/success',
      cancelUrl: 'https://example.com/cancel',
      mode: StripePaymentMode.subscription,
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

You have to setup Stripe webhook listener for payment confirmation to update RevenueCat, check out [RevenueCat's docs](https://www.revenuecat.com/docs/getting-started/stripe#5-send-stripe-tokens-to-revenuecat).

Alternatively, you can utilize our [firebase_function_stripe](https://github.com/Navideck/purchases_dart/tree/add_docs/packages/purchases_dart_stripe/firebase_function_stripe) example. This provides a demonstration of how to configure Stripe and RevenueCat using Firebase Cloud Functions, with minor modifications, this can also be used as a standalone Node.js server.

Create a Stripe Restricted key with these permissions: `Customers`: Write, `Customer session`: Write, `Checkout Sessions`: Write ,`Products`: Read, `Prices`: Read

PurchasesDartStripe uses Stripe APIs to create new customers and identifies them using metadata to store the `appUserId` from RevenueCat in Stripe. This allows querying these users on Stripe with `"query": 'metadata["uid"]:"APP_USER_ID"'`. The `appUserId` serves as the source of truth between RevenueCat and Stripe, ensuring consistent user identification across mobile and other platforms.
