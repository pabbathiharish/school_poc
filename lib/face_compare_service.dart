/*
* face_compare_service.dart
*
* Created by harishchandra on 11/05/25 5:18 pm.
* Copyright (c) 2025 harishchandra All rights reserved.
*
*/
import 'dart:io';
import 'dart:math' as math;
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';

class FaceCompareService {
  late Interpreter _interpreter;
  late List<int> _outputShape;
  late TensorImage _inputImage;
  late TensorBuffer _outputBuffer;

  void loadModel() async {
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

  Future<double> compareFaces(File sourceFile, File destFile) async {
    final emb1 = await getEmbedding(sourceFile);
    final emb2 = await getEmbedding(destFile);
    final sim = cosineSimilarity(emb1, emb2);
    return sim;
  }
}
