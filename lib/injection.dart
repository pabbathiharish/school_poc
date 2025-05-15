/*
* injection.dart
*
* Created by harishchandra on 15/05/25 1:28 pm.
* Copyright (c) 2025 harishchandra All rights reserved.
*
*/

import 'package:get/get.dart';
import 'package:school_poc/login_controller.dart';
import 'package:school_poc/signup_controller.dart';

void init() {
  Get.lazyPut(fenix: true, () => SignupController());
  Get.lazyPut(fenix: true, () => LoginController());
}
