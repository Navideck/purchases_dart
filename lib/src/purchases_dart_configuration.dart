/// Configuration object used when calling [PurchasesDart.configure] to configure the PurchasesDart plugin.
///
/// This class contains the necessary parameters to initialize the PurchasesDart SDK,
/// including the Web Billing API key and an optional app user ID.
class PurchasesDartConfiguration {
  /// RevenueCat Web Billing API Key.
  ///
  /// This key is required to authenticate with RevenueCat's backend services.
  /// You can obtain this key from your RevenueCat dashboard.
  final String webBillingApiKey;

  /// An optional unique identifier for identifying the user.
  ///
  /// If provided, this ID will be used to associate purchases with a specific user.
  /// If not provided, an anonymous ID will be generated and stored locally.
  /// It's recommended to provide a persistent user ID to enable purchase restoration
  /// after app reinstallation.
  final String? appUserId;

  /// Creates a [PurchasesDartConfiguration] with the given parameters.
  ///
  /// [webBillingApiKey] The RevenueCat Web Billing API key (required).
  /// [appUserId] An optional unique identifier for the user.
  PurchasesDartConfiguration({
    required this.webBillingApiKey,
    this.appUserId,
  });
}
