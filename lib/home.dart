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

  bool _asBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final lower = value.toLowerCase();
      return lower == 'true' || lower == '1' || lower == 'yes';
    }
    return false;
  }

  Future<void> _handleLogout(CookieRequest request) async {
    final profileNotifier = context.read<UserProfileNotifier>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    if (profileNotifier.isGuest) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('You are already browsing as a guest.')),
        );
      navigator.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
      return;
    }

    if (!request.loggedIn) {
      profileNotifier.enterGuestMode();
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Session expired. Continuing as guest.'),
          ),
        );
      navigator.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
      return;
    }

    try {
      final response = await request.logout(logoutUrl);
      final message = response["message"] ?? 'Logged out successfully.';
      profileNotifier.enterGuestMode();
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text("$message You're now browsing as a guest.")),
        );
      navigator.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    } catch (e) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Failed to log out. Please try again.')),
        );
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_profileRequested) {
      _profileRequested = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _ensureProfile();
      });
    }
  }

  Future<void> _ensureProfile() async {
    final profileNotifier = context.read<UserProfileNotifier>();
    final request = context.read<CookieRequest>();
    if (!request.loggedIn) {
      profileNotifier.enterGuestMode();
      return;
    }
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
    final isStaff =
        profile.isStaff || _asBool(request.getJsonData()['is_staff']);
    final userData = request.getJsonData();
    final fallbackUsername = userData['username']?.toString() ?? '';
    final username = profile.isGuest
        ? 'Guest'
        : profile.username.isNotEmpty
        ? profile.username
        : (fallbackUsername.isNotEmpty ? fallbackUsername : 'User');
    final greeting = profile.isGuest ? 'Welcome, Guest' : 'Welcome, $username';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Sportwatch New Generations'),
        actions: [const ThemeToggleButton()],
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
                  profile.isGuest
                      ? 'Login required to access admin tools'
                      : isStaff
                      ? 'Manage content & analytics'
                      : 'Staff only',
                ),
                enabled: !profile.isGuest && isStaff && profile.hasLoaded,
                onTap: profile.isGuest
                    ? null
                    : () {
                        Navigator.pop(context);
                        if (!isStaff) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Admin access is restricted to staff users.',
                              ),
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
              const Divider(),
              if (profile.isGuest)
                ListTile(
                  leading: const Icon(Icons.login),
                  title: const Text('Login'),
                  subtitle: const Text('Sign in to unlock all features'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                    );
                  },
                )
              else
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Logout'),
                  onTap: () {
                    Navigator.pop(context);
                    _handleLogout(request);
                  },
                ),
            ],
          ),
        ),
      ),
      body: const Center(child: Text('Welcome to Sportwatch NG!')),
    );
  }
}
