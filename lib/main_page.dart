import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:sportwatch_ng/portal_berita/news_page.dart';
import 'package:sportwatch_ng/user_profile_notifier.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});
  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  bool _profileRequested = false;

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
      // ignore errors; profile will retry when drawer/login used
    }
  }

  @override
  Widget build(BuildContext context) {
    return const NewsPage();
  }
}
