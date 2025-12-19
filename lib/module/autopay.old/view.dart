import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:parking_gate/module/autopay.old/view/registerform.dart';
import 'package:parking_gate/widgets/custom.dart';

import '../../entity/payment_methods.dart' as me;
import '../../utility/async_lock.dart';
import 'controller.dart';

class AutoPayView extends StatefulWidget{
  final String loginID;
  final AutoPayController controller;
  const AutoPayView._({super.key, required this.controller, required this.loginID}) ;
  factory AutoPayView.from(Database database,String loginID,{Key? key}){
    return AutoPayView._(controller: AutoPayController.get(db:database,loginID:loginID),key:key,loginID:loginID);
  }
  @override
  State<AutoPayView> createState()=> _AutoPayViewState();
}

class _AutoPayViewState extends State<AutoPayView> {
  me.PaymentMethods? paymentMethods;
  bool autoPayEnabled = false;
  AsyncLock worker=AsyncLock();
  bool noMethod()=>paymentMethods?.preferred==null;

  @override
  void initState() {
    super.initState();
    widget.controller.initialisePaymentService();
    Stripe.instance.initPaymentSheet(paymentSheetParameters: .new(
      allowsDelayedPaymentMethods: false,
      setupIntentClientSecret:"",
      intentConfiguration: IntentConfiguration(mode: IntentMode.setupMode(setupFutureUsage: IntentFutureUsage.OffSession))
    ));
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title:CustomText("Automatic Payment")),
      body:Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Column(spacing:4,children: [
        CustomText("Automatic Payment is ${autoPayEnabled?"enabled.":"disabled."}"),
        CustomText(noMethod()
        ?"At least one payment method must be saved before Automatic Payment feature can be enabled."
        :"The first payment method will be charged first. Subsequent payment methods are charged only if previous payment methods fail to settle the payment.")]
        ),Column(spacing:4,children: _paymentMethodEntries(context)),
        Row(spacing:4,mainAxisAlignment:MainAxisAlignment.spaceAround, children: [
          CustomButton(title: '<', onPressed: (){Navigator.pop(context);}),
          noMethod()?DisabledButton(title:"N/A",onPressed: (){}):
          autoPayEnabled?SeriousButton(title:"Disable",onPressed: ()async{
            try{await worker.work(()async{await widget.controller.disable();});}catch (e){ switch (e){
          case BusyStateException _:return;
          default: displayError(e);
        }}})
          :ConfirmButton(title:"Enable",onPressed: ()async{
            try{await worker.work(()async{await widget.controller.enable();});}catch (e){ switch (e){
          case BusyStateException _:return;
          default: displayError(e);
        }}}),
          ConfirmButton(title: "Add New", onPressed: openRegisterForm)
        ],)
      ],
    ));
  }

  void openRegisterForm()async{
     me.PaymentMethod.service.
    var a=await me.PaymentMethod.service.presentPaymentSheet(options: PaymentSheetPresentOptions(
      
    ));
    me.PaymentMethod.service.confirmPaymentSheetPayment();
    me.PaymentMethod.service.confirmSetupIntent(paymentIntentClientSecret: paymentIntentClientSecret, params: params)
    
    /*
    print("registerform");
    var a=await stripe.Stripe.instance.presentPaymentSheet();
    var b=await widget.controller.payment!.registerAutoPaymentMethod({widget.loginID:a?.toJson()??{}}.entries.first);
    await widget.controller.newMethod(b);
  
    
    Stripe.instance.presentPaymentSheet();*/

    Navigator.push(context,
      MaterialPageRoute(
        builder: (context) => RegisterMethodFormView(controller: widget.controller,loginID: widget.loginID),
      ),
    );
  }

   List<Widget> _paymentMethodEntries(BuildContext context){
    List<Widget> pmWidgets=[];
    PMNode? pm=paymentMethods?.firstMethod;
    PMNode? prev;
    while(pm!=null){
      pmWidgets.add(_paymentMethodEntry(context,pm.me,prev?.me,pm.next?.me));
      prev=pm;pm=pm.next;
    }
    return pmWidgets;
  }
  
  Widget _paymentMethodEntry(BuildContext context,PaymentMethod method,PaymentMethod? prev,PaymentMethod? next){
    List<Widget> buttons = [];
    if (prev!=null) buttons.add(_upButton(context,prev,method));
    buttons.add(_closeButton(context,method));
    if (next!=null) buttons.add(_nextButton(context,method,next));
    return 
      Row(children: [
        Column(children: [
          CustomText(method.type),
          CustomText(method.created.toString()),
        ]),
        Column(children: buttons)
      ]);
  }

  Widget _upButton(BuildContext context,PaymentMethod prev,PaymentMethod method){
    return CustomButton(title: 'Up', onPressed: () async {
      try{await worker.work(()async{await widget.controller.swapMethods(prev,method);});}catch (e){ switch (e){
          case BusyStateException _:return;
          default: displayError(e);
        }}});
  }

  Widget _closeButton(BuildContext context,PaymentMethod method){
    return CustomButton(title: 'Delete', onPressed: () async {
      try{await worker.work(()async{await widget.controller.removePaymentMethod(method);});}catch (e){ switch (e){
          case BusyStateException _:return;
          default: displayError(e);
        }}});
    }

  Widget _nextButton(BuildContext context,PaymentMethod method,PaymentMethod next){
    return CustomButton(title: 'Down', onPressed: () async {
      try{await worker.work(()async{await widget.controller.swapMethods(method,next);});}catch (e){ switch (e){
          case BusyStateException _:return;
          default: displayError(e);
        }}});
  }

  void displayError(Object e){
    showModalBottomSheet(context: context,builder: (context) {
      return Scaffold(appBar: AppBar(title:CustomText("Error!")),
      body:Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(children: [
        Column(children: [CustomText("An error occurred while trying to save your payment method:"),
        CustomText(e.toString())]),
        ConfirmButton(title: "OK", onPressed: (){})
        ])
      ])
    );
    });
  }
  //TODO: Dismiss
  Widget displayErrorMessage(BuildContext context,Object e){
    return Scaffold(appBar: AppBar(title:CustomText("Error!")),
      body:Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(children: [
        Column(children: [CustomText("An error occurred while trying to save your payment method:"),
        CustomText(e.toString())]),
        ConfirmButton(title: "OK", onPressed: (){})
        ])
      ])
    );
  }
}
