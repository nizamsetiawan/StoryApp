import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'app.dart';
import 'data/authentication/authentication_repository.dart';

void main() async {
  /// Widgets binding
  WidgetsFlutterBinding.ensureInitialized();


  /// Load env
  await dotenv.load(fileName: ".env");

  /// Get local storage
  await GetStorage.init();




  /// Initialize authentication repository
  Get.put(AuthenticationRepository());

  // Load all material design/localization/themes/bindings
  runApp(const App());
}