import 'package:flutter/foundation.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:sportwatch_ng/config.dart';

class UserProfileNotifier extends ChangeNotifier {
  bool? _isStaff;
  bool? _isSuperUser;
  String? _username;
  String? _email;
  bool _hasLoaded = false;

  bool get hasLoaded => _hasLoaded;
  bool get isStaff => _isStaff ?? false;
  bool get isSuperUser => _isSuperUser ?? false;
  String get username => _username ?? '';
  String get email => _email ?? '';

  Future<void> refresh(CookieRequest request) async {
    if (!request.loggedIn) {
      _reset();
      return;
    }
    try {
      final response = await request.get(profileUrl);
      _username = response['username'] as String? ?? _username;
      _email = response['email'] as String? ?? _email;
      _isStaff = response['is_staff'] == true;
      _isSuperUser = response['is_superuser'] == true;
      _hasLoaded = true;
      notifyListeners();
    } catch (e) {
      // keep previous data but mark as loaded to avoid repeated retries
      _hasLoaded = true;
      notifyListeners();
      rethrow;
    }
  }

  void _reset() {
    _isStaff = false;
    _isSuperUser = false;
    _username = null;
    _email = null;
    _hasLoaded = true;
    notifyListeners();
  }
}
