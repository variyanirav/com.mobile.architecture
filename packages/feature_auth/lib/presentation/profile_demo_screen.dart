import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../di/profile_di.dart';
import '../presentation/profile/pages/profile_page.dart';

/// Example screen to demonstrate the Profile feature
/// This is a simple entry point for testing the Day 7 implementation
class ProfileDemoScreen extends StatelessWidget {
  const ProfileDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Day 7: Profile Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.account_circle, size: 100, color: Colors.blue),
            const SizedBox(height: 24),
            const Text(
              'Day 7 Learning Demo',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'This demo covers:\n'
                '• Code generation (freezed, json_serializable)\n'
                '• DTOs with defensive parsing\n'
                '• Domain models\n'
                '• Repository pattern with Either\n'
                '• Multi-layer error handling\n'
                '• Smart BLoC with retry logic\n'
                '• Comprehensive UI error states',
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BlocProvider.value(
                      value: ProfileDI.profileBloc,
                      child: const ProfilePage(userId: 'user123'),
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text('View User Profile'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {
                _showInfoDialog(context);
              },
              icon: const Icon(Icons.info_outline),
              label: const Text('What to Expect'),
            ),
          ],
        ),
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mock API Behavior'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'The mock API simulates real-world scenarios:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text('• 70% - Success with valid data'),
              Text('• 10% - Garbage data (null fields, bad format)'),
              Text('• 10% - Server error (500)'),
              Text('• 10% - Network timeout'),
              SizedBox(height: 16),
              Text(
                'Try multiple times to see different error handling!',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Features to explore:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Retry button with countdown'),
              Text('• Offline mode (cached data)'),
              Text('• Contact support with reference'),
              Text('• Different error icons/colors by type'),
              Text('• Technical details expansion'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }
}
