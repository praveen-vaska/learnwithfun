import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/stories_cubit.dart';
import '../core/constants/asset_paths.dart';
import '../core/illustrations/kid_scenes.dart';
import '../features/challenges/daily_challenge_screen.dart';
import '../features/learning/alphabet_grid_screen.dart';
import '../features/learning/lesson_screen.dart';
import '../features/main_nav/main_nav_screen.dart';
import '../features/mini_games/memory_match_screen.dart';
import '../features/mini_games/mini_games_screen.dart';
import '../features/notifications/notifications_screen.dart';
import '../features/onboarding/age_selection_screen.dart';
import '../features/onboarding/choose_avatar_screen.dart';
import '../features/onboarding/create_profile_screen.dart';
import '../features/onboarding/language_selection_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/onboarding/profile_created_screen.dart';
import '../features/parent_zone/parent_dashboard_screen.dart';
import '../features/parent_zone/screen_time_screen.dart';
import '../features/profile/learning_progress_screen.dart';
import '../features/quiz/quiz_question_screen.dart';
import '../features/quiz/quiz_result_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/splash/splash_screen.dart';
import '../features/stories/stories_screen.dart';
import '../features/stories/story_reader_screen.dart';
import '../features/stories/kid_video_player_screen.dart';

/// Debug-only: lets a web build open a screen directly via `?screen=<name>`.
/// Used for visual QA screenshots. Returns null in release builds or when no
/// screen is requested, so the normal splash flow runs.
Widget? debugCatalogScreen() {
  if (kReleaseMode || !kIsWeb) return null;
  final name = Uri.base.queryParameters['screen'];
  if (name == null) return null;
  return _DebugScreenHost(name: name);
}

class _DebugScreenHost extends StatelessWidget {
  final String name;
  const _DebugScreenHost({required this.name});

  @override
  Widget build(BuildContext context) {
    switch (name) {
      case 'scene_reading':
        return _sceneHost(const ReadingHeroScene(size: 380), dark: true);
      case 'scene_rocket':
        return _sceneHost(const RocketBoyScene(size: 380));
      case 'scene_trophy':
        return _sceneHost(const TrophyScene(size: 380));
      case 'scene_castle':
        return _sceneHost(const StoryCastleScene(size: 380));
      case 'splash':
        return const SplashScreen();
      case 'onboarding2':
        return const OnboardingScreen(initialPage: 1);
      case 'onboarding3':
        return const OnboardingScreen(initialPage: 2);
      case 'onboarding':
        return const OnboardingScreen();
      case 'age':
        return const AgeSelectionScreen();
      case 'language':
        return const LanguageSelectionScreen(
          selectedAgeBand: '6 - 8 Years',
          ageNumber: 6,
        );
      case 'create_profile':
        return const CreateProfileScreen(
          selectedAgeBand: '6 - 8 Years',
          ageNumber: 6,
          selectedLanguage: 'English',
        );
      case 'avatar':
        return const ChooseAvatarScreen(currentAvatar: AssetPaths.avatarBoy1);
      case 'profile_created':
        return const ProfileCreatedScreen(childName: 'Arab');
      case 'home':
        return const MainNavScreen();
      case 'categories':
        return const MainNavScreen(initialIndex: 1);
      case 'quiz_intro':
        return const MainNavScreen(initialIndex: 2);
      case 'rewards':
        return const MainNavScreen(initialIndex: 3);
      case 'profile':
        return const MainNavScreen(initialIndex: 4);
      case 'alphabet':
        return const AlphabetGridScreen();
      case 'lesson':
        return const LessonScreen();
      case 'quiz':
        return const QuizQuestionScreen();
      case 'quiz_result':
        return const QuizResultScreen(score: 4, total: 5, earnedXp: 40);
      case 'minigames':
        return const MiniGamesScreen();
      case 'memory':
        return const MemoryMatchScreen();
      case 'challenge':
        return const DailyChallengeScreen();
      case 'stories':
        return const StoriesScreen();
      case 'reader':
        final cubit = context.read<StoriesCubit>();
        if (cubit.state.currentStory == null &&
            cubit.state.stories.isNotEmpty) {
          cubit.openStory(cubit.state.stories[1]);
        }
        return const StoryReaderScreen();
      case 'video':
        final cubit = context.read<StoriesCubit>();
        final videoStory = cubit.state.stories.firstWhere(
          (s) => s.hasVideo,
          orElse: () => cubit.state.stories.first,
        );
        return KidVideoPlayerScreen(story: videoStory);
      case 'progress':
        return const LearningProgressScreen();
      case 'parent':
        return const ParentDashboardScreen();
      case 'screen_time':
        return const ScreenTimeScreen();
      case 'settings':
        return const SettingsScreen();
      case 'notifications':
        return const NotificationsScreen();
      default:
        return const OnboardingScreen();
    }
  }
}

Widget _sceneHost(Widget scene, {bool dark = false}) => Scaffold(
  backgroundColor: dark ? const Color(0xFF7952F5) : const Color(0xFFE6DCFF),
  body: Center(child: scene),
);
