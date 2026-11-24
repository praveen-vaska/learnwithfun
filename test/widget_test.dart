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
import 'package:learnwithfun/features/quiz/quiz_intro_screen.dart';
import 'package:learnwithfun/blocs/quiz_cubit.dart';
import 'package:learnwithfun/features/auth/screens/login_screen.dart';
import 'package:learnwithfun/features/auth/screens/signup_screen.dart';
import 'package:learnwithfun/data/repositories/auth_repository.dart';
import 'package:learnwithfun/blocs/auth_cubit.dart';
import 'package:learnwithfun/blocs/learning_cubit.dart';
import 'package:learnwithfun/features/learning/lesson_screen.dart';

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

  testWidgets('QuizIntroScreen renders 10 progressive levels and animal sound quiz map', (
    WidgetTester tester,
  ) async {
    final storage = LocalStorageService();
    await storage.init();
    final learningRepo = MockLearningRepository(storage);

    await tester.pumpWidget(
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider<LearningRepository>.value(value: learningRepo),
        ],
        child: BlocProvider<QuizCubit>(
          create: (_) => QuizCubit(learningRepo),
          child: const MaterialApp(home: QuizIntroScreen()),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Animal Sounds Quiz'), findsOneWidget);
    expect(find.text('10 Progressive Levels 🏆'), findsOneWidget);
    expect(find.text('Real Animal Sounds!'), findsOneWidget);
    expect(find.text('Play Level 1 ▶️'), findsOneWidget);
    expect(find.text('Very Easy'), findsWidgets);
  });

  testWidgets('LoginScreen renders segmented phone/email toggle and demo quick-fill', (
    WidgetTester tester,
  ) async {
    final storage = LocalStorageService();
    await storage.init();
    final authRepo = LocalAuthRepository(storage);

    await tester.pumpWidget(
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider<AuthRepository>.value(value: authRepo),
        ],
        child: BlocProvider<AuthCubit>(
          create: (_) => AuthCubit(authRepo, storage),
          child: const MaterialApp(home: LoginScreen()),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Welcome Back! 👋'), findsOneWidget);
    expect(find.text('📱 Mobile Number'), findsOneWidget);
    expect(find.text('✉️ Email Address'), findsOneWidget);
    expect(find.text('Login to LearnWithFun 🚀'), findsOneWidget);
    expect(find.text('Sign Up Now'), findsOneWidget);
    expect(find.text('Continue as Guest Explorer 🎈'), findsOneWidget);
  });

  testWidgets('SignUpScreen renders registration inputs and switch options', (
    WidgetTester tester,
  ) async {
    final storage = LocalStorageService();
    await storage.init();
    final authRepo = LocalAuthRepository(storage);

    await tester.pumpWidget(
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider<AuthRepository>.value(value: authRepo),
        ],
        child: BlocProvider<AuthCubit>(
          create: (_) => AuthCubit(authRepo, storage),
          child: const MaterialApp(home: SignUpScreen()),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Join Learn With Fun! 🚀'), findsOneWidget);
    expect(find.text('Parent / Child Name'), findsOneWidget);
    expect(find.text('Create Account 🎉'), findsOneWidget);
    expect(find.text('Login Here'), findsOneWidget);
  });

  testWidgets('LessonScreen renders Previous, Try It! and Next buttons', (
    WidgetTester tester,
  ) async {
    final storage = LocalStorageService();
    await storage.init();
    final learningRepo = MockLearningRepository(storage);
    final userRepo = MockUserRepository(storage);

    final learningCubit = LearningCubit(learningRepo);
    learningCubit.selectCategory('abc');
    final userCubit = UserCubit(userRepo);

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<LearningCubit>.value(value: learningCubit),
          BlocProvider<UserCubit>.value(value: userCubit),
        ],
        child: const MaterialApp(home: LessonScreen()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Previous'), findsOneWidget);
    expect(find.text('Try It! 🌟'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);

    // Tap Try It! 🌟 button to open Duolingo practice sheet
    await tester.tap(find.text('Try It! 🌟'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Duolingo Kid Practice'), findsOneWidget);
    expect(find.text('Speak & Spell 🎤'), findsOneWidget);
    expect(find.text('Trace & Draw ✏️'), findsOneWidget);
    expect(find.text('1. Say "A"'), findsOneWidget);
    expect(find.text('2. Say "A for Apple"'), findsOneWidget);
    expect(find.text('I Said "A"! 🌟'), findsOneWidget);

    // Switch to Trace & Draw tab
    await tester.tap(find.text('Trace & Draw ✏️'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('1. Trace "A"'), findsOneWidget);
    expect(find.text('2. Trace "Apple"'), findsOneWidget);
    expect(find.text('Check My Work 🎨'), findsOneWidget);

    // Tap "Check My Work 🎨" without drawing -> shows prompt SnackBar
    await tester.tap(find.text('Check My Work 🎨'));
    await tester.pump(const Duration(milliseconds: 300));

    // Close the sheet via close button or completion
    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Verify back on LessonScreen with Try It! 🌟 visible and sheet closed
    expect(find.text('Try It! 🌟'), findsOneWidget);
    expect(find.text('Duolingo Kid Practice'), findsNothing);
  });
}
