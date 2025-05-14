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
          appBar: AppBar(
            title: Text("School Attendance Poc"),
            actions: [
              ElevatedButton(
                  onPressed: () => ctrlLogin.restart(), child: Text("ReStart"))
            ],
          ),
          body: SafeArea(
              child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ctrlLogin.refImage.value.path.isNotEmpty
                    ? ClipPath(
                        clipper:
                            const ShapeBorderClipper(shape: CircleBorder()),
                        clipBehavior: Clip.hardEdge,
                        child:
                            Image.file(ctrlLogin.refImage.value, height: 220),
                      ).paddingOnly(bottom: 8)
                    : Image.asset('assets/images/portrait.png', height: 220),
                ElevatedButton(
                    onPressed: () {
                      Get.to(CameraScreen(onImageCapture: (image) {
                        ctrlLogin.refImage.value = image!;
                      }));
                    },
                    child: Text("Reference Image")),
                SizedBox(height: 20),
                ctrlLogin.newImage.value.path.isNotEmpty
                    ? ClipPath(
                        clipper:
                            const ShapeBorderClipper(shape: CircleBorder()),
                        clipBehavior: Clip.hardEdge,
                        child:
                            Image.file(ctrlLogin.newImage.value, height: 220))
                    : Image.asset('assets/images/portrait.png', height: 220)
                        .paddingOnly(bottom: 8),
                ElevatedButton(
                    onPressed: () {
                      Get.to(CameraScreen(onImageCapture: (image) {
                        ctrlLogin.newImage.value = image!;
                      }));
                    },
                    child: Text("New Image")),
                SizedBox(height: 20),
                Column(
                  children: [
                    ctrlLogin.isLoading.value
                        ? CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: ctrlLogin.compareFaces,
                            child: Text("Authenticate")),
                    SizedBox(height: 20),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                            child: Text(ctrlLogin.resultText.value,
                                textAlign: TextAlign.center))
                      ],
                    ),
                  ],
                ).paddingOnly(bottom: 32),
              ],
            ).paddingAll(16),
          )),
        ));
  }
}
