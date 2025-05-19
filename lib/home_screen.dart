/*
* home_screen.dart
*
* Created by harishchandra on 15/05/25 2:29 pm.
* Copyright (c) 2025 harishchandra All rights reserved.
*
*/

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:school_poc/login_controller.dart';
import 'package:school_poc/login_screen.dart';
import 'package:school_poc/signup_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  LoginController ctrlLogin = Get.find();
  SignupController ctrlSignUp = Get.find();
  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text("Dashboard"),
            actions: [
              TextButton(
                  onPressed: () {
                    Get.offAll(LoginScreen());
                  },
                  child: Text("Logout")),
              SizedBox(
                width: 16,
              )
            ],
          ),
          body: SafeArea(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Welcome Back!",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 24),
                  )
                ],
              ).paddingOnly(bottom: 64),
              Image.file(
                ctrlSignUp.image.value,
                width: 150,
                height: 150,
              ).paddingOnly(bottom: 24),
              Text(
                "${ctrlSignUp.ctrlName.value.text.capitalizeFirst}",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 24),
              ),
              Text(
                ctrlSignUp.ctrlStudentId.value.text,
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
              ).paddingOnly(bottom: 8),
              Text(
                ctrlLogin.address.value,
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ).paddingOnly(bottom: 8),
            ],
          )),
        ));
  }
}
