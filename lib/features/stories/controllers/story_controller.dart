import 'dart:io';
import 'package:get/get.dart';
import 'package:storyapp/data/stories/story_repository.dart';
import 'package:storyapp/features/stories/models/story_model.dart';
import 'package:storyapp/utils/constraints/image_strings.dart';
import 'package:storyapp/utils/helpers/loaders.dart';
import 'package:storyapp/utils/logging/logger.dart';
import 'package:storyapp/utils/popups/full_screen_loader.dart';

class StoryController extends GetxController {
  static StoryController get instance => Get.find();

  final _storyRepo = Get.put(StoryRepository());
  final stories = <StoryModel>[].obs;
  final isLoading = false.obs;
  final currentPage = 1.obs;
  final hasMore = true.obs;

  @override
  void onInit() {
    fetchStories();
    super.onInit();
  }

  Future<void> fetchStories({bool refresh = false}) async {
    try {
      if (refresh) {
        currentPage.value = 1;
        hasMore.value = true;
        stories.clear();
      }

      if (!hasMore.value) return;

      isLoading.value = true;
      TLoggerHelper.info('Fetching stories page ${currentPage.value}');

      final newStories = await _storyRepo.getStories(
        page: currentPage.value,
        size: 10,
      );

      if (newStories.isEmpty) {
        hasMore.value = false;
        TLoggerHelper.debug('No more stories available');
      } else {
        stories.addAll(newStories);
        currentPage.value++;
        TLoggerHelper.info('Successfully fetched ${newStories.length} stories');
      }
    } catch (e) {
      TLoggerHelper.error('Error fetching stories', e);
      TLoaders.errorSnackBar(
          title: 'Error',
          message: 'Failed to load stories: ${e.toString()}'
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addStory({
    required String description,
    required File photoFile,
    double? lat,
    double? lon,
  }) async {
    try {
      // Start Loading
      TFullScreenLoader.openLoadingDialog('Uploading story...', TImages.loadingAnimation);
      TLoggerHelper.info('Starting story upload process');

      // Upload story
      await _storyRepo.addStory(
        description: description,
        photoFile: photoFile,
        lat: lat,
        lon: lon,
      );

      // Stop Loading
      TFullScreenLoader.stopLoading();
      TLoggerHelper.info('Story uploaded successfully');

      // Show success message
      TLoaders.successSnackBar(
          title: 'Success',
          message: 'Story added successfully'
      );

      // Refresh stories list
      await fetchStories(refresh: true);

      // Navigate back
      Get.until((route) => route.isFirst);
    } catch (e) {
      // Stop Loading
      TFullScreenLoader.stopLoading();
      TLoggerHelper.error('Error uploading story', e);

      // Show error message
      TLoaders.errorSnackBar(
          title: 'Error',
          message: 'Failed to add story: ${e.toString()}'
      );

      rethrow;
    }
  }

  Future<StoryModel> getStoryDetail(String storyId) async {
    try {
      TLoggerHelper.info('Fetching story detail for ID: $storyId');
      final story = await _storyRepo.getStoryDetail(storyId);
      TLoggerHelper.info('Successfully fetched story detail');
      return story;
    } catch (e) {
      TLoggerHelper.error('Error fetching story detail', e);
      TLoaders.errorSnackBar(
          title: 'Error',
          message: 'Failed to load story details: ${e.toString()}'
      );
      rethrow;
    }
  }
}