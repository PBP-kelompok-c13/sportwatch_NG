import 'package:pbp_django_auth/pbp_django_auth.dart';

class FakeCookieRequest extends CookieRequest {
  FakeCookieRequest({
    Map<String, dynamic>? newsResponse,
    Map<String, dynamic>? userData,
  }) {
    _newsResponse = newsResponse ?? _defaultNewsResponse;
    jsonData = userData ?? {};
    initialized = true;
    loggedIn = false;
  }

  late final Map<String, dynamic> _newsResponse;

  @override
  Future init() async {
    initialized = true;
  }

  @override
  Future<dynamic> get(String url) async {
    return _newsResponse;
  }

  @override
  Future<dynamic> logout(String url) async {
    loggedIn = false;
    jsonData = {};
    return {"message": "Logged out"};
  }

  static Map<String, dynamic> get _defaultNewsResponse {
    final now = DateTime(2024, 01, 01).toIso8601String();
    return {
      "results": List.generate(3, (index) {
        return {
          "id": "${index + 1}",
          "judul": "Sample News ${index + 1}",
          "konten": "Sample content for news item ${index + 1}",
          "kategori": index.isEven ? "Football" : "Basketball",
          "thumbnail": "",
          "views": 50 + index,
          "penulis": "Reporter ${index + 1}",
          "sumber": "Automated Test",
          "is_published": true,
          "tanggal_dibuat": now,
          "tanggal_diperbarui": now,
          "reaction_summary": [
            {
              "key": "like",
              "label": "Like",
              "emoji": "👍",
              "count": 10 + index,
            },
          ],
          "user_reaction": null,
        };
      }),
      "has_next": false,
    };
  }
}
