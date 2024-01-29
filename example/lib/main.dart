// ignore_for_file: avoid_print

import 'package:example/env.dart' as env;
import 'package:flutter/material.dart';
import 'package:purchases_dart/purchases_dart.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:flutter_json_view/flutter_json_view.dart';

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
  final String userId = "test_user_id";
  Map<String, dynamic>? result;
  bool isLoading = false;

  @override
  void initState() {
    PurchasesDart.setup(
      apiKey: env.revenueCatApiKey,
      storeProduct: StripeStoreProduct(
        stripeApi: env.stripeApiKey,
      ),
    );
    super.initState();
  }

  void _getCustomerInfo() async {
    setState(() {
      isLoading = true;
      result = null;
    });
    try {
      CustomerInfo? customerInfo = await PurchasesDart.getCustomerInfo(userId);
      print(customerInfo?.toJson());
      setState(() {
        isLoading = false;
        result = customerInfo?.toJson();
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        result = {"error": e.toString()};
      });
    }
  }

  void _getOfferings() async {
    setState(() {
      isLoading = true;
      result = null;
    });
    try {
      Offerings? offerings = await PurchasesDart.getOfferings(userId);
      print(offerings?.toJson());
      setState(() {
        isLoading = false;
        result = offerings?.toJson();
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        result = {"error": e.toString()};
      });
    }
  }

  void _syncPurchases() async {
    await PurchasesDart.syncPurchases(userId);
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
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _getOfferings,
                    child: const Text("Get Offerings"),
                  ),
                  ElevatedButton(
                    onPressed: _getCustomerInfo,
                    child: const Text("Get CustomerInfo"),
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
                    onPressed: _syncPurchases,
                    child: const Text("Sync Purchases"),
                  ),
                ],
              ),
            ),
            const Divider(),
            if (isLoading) const CircularProgressIndicator.adaptive(),
            Expanded(
              child: SingleChildScrollView(
                child: result == null
                    ? const SizedBox.shrink()
                    : Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: JsonView.map(
                          result!,
                          theme: JsonViewTheme(
                            backgroundColor:
                                Theme.of(context).colorScheme.background,
                            openIcon: const Icon(Icons.arrow_drop_down),
                            closeIcon: const Icon(Icons.arrow_right),
                          ),
                        ),
                      ),
              ),
            )
          ],
        ));
  }
}
