/// Used when calling [configure] to configure the PurchasesDart plugin
class PurchasesDartConfiguration {
  /// RevenueCat WebBillingAPI Key.
  final String webBillingApiKey;

  /// An optional unique id for identifying the user.
  final String? appUserId;

  PurchasesDartConfiguration({
    required this.webBillingApiKey,
    this.appUserId,
  });
}
