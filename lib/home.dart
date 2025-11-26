import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:sportwatch_ng/config.dart';
import 'package:sportwatch_ng/login.dart';
import 'package:sportwatch_ng/theme_notifier.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<void> _handleLogout(CookieRequest request) async {
    final response = await request.logout(logoutUrl);
    final message = response["message"] ?? 'Unknown response';
    if (!mounted) return;

    if (response['status']) {
      final uname = response["username"] ?? '';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("$message See you again, $uname.")),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    final themeNotifier = context.watch<ThemeNotifier>();
    final userData = request.getJsonData();
    final rawUsername = userData['username']?.toString() ?? '';
    final username = rawUsername.isNotEmpty ? rawUsername : 'User';
    final greeting = 'Welcome, $username';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Sportwatch New Generations'),
        actions: [
          IconButton(
            tooltip:
                themeNotifier.isDark ? 'Switch to light mode' : 'Switch to dark mode',
            icon: Icon(
              themeNotifier.isDark ? Icons.light_mode : Icons.dark_mode,
            ),
            onPressed: themeNotifier.toggle,
          ),
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
                subtitle: const Text('Placeholder'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Admin panel will be available soon.'),
                      duration: Duration(seconds: 2),
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
