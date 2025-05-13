/*
* face_crop_service.dart.dart
*
* Created by harishchandra on 11/05/25 10:10 pm.
* Copyright (c) 2025 harishchandra All rights reserved.
*
*/
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as imglib;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class FaceCropService {
  final faceDetector = FaceDetector(
    options: FaceDetectorOptions(enableContours: true),
  );

  Future<File?> detectAndCropFace(File image) async {
    InputImage inputImage;
    if (Platform.isIOS) {
      final File iosImageProcessed = await bakeImageOrientation(image);
      inputImage = InputImage.fromFilePath(iosImageProcessed.path);
    } else {
      inputImage = InputImage.fromFilePath(image.path);
    }
    print('INPUT IMAGE PROCESSED: ${inputImage.filePath}}');

    final faceDetector =
        FaceDetector(options: FaceDetectorOptions(enableContours: true));
    final faces = await faceDetector.processImage(inputImage);
    if (faces.isEmpty) {
      print("No faces detected");
      return null;
    }
    final face = faces.first;
    final faceRect = face.boundingBox;

    final croppedImage = await cropFace1(image.path, faceRect);
    return croppedImage;
  }

  bakeImageOrientation(File pickedFile) async {
    if (Platform.isIOS) {
      final directory = await getApplicationDocumentsDirectory();
      final path = directory.path;
      final filename = DateTime.now().millisecondsSinceEpoch.toString();

      final imglib.Image? capturedImage =
          imglib.decodeImage(await File(pickedFile.path).readAsBytes());

      final imglib.Image orientedImage = imglib.bakeOrientation(capturedImage!);

      final imageToBeProcessed = await File('$path/$filename')
          .writeAsBytes(imglib.encodeJpg(orientedImage));

      return imageToBeProcessed;
    }
    return null;
  }

  Future<File> cropFace1(String imagePath, Rect faceRect) async {
    final originalFile = File(imagePath);
    final bytes = await originalFile.readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    final originalImage = frame.image;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint();

    final adjustedRect = Rect.fromLTWH(
      faceRect.left.clamp(0, originalImage.width.toDouble()),
      faceRect.top.clamp(0, originalImage.height.toDouble()),
      faceRect.width.clamp(0, originalImage.width.toDouble() - faceRect.left),
      faceRect.height.clamp(0, originalImage.height.toDouble() - faceRect.top),
    );

    canvas.drawImageRect(
      originalImage,
      adjustedRect,
      Rect.fromLTWH(0, 0, adjustedRect.width, adjustedRect.height),
      paint,
    );

    final picture = recorder.endRecording();
    final croppedImage = await picture.toImage(
        adjustedRect.width.toInt(), adjustedRect.height.toInt());

    final byteData =
        await croppedImage.toByteData(format: ui.ImageByteFormat.png);
    final pngBytes = byteData!.buffer.asUint8List();

    final appDir = await getApplicationDocumentsDirectory();
    final croppedFile = File(join(appDir.path, 'cropped_face.png'));
    await croppedFile.writeAsBytes(pngBytes);

    return croppedFile;
  }
}
