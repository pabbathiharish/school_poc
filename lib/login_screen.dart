/*
* login_screen.dart
*
* Created by harishchandra on 11/05/25 12:32 am.
* Copyright (c) 2025 harishchandra All rights reserved.
*
*/

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:school_poc/camera_screen.dart';
import 'package:school_poc/login_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  LoginController ctrlLogin = LoginController();

  @override
  void initState() {
    super.initState();
    ctrlLogin.initLoginScreen();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
          body: SafeArea(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Face Reorganisation App").paddingOnly(right: 16),
                  ElevatedButton(
                          onPressed: () => ctrlLogin.restart(),
                          child: Text("ReStart"))
                      .paddingOnly(bottom: 16)
                ],
              ),
              !ctrlLogin.refImage.value.path.isEmpty
                  ? Image.file(ctrlLogin.refImage.value, height: 150)
                      .paddingOnly(bottom: 8)
                  : Container(),
              Row(
                children: [
                  ElevatedButton(
                      onPressed: () => ctrlLogin.pickImage(true),
                      child: Text("Take Reference Image")),
                  ElevatedButton(
                      onPressed: () {
                        Get.to(CameraScreen(onImageCapture: (image) {
                          ctrlLogin.refImage.value = image!;
                        }));
                      },
                      child: Text("Take Cam"))
                ],
              ),
              SizedBox(height: 20),
              !ctrlLogin.newImage.value.path.isEmpty
                  ? Image.file(ctrlLogin.newImage.value, height: 150)
                      .paddingOnly(bottom: 8)
                  : Container(),
              Row(
                children: [
                  ElevatedButton(
                      onPressed: () => ctrlLogin.pickImage(false),
                      child: Text("Take New Image")),
                  ElevatedButton(
                      onPressed: () {
                        Get.to(CameraScreen(onImageCapture: (image) {
                          ctrlLogin.newImage.value = image!;
                        }));
                      },
                      child: Text("Image Cam"))
                ],
              ),
              SizedBox(height: 20),
              Column(
                children: [
                  ctrlLogin.isLoading.value
                      ? CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: ctrlLogin.compareFaces,
                          child: Text("Compare Faces")),
                  SizedBox(height: 20),
                  Text(ctrlLogin.resultText.value, textAlign: TextAlign.center),
                  // ctrlLogin.croppedImages.isNotEmpty
                  //     ? Image.file(ctrlLogin.newImage.value, height: 150)
                  //         .paddingOnly(bottom: 8)
                  //     : Container()
                ],
              ).paddingOnly(bottom: 32),
            ],
          ).paddingAll(16)),
        ));
  }
}
