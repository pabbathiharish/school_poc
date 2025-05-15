/*
* signup_screen.dart
*
* Created by harishchandra on 15/05/25 1:06 pm.
* Copyright (c) 2025 harishchandra All rights reserved.
*
*/

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:school_poc/camera_screen.dart';
import 'package:school_poc/images.dart';
import 'package:school_poc/signup_controller.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  SignupController ctrlSignUp = Get.find();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "SignUp",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 24),
              ).paddingOnly(bottom: 62),
              InkWell(
                child: ctrlSignUp.image.value.path.isNotEmpty
                    ? Image.file(
                        ctrlSignUp.image.value,
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
                    ctrlSignUp.image.value = pickedImage!;
                  }));
                },
              ),
              Text("Upload student photo*").paddingOnly(bottom: 32),
              TextFormField(
                controller: ctrlSignUp.ctrlStudentId.value,
                decoration: InputDecoration(
                    hintText: "Please enter student id",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    )),
              ).paddingOnly(bottom: 16),
              TextFormField(
                controller: ctrlSignUp.ctrlName.value,
                decoration: InputDecoration(
                    hintText: "Please enter student name",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    )),
              ).paddingOnly(bottom: 32),
              ctrlSignUp.isLoading.value
                  ? CircularProgressIndicator()
                  : FilledButton(
                      onPressed: () {
                        // save info
                        FocusManager.instance.primaryFocus?.unfocus();
                        ctrlSignUp.onTapSignUp();
                      },
                      child: Text("Sign Up")),
            ],
          ).paddingAll(16),
        ));
  }
}
