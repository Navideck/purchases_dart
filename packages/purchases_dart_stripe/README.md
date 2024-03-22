## Purchases Dart Stripe

Stripe store for `purchases_dart` plugin

## Get Started

Use with [purchases_dart]() plugin

Create a Stripe store product interface first

```dart
StoreProductInterface storeProduct = StripeStoreProduct(
  stripeApi: 'STRIPE_API_KEY',
  // Build checkout session for stripe, this will be called on using [PurchasesDart.purchasePackage] api, to build checkout url of that stripe product
  // return map or [StripeCheckoutUrlBuilder.build()], available params: https://docs.stripe.com/api/checkout/sessions/object
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
  // Launch stripe checkout url in browser or in webView, this will be called after generating url using params from `checkoutSessionsBuilder`
  onCheckoutUrlGenerated: (Package package, String sessionId, String url) {
     launchUrlString(url),
  },
  // Optionally set customer builder, this will be called whenever a new appUserID from RevenueCat will be used on Stripe,
  // Stripe will create a new customer for that appUserID, so use this callback to add more parameters to that new customer
  // return a map, available params: https://docs.stripe.com/api/customers/create
  stripeNewCustomerBuilder: (userId) async {
    return StripeCustomerBuilder(
        email: 'user@gmail.com',
    ).build();
   },
);
```

Use this interface to configure PurchasesDart

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

Uses Stripe apis to create new customers, and to identify customer, uses metadata to store the appUserId from RevenueCat in stripe
so we can query these users on stripe using, `"query": 'metadata["uid"]:"APP_USER_ID"'` on stripe, this appUserId is source of truth between RevenueCat and Stripe
and use this same appUserId on mobile or other platforms
