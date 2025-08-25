# PurchasesDart

`PurchasesDart` is a dart implementation of the [purchases_flutter](https://pub.dev/packages/purchases_flutter) plugin, designed to facilitate in-app purchases and subscriptions with `WebBilling`. The `purchases_dart` package follows closely the native APIs from `purchases_flutter`.

## Usage

### Configure

Before using `PurchasesDart`, you must configure it with `PurchasesDartConfiguration`. This configuration requires a WebBilling API key and a userId ( maybe use an auth system to get a consistent userId )

```dart
await PurchasesDart.configure(
  PurchasesDartConfiguration(
    apiKey: WEb_BILLING_API_KEY,
    appUserId: userId,
  ),
);
```

### Get customer info

```dart
await PurchasesDart.getCustomerInfo();
```

### Get offerings

```dart
await PurchasesDart.getOfferings();
```

### Purchase package

Make sure the WebBillingUrl is configured for the package in Revenuecat dashboard

then get the WebBillingUrl using

```dart
await PurchasesDart.getWebBillingUrl(package);
```

launch the url in browser using `url_launcher`

To get back to the app:

set a success page url to this `WebBillingUrl` config, which can open your app using deep link

use [app_links](https://pub.dev/packages/app_links) to configure deep link in your app

## Important Notes

It is crucial to use a consistent `appUserId` with `PurchasesDart`. Using `AnonymousUserId` is not recommended because there is currently no way to restore the purchases of an anonymous user if the application is uninstalled.
