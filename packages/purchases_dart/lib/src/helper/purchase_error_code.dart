// ignore_for_file: constant_identifier_names

import 'package:flutter/services.dart';

class PurchasesDartError {
  final PurchasesDartErrorCode code;
  final String? underlyingErrorMessage;

  const PurchasesDartError({
    required this.code,
    this.underlyingErrorMessage,
  });

  String get message => code.description;

  PlatformException toPlatformException() {
    return PlatformException(
      code: code.code.toString(),
      message: message,
      details: underlyingErrorMessage,
    );
  }

  @override
  String toString() {
    return 'PurchasesError(code=$code, underlyingErrorMessage=$underlyingErrorMessage, message=$message)';
  }
}

class PurchasesDartErrorCode {
  final int code;
  final String description;

  const PurchasesDartErrorCode(this.code, this.description);

  static const PurchasesDartErrorCode UnknownError =
      PurchasesDartErrorCode(0, 'Unknown error.');
  static const PurchasesDartErrorCode PurchaseCancelledError =
      PurchasesDartErrorCode(1, 'Purchase was cancelled.');
  static const PurchasesDartErrorCode StoreProblemError =
      PurchasesDartErrorCode(2, 'There was a problem with the store.');
  static const PurchasesDartErrorCode PurchaseNotAllowedError = PurchasesDartErrorCode(
      3, 'The device or user is not allowed to make the purchase.');
  static const PurchasesDartErrorCode PurchaseInvalidError = PurchasesDartErrorCode(
      4, 'One or more of the arguments provided are invalid.');
  static const PurchasesDartErrorCode ProductNotAvailableForPurchaseError =
      PurchasesDartErrorCode(5, 'The product is not available for purchase.');
  static const PurchasesDartErrorCode ProductAlreadyPurchasedError =
      PurchasesDartErrorCode(6, 'This product is already active for the user.');
  static const PurchasesDartErrorCode ReceiptAlreadyInUseError = PurchasesDartErrorCode(
      7, 'There is already another active subscriber using the same receipt.');
  static const PurchasesDartErrorCode InvalidReceiptError =
      PurchasesDartErrorCode(8, 'The receipt is not valid.');
  static const PurchasesDartErrorCode MissingReceiptFileError =
      PurchasesDartErrorCode(9, 'The receipt is missing.');
  static const PurchasesDartErrorCode NetworkError =
      PurchasesDartErrorCode(10, 'Error performing request.');
  static const PurchasesDartErrorCode InvalidCredentialsError = PurchasesDartErrorCode(
      11,
      'There was a credentials issue. Check the underlying error for more details.');
  static const PurchasesDartErrorCode UnexpectedBackendResponseError =
      PurchasesDartErrorCode(12, 'Received unexpected response from the backend.');
  static const PurchasesDartErrorCode InvalidAppUserIdError =
      PurchasesDartErrorCode(14, 'The app user id is not valid.');
  static const PurchasesDartErrorCode OperationAlreadyInProgressError =
      PurchasesDartErrorCode(15, 'The operation is already in progress.');
  static const PurchasesDartErrorCode UnknownBackendError =
      PurchasesDartErrorCode(16, 'There was an unknown backend error.');
  static const PurchasesDartErrorCode InvalidAppleSubscriptionKeyError =
      PurchasesDartErrorCode(
    17,
    'Apple Subscription Key is invalid or not present. '
    'In order to provide subscription offers, you must first generate a subscription key. '
    'Please see https://docs.revenuecat.com/docs/ios-subscription-offers for more info.',
  );
  static const PurchasesDartErrorCode IneligibleError =
      PurchasesDartErrorCode(18, 'The User is ineligible for that action.');
  static const PurchasesDartErrorCode InsufficientPermissionsError =
      PurchasesDartErrorCode(
          19, 'App does not have sufficient permissions to make purchases.');
  static const PurchasesDartErrorCode PaymentPendingError =
      PurchasesDartErrorCode(20, 'The payment is pending.');
  static const PurchasesDartErrorCode InvalidSubscriberAttributesError =
      PurchasesDartErrorCode(
          21, 'One or more of the attributes sent could not be saved.');
  static const PurchasesDartErrorCode LogOutWithAnonymousUserError =
      PurchasesDartErrorCode(
          22, 'Called logOut but the current user is anonymous.');
  static const PurchasesDartErrorCode ConfigurationError = PurchasesDartErrorCode(23,
      'There is an issue with your configuration. Check the underlying error for more details.');
  static const PurchasesDartErrorCode UnsupportedError = PurchasesDartErrorCode(
    24,
    'There was a problem with the operation. Looks like we doesn\'t support '
    'that yet. Check the underlying error for more details.',
  );
  static const PurchasesDartErrorCode EmptySubscriberAttributesError =
      PurchasesDartErrorCode(
          25, 'A request for subscriber attributes returned none.');
  static const PurchasesDartErrorCode CustomerInfoError = PurchasesDartErrorCode(
      28, 'There was a problem related to the customer info.');
  static const PurchasesDartErrorCode SignatureVerificationError =
      PurchasesDartErrorCode(
    36,
    'Request failed signature verification. Please see https://rev.cat/trusted-entitlements for more info.',
  );
}
