/*
* compress_object.dart
*
* Created by harishchandra on 13/05/25 11:57 pm.
* Copyright (c) 2025 harishchandra All rights reserved.
*
*/

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as Im;

class CompressObject {
  File imageFile;
  String path;
  int rand;
  CompressObject(this.imageFile, this.path, this.rand);
}

String decodeImage(CompressObject object) {
  Im.Image? image = Im.decodeImage(object.imageFile.readAsBytesSync());
  Im.Image smallerImage = Im.copyResize(image!,
      width: 200,
      height: 200); // choose the size here, it will maintain aspect ratio
  var decodedImageFile = File(object.path + '/img_${object.rand}.jpg');
  decodedImageFile.writeAsBytesSync(Im.encodeJpg(smallerImage, quality: 85));
  return decodedImageFile.path;
}

Future<String> compressImage(CompressObject object) async {
  return compute(decodeImage, object);
}
