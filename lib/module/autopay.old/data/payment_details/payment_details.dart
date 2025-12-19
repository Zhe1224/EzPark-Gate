import 'package:flutter/material.dart';
import 'package:parking_gate/widgets/custom.dart';

import '../../../../service/payment.dart';
export 'package:flutter/material.dart';


abstract class PaymentDetails{
  static Widget renderForm(){return CustomText("");}
  Item toJson();
}

class DetailedPaymentMethod extends PaymentMethod{
  PaymentDetails details;

  DetailedPaymentMethod({
    super.id,
    required super.user,
    super.fallback,
    required super.type,
    super.token,
    required super.created,
    required this.details
  });
}