import 'dart:core';

class DateActive {
  final bool isActive;
  final bool inGracePeriod;

  DateActive(this.isActive, this.inGracePeriod);
}

class DateHelper {
  static const Duration entitlementGracePeriod = Duration(days: 3);

  /// Calculates whether a subscription/entitlement is currently active according to the expiration date and last
  /// successful request date, while considering a given grace period
  static DateActive isDateActive(
    DateTime? expirationDate,
    DateTime requestDate, {
    Duration gracePeriod = entitlementGracePeriod,
  }) {
    if (expirationDate == null) return DateActive(true, true);

    bool inGracePeriod = DateTime.now().millisecondsSinceEpoch -
            requestDate.millisecondsSinceEpoch <=
        gracePeriod.inMilliseconds;
    DateTime referenceDate = inGracePeriod ? requestDate : DateTime.now();
    return DateActive(
      expirationDate.isAfter(referenceDate),
      inGracePeriod,
    );
  }
}
