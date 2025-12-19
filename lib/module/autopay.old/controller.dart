


import '../../service/payment.dart';

class AutoPayController{
  final Database _db;
  final String loginID;
  PaymentService? payment;

  // Private unnamed constructor
  AutoPayController._(this._db,this.loginID);

  // Factory constructor that initializes the _AutoPayDataClient
  factory AutoPayController.get({required Database db,required String loginID}) {
    return AutoPayController._(db,loginID);
  }

  void initialisePaymentService(){
    payment=MockPaymentService();
  }

  Future<void> newMethod(Item item /*PaymentDetails method*/)async {
      /*String token = await payment!.registerAutoPaymentMethod(method.toJson());*/
      PaymentMethod pm=/*PaymentMethod.fromJson(method.toJson());*/
      PaymentMethod(user: loginID, type: item.value["type"], created: DateTime.now());
      pm.token=item.value["token"];
      pm.user=loginID;
      await _db.newMethod(pm.toJson());
  }

  Future<void> removePaymentMethod(PaymentMethod method)async{
      _db.removePaymentMethod(method.id!);
  }

  Future<void> swapMethods(PaymentMethod toBack,PaymentMethod toFront)async{
      _db.swapMethods(toBack.id!,toBack.fallback,toFront.id!,toFront.fallback);
  }

  Future<void> disable()async{
      _db.disableAutoPay(loginID);
  }
  
  Future<void> enable()async{
      _db.enableAutoPay(loginID);
  }
}