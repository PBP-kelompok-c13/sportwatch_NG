import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:sportwatch_ng/admin/admin_panel_page.dart';
import 'package:sportwatch_ng/config.dart';
import 'package:sportwatch_ng/login.dart';
import 'package:sportwatch_ng/user_profile_notifier.dart';
import 'package:sportwatch_ng/widgets/theme_toggle_button.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _profileRequested = false;

  Future<void> _handleLogout(CookieRequest request) async {
    final response = await request.logout(logoutUrl);
    final message = response["message"] ?? 'Unknown response';
    if (!mounted) return;

    if (response['status']) {
      final profileNotifier = context.read<UserProfileNotifier>();
      await profileNotifier.refresh(request);
      if (!mounted) return;
      final uname = response["username"] ?? '';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("$message See you again, $uname.")),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_profileRequested) {
      _profileRequested = true;
      _ensureProfile();
    }
  }

  Future<void> _ensureProfile() async {
    final profileNotifier = context.read<UserProfileNotifier>();
    if (profileNotifier.hasLoaded) return;
    final request = context.read<CookieRequest>();
    try {
      await profileNotifier.refresh(request);
    } catch (_) {
      // Ignore errors; drawer will remain disabled until next attempt.
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    final profile = context.watch<UserProfileNotifier>();
    final userData = request.getJsonData();
    final rawUsername = userData['username']?.toString() ?? '';
    final username = rawUsername.isNotEmpty ? rawUsername : 'User';
    final greeting = 'Welcome, $username';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Sportwatch New Generations'),
        actions: [
          const ThemeToggleButton(),
        ],
      ),
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      greeting,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      username,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.admin_panel_settings_outlined),
                title: const Text('Admin Panel'),
                subtitle: Text(
                  profile.hasLoaded
                      ? (profile.isStaff
                          ? 'Manage content & analytics'
                          : 'Staff only')
                      : 'Checking permissions...',
                ),
                enabled: profile.hasLoaded,
                onTap: !profile.hasLoaded
                    ? null
                    : () {
                        Navigator.pop(context);
                        if (!profile.isStaff) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Admin access is restricted to staff users.'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                          return;
                        }
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AdminPanelPage(),
                          ),
                        );
                      },
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Logout'),
                onTap: () => _handleLogout(request),
              ),
            ],
          ),
        ),
      ),
      body: const Center(child: Text('Welcome to Sportwatch NG!')),
    );
  }
}
