import 'dart:io';
import 'package:get/get.dart';
import 'package:storyapp/utils/logging/logger.dart';
import 'package:storyapp/features/stories/models/story_model.dart';
import 'package:storyapp/utils/api_exceptions.dart';
import 'package:storyapp/utils/http/http_client.dart';

class StoryRepository extends GetxController {
  static StoryRepository get instance => Get.find();

  final _api = THttpHelper();

  Future<List<StoryModel>> getStories({
    int page = 1,
    int size = 10,
    bool withLocation = false,
  }) async {
    try {
      TLoggerHelper.debug('Fetching stories with params: page=$page, size=$size, location=$withLocation');

      final response = await _api.get(
        '/stories?page=$page&size=$size&location=${withLocation ? 1 : 0}',
      );

      final stories = (response['listStory'] as List)
          .map((story) => StoryModel.fromJson(story))
          .toList();

      TLoggerHelper.debug('Successfully parsed ${stories.length} stories');
      return stories;
    } catch (e) {
      TLoggerHelper.error('Error getting stories', e);
      throw TApiException(message: e.toString());
    }
  }

  Future<StoryModel> getStoryDetail(String storyId) async {
    try {
      TLoggerHelper.debug('Fetching story detail for ID: $storyId');

      final response = await _api.get('/stories/$storyId');
      final story = StoryModel.fromJson(response['story']);

      TLoggerHelper.debug('Successfully parsed story detail');
      return story;
    } catch (e) {
      TLoggerHelper.error('Error getting story detail', e);
      throw TApiException(message: e.toString());
    }
  }

  Future<void> addStory({
    required String description,
    required File photoFile,
    double? lat,
    double? lon,
  }) async {
    try {
      TLoggerHelper.debug('Starting to upload story');
      TLoggerHelper.info('Story details - description: $description, lat: $lat, lon: $lon');

      final response = await _api.uploadStory(
        endpoint: '/stories',
        description: description,
        photo: photoFile,
        lat: lat,
        lon: lon,
      );

      if (response['error'] == true) {
        TLoggerHelper.warning('API returned error: ${response['message']}');
        throw TApiException(message: response['message']);
      }

      TLoggerHelper.info('Story uploaded successfully');
    } catch (e) {
      TLoggerHelper.error('Error adding story', e);
      throw TApiException(message: e.toString());
    }
  }
}