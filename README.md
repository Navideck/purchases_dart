# PurchasesDart

`PurchasesDart` is a Dart implementation of the [purchases_flutter](https://pub.dev/packages/purchases_flutter) plugin, designed to facilitate in-app purchases and subscriptions with Web Billing. The `purchases_dart` package closely follows the native APIs from `purchases_flutter`.

## Usage

### Configure

Before using `PurchasesDart`, you must configure it with a `PurchasesDartConfiguration`. This configuration requires a Web Billing API key and an `appUserId`. 

```dart
await PurchasesDart.configure(
  PurchasesDartConfiguration(
    apiKey: WEB_BILLING_API_KEY,
    appUserId: "MY_USER_ID",
  ),
);
```

`appUserId` is an optional parameter used to identify users of your app. While optional, it is **crucial** to provide a persistent `appUserId` per user if you want to restore purchases after re-installing the app. 

**Why it matters:** Purchase data is stored on RevenueCat's backend and associated with the `appUserId`. If you can provide the same `appUserId` after reinstall, purchases can be restored. If not provided, an anonymous ID is generated and stored locally on the device, which is lost when the app is uninstalled.

**Best practice:** Use an authentication system (e.g., Firebase Authentication) to generate and persist a stable `appUserId` that can be retrieved after app reinstall.

### Get Customer Info

```dart
await PurchasesDart.getCustomerInfo();
```

### Get Offerings

```dart
await PurchasesDart.getOfferings();
```

### Purchase a Package

#### Step 1: Configure Web Purchase Link in RevenueCat Dashboard

Before making purchases, you must configure a Web Purchase Link for each offering in the RevenueCat dashboard:

1. Navigate to your offering in the RevenueCat dashboard
2. Add a **Web Purchase Link** for the offering
3. This will generate a web purchase link URL that you can use in your app

**Optional: Configure Deep Linking for Post-Purchase Redirect**

To redirect users back to your app after a successful purchase:

1. In the Web Purchase Link configuration, go to the **Success** section
2. Choose **Redirect to a custom success page**
3. Set a URL that can open your app using a deep link
4. Configure deep link handling in your app using [app_links](https://pub.dev/packages/app_links)

#### Step 2: Get and Launch the Web Purchase Link

Retrieve the web purchase link for a package and launch it in the user's browser:

```dart
Uri? webBillingUrl = await PurchasesDart.getWebBillingUrl(
  package,
  email: userEmail, // Optional: pre-fill the user's email
);

if (webBillingUrl != null) {
  await launchUrl(webBillingUrl); // Using url_launcher package
}
```

Make sure to import and use the [url_launcher](https://pub.dev/packages/url_launcher) package to launch the URL.
