// ignore_for_file: constant_identifier_names

class ReservedSubscriberAttribute {
  final String value;
  const ReservedSubscriberAttribute._(this.value);

  // Special Attributes
  static const EMAIL = ReservedSubscriberAttribute._("\$email");
  static const DISPLAY_NAME = ReservedSubscriberAttribute._("\$displayName");
  static const PHONE_NUMBER = ReservedSubscriberAttribute._("\$phoneNumber");
  static const FCM_TOKENS = ReservedSubscriberAttribute._("\$fcmTokens");

  // Device Identifiers
  static const IDFA = ReservedSubscriberAttribute._("\$idfa");
  static const IDFV = ReservedSubscriberAttribute._("\$idfv");
  static const IP = ReservedSubscriberAttribute._("\$ip");
  static const DEVICE_VERSION =
      ReservedSubscriberAttribute._("\$deviceVersion");
  static const GPS_AD_ID = ReservedSubscriberAttribute._("\$gpsAdId");
  static const AMAZON_AD_ID = ReservedSubscriberAttribute._("\$amazonAdId");

  // Attribution IDs
  static const ADJUST_ID = ReservedSubscriberAttribute._("\$adjustId");
  static const APPSFLYER_ID = ReservedSubscriberAttribute._("\$appsflyerId");
  static const FB_ANON_ID = ReservedSubscriberAttribute._("\$fbAnonId");
  static const MPARTICLE_ID = ReservedSubscriberAttribute._("\$mparticleId");
  static const ONESIGNAL_ID = ReservedSubscriberAttribute._("\$onesignalId");
  static const ONESIGNAL_USER_ID =
      ReservedSubscriberAttribute._("\$onesignalUserId");
  static const AIRSHIP_CHANNEL_ID =
      ReservedSubscriberAttribute._("\$airshipChannelId");
  static const CLEVER_TAP_ID = ReservedSubscriberAttribute._("\$clevertapId");
  static const KOCHAVA_DEVICE_ID =
      ReservedSubscriberAttribute._("\$kochavaDeviceId");

  // Integration IDs
  static const MIXPANEL_DISTINCT_ID =
      ReservedSubscriberAttribute._("\$mixpanelDistinctId");
  static const FIREBASE_APP_INSTANCE_ID =
      ReservedSubscriberAttribute._("\$firebaseAppInstanceId");
  static const TENJIN_ANALYTICS_INSTALLATION_ID =
      ReservedSubscriberAttribute._("\$tenjinId");

  // Optional campaign parameters
  static const MEDIA_SOURCE = ReservedSubscriberAttribute._("\$mediaSource");
  static const CAMPAIGN = ReservedSubscriberAttribute._("\$campaign");
  static const AD_GROUP = ReservedSubscriberAttribute._("\$adGroup");
  static const AD = ReservedSubscriberAttribute._("\$ad");
  static const KEYWORD = ReservedSubscriberAttribute._("\$keyword");
  static const CREATIVE = ReservedSubscriberAttribute._("\$creative");
}
