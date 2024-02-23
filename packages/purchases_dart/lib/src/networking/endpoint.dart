class Endpoint {
  final String pathTemplate;
  final String name;

  Endpoint(this.pathTemplate, this.name);

  String get path => pathTemplate;

  bool supportsSignatureVerification() {
    if (this is GetCustomerInfo ||
        this is LogIn ||
        this is PostReceipt ||
        this is GetOfferings ||
        this is GetProductEntitlementMapping) {
      return true;
    } else {
      return false;
    }
  }

  bool needsNonceToPerformSigning() {
    if (this is GetCustomerInfo || this is LogIn || this is PostReceipt) {
      return true;
    } else {
      return false;
    }
  }
}

class GetCustomerInfo extends Endpoint {
  final String userId;
  GetCustomerInfo(this.userId)
      : super("/subscribers/${Uri.encodeComponent(userId)}", "get_customer");
}

class PostReceipt extends Endpoint {
  PostReceipt() : super("/receipts", "post_receipt");
}

class GetOfferings extends Endpoint {
  final String userId;

  GetOfferings(this.userId)
      : super("/subscribers/${Uri.encodeComponent(userId)}/offerings",
            "get_offerings");
}

class LogIn extends Endpoint {
  LogIn() : super("/subscribers/identify", "log_in");
}

class PostDiagnostics extends Endpoint {
  PostDiagnostics() : super("/diagnostics", "post_diagnostics");
}

class PostPaywallEvents extends Endpoint {
  PostPaywallEvents() : super("/events", "post_paywall_events");
}

class PostAttributes extends Endpoint {
  final String userId;

  PostAttributes(this.userId)
      : super("/subscribers/${Uri.encodeComponent(userId)}/attributes",
            "post_attributes");
}

class GetAmazonReceipt extends Endpoint {
  final String userId;
  final String receiptId;

  GetAmazonReceipt(this.userId, this.receiptId)
      : super("/receipts/amazon/$userId/$receiptId", "get_amazon_receipt");
}

class GetProductEntitlementMapping extends Endpoint {
  GetProductEntitlementMapping()
      : super(
            "/product_entitlement_mapping", "get_product_entitlement_mapping");
}
