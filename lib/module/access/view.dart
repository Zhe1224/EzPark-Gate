



import 'package:flutter/material.dart';
import '../../entity/gate.dart';
import '../../widgets/custom.dart';

import 'controller.dart';
import 'view/entry.dart';
import 'view/exit.dart';

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
class AccessView extends StatefulWidget{
  final AccessController controller;
  const AccessView._({super.key, required this.controller}) ;
  factory AccessView.from(Gate gate,{Key? key}){
    return AccessView._(controller: AccessController(gate: gate),key:key);
  }
  @override
  State<AccessView> createState()=> _AccessViewState();
}

// Import the camera package

class _AccessViewState extends State<AccessView> {
  @override
  void initState() {
    super.initState();
  }

  void _displayPage(Widget page){
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => page
      ),
    );
  }

  void _displayEntryScannerPage()  {
    _displayPage(EntryView(controller: widget.controller));
  }

  void _displayExitScannerPage() {
    _displayPage(ExitView(controller: widget.controller));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [CustomText("EZPark"), CustomText("Parking Access and Payment")]
        ),
      ),
      body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            CustomText("Logged in as ${widget.controller.gate.name}"),
            Column(mainAxisAlignment: MainAxisAlignment.spaceAround,spacing:8,
              children: [
                Row(children: [],),
                CustomText("Register Vehicles..."),
                CustomButton(title: "Entry", onPressed: _displayEntryScannerPage),
                CustomButton(title: "Exit", onPressed: _displayExitScannerPage)
              ],
            ),
                SeriousButton(title: "Logout", onPressed: () {
              Navigator.pop(context);
            }),
          ],
      ),
    );
  }
}
