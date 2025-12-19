import 'data.dart';

class MockDatabase extends Database{
  @override
  Future<void> confirmShopper(String loginID){return Future.delayed(Duration(),(){});}
  @override
  Future<void> confirmGate(String loginID){return Future.delayed(Duration(),(){});}

  @override
  Future<String>   getPaymentAPIKey(){return Future.delayed(Duration(),()=>"");}

  @override
  Future<String>   getKey(){return Future.delayed(Duration(),()=>"");}

  @override
  Future<Items>    getDiscountEvents(){{return Future.delayed(Duration(),()=>{});}}
  @override
  Future<Items>    getParkingRates(){{return Future.delayed(Duration(),()=>{});}}
  @override
  Future<Items>    getPaymentMethods(ID shopper){{return Future.delayed(Duration(),()=>{});}}
  @override
  Future<Item?>    getVehicleOwner(ID session){{return Future.delayed(Duration(),()=>{} as Item);}}
  @override
  Future<Item>     getActiveSession(String plateNo){{return Future.delayed(Duration(),()=>{} as Item);}}
  @override
  Future<Item>     getAppliedVoucher(ID session){{return Future.delayed(Duration(),()=>{} as Item);}}
  @override
  Future<DateTime> logEntryTime(String plateNo){{return Future.delayed(Duration(),()=>DateTime.now());}}
  @override
  Future<void>     logParkingExitTime(ID session,DateTime time){return Future.delayed(Duration(),(){});}
  @override
  Future<void>     markPaymentSessionAsPaid(ID session){return Future.delayed(Duration(),(){});}

  @override
  Future<ID>       newMethod(Item method){return Future.delayed(Duration(),()=>"");}
  @override
  Future<void>     removePaymentMethod(ID method){return Future.delayed(Duration(),(){});}
  @override
  Future<void>     swapMethods(ID toBack,ID? toBackFallback, ID toFront,ID? toFrontFallback){return Future.delayed(Duration(),(){});}
  @override
  Future<void>     disableAutoPay(ID user){return Future.delayed(Duration(),(){});}
  @override
  Future<void>     enableAutoPay(ID user){return Future.delayed(Duration(),(){});}
  @override
  Future<void>     setFallback(ID method,ID fallback){return Future.delayed(Duration(),(){});}
  @override
  Future<void>     replaceWithFallback(ID method,ID fallback){return Future.delayed(Duration(),(){});}
}