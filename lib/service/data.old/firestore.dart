import 'data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreDatabase implements Database{
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  @override Future<Items> getDiscountEvents() async=>_getAllItems('discount_events');

  @override Future<Items> getParkingRates() async=>await _getAllItems('parking_rates');

  @override Future<Items> getPaymentMethods(ID shopper) async=>await _getItems('payment_methods','userID',shopper);

  @override Future<Item?> getVehicleOwner(ID vehicle) async{
    try {return await _getItem('users',(await _getItem('vehicles',vehicle)).value['userID']);}
    on ItemNotFound {return null;}
  }
  
  @override Future<Item> getActiveSession(String plateNo) async{
    QuerySnapshot<ItemBody> querySnapshot = await _c('parking_session').where('vehicleID', isEqualTo: _getVehicleID(plateNo)).where('exitTimestamp',isNull:true).get();
    try{return (_unwrapQuery(querySnapshot)).entries.first;}catch(e){throw ItemNotFound();}
  }
  
  @override Future<DateTime> logEntryTime(String plateNo) async{
    return (await (await _c('parking_session').add({
      'vehicleID' : (await _getVehicleID(plateNo)),
      'entryTimestamp' : DateTime.now(),
      'paymentStatus' : 'unpaid'
    })).get())['entryTimestamp'];
  }
  
  @override Future<void> logParkingExitTime(ID session,DateTime time) async{await _d('parking_session',session).update({'exitTimestamp':time});}
  
  @override Future<void> markPaymentSessionAsPaid(ID session) async{await _d('parking_session',session).update({'paymentStatus':'paid'});}
  
  Future<Item> _getVehicleByPlateNum(String plateNo) async=>(await _getItems('vehicles','carPlate',plateNo)).entries.first;
  
  Future<ID> _getVehicleID(String plateNo)async=>(await _getVehicleByPlateNum(plateNo)).key;
  
  CollectionReference<ItemBody> _c(String collection)=>firestore.collection(collection);
  
  DocumentReference<ItemBody> _d(String collection,ID key)=>_c(collection).doc(key);
  
  Future<Item> _getItem(String collection,ID key) async{
    final DocumentSnapshot<ItemBody> document = await _d(collection,key).get();
    if (!document.exists) throw ItemNotFound();
    if (document.data()==null) throw ItemNotFound();
    return {key:document.data()!}.entries.first;
  }
  
  Future<Items> _getAllItems(String collection) async{
    QuerySnapshot<ItemBody> querySnapshot = await _c(collection).get();
    return _unwrapQuery(querySnapshot);
    }
  
  Future<Items> _getItems(String collection,ID key,Object value) async {
    QuerySnapshot<ItemBody> querySnapshot = await _c(collection).where(key, isEqualTo: value).get();
    return _unwrapQuery(querySnapshot);
  }
  
  Items _unwrapQuery(QuerySnapshot<ItemBody> querySnapshot){
    Items output={};
    List docs=(querySnapshot.docs);
    docs.map((doc) {
      output[doc.id]=doc.get();
    });
    return output;
  }

  Future<Item> getGate(String username) async {
    return (await _getItems('cameras', 'name',username)).entries.first;
  }

  Future<Item> getShopper(String email) async {
    return (await _getItems('users', 'name',email)).entries.first;
  }
  
  @override
  Future<String> getKey() async {
    return (await _getItem('apiKey', 'stripe')).value.entries.first.value.toString();
  }
  
  @override
  Future<void> disableAutoPay(ID user) async{
    await _d('users',user.toString()).update({'useAutoPay':'no'});
  }
  
  @override
  Future<void> enableAutoPay(ID user) async {
    await _d('users',user.toString()).update({'useAutoPay':'yes'});
  }
  
  @override
  Future<ID> newMethod(Item method) async {
    return (await _c('payment-methods').add(method.value)).id;
  }

  Future<void> updatePaymentMethod(Item method)async{

  }
  
  @override
  Future<void> removePaymentMethod(ID method) async {
    _d('payment-methods',method).delete();
  }
  
  @override
  Future<void> swapMethods(ID toBack,ID? toBackFallback, ID toFront,ID? toFrontFallback) async {
    await firestore.runTransaction<void>((transaction) async {
      //ABCDE : B<->D : ADCBE
      await Future.wait<void>([
      replaceWithFallback(toBack,toFront)//A>D
      .then((_){
        if (toBackFallback==null) return;
        setFallback(toBackFallback,toBack);//C>B
      })
      ,setFallback(toBack,toFrontFallback)//B>E
      ,setFallback(toFront,toBackFallback)//D>C
      ],eagerError: true);
    });
  }
  
  @override
  Future<void> setFallback(ID method, ID? fallback) async {
    await _d('payment_methods',method).update({"fallback":fallback});
  }
  
  @override
  Future<void> replaceWithFallback(ID method, ID fallback) async{
    (await _getItems('payment_methods','fallback',method)).forEach(
      (id,item){_d('payment_methods',id).update({"fallback":fallback});}
    );    
    final paymentMethods = await _getItems('payment_methods', 'fallback', method);
    final List<Future<void>> updateFutures=[];
    paymentMethods.forEach((id,item){updateFutures.add(_d('payment_methods', id).update({"fallback": fallback}));});
    await Future.wait(updateFutures);
  }
  
  @override
  Future<Item> getAppliedVoucher(ID session) async {
    return (await _getItems('vouchers', 'parkingSessionId', session)).entries.first;
  }
  
  @override
  Future<void> confirmGate(String loginID) async{
    await getGate(loginID);
  }

  @override
  Future<void> confirmShopper(String loginID) async {
    await getShopper(loginID);
  }
  
  @override
  Future<String> getPaymentAPIKey() {
    return Future.delayed(Duration(),()=>"");
  }
}
