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

  bool _asBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final lower = value.toLowerCase();
      return lower == 'true' || lower == '1' || lower == 'yes';
    }
    return false;
  }

  Future<void> refresh(
    CookieRequest request, {
    bool throwOnError = false,
  }) async {
    if (!request.loggedIn) {
      _setGuest();
      return;
    }

    final loginData = request.getJsonData();
    _isGuest = false;
    _username = loginData['username']?.toString() ?? _username;
    _email = loginData['email']?.toString() ?? _email;
    _isStaff = _asBool(loginData['is_staff']);
    _isSuperUser = _asBool(loginData['is_superuser']);
    _hasLoaded = false;
    notifyListeners();

    try {
      final response = await request.get(profileUrl);
      if (response is! Map) {
        throw const FormatException('Invalid profile response');
      }
      _username = response['username']?.toString() ?? _username;
      _email = response['email']?.toString() ?? _email;
      _isStaff = _asBool(response['is_staff']);
      _isSuperUser = _asBool(response['is_superuser']);
    } catch (e) {
      if (throwOnError) {
        _hasLoaded = true;
        notifyListeners();
        rethrow;
      }
      // Keep fallback login data when profile endpoint is unavailable.
    } finally {
      _hasLoaded = true;
      notifyListeners();
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
