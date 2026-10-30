import 'package:purchases_flutter/purchases_flutter.dart';

/// Converts the virtual-currency payload returned by RevenueCat into the
/// representation used by purchases_flutter.
class VirtualCurrenciesParser {
  static VirtualCurrencies parse(Map<String, dynamic> response) {
    if (response['virtual_currencies'] case final Map data?) {
      return VirtualCurrencies.fromJson({
        'all': Map<String, dynamic>.from(data),
      });
    }

    throw StateError('Invalid RevenueCat virtual currencies response');
  }
}

extension VirtualCurrenciesJson on VirtualCurrencies {
  Map<String, dynamic> toJson() => {
        'all': {
          for (final entry in all.entries)
            entry.key: {
              'balance': entry.value.balance,
              'name': entry.value.name,
              'code': entry.value.code,
              'serverDescription': entry.value.serverDescription,
            },
        },
      };
}
