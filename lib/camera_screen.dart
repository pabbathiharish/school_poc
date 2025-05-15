/*
* camera_screen.dart
*
* Created by harishchandra on 13/05/25 11:33 pm.
* Copyright (c) 2025 harishchandra All rights reserved.
*
*/

import 'dart:io';
import 'dart:ui' as ui;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as imglib;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import 'main.dart';

class CameraScreen extends StatefulWidget {
  CameraScreen({super.key, required this.onImageCapture});
  Function(File?) onImageCapture;

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  File? _croppedFaceImage;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      firstCamera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.nv21
          : ImageFormatGroup.bgra8888,
    );
    _initializeControllerFuture = _controller.initialize();
  }

  bakeImageOrientation(XFile pickedFile) async {
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

  Future<void> captureAndDetectFace() async {
    try {
      await _initializeControllerFuture;
      final image = await _controller.takePicture();

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
        return;
      }

      final face = faces.first;
      final faceRect = face.boundingBox;

      final croppedImage = await cropFace(image.path, faceRect);

      setState(() {
        _croppedFaceImage = croppedImage;
      });
      widget.onImageCapture(croppedImage);
      faceDetector.close();
      Get.back();
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<File> cropFace(String imagePath, Rect faceRect) async {
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
    final filename = DateTime.now().millisecondsSinceEpoch.toString();
    final croppedFile = File(join(appDir.path, 'cropped_face_$filename.png'));
    await croppedFile.writeAsBytes(pngBytes);

    return croppedFile;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Face Cropper')),
      body: Stack(
        children: [
          Positioned(
              child: FutureBuilder<void>(
            future: _initializeControllerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return CameraPreview(_controller);
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          )),
          Positioned(
              bottom: 16,
              left: Get.width / 2 - 40,
              child: InkWell(
                child: Image.asset(
                  "assets/images/ic_shoot.png",
                  width: 80,
                  height: 80,
                ),
                onTap: () async {
                  captureAndDetectFace();
                },
              )),
        ],
      ),
    );
  }
}
