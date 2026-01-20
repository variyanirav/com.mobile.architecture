import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:feature_auth/feature_auth.dart';
import 'core/routes/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    // Set up dependency injection for AuthBloc
    final authRepository = AuthRepositoryImpl();
    final loginUseCase = LoginUseCase(authRepository);

    return BlocProvider(
      create: (_) => AuthBloc(loginUseCase),
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          // Update router auth state when authentication changes
          if (state is AuthAuthenticated) {
            ref.read(authStateProvider.notifier).state = true;
          } else if (state is AuthUnauthenticated) {
            ref.read(authStateProvider.notifier).state = false;
          }
        },
        child: MaterialApp.router(
          title: 'Flutter Architecture - Day 6',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
            useMaterial3: true,
          ),
          routerConfig: router,
        ),
      ),
    );
  }
}

