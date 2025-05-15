/*
* login_controller.dart
*
* Created by harishchandra on 11/05/25 12:33 am.
* Copyright (c) 2025 harishchandra All rights reserved.
*
*/
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:geocoding/geocoding.dart' as geoCoding;
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'package:school_poc/face_compare_service.dart';
import 'package:school_poc/home_screen.dart';
import 'package:school_poc/signup_controller.dart';
import 'package:school_poc/utils.dart';

class LoginController extends GetxController {
  final ImagePicker _picker = ImagePicker();
  var newImage = File("").obs;
  var address = "".obs;
  var isLoading = false.obs;

  // location service
  Location location = Location();
  LocationData? locationData;
  final compareService = FaceCompareService();
  SignupController ctrlSignUp = Get.find();

  void initLoginScreen() async {
    compareService.loadModel();
    initLocation();
  }

  Future<void> pickImage(bool isReference) async {
    final pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        imageQuality: 100);
    if (pickedFile != null) {
      newImage.value = File(pickedFile.path);
    }
  }

  void resetAll() {
    ctrlSignUp.ctrlStudentId.value = TextEditingController();
    ctrlSignUp.ctrlName.value = TextEditingController();
    ctrlSignUp.image.value = File('');
    newImage.value = File("");
  }

  onTapLogin() async {
    if (newImage.value.path.isEmpty) {
      Utils.shared.showAlertDialog(
        "Alert",
        "Image should not empty",
        onClickOk: () {
          Get.back(closeOverlays: true);
        },
      );
    } else {
      isLoading.value = true;
      final sim = await compareService.compareFaces(
          ctrlSignUp.image.value, newImage.value);
      locationData = await location.getLocation();
      List<geoCoding.Placemark> placemarks =
          await geoCoding.placemarkFromCoordinates(
              locationData!.latitude!, locationData!.longitude!);
      address.value =
          '${placemarks.first.name},${placemarks.first.name},${placemarks.first.subLocality},${placemarks.first.locality},${placemarks.first.subAdministrativeArea},${placemarks.first.administrativeArea},${placemarks.first.postalCode},${placemarks.first.country}';
      isLoading.value = false;
      if (sim > 0.80) {
        Utils.shared.showAlertDialog(
          "Success",
          '✅ Face Matched!.\n Authentication Success',
          onClickOk: () {
            Get.back(closeOverlays: true);
            Get.offAll(HomeScreen());
          },
        );
      } else {
        Utils.shared.showAlertDialog(
          "Error",
          '❌ Face Not Matched.\n Authentication Failed!. Please retry uploading proper photo',
          onClickOk: () {
            Get.back(closeOverlays: true);
          },
        );
      }
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
