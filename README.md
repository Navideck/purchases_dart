# PurchasesDart

`PurchasesDart` is a Dart implementation of the [purchases_flutter](https://pub.dev/packages/purchases_flutter) plugin, designed to facilitate in-app purchases and subscriptions using **Web Billing**. The `purchases_dart` package closely follows the native APIs of `purchases_flutter`.

## Usage

### Configure

Before using `PurchasesDart`, you need to configure it with `PurchasesDartConfiguration`.
This configuration requires a Web Billing API key and a user ID (you can use your auth system to generate a consistent user ID).

```dart
await PurchasesDart.configure(
  PurchasesDartConfiguration(
    apiKey: WEB_BILLING_API_KEY,
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

Make sure the **Web Billing URL** is configured for the package in your **RevenueCat** dashboard.

Then, retrieve the Web Billing URL using:

```dart
await PurchasesDart.getWebBillingUrl(package);
```

Launch the URL in a browser using `url_launcher`.

#### To return to the app:

* Set a success page URL in your Web Billing configuration that can open your app via deep link.
* Use [app_links](https://pub.dev/packages/app_links) to handle deep links in your app.

## Important Notes

It’s crucial to use a **consistent** `appUserId` with `PurchasesDart`.
Using an anonymous user ID is **not recommended**, as there’s currently no way to restore purchases for anonymous users if the app is uninstalled.
