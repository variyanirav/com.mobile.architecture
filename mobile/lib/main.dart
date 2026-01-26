import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:feature_auth/feature_auth.dart';
import 'package:feature_auth/di/profile_di.dart';
import 'package:feature_auth/presentation/profile_demo_screen.dart';
import 'core/routes/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Day 7 Profile feature dependencies
  await ProfileDI.initialize();

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
          title: 'Flutter Architecture - Day 7',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
            useMaterial3: true,
          ),
          routerConfig: router,
          // Add FAB for quick access to Day 7 demo
          builder: (context, child) {
            return Scaffold(
              body: child,
              floatingActionButton: FloatingActionButton.extended(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ProfileDemoScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.science),
                label: const Text('Day 7 Demo'),
                backgroundColor: Colors.orange,
              ),
            );
          },
        ),
      ),
    );
  }
}
