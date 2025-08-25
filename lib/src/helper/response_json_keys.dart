class CustomerInfoResponseJsonKeys {
  static const String requestDate = 'request_date';
  static const String requestDateMs = 'request_date_ms';
  static const String subscriber = 'subscriber';
  static const String originalAppUserId = 'original_app_user_id';
  static const String originalApplicationVersion =
      'original_application_version';
  static const String entitlements = 'entitlements';
  static const String firstScreen = 'first_seen';
  static const String originalPurchaseDate = 'original_purchase_date';
  static const String nonSubscriptions = 'non_subscriptions';
  static const String subscriptions = 'subscriptions';
  static const String managementUrl = 'management_url';
  static const String purchaseDate = 'purchase_date';
}

class EntitlementsResponseJsonKeys {
  static const String expiresDate = 'expires_date';
  static const String productIdentifier = 'product_identifier';
  static const String productPlanIdentifier = 'product_plan_identifier';
  static const String purchaseDate = 'purchase_date';
}

class ProductResponseJsonKeys {
  static const String billingIssuesDetectedAt = 'billing_issues_detected_at';
  static const String isSandbox = 'is_sandbox';
  static const String originalPurchaseDate = 'original_purchase_date';
  static const String purchaseDate = 'purchase_date';
  static const String productPlanIdentifier = 'product_plan_identifier';
  static const String store = 'store';
  static const String unsubscribeDetectedAt = 'unsubscribe_detected_at';
  static const String expiresDate = 'expires_date';
  static const String periodType = 'period_type';
  static const String ownershipType = 'ownership_type';
}
