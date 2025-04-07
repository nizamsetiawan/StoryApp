import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:storyapp/routes/app_routes.dart';
import 'package:storyapp/utils/constraints/colors.dart';
import 'package:storyapp/utils/theme/theme.dart';

import 'bindings/general_bindings.dart';
import 'data/authentication/authentication_repository.dart';
import 'features/onboarding/screens/onboarding_screen.dart';
import 'features/stories/screens/home_screen.dart';


class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: TAppTheme.lightTheme,
      darkTheme: TAppTheme.darkTheme,
      initialBinding: GeneralBindings(),
      getPages: AppRoutes.pages,
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authRepo = Get.put(AuthenticationRepository());
    return Obx(() {
      if (authRepo.isLoggedIn) {
        return const HomeScreen();
      } else {
        return const OnboardingScreen();
      }
    });
  }
}