import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../common/statics.dart';
import '../services/firebase_service.dart';

class UpgradeToPremiumPage extends StatelessWidget {
  UpgradeToPremiumPage({Key? key}) : super(key: key);
  Map<String, dynamic>? paymentIntentData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Upgrade your package"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(8.0, 10.0, 8.0, 15.0),
            child: Text(
              "Upgrade your current package to view this feature.",
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 10.0, left: 8.0, right: 8.0,),
                  child: Material(
                    color: const Color(0xFF0E3B10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0)
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.0),
                          color: const Color(0xFFD2D2CD),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: const [
                                  Text("Upgrade to Premium", style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
                                  Text("INR 380.00", style: TextStyle(fontSize: 26.0, fontWeight: FontWeight.w900)),
                                ],
                              ),
                              const SizedBox(height: 5.0),
                              ElevatedButton(
                                onPressed: () {
                                  makePayment(context, "100", "INR");
                                },
                                style: ElevatedButton.styleFrom(
                                  elevation: 4.0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                                child: const Text("Make Payment (Credit/Debit card)"),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  makePaymentWithGooglePay("100", "INR");
                                },
                                style: ElevatedButton.styleFrom(
                                  elevation: 4.0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  backgroundColor: const Color(0xFFF3AF35)
                                ),
                                child: const Text("Make Payment (Google Pay)"),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> makePaymentWithGooglePay(String amount, String currency) async {
    try {
      paymentIntentData = await createPaymentIntent(amount, currency);

      // var gInit = await Stripe.instance.isGooglePaySupported(const IsGooglePaySupportedParams(testEnv: true));
      // debugPrint("Check GPay availability: $gInit");

      var gPayInitParams = const GooglePayInitParams(merchantName: 'Sam', countryCode: 'IN', testEnv: true);

      if (paymentIntentData != null) {
        await Stripe.instance.initGooglePay(
            gPayInitParams
        );
        displayPaymentSheetForGooglePay();
      }
    } catch (e) {
      debugPrint("$e");
    }
  }


  Future<void> makePayment(BuildContext context, String amount, String currency) async {
    try {
      paymentIntentData = await createPaymentIntent(amount, currency);

      if (paymentIntentData != null) {
        await Stripe.instance.initPaymentSheet(
            paymentSheetParameters: SetupPaymentSheetParameters(
              googlePay: const PaymentSheetGooglePay(merchantCountryCode: 'IN', testEnv: true),
              merchantDisplayName: "Prospects",
              customerId: paymentIntentData!["customer"],
              paymentIntentClientSecret: paymentIntentData!["client_secret"],
              customerEphemeralKeySecret: paymentIntentData!["ephemeralkey"],
            )
        );
        displayPaymentSheet(context);
      }
    } catch (e) {
      debugPrint("$e");
    }
  }

  Future<Map<String, dynamic>?> createPaymentIntent(String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        'amount': calculateAmount(amount),
        'currency': currency,
        'payment_method_types[]': "card"
      };

      var response = await http.post(
          Uri.parse("https://api.stripe.com/v1/payment_intents"),
          body: body,
          headers: {
            "Authorization": "Bearer ${Statics.stripeSecretKey}",
            "Content-Type": "application/x-www-form-urlencoded"
          }
      );

      return jsonDecode(response.body);
    } catch (e) {
      debugPrint("Exception(Stripe API post) $e");
      return null;
    }
  }

  String calculateAmount(String amount) {
    final a = (int.parse(amount)) * 100;
    return a.toString();
  }

  void displayPaymentSheet(BuildContext context) async {
    try {
      await Stripe.instance.presentPaymentSheet();
      // Get.snackbar("Payment info", "Payment Successful");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text("Payment Success - Sam Caller"),
          duration: Duration(milliseconds: 500),

        ),
      );
      await FirebaseService.updateToPremiumPackageCurrentUser();
    } on Exception catch(e) {
      if (e is StripeException) {
        debugPrint("Error from stripe $e");
      } else {
        debugPrint("Error occurred $e");
      }
    } catch (e) {
      debugPrint("EXCEPTION $e");
    }
  }

  void displayPaymentSheetForGooglePay() async {
    try {
      var presentParams = const PresentGooglePayParams(clientSecret: Statics.stripeSecretKey);
      await Stripe.instance.presentGooglePay(presentParams);
      Get.snackbar("Payment info", "Payment Successful");
    } on Exception catch(e) {
      if (e is StripeException) {
        debugPrint("Error from stripe $e");
      } else {
        debugPrint("Error occurred $e");
      }
    } catch (e) {
      debugPrint("EXCEPTION $e");
    }
  }
}
