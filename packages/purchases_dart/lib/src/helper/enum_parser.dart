import 'dart:convert';

import 'package:purchases_flutter/models/entitlement_info_wrapper.dart';
import 'package:purchases_flutter/models/store.dart';

Store getStore(String name) {
  switch (name.toLowerCase()) {
    case "app_store":
      return Store.appStore;
    case "mac_app_store":
      return Store.macAppStore;
    case "play_store":
      return Store.playStore;
    case "stripe":
      return Store.stripe;
    case "promotional":
      return Store.promotional;
    case "amazon":
      return Store.amazon;
    default:
      return Store.unknownStore;
  }
}

PeriodType getPeriodType(String name) {
  switch (jsonDecode(name)) {
    case "normal":
      return PeriodType.normal;
    case "intro":
      return PeriodType.intro;
    case "trial":
      return PeriodType.trial;
    default:
      return PeriodType.normal;
  }
}

OwnershipType getOwnershipType(String name) {
  switch (jsonDecode(name)) {
    case "PURCHASED":
      return OwnershipType.purchased;
    case "FAMILY_SHARED":
      return OwnershipType.familyShared;
    default:
      return OwnershipType.unknown;
  }
}
