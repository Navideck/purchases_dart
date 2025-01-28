import 'package:purchases_dart/src/helper/response_json_keys.dart';

class RawCustomer {
  RawCustomer({
    required this.requestDate,
    required this.entitlements,
    required this.firstSeen,
    required this.lastSeen,
    required this.managementUrl,
    required this.nonSubscriptions,
    required this.nonSubscriptionsLatestPurchases,
    required this.originalAppUserId,
    required this.originalApplicationVersion,
    required this.originalPurchaseDate,
    required this.otherPurchases,
    required this.subscriptions,
  });

  final String requestDate;
  final List<RawEntitlementObject>? entitlements;
  final DateTime? firstSeen;
  final DateTime? lastSeen;
  final List<RawSubscriptionObject>? nonSubscriptions;
  final List<RawSubscriptionObject>? nonSubscriptionsLatestPurchases;
  final String? originalAppUserId;
  final List<RawSubscriptionObject>? otherPurchases;
  final List<RawSubscriptionObject>? subscriptions;
  final String? managementUrl;
  final dynamic originalApplicationVersion;
  final dynamic originalPurchaseDate;

  factory RawCustomer.fromJson(Map<String, dynamic> rawJson) {
    Map<String, dynamic> json =
        rawJson[CustomerInfoResponseJsonKeys.subscriber];
    return RawCustomer(
      requestDate: rawJson["request_date"] ?? "",
      entitlements: entitlementsFromJson(json["entitlements"]),
      firstSeen: DateTime.tryParse(json["first_seen"] ?? ""),
      lastSeen: DateTime.tryParse(json["last_seen"] ?? ""),
      managementUrl: json["management_url"],
      originalAppUserId: json["original_app_user_id"],
      originalApplicationVersion: json["original_application_version"],
      originalPurchaseDate: json["original_purchase_date"],
      nonSubscriptions: nonSubscriptionsFromJson(json["non_subscriptions"]),
      nonSubscriptionsLatestPurchases:
          nonSubscriptionsFromJson(json["non_subscriptions"], true),
      otherPurchases: subscriptionsFromJson(json["other_purchases"]),
      subscriptions: subscriptionsFromJson(json["subscriptions"]),
    );
  }

  Map<String, dynamic> toJson() => {
        "request_date": requestDate,
        "entitlements": entitlements?.map((e) => e.toJson()),
        "first_seen": firstSeen?.toIso8601String(),
        "last_seen": lastSeen?.toIso8601String(),
        "management_url": managementUrl,
        "non_subscriptions": nonSubscriptions,
        "original_app_user_id": originalAppUserId,
        "original_application_version": originalApplicationVersion,
        "original_purchase_date": originalPurchaseDate,
        "other_purchases": otherPurchases,
        "subscriptions": subscriptions?.map((e) => e.toJson()),
      };
}

List<RawEntitlementObject> entitlementsFromJson(Map<String, dynamic>? json) {
  List<RawEntitlementObject> result = [];
  json?.forEach((key, value) {
    result.add(RawEntitlementObject.fromJson(key, value));
  });
  return result;
}

List<RawSubscriptionObject> subscriptionsFromJson(Map<String, dynamic>? json) {
  List<RawSubscriptionObject> result = [];
  json?.forEach((key, value) {
    result.add(RawSubscriptionObject.fromJson(key, value));
  });
  return result;
}

List<RawSubscriptionObject> nonSubscriptionsFromJson(
  Map<String, dynamic>? json, [
  bool onlyLatestPurchases = false,
]) {
  List<RawSubscriptionObject> result = [];
  json?.forEach((key, value) {
    List<RawSubscriptionObject> values =
        List<RawSubscriptionObject>.from(value.map(
      (e) => RawSubscriptionObject.fromJson(key, e),
    ));
    if (onlyLatestPurchases) {
      result.add(values.last);
    } else {
      result.addAll(values);
    }
  });
  return result;
}

class RawEntitlementObject {
  RawEntitlementObject({
    required this.id,
    required this.expiresDate,
    required this.gracePeriodExpiresDate,
    required this.productIdentifier,
    required this.purchaseDate,
  });
  final String id;
  final DateTime? expiresDate;
  final dynamic gracePeriodExpiresDate;
  final String? productIdentifier;
  final DateTime? purchaseDate;

  factory RawEntitlementObject.fromJson(String id, Map<String, dynamic> json) {
    return RawEntitlementObject(
      id: id,
      expiresDate: DateTime.tryParse(json["expires_date"] ?? ""),
      gracePeriodExpiresDate: json["grace_period_expires_date"],
      productIdentifier: json["product_identifier"],
      purchaseDate: DateTime.tryParse(json["purchase_date"] ?? ""),
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "expires_date": expiresDate?.toIso8601String(),
        "grace_period_expires_date": gracePeriodExpiresDate,
        "product_identifier": productIdentifier,
        "purchase_date": purchaseDate?.toIso8601String(),
      };
}

class RawSubscriptionObject {
  RawSubscriptionObject({
    required this.id,
    required this.identifier,
    required this.autoResumeDate,
    required this.billingIssuesDetectedAt,
    required this.expiresDate,
    required this.gracePeriodExpiresDate,
    required this.isSandbox,
    required this.originalPurchaseDate,
    required this.periodType,
    required this.purchaseDate,
    required this.refundedAt,
    required this.store,
    required this.storeTransactionId,
    required this.unsubscribeDetectedAt,
  });

  final String? id;
  final String identifier;
  final dynamic autoResumeDate;
  final String? billingIssuesDetectedAt;
  final DateTime? expiresDate;
  final dynamic gracePeriodExpiresDate;
  final bool? isSandbox;
  final DateTime? originalPurchaseDate;
  final String? periodType;
  final DateTime? purchaseDate;
  final dynamic refundedAt;
  final String? store;
  final String? storeTransactionId;
  final String? unsubscribeDetectedAt;

  factory RawSubscriptionObject.fromJson(
      String key, Map<String, dynamic> json) {
    return RawSubscriptionObject(
      identifier: key,
      id: json["id"],
      autoResumeDate: json["auto_resume_date"],
      billingIssuesDetectedAt: json["billing_issues_detected_at"],
      expiresDate: DateTime.tryParse(json["expires_date"] ?? ""),
      gracePeriodExpiresDate: json["grace_period_expires_date"],
      isSandbox: json["is_sandbox"],
      originalPurchaseDate:
          DateTime.tryParse(json["original_purchase_date"] ?? ""),
      periodType: json["period_type"],
      purchaseDate: DateTime.tryParse(json["purchase_date"] ?? ""),
      refundedAt: json["refunded_at"],
      store: json["store"],
      storeTransactionId: json["store_transaction_id"],
      unsubscribeDetectedAt: json["unsubscribe_detected_at"],
    );
  }

  Map<String, dynamic> toJson() => {
        "identifier": identifier,
        "auto_resume_date": autoResumeDate,
        "billing_issues_detected_at": billingIssuesDetectedAt,
        "expires_date": expiresDate?.toIso8601String(),
        "grace_period_expires_date": gracePeriodExpiresDate,
        "is_sandbox": isSandbox,
        "original_purchase_date": originalPurchaseDate?.toIso8601String(),
        "period_type": periodType,
        "purchase_date": purchaseDate?.toIso8601String(),
        "refunded_at": refundedAt,
        "store": store,
        "store_transaction_id": storeTransactionId,
        "unsubscribe_detected_at": unsubscribeDetectedAt,
      };
}
