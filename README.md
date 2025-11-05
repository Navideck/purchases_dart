# PurchasesDart

`PurchasesDart` is a Dart implementation of the [purchases_flutter](https://pub.dev/packages/purchases_flutter) plugin, designed to facilitate in-app purchases and subscriptions with `Web Billing`. The `purchases_dart` package follows closely the native APIs from `purchases_flutter`.

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

#### Step 1: Configure WebBillingUrl in RevenueCat Dashboard

Before making purchases, you must configure WebBillingUrl for each offering in the RevenueCat dashboard:

1. Navigate to the **Web** section of your RevenueCat dashboard
2. For each offering, select **+ Create web purchase link** to generate the WebBillingUrl

**Optional: Configure deep linking for post-purchase redirect**

To redirect users back to your app after a successful purchase:

1. In the WebBillingUrl configuration, go to the **Success** section
2. Choose **Redirect to a custom success page**
3. Set a URL that can open your app using a deep link
4. Configure deep link handling in your app using [app_links](https://pub.dev/packages/app_links)

#### Step 2: Get and launch the WebBillingUrl

Retrieve the WebBillingUrl for a package and launch it in the user's browser:

```dart
Uri? webBillingUrl = await PurchasesDart.getWebBillingUrl(
  package,
  email: userEmail, // Optional: pre-fill the user's email
);
```

launch the `webBillingUrl` in browser using [url_launcher](https://pub.dev/packages/url_launcher)

## Important Notes

It is crucial to use a consistent `appUserId` with `PurchasesDart`. Using `AnonymousUserId` is not recommended because there is currently no way to restore the purchases of an anonymous user if the application is uninstalled.
