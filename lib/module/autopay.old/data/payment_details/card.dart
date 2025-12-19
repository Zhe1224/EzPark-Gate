
import '../../../../service/data.old/data.dart';
import 'payment_details.dart';

class Card extends PaymentDetails{
  @override
  static Widget renderForm() {
    // TODO: implement renderForm
    throw UnimplementedError();
  }

  @override
  Item toJson() {
    // TODO: implement toJson
    throw UnimplementedError();
  }
  
}

class Wallet extends PaymentDetails{
  @override
  static Widget renderForm() {
    // TODO: implement renderForm
    throw UnimplementedError();
  }
  
  @override
  Item toJson() {
    // TODO: implement toJson
    throw UnimplementedError();
  }
  
}