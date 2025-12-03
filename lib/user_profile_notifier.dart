import 'package:flutter/foundation.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:sportwatch_ng/config.dart';

class UserProfileNotifier extends ChangeNotifier {
  bool _isStaff = false;
  bool _isSuperUser = false;
  String _username = 'Guest';
  String? _email;
  bool _hasLoaded = true;
  bool _isGuest = true;

  bool get hasLoaded => _hasLoaded;
  bool get isStaff => _isStaff;
  bool get isSuperUser => _isSuperUser;
  String get username => _username;
  String get email => _email ?? '';
  bool get isGuest => _isGuest;

  Future<void> refresh(CookieRequest request) async {
    if (!request.loggedIn) {
      _setGuest();
      return;
    }
    try {
      final response = await request.get(profileUrl);
      _isGuest = false;
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

  void enterGuestMode() {
    _setGuest();
  }

  void resetToAnonymous() {
    _setGuest();
  }

  void _setGuest({bool notify = true}) {
    _isStaff = false;
    _isSuperUser = false;
    _username = 'Guest';
    _email = null;
    _hasLoaded = true;
    _isGuest = true;
    if (notify) {
      notifyListeners();
    }
  }
}
