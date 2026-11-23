import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:learnwithfun/app.dart';
import 'package:learnwithfun/blocs/stories_cubit.dart';
import 'package:learnwithfun/blocs/user_cubit.dart';
import 'package:learnwithfun/data/mock/mock_data.dart';
import 'package:learnwithfun/data/services/local_storage_service.dart';
import 'package:learnwithfun/data/repositories/learning_repository.dart';
import 'package:learnwithfun/data/repositories/user_repository.dart';
import 'package:learnwithfun/features/stories/kid_video_player_screen.dart';
import 'package:learnwithfun/features/stories/stories_screen.dart';
import 'package:learnwithfun/features/mini_games/memory_match_screen.dart';

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('App smoke test - starts on SplashScreen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const LearnWithFunApp());
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.bySemanticsLabel('Learn With Fun!'), findsOneWidget);
    expect(find.text('Kids Smart Learning App'), findsOneWidget);
    expect(find.text('Start Learning'), findsOneWidget);
  });

  testWidgets(
    'KidVideoPlayerScreen renders pinned stage, top bar and controls',
    (WidgetTester tester) async {
      final storage = LocalStorageService();
      await storage.init();
      final learningRepo = MockLearningRepository(storage);
      final userRepo = MockUserRepository(storage);

      final story = MockData.stories.firstWhere((s) => s.hasVideo);

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => StoriesCubit(learningRepo)),
            BlocProvider(create: (_) => UserCubit(userRepo)),
          ],
          child: MaterialApp(home: KidVideoPlayerScreen(story: story)),
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));

      // Verify top bar and back button
      expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);
      expect(find.text(story.title), findsAtLeastNWidgets(1));

      // Verify kid navigation action buttons
      expect(find.text('Previous'), findsOneWidget);
      expect(find.text('Replay'), findsOneWidget);
      expect(find.text('Next Song'), findsOneWidget);
      expect(find.text('Yay!'), findsOneWidget);

      // Verify Sing Along Lyrics or Moral section
      if (story.lyrics.isNotEmpty) {
        expect(find.text('Sing Along Lyrics 🎤'), findsOneWidget);
      }
    },
  );

  testWidgets(
    'StoriesScreen renders tabs, filters and story cards without overflow',
    (WidgetTester tester) async {
      final storage = LocalStorageService();
      await storage.init();
      final learningRepo = MockLearningRepository(storage);
      final userRepo = MockUserRepository(storage);

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => StoriesCubit(learningRepo)),
            BlocProvider(create: (_) => UserCubit(userRepo)),
          ],
          child: const MaterialApp(home: StoriesScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Stories & Rhymes'), findsOneWidget);
      expect(find.text('All Languages'), findsOneWidget);
      expect(find.text('Telugu (తెలుగు)'), findsOneWidget);
      expect(find.text('Hindi (हिंदी)'), findsOneWidget);
      expect(find.text('▶ Videos'), findsOneWidget);
    },
  );

  testWidgets('MemoryMatchScreen renders 10 progressive levels and level map', (
    WidgetTester tester,
  ) async {
    final storage = LocalStorageService();
    await storage.init();
    final userRepo = MockUserRepository(storage);

    await tester.pumpWidget(
      BlocProvider(
        create: (_) => UserCubit(userRepo),
        child: const MaterialApp(home: MemoryMatchScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Match Pairs Levels'), findsOneWidget);
    expect(find.text('Solve Level to Unlock Next! 🚀'), findsOneWidget);
    expect(find.text('Level 1'), findsOneWidget);
    expect(find.text('Baby Farm'), findsOneWidget);
    expect(find.text('Play ▶'), findsOneWidget);
  });

  testWidgets('MemoryMatchScreen renders 10 progressive levels and level map', (
    WidgetTester tester,
  ) async {
    final storage = LocalStorageService();
    await storage.init();
    final userRepo = MockUserRepository(storage);

    await tester.pumpWidget(
      BlocProvider(
        create: (_) => UserCubit(userRepo),
        child: const MaterialApp(home: MemoryMatchScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Match Pairs Levels'), findsOneWidget);
    expect(find.text('Solve Level to Unlock Next! 🚀'), findsOneWidget);
    expect(find.text('Level 1'), findsOneWidget);
    expect(find.text('Baby Farm'), findsOneWidget);
    expect(find.text('Play ▶'), findsOneWidget);
  });
}
