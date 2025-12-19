

import 'package:camera/camera.dart';
export 'package:camera/camera.dart';

class Cameras{
  static List<CameraDescription>? cameras;
  static Future<List<CameraDescription>> getCameras() async{
    await Future.doWhile(()=>cameras==null);
    return cameras!;
  }
}