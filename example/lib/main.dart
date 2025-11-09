// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:purchases_dart/purchases_dart.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

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
  final TextEditingController _userIdController = TextEditingController();

  Offerings? offerings;
  CustomerInfo? customerInfo;
  bool isLoading = false;

  Future<void> _initialize() async {
    PurchasesDart.setLogLevel(LogLevel.verbose);

    // configure PurchasesDart
    await PurchasesDart.configure(
      PurchasesDartConfiguration(
        webBillingApiKey: , // Fill with your web billing api key
      ),
    );

    _userIdController.text = PurchasesDart.appUserId ?? "";
  }

  // TestStripeCard: 4242 4242 4242 4242
  @override
  void initState() {
    super.initState();
    _initialize();
  }

  void _getCustomerInfo() async {
    setState(() => isLoading = true);
    try {
      CustomerInfo? customerInfo = await PurchasesDart.getCustomerInfo();
      print(customerInfo);
      setState(() {
        isLoading = false;
        this.customerInfo = customerInfo;
      });
    } catch (e, stackTrace) {
      setState(() => isLoading = false);
      print(e);
      print(stackTrace);
    }
  }

  void _getOfferings() async {
    setState(() => isLoading = true);
    try {
      Offerings? offerings = await PurchasesDart.getOfferings();
      print(offerings);
      setState(() {
        this.offerings = offerings;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      print(e);
    }
  }

  void _purchasePackage(Package package) async {
    setState(() => isLoading = true);
    try {
      Uri? webBillingUrl = await PurchasesDart.getWebCheckoutUrl(
        package,
        //  email: "testuser@gmail.com",
      );
      if (webBillingUrl != null) {
        await launchUrl(webBillingUrl);
      } else {
        throw Exception("Failed to get web billing url");
      }
      setState(() => isLoading = false);
    } catch (e) {
      setState(() => isLoading = false);
      print(e);
    }
  }

  Future<void> loginUser() async {
    try {
      LogInResult? logInResult = await PurchasesDart.login(
        _userIdController.text,
      );
      print(
        'LogInResult: Created: ${logInResult.created} | Customer: ${logInResult.customerInfo}',
      );
      setState(() {
        customerInfo = logInResult.customerInfo;
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> logoutUser() async {
    try {
      await PurchasesDart.logout();
      _userIdController.text = PurchasesDart.appUserId ?? "";
      _getCustomerInfo();
    } catch (e) {
      print(e);
    }
  }

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
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: _userIdController,
                decoration: const InputDecoration(
                  labelText: "User Id",
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: loginUser,
                    child: const Text("Login"),
                  ),
                  ElevatedButton(
                    onPressed: logoutUser,
                    child: const Text("Logout"),
                  ),
                ],
              ),
            ),
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
                        subtitle: Text(
                          "${package.presentedOfferingContext.offeringIdentifier}\n"
                          "${package.storeProduct.priceString}",
                        ),
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
              title: const Text("Customer Info"),
              subtitle: Text(
                'OriginalAppUserID: ${customerInfo.originalAppUserId}'
                '\nFirstSeen: ${customerInfo.firstSeen}',
              ),
            ),
            const Divider(),
            Text(
              "Entitlements: Active - ${customerInfo.entitlements.active.entries.length} | All - ${customerInfo.entitlements.all.entries.length}",
            ),
            ...customerInfo.entitlements.all.entries.map((e) {
              EntitlementInfo entitlementInfo = e.value;
              return ListTile(
                tileColor:
                    entitlementInfo.isActive ? Colors.green : Colors.grey,
                title: Text('Identifier: ${entitlementInfo.identifier}'),
                subtitle: Text(
                  'PurchaseDate: ${entitlementInfo.originalPurchaseDate}',
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
