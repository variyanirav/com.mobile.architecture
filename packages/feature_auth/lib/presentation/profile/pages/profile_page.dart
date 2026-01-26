import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:core/error/failures_freezed.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';

/// Profile page with smart error handling UI
class ProfilePage extends StatelessWidget {
  final String userId;

  const ProfilePage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<ProfileBloc>().add(
                ProfileEvent.refreshProfile(userId: userId),
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          state.maybeWhen(
            error:
                (
                  failure,
                  message,
                  canRetry,
                  retryCount,
                  maxRetries,
                  technicalDetails,
                  shouldShowOfflineMode,
                  shouldContactSupport,
                  supportReference,
                ) {
                  // Show authentication errors with navigation to login
                  if (failure is AuthenticationFailure) {
                    _showAuthErrorDialog(context);
                  }
                },
            orElse: () {},
          );
        },
        builder: (context, state) {
          return state.when(
            initial: () => _buildInitialState(context),
            loading: () => _buildLoadingState(),
            loaded: (profile) => _buildSuccessState(context, profile),
            retrying: (attempt, maxAttempts) =>
                _buildRetryingState(attempt, maxAttempts),
            error:
                (
                  failure,
                  userMessage,
                  canRetry,
                  retryCount,
                  maxRetries,
                  technicalDetails,
                  shouldShowOfflineMode,
                  shouldContactSupport,
                  supportReference,
                ) => _buildErrorState(
                  context,
                  failure,
                  userMessage,
                  canRetry,
                  retryCount,
                  maxRetries,
                  technicalDetails,
                  shouldShowOfflineMode,
                  shouldContactSupport,
                  supportReference,
                ),
          );
        },
      ),
    );
  }

  Widget _buildInitialState(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          context.read<ProfileBloc>().add(
            ProfileEvent.loadProfile(userId: userId),
          );
        },
        child: const Text('Load Profile'),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading profile...'),
        ],
      ),
    );
  }

  Widget _buildRetryingState(int attempt, int maxAttempts) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text('Retrying... (Attempt $attempt of $maxAttempts)'),
        ],
      ),
    );
  }

  Widget _buildSuccessState(BuildContext context, dynamic profile) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar section
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: profile.avatarUrl != null
                      ? NetworkImage(profile.avatarUrl!)
                      : null,
                  child: profile.avatarUrl == null
                      ? Text(
                          profile.displayName[0].toUpperCase(),
                          style: const TextStyle(fontSize: 40),
                        )
                      : null,
                ),
                const SizedBox(height: 16),
                Text(
                  profile.displayName,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                Text(
                  profile.email,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Status badges
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (profile.isActive)
                _buildBadge('Active', Colors.green, Icons.check_circle),
              if (!profile.isActive)
                _buildBadge('Inactive', Colors.red, Icons.cancel),
              if (profile.emailVerified)
                _buildBadge('Verified', Colors.blue, Icons.verified),
              if (!profile.emailVerified)
                _buildBadge('Unverified', Colors.orange, Icons.warning),
            ],
          ),
          const SizedBox(height: 24),

          // Profile details
          _buildInfoCard('Account Information', [
            _buildInfoRow('User ID', profile.id),
            _buildInfoRow('Theme', profile.theme),
            _buildInfoRow(
              'Notifications',
              profile.notificationsEnabled ? 'Enabled' : 'Disabled',
            ),
            _buildInfoRow('Created', _formatDate(profile.createdAt)),
            if (profile.lastLoginAt != null)
              _buildInfoRow('Last Login', _formatDate(profile.lastLoginAt!)),
          ]),
          const SizedBox(height: 16),

          // Profile status indicator
          if (profile.needsUpdate)
            Card(
              color: Colors.orange[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange[700]),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Your profile hasn\'t been updated in over 30 days. Consider reviewing your information.',
                        style: TextStyle(color: Colors.orange[700]),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    Failure failure,
    String userMessage,
    bool canRetry,
    int retryCount,
    int maxRetries,
    String? technicalDetails,
    bool shouldShowOfflineMode,
    bool shouldContactSupport,
    String? supportReference,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Error icon with type-specific color
            Icon(
              _getErrorIcon(failure),
              size: 64,
              color: _getErrorColor(failure),
            ),
            const SizedBox(height: 24),

            // User-friendly error message
            Text(
              userMessage,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),

            // Technical details (for developers/support)
            if (technicalDetails != null)
              ExpansionTile(
                title: const Text(
                  'Technical Details',
                  style: TextStyle(fontSize: 14),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      technicalDetails,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontFamily: 'monospace',
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 24),

            // Action buttons based on error type
            if (canRetry && retryCount < maxRetries) ...[
              ElevatedButton.icon(
                onPressed: () {
                  context.read<ProfileBloc>().add(
                    ProfileEvent.retry(userId: userId),
                  );
                },
                icon: const Icon(Icons.refresh),
                label: Text('Retry (${maxRetries - retryCount} left)'),
              ),
              const SizedBox(height: 8),
            ],

            // Offline mode option
            if (shouldShowOfflineMode) ...[
              OutlinedButton.icon(
                onPressed: () {
                  context.read<ProfileBloc>().add(
                    ProfileEvent.loadCachedProfile(userId: userId),
                  );
                },
                icon: const Icon(Icons.offline_bolt),
                label: const Text('View Offline Version'),
              ),
              const SizedBox(height: 8),
            ],

            // Contact support
            if (shouldContactSupport) ...[
              TextButton.icon(
                onPressed: () {
                  _showContactSupportDialog(context, supportReference);
                },
                icon: const Icon(Icons.support_agent),
                label: const Text('Contact Support'),
              ),
              if (supportReference != null)
                Text(
                  'Reference: $supportReference',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String label, Color color, IconData icon) {
    return Chip(
      avatar: Icon(icon, size: 18, color: color),
      label: Text(label),
      backgroundColor: color.withOpacity(0.1),
      labelStyle: TextStyle(color: color, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  IconData _getErrorIcon(Failure failure) {
    return failure.when(
      network: (_, __) => Icons.wifi_off,
      server: (_, __) => Icons.cloud_off,
      authentication: (_, __) => Icons.lock_outline,
      validation: (_, __) => Icons.error_outline,
      cache: (_, __) => Icons.storage,
      unexpected: (_, __) => Icons.help_outline,
    );
  }

  Color _getErrorColor(Failure failure) {
    return failure.when(
      network: (_, __) => Colors.orange,
      server: (_, __) => Colors.red,
      authentication: (_, __) => Colors.purple,
      validation: (_, __) => Colors.amber,
      cache: (_, __) => Colors.blue,
      unexpected: (_, __) => Colors.grey,
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showAuthErrorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Session Expired'),
        content: const Text(
          'Your session has expired. Please log in again to continue.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Navigate to login page
              // Navigator.of(context).pushReplacementNamed('/login');
            },
            child: const Text('Go to Login'),
          ),
        ],
      ),
    );
  }

  void _showContactSupportDialog(BuildContext context, String? reference) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contact Support'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Please contact support with the following reference number:',
            ),
            const SizedBox(height: 16),
            if (reference != null)
              SelectableText(
                reference,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold,
                ),
              ),
            const SizedBox(height: 16),
            const Text('Support Email: support@example.com'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
