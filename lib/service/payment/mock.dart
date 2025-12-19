import 'payment.dart';
import 'package:flutter/foundation.dart';

class MockPaymentService implements PaymentService {

  // In-memory storage for mocked payment methods
  final List<PaymentMethod> _paymentMethods = [];

  MockPaymentService();

  @override
  Future<void> settlePayment(
    PaymentMethods methods,
    double amount) async {
    // Simulate payment processing logic without actual network call
    if (amount <= 0) {
      throw PaymentMethodNotValid();
    }
    if (kDebugMode) {
      print("Mock payment of MYR $amount settled using token: ${methods.firstMethod?.me.token ?? "null"}");
    }
  }

  @override
  Future<String> registerAutoPaymentMethod(
    Item method
  ) async {
    /*// Check if the payment method already exists
     if (_paymentMethods.any((m) => m.token == method.token)) {
      throw PaymentMethodAlreadyExists();
    } */

    // Simulate adding a new payment method
    _paymentMethods.add(PaymentMethod.fromJson(method));
    if (kDebugMode) {
      print("Mock payment method registered");
    }
    return Future.delayed(Duration(),()=>"12244896");
    
  }

  @override
  Future<void> removePaymentMethod(String methodId) async {
    // Locate and remove the payment method
    try {
      final method = _paymentMethods.firstWhere((m) => m.token == methodId);
      // Simulate payment method removal
      _paymentMethods.remove(method);
      if (kDebugMode) {
        print("Mock payment method removed: $methodId");
      }
    } on Exception {
      throw PaymentMethodNotExist();
    }
  }

  // Additional method to list payment methods (for testing)
  List<PaymentMethod> getPaymentMethods() {
    return List.from(_paymentMethods);
  }
}
