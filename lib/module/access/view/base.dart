import 'package:flutter/material.dart';
import 'package:parking_gate/styles.dart';

import '../../../service/camera.dart';
import '../../../utility/async_lock.dart';
import '../../../widgets/custom.dart';
import '../../../widgets/now_time_display.dart';
import '../controller.dart';
export '../controller.dart';
export '../../../widgets/custom.dart';
export '../../../utility/async_lock.dart';
export '../../../entity/gate.dart';
export 'package:flutter/material.dart';

abstract class PlateScannerPageBase extends StatefulWidget{
  static const title="Register Vehicle Entry";
  final AccessController controller;
  final CameraController camera;
  const PlateScannerPageBase({super.key, required this.controller, required this.camera});

  @override
  State<PlateScannerPageBase> createState();
}

abstract class PlateScannerPageBaseState extends State<PlateScannerPageBase>{
  bool logging = false;
  Widget? card;
  AsyncLock worker=AsyncLock();

  @override
  void initState(){
    super.initState();
    // To display the current output from the Camera,
    // create a CameraController.
    
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    widget.camera.dispose();
    super.dispose();
  }

  void start();

  void setCard(Widget card){
      setState(() {
        this.card=card;
        Future.delayed(const Duration(seconds:10),(){
          setState(() {this.card=null;});
        });
      });
  }
  
  @override
  Widget build(BuildContext context) {
    List<Widget> buttons=[];
    if (!logging) {buttons.addAll([
      CustomButton(onPressed: () {
        Navigator.pop(context);
      }, title:"<"),
      ConfirmButton(onPressed: () {
        setState(() {
          logging=true;
        });
        start();
      }, title: "Start")
    ]);}else{
      buttons.add(
        SeriousButton(onPressed: () {
          setState(() {
            logging=false;
          });
          widget.camera.stopImageStream();
        }, title: "Stop")
      );
    }
    return Scaffold(
      appBar: AppBar(title:CustomText(PlateScannerPageBase.title)),
      body:
      Padding(padding:EdgeInsets.all(0),child: 
        Stack(
          children:[
            FutureBuilder<void>(
            future: Future.delayed(Duration(),()=>()),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                // If the Future is complete, display the preview.
                return Stack(alignment: AlignmentGeometry.bottomCenter,
                children:[
                  CameraPreview(widget.camera)
                  ,Card(color:AppStyles.pageBackgroundColor,child:
                  Column(mainAxisSize: MainAxisSize.min,
                    children: [
                      card??CustomText(""),
                      NowTimeDisplay(),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceAround ,children: buttons)
                  ]))]);
              } else {
                // Otherwise, display a loading indicator.
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
          ]
        ),
    ));
  }
}