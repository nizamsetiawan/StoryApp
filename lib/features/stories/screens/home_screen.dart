import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:storyapp/features/stories/screens/story_detail_screen.dart';
import '../../../common/widgets/appbar/appbar.dart';
import '../../../data/authentication/authentication_repository.dart';
import '../controllers/story_controller.dart';
import '../models/story_model.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(StoryController());
    return Scaffold(
      appBar: TAppBar(
        title: const Text('Dicoding Stories'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Get.rootDelegate.toNamed('/add-story'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Get.defaultDialog(
                title: 'Logout',
                middleText: 'Are you sure you want to logout?',
                textConfirm: 'Yes',
                textCancel: 'No',
                confirmTextColor: Colors.white,
                onConfirm: () {
                  Get.find<AuthenticationRepository>().logout();
                },              );
            },
          ),
        ],
      ),
      body: Obx(
            () => RefreshIndicator(
          onRefresh: () async => controller.fetchStories(refresh: true),
          child: ListView.builder(
            itemCount: controller.stories.length + (controller.hasMore.value ? 1 : 0),
            itemBuilder: (context, index) {
              if (index < controller.stories.length) {
                final story = controller.stories[index];
                return StoryCard(story: story);
              } else {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                } else {
                  return Center(
                    child: TextButton(
                      onPressed: () => controller.fetchStories(),
                      child: const Text('Load More'),
                    ),
                  );
                }
              }
            },
          ),
        ),
      ),
    );
  }
}

class StoryCard extends StatelessWidget {
  final StoryModel story;

  const StoryCard({super.key, required this.story});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: () => Get.to(() => StoryDetailScreen(storyId: story.id)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(
                story.photoUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    story.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    story.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '${story.createdAt.day}/${story.createdAt.month}/${story.createdAt.year}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}