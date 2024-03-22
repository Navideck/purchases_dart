import 'package:purchases_dart_stripe/purchases_dart_stripe.dart';

class StripeCurrency {
  final String currency;
  final double amount;
  late String formattedPrice;

  StripeCurrency(this.currency, this.amount, [String? formattedPrice]) {
    this.formattedPrice =
        formattedPrice ?? '${amount.toStringAsFixed(2)} $currency';
  }

  factory StripeCurrency.fromStripePrice(
      StripePrice price, StripeCurrencyFormatter? formatter) {
    int? amount = price.unitAmount;
    if (amount == null) throw Exception('StripePrice.unitAmount is null');
    String? currency = price.currency;
    if (currency == null) throw Exception('StripePrice.currency is null');
    StripeCurrency stripeCurrency = formatter?.call(amount, currency) ??
        defaultCurrencyFormatter(amount, currency);
    return stripeCurrency;
  }

  static StripeCurrencyFormatter defaultCurrencyFormatter =
      (int amount, String currency) {
    // No decimal for zero decimal currencies
    if (stripeZeroDecimalCurrencies.contains(currency.toLowerCase())) {
      return StripeCurrency(
        currency,
        amount.toDouble(),
        '${amount.toDouble()} $currency',
      );
    }
    // Decimal for other currencies
    double amountDouble = amount / 100;
    return switch (currency.toLowerCase()) {
      'usd' => StripeCurrency(
          '\$',
          amountDouble,
          '\$ ${amountDouble.toStringAsFixed(2)}',
        ),
      'eur' => StripeCurrency('€', amountDouble),
      _ => StripeCurrency(currency, amountDouble),
    };
  };

  // https://stripe.com/docs/currencies#zero-decimal
  static List<String> stripeZeroDecimalCurrencies = [
    'bif',
    'clp',
    'djf',
    'gnf',
    'jpy',
    'kmf',
    'krw',
    'mga',
    'pyg',
    'rwf',
    'vnd',
    'vuv',
    'xaf',
    'xof',
    'xpf',
  ];
}
