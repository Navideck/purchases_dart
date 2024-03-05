## Purchases Dart

Dart implementation of purchases_flutter plugin

## Get Started

This plugin currently supports Stripe

Run `example` app, rename `example/lib/env.example.dart` to `env.dart` and configure revenueCat and Stripe keys

## Supported scenarios

Scenario 1
- user logins Firebase
- rc.configure(id)	-> set a global user id
rc.purchase()


Scenario 2
- rc.configure() -> set a random global user id
- user logins Firebase
- rc.login(id)
- rc.purchase()


Scenario 3
- rc.configure() -> set a random global user id
- rc.purchase()