import 'package:flutter/material.dart';
import 'package:parking_gate/widgets/custom.dart';
import '../utility/async_lock.dart';

import '../entity/payment_methods.dart';
import '../entity/shopper.dart';

class PaymentMethodCards extends StatefulWidget{
  final Shopper shopper;
  final AsyncLock worker;
  const PaymentMethodCards({super.key, required this.shopper, required this.worker});

  @override
  State<PaymentMethodCards> createState() =>_PaymentMethodCardsState();
}

class _PaymentMethodCardsState extends State<PaymentMethodCards>{
  late PaymentMethods methods;

  @override void initState() async {
    super.initState();
    methods=(await widget.worker.work<PaymentMethods>(widget.shopper.getPaymentMethods))!;
  }

  @override
  Widget build(BuildContext context) {
    PaymentMethod? method = methods.preferred;
    List<Widget> cards=[];
    while (method!=null) {
      cards.add(PaymentMethodCard(method:method, worker:widget.worker).build(context));
      method=method.next;
    }
    return ListView(
    children: cards);
  }
}

class PaymentMethodCard extends StatelessWidget{
  final PaymentMethod method;
  final AsyncLock worker;

  const PaymentMethodCard({super.key,required this.method, required this.worker});
  
  @override
  Widget build(BuildContext context){
    List<Widget> buttons = [];
    if (method.prev!=null) buttons.add(button('Up',method.swapPrev));
    buttons.add(button('Delete',method.delete));
    if (method.next!=null) buttons.add(button('Down',method.swapNext));
    //TODO
    return 
      Row(children: [
        Column(children: [
          CustomText(method.type),
          CustomText(method.created.toString()),
        ]),
        Column(children: buttons)
      ]);
  }

  Widget button(String label,Future<void> Function() action){
    return CustomButton(title:label, onPressed: () async {await worker.work(()async{action;});});
  }
}