# PurchasesDart

`PurchasesDart` is a pure Dart implementation of the `purchases_flutter` plugin, designed to facilitate in-app purchases and subscriptions. This plugin requires a `storeProduct` for communication with the store backend. It is platform-independent and can be integrated with various store implementations, such as Stripe, through `purchases_dart_stripe`.

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

## APIs

`PurchasesDart` provides a range of APIs to manage in-app purchases and subscriptions:

### Configuration and Logging

- **configure**: Initializes the plugin with the provided configuration.
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