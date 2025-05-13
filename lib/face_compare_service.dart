/*
* face_compare_service.dart
*
* Created by harishchandra on 11/05/25 5:18 pm.
* Copyright (c) 2025 harishchandra All rights reserved.
*
*/
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';

class FaceCompareService {
  late Interpreter _interpreter;
  late ImageProcessor _imageProcessor;
  TensorImage? _inputImage;
  TensorBuffer? _outputBuffer;

  final int inputSize = 112;
  final int embeddingDim = 192;

  Future<void> loadModel() async {
    _interpreter = await Interpreter.fromAsset('models/mobilefacenet.tflite');
    _imageProcessor = ImageProcessorBuilder()
        .add(ResizeOp(inputSize, inputSize, ResizeMethod.BILINEAR))
        .build();
  }

  Future<List<double>> getEmbedding(Uint8List imageBytes) async {
    img.Image? baseImage = img.decodeImage(imageBytes);
    if (baseImage == null) throw Exception('Invalid image data');

    _inputImage = TensorImage(TfLiteType.float32);
    _inputImage?.loadImage(baseImage);
    _inputImage = _imageProcessor.process(_inputImage!);

    // Create output buffer with correct shape and type
    final outputTensor = _interpreter.getOutputTensor(0);
    _outputBuffer = TensorBuffer.createFixedSize(
      outputTensor.shape,
      outputTensor.type,
    );

    _interpreter.run(_inputImage!.buffer, _outputBuffer!.buffer);

    return _l2Normalize(_outputBuffer!.getDoubleList());
  }

  bool isSameFace(List<double> emb1, List<double> emb2,
      {double threshold = 1.0}) {
    final dist = math.sqrt(
        List.generate(emb1.length, (i) => math.pow(emb1[i] - emb2[i], 2))
            .reduce((a, b) => a + b));
    return dist < threshold;
  }

  List<double> _l2Normalize(List<double> vector) {
    final norm = math.sqrt(vector.map((e) => e * e).reduce((a, b) => a + b));
    return vector.map((e) => e / norm).toList();
  }
}
