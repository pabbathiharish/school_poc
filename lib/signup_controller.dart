/*
* signup_controller.dart
*
* Created by harishchandra on 12/05/25 9:10 pm.
* Copyright (c) 2025 harishchandra All rights reserved.
*
*/

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:school_poc/login_screen.dart';
import 'package:school_poc/utils.dart';

class SignupController extends GetxController {
  var isLoading = false.obs;
  var image = File('').obs;
  var ctrlName = TextEditingController().obs;
  var ctrlStudentId = TextEditingController().obs;

  onTapSignUp() {
    if (ctrlName.value.text.isEmpty) {
      Utils.shared.showAlertDialog(
        "Alert",
        "Please enter name",
        onClickOk: () {
          Get.back(closeOverlays: true);
        },
      );
    } else if (ctrlStudentId.value.text.isEmpty) {
      Utils.shared.showAlertDialog(
        "Alert",
        "Please enter student id",
        onClickOk: () {
          Get.back(closeOverlays: true);
        },
      );
    } else if (image.value.path.isEmpty) {
      Utils.shared.showAlertDialog(
        "Alert",
        "Image should not empty",
        onClickOk: () {
          Get.back(closeOverlays: true);
        },
      );
    } else {
      isLoading.value = true;
      Future.delayed(Duration(seconds: 2), () {
        isLoading.value = false;
        Utils.shared.showAlertDialog(
          "Signup Successful",
          "Your profile has been created.\nYou can now log in using face recognition.",
          onClickOk: () {
            Get.back(closeOverlays: true);
            Get.to(LoginScreen());
          },
        );
      });
    }
  }
}
