# PurchasesDart

`PurchasesDart` is a pure Dart implementation of the `purchases_flutter` plugin, designed to facilitate in-app purchases and subscriptions. The `purchases_dart` package follows closely the native APIs from `purchases_flutter`. You can use it with all platforms Flutter supports, not just iOS and Android.

`PurchasesDart` is designed to work with different payment gateways (stores) and can be integrated with various store implementations. We provide `purchases_dart_stripe` for out-of-the-box Stripe support. However, `purchases_dart` is not limited to a specific store and can be extended to support any store of your choice.

It requires a `storeProduct` to communicate with the store backend. The `storeProduct` class serves as an interface for communication with different stores. For example, the `StripeStoreProduct` extends the `StoreProductInterface` for communication with the Stripe store backend. Similarly, if you want to build for the Play Store, you would need to create a `StoreProductInterface` implementation specific to the Play Store.

## Getting Started

Before using `PurchasesDart`, you must configure it with `PurchasesDartConfiguration`. This configuration requires an API key, a user ID, and a `storeProduct` instance. Below is an example of how to configure `PurchasesDart`:

```dart
await PurchasesDart.configure(
  PurchasesDartConfiguration(
    apiKey: env.revenueCatApiKey,
    appUserId: userId,
    storeProduct: storeProduct,
  ),
);
```

## Example app

To run the example app, follow these steps:

1. Open the `example` app folder.
2. Rename `example/lib/env.example.dart` to `env.dart`.
3. Configure your RevenueCat and Stripe keys in the `env.dart` file.

That's it! You are now ready to use `purchases_dart` in your Dart projects.

## APIs

`PurchasesDart` provides a range of APIs to manage in-app purchases and subscriptions:

### Configuration and Logging

- **configure**: Initializes the package with the provided configuration.
- **setLogLevel**: Sets the log level for debugging purposes.
- **setLogHandler**: Sets a custom log handler.

### Customer Information

- **getCustomerInfo**: Retrieves information about the customer.
- **addCustomerInfoUpdateListener**: Registers a listener for customer information updates.
- **removeCustomerInfoUpdateListener**: Unregisters a listener for customer information updates.

### Offerings and Purchases

- **getOfferings**: Fetches available offerings for purchase.
- **purchasePackage**: Initiates the purchase of a package.

### User Management

- **login**: Logs in a user with a specific ID.
- **logout**: Logs out the current user.
- **isAnonymous**: Checks if the current user is anonymous.
- **updateAppUserId**: Updates the cached app user ID. Recommended over using `login` or `logout` as it only updates the app user ID locally.

## Important Notes

- It is crucial to use a consistent `appUserId` with `PurchasesDart`. Using `AnonymousUserId` is not recommended because there is currently no way to restore the purchases of an anonymous user if the application is uninstalled.
- The `purchasePackage` API does not return customer information directly. The `StoreInterface` should provide a mechanism to update `customerInfoUpdate` after a purchase.

## Integration with Stripe

For integrating Stripe as the store backend, please refer to the `purchases_dart_stripe` implementation. This additional package provides a `StripeStore` implementation that can be used with `PurchasesDart`.