# PurchasesDart

`PurchasesDart` is a pure Dart implementation of the [purchases_flutter](https://pub.dev/packages/purchases_flutter) plugin, designed to facilitate in-app purchases and subscriptions. The `purchases_dart` package follows closely the native APIs from `purchases_flutter`. You can use it with all platforms Flutter supports, not just iOS and Android. it is designed to work with different payment gateways (stores) and can be integrated with various store implementations.

## Getting Started

Before using `PurchasesDart`, you must configure it with `PurchasesDartConfiguration`. This configuration requires an API key, a user ID, and a `storeProduct` instance. Below is an example of how to configure `PurchasesDart`:

```dart
await PurchasesDart.configure(
  PurchasesDartConfiguration(
    apiKey: env.revenueCatApiKey,
    appUserId: userId,
    storeProduct: StoreProductInterface,
  ),
);
```

It requires a `storeProduct` to communicate with the store backend. The `storeProduct` class serves as an interface for communication with different stores. For example, the [StripeStoreProduct](https://github.com/Navideck/purchases_dart/blob/add_docs/packages/purchases_dart_stripe/lib/src/stripe_store_product.dart) from [purchases_dart_stripe](https://pub.dev/packages/purchases_dart_stripe) extends the `StoreProductInterface` for communication with the Stripe store backend. Similarly, if you want to build for the Play Store, you would need to create a `StoreProductInterface` implementation specific to the Play Store.

## Integration with Stripe

For integrating Stripe as the store backend, please refer to the [purchases_dart_stripe](https://pub.dev/packages/purchases_dart_stripe) implementation. This additional package provides a `StripeStore` implementation that can be used with `PurchasesDart`.

## Important Notes

It is crucial to use a consistent `appUserId` with `PurchasesDart`. Using `AnonymousUserId` is not recommended because there is currently no way to restore the purchases of an anonymous user if the application is uninstalled.
