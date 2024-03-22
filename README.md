# Purchases Dart

Pure Dart implementation of the [purchases_flutter](https://pub.dev/packages/purchases_flutter) plugin aka RevenueCat plugin.

## Get Started

The `purchases_dart` package imports the native APIs from `purchases_flutter` and requires a store. We provide `purchases_dart_stripe` for the Stripe store, but `purchases_dart` is independent of the store and can be extended with a store of your own choice.

To get started, follow these steps:

1. Run the `example` app.
2. Rename `example/lib/env.example.dart` to `env.dart`.
3. Configure your RevenueCat and Stripe keys in the `env.dart` file.

That's it! You are now ready to use `purchases_dart` in your Dart projects.
