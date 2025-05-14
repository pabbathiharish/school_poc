/*
* login_controller.dart
*
* Created by harishchandra on 11/05/25 12:33 am.
* Copyright (c) 2025 harishchandra All rights reserved.
*
*/
import 'dart:io';
import 'dart:math' as math;
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart' as geoCoding;
import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';

class LoginController extends GetxController {
  late Interpreter _interpreter;
  late List<int> _outputShape;
  late TensorImage _inputImage;
  late TensorBuffer _outputBuffer;

  final ImagePicker _picker = ImagePicker();
  var refImage = File("").obs;
  var newImage = File("").obs;
  var resultText = "".obs;
  var isLoading = false.obs;
  var croppedImages = <File>[].obs;

  // location service
  Location location = Location();
  LocationData? locationData;

  void initLoginScreen() async {
    _loadModel();
    initLocation();
  }

  void _loadModel() async {
    final interpreterOptions = InterpreterOptions();
    _interpreter = await Interpreter.fromAsset('models/mobilefacenet.tflite',
        options: interpreterOptions);
    _outputShape = _interpreter.getOutputTensor(0).shape;
    _outputBuffer = TensorBufferFloat(_outputShape);
  }

  Future<img.Image?> decodeImageInBackground(Uint8List rawBytes) async {
    return await compute(img.decodeImage, rawBytes);
  }

  Future<List<double>> getEmbedding(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final oriImage = await decodeImageInBackground(bytes);
      if (oriImage == null) throw Exception("Image decoding failed");
      // // Resize image
      // final resized = img.copyResize(oriImage,
      //     width: 256, height: 256); // Assuming 112x112 input

      // Load image to TensorImage
      var tensorImage = TensorImage(TfLiteType.float32);
      tensorImage.loadImage(oriImage);

      // Normalize the image [0-255] to [-1, 1] assuming model requires that
      final imageProcessor = ImageProcessorBuilder()
          .add(ResizeOp(112, 112, ResizeMethod.BILINEAR))
          .add(NormalizeOp(127.5, 127.5))
          .build();

      _inputImage = imageProcessor.process(tensorImage);

      // Ensure output buffer is set up
      _outputBuffer = TensorBuffer.createFixedSize(
        _interpreter.getOutputTensor(0).shape,
        _interpreter.getOutputTensor(0).type,
      );

      // Run model
      _interpreter.run(_inputImage.buffer, _outputBuffer.buffer);

      return _l2Normalize(_outputBuffer.getDoubleList());
    } catch (e) {
      print("Error in getEmbedding: $e");
      return [];
    }
  }

  List<double> _l2Normalize(List<double> vector) {
    final norm = vector.map((e) => e * e).reduce((a, b) => a + b);
    final magnitude = norm == 0 ? 1.0 : math.sqrt(norm);
    return vector.map((e) => e / magnitude).toList();
  }

  double cosineSimilarity(List<double> e1, List<double> e2) {
    double dot = 0, normA = 0, normB = 0;
    for (int i = 0; i < e1.length; i++) {
      dot += e1[i] * e2[i];
      normA += e1[i] * e1[i];
      normB += e2[i] * e2[i];
    }
    return dot / (sqrt(normA) * sqrt(normB));
  }

  restart() {
    refImage.value = File('');
    newImage.value = File('');
    resultText.value = '';
    croppedImages.clear();
  }

  Future<void> pickImage(bool isReference) async {
    final pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        imageQuality: 100);
    if (pickedFile != null) {
      if (isReference) {
        refImage.value = File(pickedFile.path);
      } else {
        newImage.value = File(pickedFile.path);
      }
    }
  }

  Future<void> compareFaces() async {
    resultText.value = '';
    if (refImage.value.path != '' && newImage.value.path != '') {
      isLoading.value = true;

      final emb1 = await getEmbedding(refImage.value);
      final emb2 = await getEmbedding(newImage.value);

      final sim = cosineSimilarity(emb1, emb2);
      locationData = await location.getLocation();
      List<geoCoding.Placemark> placemarks =
          await geoCoding.placemarkFromCoordinates(
              locationData!.latitude!, locationData!.longitude!);
      final address =
          '${placemarks.first.name},${placemarks.first.name},${placemarks.first.subLocality},${placemarks.first.locality},${placemarks.first.subAdministrativeArea},${placemarks.first.administrativeArea},${placemarks.first.postalCode},${placemarks.first.country}';
      isLoading.value = false;
      resultText.value = sim > 0.80
          ? '✅ Face Matched! Attendance Marked.\nSimilarity: ${sim.toStringAsFixed(4)} \n Location Info: ${locationData?.latitude?.toStringAsFixed(3)}, ${locationData?.longitude?.toStringAsFixed(3)} \n ${address}'
          : '❌ Face Not Matched.\nSimilarity: ${sim.toStringAsFixed(4)}';
      print(resultText);
    } else {
      isLoading.value = false;
      print("please check image");
    }
  }

  initLocation() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
    // location.changeSettings(
    //     accuracy: LocationAccuracy.high, interval: 10, distanceFilter: 0);
  }
}
