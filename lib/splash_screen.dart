/*
* splash_screen.dart
*
* Created by harishchandra on 15/05/25 12:52 pm.
* Copyright (c) 2025 harishchandra All rights reserved.
*
*/

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:school_poc/signup_screen.dart';

import 'images.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 2), () {
      Get.offAll(SignupScreen());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset(Images.splash),
      ),
    );
  }
}
