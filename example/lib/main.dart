// ignore_for_file: avoid_print

import 'package:example/env.dart' as env;
import 'package:flutter/material.dart';
import 'package:purchases_dart/purchases_dart.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:url_launcher/url_launcher_string.dart';

void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainApp(),
    ),
  );
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final String userId = "test_user";
  Offerings? offerings;
  CustomerInfo? customerInfo;
  bool isLoading = false;

  Future<Map<String, dynamic>> _buildStripeCheckoutData(
    String stripePriceId,
    Package package,
  ) async {
    var data = {
      'success_url': 'https://example.com/success',
      'cancel_url': 'https://example.com/cancel',
      'line_items': [
        {'price': stripePriceId, 'quantity': 1},
      ],
    };
    if (package.packageType == PackageType.lifetime) {
      data['mode'] = "payment";
    } else {
      data['mode'] = "subscription";
    }
    return data;
  }

  // TestStripeCard: 4242 4242 4242 4242
  @override
  void initState() {
    // use stripe storeProductInterface
    StoreProductInterface storeProduct = StripeStoreProduct(
      stripeApi: env.stripeApiKey,
      checkoutSessionsBuilder: _buildStripeCheckoutData,
      onCheckoutUrlGenerated: (String sessionId, String url) =>
          launchUrlString(url),
    );

    // configure PurchasesDart
    PurchasesDart.configure(
      PurchasesDartConfiguration(
        apiKey: env.revenueCatApiKey,
        appUserId: userId,
        storeProduct: storeProduct,
      ),
    );

    // add customerInfoUpdateListener
    PurchasesDart.addCustomerInfoUpdateListener((customerInfo) {
      print("CustomerInfoUpdateListener");
      print(customerInfo.toJson());
    });
    super.initState();
  }

  void _getCustomerInfo() async {
    setState(() {
      isLoading = true;
    });
    try {
      CustomerInfo? customerInfo = await PurchasesDart.getCustomerInfo();
      print(customerInfo?.toJson());
      setState(() {
        isLoading = false;
        this.customerInfo = customerInfo;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print(e);
    }
  }

  void _getOfferings() async {
    setState(() {
      isLoading = true;
    });
    try {
      Offerings? offerings = await PurchasesDart.getOfferings();
      print(offerings?.toJson());
      setState(() {
        this.offerings = offerings;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print(e);
    }
  }

  void _purchasePackage(Package package) async {
    setState(() {
      isLoading = true;
    });
    try {
      await PurchasesDart.purchasePackage(package);
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print(e);
    }
  }

  // void _syncPurchases() async {
  //   await PurchasesDart.syncPurchases(userId);
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('RevenueCat Dart'),
          elevation: 4,
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _getCustomerInfo,
                    child: const Text("Get CustomerInfo"),
                  ),
                  ElevatedButton(
                    onPressed: _getOfferings,
                    child: const Text("Get Offerings"),
                  ),
                ],
              ),
            ),
            // Padding(
            //   padding: const EdgeInsets.symmetric(vertical: 8.0),
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            //     children: [
            //       ElevatedButton(
            //         onPressed: _syncPurchases,
            //         child: const Text("Sync Purchases"),
            //       ),
            //     ],
            //   ),
            // ),
            const Divider(),
            if (isLoading) const CircularProgressIndicator.adaptive(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    if (customerInfo != null)
                      CustomerInfoWidget(customerInfo: customerInfo!),
                    const Divider(),
                    if (offerings != null)
                      OfferingsWidget(
                        offerings: offerings!,
                        onPackageTap: _purchasePackage,
                      ),
                  ],
                ),
              ),
            )
          ],
        ));
  }
}

class OfferingsWidget extends StatelessWidget {
  final Offerings offerings;
  final Function(Package) onPackageTap;
  const OfferingsWidget({
    super.key,
    required this.offerings,
    required this.onPackageTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          title: Text("Current Offering ( ${offerings.current?.identifier} )"),
          subtitle: Text(
            'Available Offerings ${offerings.all.entries.length}',
          ),
        ),
        ...offerings.all.entries.map((e) {
          Offering offering = e.value;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Text(
                      "Name: ${offering.identifier} | Packages ${offering.availablePackages.length}",
                    ),
                    const Divider(),
                    ...offering.availablePackages.map((package) {
                      return ListTile(
                        onTap: () => onPackageTap(package),
                        title: Text(package.storeProduct.title),
                        subtitle: Text(package.storeProduct.description),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
          );
        })
      ],
    );
  }
}

class CustomerInfoWidget extends StatelessWidget {
  final CustomerInfo customerInfo;
  const CustomerInfoWidget({super.key, required this.customerInfo});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        child: Column(
          children: [
            ListTile(
              title: Text("Customer Info :${customerInfo.originalAppUserId}"),
              subtitle: Text('FirstSeen: ${customerInfo.firstSeen}'),
            ),
            const Divider(),
            Text(
              "Entitlements: Active - ${customerInfo.entitlements.active.entries.length} | All - ${customerInfo.entitlements.all.entries.length}",
            ),
            ...customerInfo.entitlements.active.entries.map((e) {
              EntitlementInfo entitlementInfo = e.value;
              return ListTile(
                title: Text('Identifier: ${entitlementInfo.identifier}'),
                subtitle: Text(
                    'PurchaseDate: ${entitlementInfo.originalPurchaseDate}'),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
