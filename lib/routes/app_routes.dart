import 'package:get/get.dart';
import '../app.dart';
import '../features/authentication/screens/login/login_screen.dart';
import '../features/authentication/screens/signup/signup_screen.dart';
import '../features/stories/screens/add_story_screen.dart';
import '../features/stories/screens/home_screen.dart';
import '../features/stories/screens/story_detail_screen.dart';

class AppRoutes {
  static final pages = [
    GetPage(
      name: '/',
      page: () => const AuthWrapper(),
      children: [
        GetPage(
          name: '/home',
          page: () => const HomeScreen(),
        ),
      ],
    ),
    GetPage(name: '/login', page: () => const LoginScreen()),
    GetPage(name: '/signup', page: () => const SignupScreen()),
    GetPage(
      name: '/story-detail',
      page: () => StoryDetailScreen(storyId: Get.parameters['id']!),
    ),
    GetPage(name: '/add-story', page: () => const AddStoryScreen()),
  ];
}