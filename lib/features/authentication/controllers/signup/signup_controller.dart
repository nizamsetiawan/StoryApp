import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:storyapp/utils/constraints/image_strings.dart';
import 'package:storyapp/utils/popups/full_screen_loader.dart';

import '../../../../data/authentication/authentication_repository.dart';
import '../../../../utils/helpers/loaders.dart';

class SignupController extends GetxController {
  static SignupController get instance => Get.find();

  // Variables
  final name = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final hidePassword = true.obs;
  final privacyPolicy = false.obs;
  final signupFormKey = GlobalKey<FormState>();

  // Authentication Repository
  final authRepo = Get.put(AuthenticationRepository());

  Future<void> signup() async {
    try {
      // Start Loading
      TFullScreenLoader.openLoadingDialog('Creating account...', TImages.loadingAnimation);

      // Validate Form
      if (!signupFormKey.currentState!.validate()) {
        TFullScreenLoader.stopLoading();
        return;
      }

      // Check Privacy Policy
      if (!privacyPolicy.value) {
        TLoaders.warningSnackBar(
          title: 'Accept Privacy Policy',
          message: 'You must accept the privacy policy to continue',
        );
        TFullScreenLoader.stopLoading();
        return;
      }

      // Register User
      await authRepo.register(name.text.trim(), email.text.trim(), password.text.trim());

      // Stop Loading
      TFullScreenLoader.stopLoading();

      // Show Success Message
      TLoaders.successSnackBar(
        title: 'Account Created',
        message: 'Your account has been created successfully!',
      );

      // Redirect to Login
      Get.offAllNamed('/login');
    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(title: 'Signup Failed', message: e.toString());
    }
  }
}