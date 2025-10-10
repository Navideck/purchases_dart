import '../../purchases_dart.dart';
import '../model/subscribe_attributes_key.dart';

class AttributeManager {
  final PurchasesBackend backend;
  AttributeManager(this.backend);

  Future<void> setAttributionID(
    ReservedSubscriberAttribute attributionKey,
    String? value,
    String appUserID,
  ) {
    final attributesToSet = {
      attributionKey.value: value,
      ..._getDeviceIdentifiers(),
    };
    return setAttributes(appUserID, attributesToSet);
  }

  Future<void> setAttributes(
    String appUserID,
    Map<String, String?> attributesToSet,
  ) {
    return backend.postAttributes(
      appUserID,
      attributesToSet: attributesToSet,
    );
  }

  Map<String, String> _getDeviceIdentifiers() {
    // Using temporary advertising ID
    const noPermissionAdvertisingIdValue =
        '00000000-0000-0000-0000-000000000000';
    return {
      ReservedSubscriberAttribute.GPS_AD_ID.value:
          noPermissionAdvertisingIdValue,
      ReservedSubscriberAttribute.IP.value: 'true',
      ReservedSubscriberAttribute.DEVICE_VERSION.value: 'true',
    };
  }
}
