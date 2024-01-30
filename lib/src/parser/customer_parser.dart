import 'dart:developer';

import 'package:collection/collection.dart';
import 'package:purchases_dart/src/helper/date_helper.dart';
import 'package:purchases_dart/src/helper/enum_parser.dart';
import 'package:purchases_dart/src/model/raw_customer.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

/// Parses a [RawCustomer] into a [CustomerInfo] object.
class CustomerParser {
  Future<CustomerInfo?> createCustomer(
    RawCustomer rawCustomer,
    String requestDate,
  ) async {
    List<RawSubscriptionObject> subscriptions = rawCustomer.subscriptions ?? [];
    List<RawSubscriptionObject> nonSubscriptionsLatestPurchases =
        rawCustomer.nonSubscriptionsLatestPurchases ?? [];
    List<RawSubscriptionObject> allSubscriptions = [
      ...nonSubscriptionsLatestPurchases,
      ...subscriptions
    ];

    List<RawEntitlementObject> rawEntitlements = rawCustomer.entitlements ?? [];

    Map<String, String> allPurchaseDates = {};
    List<String> allPurchasedProductIdentifiers = [];
    List<String> activeSubscriptions = [];
    Map<String, String?> allExpirationDates = {};
    EntitlementInfos entitlements = _createEntitlementInfos(
      entitlements: rawEntitlements,
      subscriptions: allSubscriptions,
      requestDate: requestDate,
    );
    String firstSeen = rawCustomer.firstSeen?.toString() ?? "";
    String originalAppUserId = rawCustomer.originalAppUserId ?? "";
    List<StoreTransaction> nonSubscriptionTransactions = [];

    for (var subscriptionObject in allSubscriptions) {
      allPurchasedProductIdentifiers.add(subscriptionObject.identifier);

      DateTime? purchaseDate = subscriptionObject.purchaseDate;
      if (purchaseDate != null) {
        allPurchaseDates[subscriptionObject.identifier] =
            purchaseDate.toString();
      }

      DateTime? expirationDate = subscriptionObject.expiresDate;
      if (expirationDate != null) {
        allExpirationDates[subscriptionObject.identifier] =
            expirationDate.toString();
      }

      if (_isDateActive(
        subscriptionObject.identifier,
        requestDate,
        subscriptionObject.expiresDate,
      )) {
        activeSubscriptions.add(subscriptionObject.identifier);
      }
    }

    for (var subscriptionObject in nonSubscriptionsLatestPurchases) {
      StoreTransaction? transaction =
          _createStoreTransactions(subscriptionObject);
      if (transaction != null) {
        nonSubscriptionTransactions.add(transaction);
      }
    }

    return CustomerInfo(
      entitlements,
      allPurchaseDates,
      activeSubscriptions,
      allPurchasedProductIdentifiers,
      nonSubscriptionTransactions,
      firstSeen,
      originalAppUserId,
      allExpirationDates,
      requestDate,
      latestExpirationDate: null,
      originalPurchaseDate: rawCustomer.originalPurchaseDate?.toString(),
      originalApplicationVersion:
          rawCustomer.originalApplicationVersion?.toString(),
      managementURL: rawCustomer.managementUrl,
    );
  }

  EntitlementInfos _createEntitlementInfos({
    required List<RawEntitlementObject> entitlements,
    required List<RawSubscriptionObject> subscriptions,
    required String requestDate,
  }) {
    final Map<String, EntitlementInfo> all = {};
    final Map<String, EntitlementInfo> active = {};
    for (RawEntitlementObject entitlement in entitlements) {
      EntitlementInfo? entitlementInfo = _createEntitlementInfo(
        entitlement,
        subscriptions,
        requestDate,
      );
      if (entitlementInfo == null) continue;
      all[entitlement.id] = entitlementInfo;
      if (entitlementInfo.isActive) {
        active[entitlement.id] = entitlementInfo;
      }
    }
    return EntitlementInfos(all, active);
  }

  EntitlementInfo? _createEntitlementInfo(
    RawEntitlementObject entitlement,
    List<RawSubscriptionObject> subscriptions,
    String requestDate,
  ) {
    RawSubscriptionObject? subscriptionObject = subscriptions.firstWhereOrNull(
        (element) => element.identifier == entitlement.productIdentifier);
    if (subscriptionObject == null) return null;
    return EntitlementInfo(
      entitlement.id,
      _isDateActive(
        entitlement.id,
        requestDate,
        subscriptionObject.expiresDate,
      ),
      _getWillRenew(
        subscriptionObject.store,
        subscriptionObject.expiresDate,
        subscriptionObject.unsubscribeDetectedAt,
        subscriptionObject.billingIssuesDetectedAt,
      ),
      entitlement.purchaseDate?.toString() ?? "",
      subscriptionObject.originalPurchaseDate?.toString() ?? "",
      entitlement.productIdentifier ?? "",
      subscriptionObject.isSandbox ?? false,
    );
  }

  bool _getWillRenew(
    String? store,
    DateTime? expirationDate,
    DateTime? unsubscribeDetectedAt,
    DateTime? billingIssueDetectedAt,
  ) {
    var isPromo = store != null && getStore(store) == Store.promotional;
    var isLifetime = expirationDate == null;
    var hasUnsubscribed = unsubscribeDetectedAt != null;
    var hasBillingIssues = billingIssueDetectedAt != null;
    return !(isPromo || isLifetime || hasUnsubscribed || hasBillingIssues);
  }

  bool _isDateActive(
    String identifier,
    String requestDate,
    DateTime? expirationDate,
  ) {
    DateTime requestDateTime = DateTime.parse(requestDate);
    var dateActive = DateHelper.isDateActive(expirationDate, requestDateTime);
    if (!dateActive.isActive && !dateActive.inGracePeriod) {
      log("Entitlement $identifier is no longer active (expired $expirationDate) and it's outside grace period window (last updated $requestDate)");
    }
    return dateActive.isActive;
  }

  StoreTransaction? _createStoreTransactions(
      RawSubscriptionObject subscriptionObject) {
    String? transactionIdentifier = subscriptionObject.storeTransactionId;
    if (transactionIdentifier == null) return null;
    return StoreTransaction.create(
      transactionIdentifier,
      transactionIdentifier,
      subscriptionObject.identifier,
      subscriptionObject.purchaseDate?.toString() ?? "",
    );
  }
}
