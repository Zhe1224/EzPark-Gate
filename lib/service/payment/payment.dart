import '../data.old/data.dart';
export '../data.old/data.dart';

abstract class PaymentService {
  Future<void> settlePayment(PaymentMethods methods,decimal amount);
  Future<String> registerAutoPaymentMethod(Item method);
  Future<void> removePaymentMethod(String methodId);
}

// Custom exceptions
class PaymentMethodNotValid implements Exception {}
class PaymentMethodAlreadyExists implements Exception {}
class NotAuthorized implements Exception {}
class NetworkError implements Exception {}
class PaymentMethodNotExist implements Exception {}
class PaymentMethodRegistrationFailed implements Exception {}
class PaymentMethodRemovalFailed implements Exception {}
class FetchPaymentMethodsFail extends TraceableException {
  FetchPaymentMethodsFail({super.reason});
  @override
  String name() => "Fetch Payment Methods Failed";
}

class PaymentMethod extends Data{
  String user;
  ID? fallback;
  String type;
  String? token;
  DateTime created;
  
  PaymentMethod({
    super.id,
    required this.user,
    this.fallback,
    required this.type,
    this.token,
    required this.created,
  });

  factory PaymentMethod.fromJson(Item json) {
    ItemBody data=json.value;
    return PaymentMethod(
    id:json.key,
    user: data['user'],
    fallback: data['fallback'],
    type: data['type'],
    token: data['token'],
    created: DateTime.parse(data['created']),
  );
  }
/* 
  factory PaymentMethod.fromDetails(PaymentDetails details) {
    ItemBody data=json.value;
    return PaymentMethod(
    id:json.key,
    user: data['user'],
    fallback: data['fallback'],
    type: data['type'],
    token: data['token'],
    created: DateTime.parse(data['created']),
  );
  } */

  Item toJson() {
    return {id!:{
      "user":user
      ,"fallback":fallback
      ,"type":type
      ,"token":token
      ,"created":created
    }}.entries.first;
  }
}

class PMNode{
  PaymentMethod me;
  PMNode? next;
  PMNode({required this.me,this.next});
}

//Linked list styled object for payment methods
class PaymentMethods {
  PMNode? firstMethod;

  PaymentMethods({PMNode? firstMethod});

  factory PaymentMethods.fromJson(Items json){
    Map<ID,PaymentMethod> methods = {};
    json.forEach((id,entry){methods[id]=PaymentMethod.fromJson({id:entry}.entries.first);});
    PaymentMethod first;
    Map<ID,PaymentMethod> filter = methods.map((key, value) => MapEntry(key, value));
    filter.removeWhere((_,method)=>method.fallback!=null);
    if (filter.isEmpty) return PaymentMethods();
    first=filter.values.first;
    PMNode node=PMNode(me:first);
    PMNode now=node;
    while(now.me.fallback!=null){
      now.next=PMNode(me:methods[now.me.fallback] as PaymentMethod);
      now=now.next as PMNode;
    }
    return PaymentMethods(firstMethod: node);
  }
}
