import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/theme/app_theme.dart';
import 'data/repositories/learning_repository.dart';
import 'data/repositories/user_repository.dart';
import 'data/services/local_storage_service.dart';
import 'blocs/user_cubit.dart';
import 'blocs/learning_cubit.dart';
import 'blocs/quiz_cubit.dart';
import 'blocs/daily_challenge_cubit.dart';
import 'blocs/stories_cubit.dart';
import 'features/splash/splash_screen.dart';
import 'dev/screen_catalog.dart';

class LearnWithFunApp extends StatelessWidget {
  final LocalStorageService? storageService;

  const LearnWithFunApp({super.key, this.storageService});

  @override
  Widget build(BuildContext context) {
    // Local repositories connected to persistent local backend
    final storage = storageService ?? LocalStorageService();
    final userRepository = MockUserRepository(storage);
    final learningRepository = MockLearningRepository(storage);

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<UserRepository>.value(value: userRepository),
        RepositoryProvider<LearningRepository>.value(value: learningRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<UserCubit>(create: (_) => UserCubit(userRepository)),
          BlocProvider<LearningCubit>(
            create: (_) => LearningCubit(learningRepository),
          ),
          BlocProvider<QuizCubit>(create: (_) => QuizCubit(learningRepository)),
          BlocProvider<DailyChallengeCubit>(
            create: (_) => DailyChallengeCubit(learningRepository),
          ),
          BlocProvider<StoriesCubit>(
            create: (_) => StoriesCubit(learningRepository),
          ),
        ],
        child: MaterialApp(
          title: 'LearnWithFun',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          home: debugCatalogScreen() ?? const SplashScreen(),
        ),
      ),
    );
  }
}
