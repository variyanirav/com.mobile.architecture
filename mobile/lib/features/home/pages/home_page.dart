import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:feature_auth/feature_auth.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/routes/app_router.dart';

/// Home page shown after successful login
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final user = state is AuthAuthenticated ? state.user : null;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Home'),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () => _handleLogout(context, ref),
                tooltip: 'Logout',
              ),
            ],
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (user?.avatarUrl != null)
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(user!.avatarUrl!),
                  )
                else
                  const CircleAvatar(
                    radius: 50,
                    child: Icon(Icons.person, size: 50),
                  ),
                const SizedBox(height: 24),

                Text(
                  'Welcome ${user?.name ?? 'User'}!',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                Text(
                  user?.email ?? '',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: Colors.grey),
                ),
                const SizedBox(height: 48),

                Card(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          '🎉 Day 6 Complete!',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'You have successfully implemented:',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        _buildCheckItem('✅ Feature-first architecture'),
                        _buildCheckItem('✅ Navigation with go_router'),
                        _buildCheckItem('✅ Clean Architecture layers'),
                        _buildCheckItem('✅ BLoC state management'),
                        _buildCheckItem('✅ Route guards'),
                        _buildCheckItem('✅ Working authentication flow'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCheckItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  void _handleLogout(BuildContext context, WidgetRef ref) {
    // Dispatch logout event to BLoC
    context.read<AuthBloc>().add(AuthLogoutRequested());

    // Update router auth state
    ref.read(authStateProvider.notifier).state = false;

    // Navigate to login
    context.go(AppRoutes.login);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Logged out successfully'),
        backgroundColor: Colors.orange,
      ),
    );
  }
}
