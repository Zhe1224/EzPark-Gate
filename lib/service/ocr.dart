import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
export 'package:camera/camera.dart';

class NoTextFound implements Exception {}

class OCRService{
  final TextRecognizer _textRecognizer;
  final InputImageRotation rotation;
  final InputImageFormat format;

  OCRService._(this.rotation, this.format) : _textRecognizer = TextRecognizer();
  factory OCRService.get(){
    return OCRService._(
      InputImageRotation.rotation0deg, 
      Platform.isIOS ? InputImageFormat.bgra8888 : InputImageFormat.nv21
    );
  }

  /// Extract detected text from the provided CameraImage
  Future<String> extract(CameraImage image) async {
    // Convert CameraImage to InputImage
    final inputImage = _convertCameraImage(image,rotation,format);

    // Process the image
    final recognizedText = await _textRecognizer.processImage(inputImage);

    // Check if any texts were found
    if (recognizedText.text.isEmpty) {
      throw NoTextFound();
    }

    return recognizedText.text;
  }

  InputImage _convertCameraImage(
    CameraImage cameraImage, 
    InputImageRotation rotation, 
    InputImageFormat format
  ) {
    final WriteBuffer allBytes = WriteBuffer();
    for (var plane in cameraImage.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    final metadata = InputImageMetadata(
      size: Size(cameraImage.width.toDouble(), cameraImage.height.toDouble()),
      rotation: rotation,
      format: format,
      bytesPerRow: cameraImage.planes[0].bytesPerRow, // Ideally, use the first plane's bytes per row.
    );

    return InputImage.fromBytes(
      bytes: bytes,
      metadata: metadata,
    );
  }

  /// Dispose the resources used by the text recognizer
  void dispose() {
    _textRecognizer.close();
  }
}
