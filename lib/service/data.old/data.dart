

import 'firestore.dart';
export 'firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TraceableException implements Exception {
  String name() => "Traceable Exception"; 
  Object? reason; 
  TraceableException({this.reason});
  
  @override
  String toString() {
    return "$name because $reason";
  }
}

class ItemNotFound extends TraceableException{@override String name()=>"Database: No Such Item"; }
class NotAuthorised extends TraceableException{@override String name()=>"Database: Not Authorised"; }
class NetworkError extends TraceableException{@override String name()=>"Database: Network Error"; }

abstract class LoginMethod{
  final Database database=FirestoreDatabase();
  final Authenticator auth=MockAuthenticator();
  Future<void> login();
}

abstract class IDPasswordPair extends LoginMethod{
  String loginID="";
  String password="";
  IDPasswordPair({required this.loginID,required this.password});
  @override
  Future<void> login() async {
    await Future.wait([
      auth.loginIDPasswordPair(this),
      _confirmUser()
    ]);
  }
  Future<void> _confirmUser();
}

class ShopperIDPasswordPair extends IDPasswordPair{
  ShopperIDPasswordPair({required super.loginID,required super.password});
  @override
  Future<void> _confirmUser() async {
    await database.confirmShopper(loginID);
  }
}

class GateIDPasswordPair extends IDPasswordPair{
  GateIDPasswordPair({required super.loginID,required super.password});
  @override
  Future<void> _confirmUser() async {
    await database.confirmGate(loginID);
  }
}

abstract class Authenticator{
  Future<void> loginIDPasswordPair(IDPasswordPair creds);
}

class FirebaseAuthenticator extends Authenticator{
  @override
  Future<void> loginIDPasswordPair(IDPasswordPair creds)async {
    await FirebaseAuth.instance.signInWithEmailAndPassword(email:creds.loginID,password:creds.password);
  }
}

class MockAuthenticator extends Authenticator{
  @override
  Future<void> loginIDPasswordPair(IDPasswordPair creds)async {
    
  }
}

class Profile{
  String loginID="";
  Profile(this.loginID);
}

abstract class Database{
  Future<void> confirmShopper(String loginID);
  Future<void> confirmGate(String loginID);

  Future<String>   getPaymentAPIKey();
  /*
  Future<Item>     getShopper(String email);
  Future<Item>     getGate(String username);*/

  Future<String>   getKey();

  Future<Items>    getDiscountEvents();
  Future<Items>    getParkingRates();
  Future<Items>    getPaymentMethods(ID shopper);
  Future<Item?>    getVehicleOwner(ID session);
  Future<Item>     getActiveSession(String plateNo);
  Future<Item>     getAppliedVoucher(ID session);
  Future<DateTime> logEntryTime(String plateNo);
  Future<void>     logParkingExitTime(ID session,DateTime time);
  Future<void>     markPaymentSessionAsPaid(ID session);

  Future<ID>       newMethod(Item method);
  Future<void>     removePaymentMethod(ID method);
  Future<void>     swapMethods(ID toBack,ID? toBackFallback, ID toFront,ID? toFrontFallback);
  Future<void>     disableAutoPay(ID user);
  Future<void>     enableAutoPay(ID user);
  Future<void>     setFallback(ID method,ID fallback);
  Future<void>     replaceWithFallback(ID method,ID fallback);
}

class DataClient{
  Database db;
  DataClient({required this.db});
}

class Data{
  ID? id;
  Data({this.id});
}

typedef ID = String;
typedef ItemBody = Map<String, dynamic>;
typedef Item = MapEntry<ID,ItemBody>;
typedef Items = Map<ID,ItemBody>;
typedef decimal = double;
typedef Gate = Camera;

class Shopper extends Data{
  String email;
  String passwordHash;
  String name;
  String role;
  DateTime createdAt;
  bool useAutoPay;

  Shopper._({
    super.id,
    required this.email,
    required this.passwordHash,
    required this.name,
    required this.role,
    required this.createdAt,
    required this.useAutoPay,
  });

  factory Shopper.fromJson(Item json) {
    ItemBody data = json.value;
    return Shopper._(
      id:json.key,
      email: data['email'],
      passwordHash: data['passwordHash'],
      name: data['name'],
      role: data['role'],
      createdAt: data['createdAt'],
      useAutoPay: data['useAutoPay'] == 'yes',
    );
  }
}

class Camera extends Data{
  String name;
  String passwordHash;

  Camera._({
    super.id,
    required this.name,
    required this.passwordHash,
  });

  factory Camera.fromJson(Item json) {
    ItemBody data = json.value;
      return Camera._(
      id:json.key,
      name: data['name'],
      passwordHash: data['passwordHash'],
    );
  } 
}