import 'package:flutter/material.dart';
import 'package:parking_gate/utility/async_lock.dart';
import 'package:parking_gate/widgets/custom.dart';
import 'package:parking_gate/widgets/loading.dart';

import 'entity/gate.dart';
import 'module/access/view.dart';

///Purpose
///
///Interfaces with gate operators to serve use cases:
///
///Recognise plate number on vehicles
///Log entering vechicles' time and plate number
///Log exiting vehicles' time and plate number
///Calculate payable parking fees
///Initiate payment request
///
///Operation requests are delegated to AccessController
class AuthView extends StatefulWidget{
   //final AuthController controller;
  //final DatabaseService db;
  const AuthView({super.key, /* required this.db, required this.controller */});
  @override
  State<AuthView> createState() =>_AuthViewState();
}

class _AuthViewState extends State<AuthView>{
  AsyncLock worker=AsyncLock();
  //Role role=Role.gate;
  TextEditingController username=TextEditingController();
  TextEditingController password=TextEditingController();
  String? error;
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title:Column(children:[CustomText("EZPark"),CustomText("Parking Access and Payment")])),
      body:Stack(children:[Form(child:
      Padding(padding:EdgeInsets.all(80),child: 
        Column(spacing:8,mainAxisAlignment: MainAxisAlignment.spaceAround,crossAxisAlignment:CrossAxisAlignment.center,children:[
            CustomText('Log in')
            ,Column(spacing:8,mainAxisAlignment: MainAxisAlignment.spaceAround,crossAxisAlignment:CrossAxisAlignment.center,children:[
              /*RadioGroup(groupValue:role,onChanged:(Role?role){setState(() {this.role=role??Role.shopper;}); }, 
              child: Row(spacing:8,mainAxisAlignment:MainAxisAlignment.center,children:[
                Radio(value: Role.shopper)
                ,Radio(value: Role.gate)
              ])),*/TextFormField(controller:username,decoration :InputDecoration(label: CustomText("Username")))
              ,TextFormField(controller:password,decoration :InputDecoration(label:CustomText("Password")),obscureText: true)
              ,CustomText(error??"")
            ]),ConfirmButton(title: 'Login', onPressed: (){push(AccessView.from(Gate(id:"cIeZVZUBAjN2kU89AxwO ",name:"abc@def.ghi",location:"K61LPhzP5nwwp0FYVbny")));})
          ]))),LoadingOverlay(isLoading: worker.busy)
    ]));
  }

  void startLogin(){
    try{login;}
    catch(e){setState(() {error=e.toString();
    });}
  }

  void login() async {
    /*Gate.login(username.text,password.text);*/
    Gate gate = await Gate.login(username.text,password.text);
    /*Gate(id:"cIeZVZUBAjN2kU89AxwO ",name:"abc@def.ghi",location:"K61LPhzP5nwwp0FYVbny");*/
    push(AccessView.from(gate));
    /*
    IDPasswordPair creds=switch (role) {
      Role.shopper =>ShopperIDPasswordPair(loginID:username.text,password:password.text)
      ,Role.gate =>GateIDPasswordPair(loginID:username.text,password:password.text)
    };
    await creds.login();
    push(role.destination(Profile(creds.loginID)));*/
  }
  
  void push(Widget page){
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }
  
}
/*
enum Role{
  shopper,gate;
  String get loginIDFieldLabel=>switch (this) {shopper=>"Email address" ,gate=>"Username"};
  String get passwordFieldLabel=>"Password";
  Widget destination(Profile profile)
    =>switch (this) {
      gate => AccessView.from(profile.loginID),
      shopper => CustomText("")/*  DEPRECATED */
  };
}*/