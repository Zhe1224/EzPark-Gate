import 'package:parking_gate/module/autopay.old/data/payment_details/payment_details.dart';
import 'package:parking_gate/service/payment.dart';

import '../../../utility/async_lock.dart';
import '../../../widgets/custom.dart';
import '../controller.dart';

class RegisterMethodFormView extends StatefulWidget {
  final String loginID;
  final AutoPayController controller;
  const RegisterMethodFormView({super.key, required this.controller, required this.loginID}) ;

  @override
  State<RegisterMethodFormView> createState() => _RegisterMethodFormViewState();
}

class _RegisterMethodFormViewState extends State<RegisterMethodFormView>{
  RegisterMethodForm form=RegisterCardMethodForm();
  PaymentMethodTypes type=PaymentMethodTypes.card;
  AsyncLock worker=AsyncLock();
  @override
  Widget build(BuildContext context) {
    return
    Scaffold(
      appBar: AppBar(title:CustomText("Automatic Payment")),
      body:Column(children: [
        RadioGroup(groupValue:type,onChanged:(PaymentMethodTypes? type){setState(() {form=switch (type) {
          PaymentMethodTypes.card=>RegisterCardMethodForm(),
          PaymentMethodTypes.wallet=>RegisterWalletMethodForm(),
          _=>RegisterCardMethodForm(),
        };}); }, 
          child: Row(spacing:8,mainAxisAlignment:MainAxisAlignment.center,children:[
            Radio(value: PaymentMethodTypes.card)
            /*,Radio(value: PaymentMethodTypes.wallet)*/
          ]))
          ,form.build(context)
          ,ConfirmButton(title: "Add New", onPressed: ()async{await worker.work(()async{widget.controller.newMethod(form.details);});})
        ])
    );
  }
}

enum PaymentMethodTypes{
  card,wallet;
}

abstract class RegisterMethodForm{
  final Map<String,TextEditingController> fields={};
  Item get details;
  Widget build(BuildContext context){
    return ListView(children: 
      fields.entries.map((MapEntry<String,TextEditingController> entry){
        return TextFormField(controller: entry.value,decoration: InputDecoration(label:CustomText(entry.key)));
      }).toList()
    );
  }
}

class RegisterCardMethodForm extends RegisterMethodForm{
  @override
  final Map<String,TextEditingController> fields={
    "token":TextEditingController()
  };
  @override
  // TODO: implement details
  Item get details => {'rr':{'type':'card','token':fields["token"]!.text} } as Item;
}

class RegisterWalletMethodForm extends RegisterMethodForm{
  @override
  final Map<String,TextEditingController> fields={

  };
  @override
  // TODO: implement details
  Item get details => throw UnimplementedError();
}