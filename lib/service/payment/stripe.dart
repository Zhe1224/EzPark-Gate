import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'payment.dart';

class StripePaymentService implements PaymentService{
  final Dio dio=Dio();
  String apiKey="pk_test_51SfYQ60yzQ563uniT6TpXlnOXt3A5kQWW5GkFajrahtxsFrM2oeJ9xbAWi906LF9WagRn1i8f54xfWxZBLu8S7ES00BDvC1sHL";

  StripePaymentService();

  /// Attempt to settle payment using a list of payment methods.
  @override
  Future<void> settlePayment(
    PaymentMethods methods,
    double amount) async {
    if (methods.firstMethod == null) throw PaymentMethodNotExist;
    PMNode currentMethod = methods.firstMethod as PMNode;
    for (;;) {
      try {
        await _settlePayment(currentMethod.me.token!, amount);
        if (kDebugMode) {
          print("Payment successful using method: ${currentMethod.me.token}");
        }
        return; // Exit if the payment is settled
      } catch (e) {
        if (e is NetworkError) {
          if (kDebugMode) {
            print(
            "Payment failed for method: ${currentMethod.me.token}. Checking for fallback.",
          );
          }
          if (currentMethod.next == null) throw PaymentMethodNotExist();
          currentMethod = currentMethod.next as PMNode;
        } else {
          rethrow; // Re-throw unexpected exceptions
        }
      }
    }
  }

  /// Settle a payment for parking fee
  Future<void> _settlePayment(
    String paymentToken,
    double amount) async {
    try {

      // Set up the request headers
      final headers = {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/x-www-form-urlencoded',
      };

      // Prepare the data for the payment request
      final data = {
        'amount': (amount * 100).toString(), // Convert to cents
        'currency': 'myr',
        'source': paymentToken,
        'description': 'Parking Fee',
      };

      // Make the API call to Stripe's payment endpoint
      final response = await dio.post(
        'https://api.stripe.com/v1/charges',
        options: Options(headers: headers),
        data: data,
      );

      if (response.statusCode != 200) {
        throw NetworkError();
      }
    } on DioException {
      // Handle Dio errors (e.g., network issues)
      throw NetworkError();
    }
  }

  /// Register a new payment method
  @override
  Future<String> registerAutoPaymentMethod(
    Item method
  ) async {
    /*IntentMode.setupMode(setupFutureUsage: IntentFutureUsage.OffSession)
    Stripe.instance.confirmSetupIntent(paymentIntentClientSecret: paymentIntentClientSecret, params: params)*/

    try {
      // Set up the request headers
      final headers = {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/x-www-form-urlencoded',
      };

      // Prepare the data for registering the payment method
      final data = method;

      // Make the API call to Stripe's payment method creation endpoint
      final response = await dio.post(
        'https://api.stripe.com/v1/payment_methods',
        options: Options(headers: headers),
        data: data,
      );

      if (response.statusCode != 200) {
        throw PaymentMethodRegistrationFailed();
      }
      return "a";
    } on DioException {
      throw NetworkError();
    }
  }

  /// Remove an existing payment method
  @override
  Future<void> removePaymentMethod(String methodId) async {
    try {
      // Set up the request headers
      final headers = {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/x-www-form-urlencoded',
      };

      // Make the API call to Stripe's payment method removal endpoint
      final response = await dio.delete(
        'https://api.stripe.com/v1/payment_methods/$methodId',
        options: Options(headers: headers),
      );

      if (response.statusCode != 200) {
        throw PaymentMethodRemovalFailed();
      }
    } on DioException {
      throw NetworkError();
    }
  }
  
}