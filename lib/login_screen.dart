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
import 'package:school_poc/images.dart';
import 'package:school_poc/login_controller.dart';
import 'package:school_poc/signup_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  LoginController ctrlLogin = Get.find();
  SignupController ctrlSignUp = Get.find();

  @override
  void initState() {
    super.initState();
    ctrlLogin.initLoginScreen();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
          appBar: AppBar(
              // title: Text("School Attendance Poc"),
              // actions: [
              //   ElevatedButton(
              //       onPressed: () => ctrlLogin.restart(), child: Text("ReStart"))
              // ],
              ),
          body: SafeArea(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Sign In",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 24),
                  )
                ],
              ).paddingOnly(bottom: 62),
              InkWell(
                child: ctrlLogin.newImage.value.path.isNotEmpty
                    ? Image.file(
                        ctrlLogin.newImage.value,
                        width: 150,
                        height: 150,
                      )
                    : Image.asset(
                        Images.person,
                        width: 150,
                        height: 150,
                      ),
                onTap: () {
                  Get.to(CameraScreen(onImageCapture: (pickedImage) {
                    ctrlLogin.newImage.value = pickedImage!;
                  }));
                },
              ),
              Text("Required student photo to authenticate *")
                  .paddingOnly(bottom: 32),
              // ctrlLogin.refImage.value.path.isNotEmpty
              //     ? ClipPath(
              //         clipper:
              //             const ShapeBorderClipper(shape: CircleBorder()),
              //         clipBehavior: Clip.hardEdge,
              //         child:
              //             Image.file(ctrlLogin.refImage.value, height: 220),
              //       ).paddingOnly(bottom: 8)
              //     : Image.asset('assets/images/portrait.png', height: 220),
              // ElevatedButton(
              //     onPressed: () {
              //       Get.to(CameraScreen(onImageCapture: (image) {
              //         ctrlLogin.refImage.value = image!;
              //       }));
              //     },
              //     child: Text("Reference Image")),
              // SizedBox(height: 20),
              // ctrlLogin.newImage.value.path.isNotEmpty
              //     ? ClipPath(
              //         clipper:
              //             const ShapeBorderClipper(shape: CircleBorder()),
              //         clipBehavior: Clip.hardEdge,
              //         child:
              //             Image.file(ctrlLogin.newImage.value, height: 220))
              //     : Image.asset('assets/images/portrait.png', height: 220)
              //         .paddingOnly(bottom: 8),
              // ElevatedButton(
              //     onPressed: () {
              //       Get.to(CameraScreen(onImageCapture: (image) {
              //         ctrlLogin.newImage.value = image!;
              //       }));
              //     },
              //     child: Text("New Image")),
              // SizedBox(height: 20),
              Column(
                children: [
                  ctrlLogin.isLoading.value
                      ? CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: () {
                            ctrlLogin.onTapLogin();
                          },
                          child: Text("Login")),
                  SizedBox(height: 20),
                  // Row(
                  //   crossAxisAlignment: CrossAxisAlignment.center,
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: [
                  //     Expanded(
                  //         child: Text(ctrlLogin.resultText.value,
                  //             textAlign: TextAlign.center))
                  //   ],
                  // ),
                ],
              ),
            ],
          ).paddingAll(16)),
        ));
  }
}
