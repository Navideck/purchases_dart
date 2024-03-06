class StripeCheckoutUrlBuilder {
  String successUrl;
  String cancelUrl;
  StripePaymentMode mode;
  List<StripeCheckoutLineItem> lineItems;

  StripeCheckoutUrlBuilder({
    required this.successUrl,
    required this.cancelUrl,
    required this.mode,
    required this.lineItems,
  });

  Map<String, dynamic> build() {
    return {
      'success_url': successUrl,
      'cancel_url': cancelUrl,
      'line_items': lineItems.map((e) => e.toJson()).toList(),
      'mode': mode.value,
    };
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
