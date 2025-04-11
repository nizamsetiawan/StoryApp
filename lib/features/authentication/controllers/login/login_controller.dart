import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:storyapp/utils/popups/full_screen_loader.dart';

import '../../../../data/authentication/authentication_repository.dart';
import '../../../../utils/constraints/image_strings.dart';
import '../../../../utils/helpers/loaders.dart';

class LoginController extends GetxController {
  static LoginController get instance => Get.find();

  // Variables
  final email = TextEditingController();
  final password = TextEditingController();
  final hidePassword = true.obs;
  final rememberMe = false.obs;
  final loginFormKey = GlobalKey<FormState>();

  // Authentication Repository
  final authRepo = Get.put(AuthenticationRepository());

  Future<void> login() async {
    try {
      // Start Loading
      TFullScreenLoader.openLoadingDialog('Logging in...', TImages.loadingAnimation);

      // Validate Form
      if (!loginFormKey.currentState!.validate()) {
        TFullScreenLoader.stopLoading();
        return;
      }

      // Login User
      await authRepo.login(email.text.trim(), password.text.trim());

      // Stop Loading
      TFullScreenLoader.stopLoading();

      // Redirect
      Get.rootDelegate.offNamed('/home');
    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(title: 'Login Failed', message: e.toString());
    }
  }
}