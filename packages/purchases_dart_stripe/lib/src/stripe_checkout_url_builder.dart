class StripeCheckoutUrlBuilder {
  String successUrl;
  String cancelUrl;
  String mode;
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
      'mode': mode,
    };
  }
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
