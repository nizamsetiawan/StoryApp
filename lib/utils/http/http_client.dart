import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import '../../data/authentication/authentication_repository.dart';

class THttpHelper {
  static const String _baseUrl = 'https://story-api.dicoding.dev/v1';

  static Map<String, String> _getHeaders() {
    final authRepo = Get.find<AuthenticationRepository>();
    final headers = {
      'Content-Type': 'application/json',
    };

    if (authRepo.isLoggedIn) {
      headers['Authorization'] = 'Bearer ${authRepo.user.token}';
    }

    return headers;
  }

   Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl$endpoint'),
        headers: _getHeaders(),
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to GET data: $e');
    }
  }

   Future<Map<String, dynamic>> post(String endpoint, dynamic data) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl$endpoint'),
        headers: _getHeaders(),
        body: json.encode(data),
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to POST data: $e');
    }
  }

   Future<Map<String, dynamic>> uploadStory({
    required String endpoint,
    required String description,
    required File photo,
    double? lat,
    double? lon,
  }) async {
    try {
      final authRepo = Get.find<AuthenticationRepository>();
      final uri = Uri.parse('$_baseUrl$endpoint');

      var request = http.MultipartRequest('POST', uri);

      // Add headers
      request.headers['Authorization'] = 'Bearer ${authRepo.user.token}';

      // Add fields
      request.fields['description'] = description;
      if (lat != null) request.fields['lat'] = lat.toString();
      if (lon != null) request.fields['lon'] = lon.toString();

      // Add image file
      request.files.add(await http.MultipartFile.fromPath(
        'photo',
        photo.path,
      ));

      // Send request
      final response = await request.send();
      final responseString = await response.stream.bytesToString();
      final responseData = json.decode(responseString);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return responseData;
      } else {
        throw Exception('API Error: ${response.statusCode} - ${responseData['message']}');
      }
    } catch (e) {
      throw Exception('Failed to upload story: $e');
    }
  }

  static Map<String, dynamic> _handleResponse(http.Response response) {
    final responseBody = json.decode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return responseBody;
    } else {
      throw Exception(
          'API Error: ${response.statusCode} - ${responseBody['message']}');
    }
  }
}