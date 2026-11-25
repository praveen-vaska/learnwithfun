import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/theme/app_theme.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/learning_repository.dart';
import 'data/repositories/user_repository.dart';
import 'data/services/local_storage_service.dart';
import 'blocs/auth_cubit.dart';
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
    final authRepository = LocalAuthRepository();
    final userRepository = MockUserRepository(storage);
    final learningRepository = MockLearningRepository(storage);

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>.value(value: authRepository),
        RepositoryProvider<UserRepository>.value(value: userRepository),
        RepositoryProvider<LearningRepository>.value(value: learningRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>(
            create: (_) => AuthCubit(authRepository, storage)..checkAuthStatus(),
          ),
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
        child: BlocListener<AuthCubit, AuthState>(
          listenWhen: (previous, current) => previous != current,
          listener: (context, authState) {
            if (authState is Authenticated) {
              context.read<UserCubit>().loadForUser(authState.user);
              context.read<LearningCubit>().reloadForUser();
              context.read<QuizCubit>().reloadForUser();
              context.read<DailyChallengeCubit>().reloadForUser();
            } else if (authState is GuestExplorer) {
              context.read<UserCubit>().loadForGuest();
              context.read<LearningCubit>().reloadForUser();
              context.read<QuizCubit>().reloadForUser();
              context.read<DailyChallengeCubit>().reloadForUser();
            } else if (authState is Unauthenticated) {
              context.read<UserCubit>().loadForUser(null);
              context.read<LearningCubit>().reloadForUser();
              context.read<QuizCubit>().reloadForUser();
              context.read<DailyChallengeCubit>().reloadForUser();
            }
          },
          child: MaterialApp(
            title: 'LearnWithFun',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            home: debugCatalogScreen() ?? const SplashScreen(),
          ),
        ),
      ),
    );
  }
}
