import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'package:storyapp/utils/logging/logger.dart';

import '../../features/authentication/models/user_model.dart';
import '../../utils/api_exceptions.dart';
import '../../utils/http/http_client.dart';

class AuthenticationRepository extends GetxController {
  static AuthenticationRepository get instance => Get.find();

  final _storage = GetStorage();
  final _api = THttpHelper();

  final Rx<UserModel> _user = UserModel.empty().obs;
  UserModel get user => _user.value;

  @override
  void onReady() {
    _loadUserData();
    super.onReady();
  }

  void _loadUserData() {
    final token = _storage.read('AUTH_TOKEN');
    if (token != null) {
      _user.value = UserModel(
        id: _storage.read('USER_ID') ?? '',
        name: _storage.read('USER_NAME') ?? '',
        email: _storage.read('USER_EMAIL') ?? '',
        token: token,
      );
    }
  }

  Future<Map<String, dynamic>> register(String name, String email, String password) async {
    try {
      final response = await _api.post('/register', {
        'name': name,
        'email': email,
        'password': password,
      });

      if (response['error'] == true) {
        throw TApiException(message: response['message']);
      }

      return response;
    } catch (e) {
      TLoggerHelper.error('Registration error', e);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _api.post('/login', {
        'email': email,
        'password': password,
      });

      if (response['error'] == true) {
        throw TApiException(message: response['message']);
      }

      final loginResult = response['loginResult'];
      final user = UserModel.fromJson(loginResult);

      // Save user data
      _user.value = user;
      await _saveUserData(user);

      return response;
    } catch (e) {
      TLoggerHelper.error('Login error', e);
      rethrow;
    }
  }

  Future<void> _saveUserData(UserModel user) async {
    await _storage.write('AUTH_TOKEN', user.token);
  }

  Future<void> logout() async {
    try {
      _user.value = UserModel.empty();
      await _storage.remove('AUTH_TOKEN');
      Get.rootDelegate.offNamed('/login');

    } catch (e) {
      TLoggerHelper.error('Logout error', e);
      rethrow;
    }
  }

  bool get isLoggedIn => _user.value.token.isNotEmpty;
}