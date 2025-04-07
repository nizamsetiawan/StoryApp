import 'package:get/get.dart';
import 'package:storyapp/utils/helpers/network_manager.dart';

import '../data/authentication/authentication_repository.dart';
import '../data/stories/story_repository.dart';
import '../features/authentication/controllers/login/login_controller.dart';
import '../features/authentication/controllers/signup/signup_controller.dart';
import '../features/stories/controllers/story_controller.dart';

class GeneralBindings extends Bindings {

  @override
  void dependencies() {
    Get.put(NetworkManager());
    // Initialize repositories
    Get.lazyPut(() => AuthenticationRepository());
    Get.lazyPut(() => StoryRepository());

    // Initialize controllers
    Get.lazyPut(() => LoginController());
    Get.lazyPut(() => SignupController());
    Get.lazyPut(() => StoryController());
  }
}