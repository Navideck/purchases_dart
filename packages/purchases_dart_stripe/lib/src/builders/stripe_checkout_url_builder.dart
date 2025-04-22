/// Builder for creating a Stripe Checkout URL
/// add extra parameters if needed using [extraParams]
class StripeCheckoutUrlBuilder {
  String successUrl;
  String cancelUrl;
  StripePaymentMode mode;
  List<StripeCheckoutLineItem> lineItems;
  Map<String, Object>? extraParams;

  StripeCheckoutUrlBuilder({
    required this.successUrl,
    required this.cancelUrl,
    required this.mode,
    required this.lineItems,
    this.extraParams,
  });

  Map<String, dynamic> build() {
    var data = {
      'success_url': successUrl,
      'cancel_url': cancelUrl,
      'line_items': lineItems.map((e) => e.toJson()).toList(),
      'mode': mode.value,
    };
    if (extraParams != null) {
      data.addAll(extraParams!);
    }
    return data;
  }
}

enum StripePaymentMode {
  payment("payment"),
  setup("setup"),
  subscription("subscription");

  const StripePaymentMode(this.value);
  final String value;
}

class StripeCheckoutLineItem {
  String priceId;
  int quantity;
  StripeCheckoutLineItem({required this.priceId, required this.quantity});

  Map<String, dynamic> toJson() {
    return {
      'price': priceId,
      'quantity': quantity,
    };
  }
}
