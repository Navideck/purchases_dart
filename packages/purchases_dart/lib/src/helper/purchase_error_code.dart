// ignore_for_file: constant_identifier_names

typedef PurchasesErrorCallback = void Function(PurchasesError);

class PurchasesError {
  final PurchasesErrorCode code;
  final String? underlyingErrorMessage;

  const PurchasesError({
    required this.code,
    this.underlyingErrorMessage,
  });

  String get message => code.description;

  @override
  String toString() {
    return 'PurchasesError(code=$code, underlyingErrorMessage=$underlyingErrorMessage, message=$message)';
  }
}

class PurchasesErrorCode {
  final int code;
  final String description;

  const PurchasesErrorCode(this.code, this.description);

  static const PurchasesErrorCode UnknownError =
      PurchasesErrorCode(0, 'Unknown error.');
  static const PurchasesErrorCode PurchaseCancelledError =
      PurchasesErrorCode(1, 'Purchase was cancelled.');
  static const PurchasesErrorCode StoreProblemError =
      PurchasesErrorCode(2, 'There was a problem with the store.');
  static const PurchasesErrorCode PurchaseNotAllowedError = PurchasesErrorCode(
      3, 'The device or user is not allowed to make the purchase.');
  static const PurchasesErrorCode PurchaseInvalidError = PurchasesErrorCode(
      4, 'One or more of the arguments provided are invalid.');
  static const PurchasesErrorCode ProductNotAvailableForPurchaseError =
      PurchasesErrorCode(5, 'The product is not available for purchase.');
  static const PurchasesErrorCode ProductAlreadyPurchasedError =
      PurchasesErrorCode(6, 'This product is already active for the user.');
  static const PurchasesErrorCode ReceiptAlreadyInUseError = PurchasesErrorCode(
      7, 'There is already another active subscriber using the same receipt.');
  static const PurchasesErrorCode InvalidReceiptError =
      PurchasesErrorCode(8, 'The receipt is not valid.');
  static const PurchasesErrorCode MissingReceiptFileError =
      PurchasesErrorCode(9, 'The receipt is missing.');
  static const PurchasesErrorCode NetworkError =
      PurchasesErrorCode(10, 'Error performing request.');
  static const PurchasesErrorCode InvalidCredentialsError = PurchasesErrorCode(
      11,
      'There was a credentials issue. Check the underlying error for more details.');
  static const PurchasesErrorCode UnexpectedBackendResponseError =
      PurchasesErrorCode(12, 'Received unexpected response from the backend.');
  static const PurchasesErrorCode InvalidAppUserIdError =
      PurchasesErrorCode(14, 'The app user id is not valid.');
  static const PurchasesErrorCode OperationAlreadyInProgressError =
      PurchasesErrorCode(15, 'The operation is already in progress.');
  static const PurchasesErrorCode UnknownBackendError =
      PurchasesErrorCode(16, 'There was an unknown backend error.');
  static const PurchasesErrorCode InvalidAppleSubscriptionKeyError =
      PurchasesErrorCode(
    17,
    'Apple Subscription Key is invalid or not present. '
    'In order to provide subscription offers, you must first generate a subscription key. '
    'Please see https://docs.revenuecat.com/docs/ios-subscription-offers for more info.',
  );
  static const PurchasesErrorCode IneligibleError =
      PurchasesErrorCode(18, 'The User is ineligible for that action.');
  static const PurchasesErrorCode InsufficientPermissionsError =
      PurchasesErrorCode(
          19, 'App does not have sufficient permissions to make purchases.');
  static const PurchasesErrorCode PaymentPendingError =
      PurchasesErrorCode(20, 'The payment is pending.');
  static const PurchasesErrorCode InvalidSubscriberAttributesError =
      PurchasesErrorCode(
          21, 'One or more of the attributes sent could not be saved.');
  static const PurchasesErrorCode LogOutWithAnonymousUserError =
      PurchasesErrorCode(
          22, 'Called logOut but the current user is anonymous.');
  static const PurchasesErrorCode ConfigurationError = PurchasesErrorCode(23,
      'There is an issue with your configuration. Check the underlying error for more details.');
  static const PurchasesErrorCode UnsupportedError = PurchasesErrorCode(
    24,
    'There was a problem with the operation. Looks like we doesn\'t support '
    'that yet. Check the underlying error for more details.',
  );
  static const PurchasesErrorCode EmptySubscriberAttributesError =
      PurchasesErrorCode(
          25, 'A request for subscriber attributes returned none.');
  static const PurchasesErrorCode CustomerInfoError = PurchasesErrorCode(
      28, 'There was a problem related to the customer info.');
  static const PurchasesErrorCode SignatureVerificationError =
      PurchasesErrorCode(
    36,
    'Request failed signature verification. Please see https://rev.cat/trusted-entitlements for more info.',
  );
}
