// Available params: https://docs.stripe.com/api/customers/create
class StripeCustomerBuilder {
  String? name;
  String? email;
  String? phone;

  StripeCustomerBuilder({
    this.name,
    this.email,
    this.phone,
  });

  Map<String, dynamic> build() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
    };
  }
}
