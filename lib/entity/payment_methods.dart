import 'package:flutter_stripe/flutter_stripe.dart';

import 'entity.dart';

class PaymentMethods {
  bool loaded=false;
  PaymentMethod? preferred;
  PaymentMethods();
  factory PaymentMethods.fromItems(Items items){
    PaymentMethods out = PaymentMethods();
    Iterable<PaymentMethod> methods = items.entries.map((item)=>PaymentMethod.fromItem({item.key:item.value}.entries.single));
    try{PaymentMethod preferred = methods.firstWhere((method)=>method.prevID==null);
      PaymentMethod now = preferred;
      while (now.nextID!=null) {
        now.next=methods.singleWhere((method)=>now.nextID==method.id);
        now.next!.prev=now;
        now=now.next!;
      }
      out.preferred=preferred;out.loaded=true;return out;
    }
    catch(e){out = PaymentMethods(); out.loaded=true;return out;}
  }

  Future<void> settlePayment(decimal finalFee) async {
    await Future.doWhile(()=>!loaded);
    PaymentMethod? method=preferred;
    while (method!=null) {
      try{method.settlePayment(finalFee);return;
      }catch(e){
        method=method.next;
        continue;
      }
    }
    throw Exception('Payment methods exhausted');
  }
}

class PaymentMethod extends Model{
  static final Stripe service = Stripe.instance;
  ID? prevID;
  ID? nextID;
  PaymentMethod? prev;
  PaymentMethod? next;
  PaymentMethod({super.id});
  factory PaymentMethod.fromItem(Item item){
    PaymentMethod pm = PaymentMethod(id: item.key);
    return pm;
  }
  Future<void> settlePayment(decimal finalFee) async{
    
    //TODO
  }
  
  Future<void> swapPrev()async {
    if (prev==null) return;  //A>B>(C)>D>E
    prev=prev!.prev; //A>(C)>D
    prev!.prev=this; //(C)>B
    prev!.next=next; //B>D
    await Future.wait([update(),prev!.update()]);
  }

  Future<void> swapNext()async {
    if (next==null) return;
    next=next!.next;
    next!.next=this;
    next!.prev=prev;
    await Future.wait([update(),next!.update()]);
  }
  
  Future<void> update()async {
    await Model.database.collection('payment_methods').doc(id).update(toItem().value);
  }

  Future<void> delete()async {
    await Model.database.collection('payment_methods').doc(id).delete();
  }

  Item toItem(){
    //TODO
    return {"":""

    } as Item;
  }
}