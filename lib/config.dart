import 'package:flutter/foundation.dart';

const String _webBaseUrl = "http://127.0.0.1:8000";
const String _androidEmulatorBaseUrl = "http://10.0.2.2:8000";

String _resolveBaseUrl() {
  const override = String.fromEnvironment("SPORTWATCH_BASE_URL");
  if (override.isNotEmpty) {
    return override;
  }
  if (kIsWeb) {
    return _webBaseUrl;
  }
  return _androidEmulatorBaseUrl;
}

final String baseUrl = _resolveBaseUrl();

String _authPath(String suffix) {
  final cleaned = suffix.startsWith('/') ? suffix.substring(1) : suffix;
  return "$baseUrl/auth/$cleaned";
}

final String loginUrl = _authPath("login/");
final String registerUrl = _authPath("register/");
final String logoutUrl = _authPath("logout/");
final String profileUrl = _authPath("profile/");

String buildProxyImageUrl(String remoteUrl) {
  final encoded = Uri.encodeComponent(remoteUrl);
  return "${_authPath("proxy-image/")}?url=$encoded";
}

String newsListApi({int page = 1, int perPage = 6}) {
  final safePerPage = perPage.clamp(1, 30);
  final uri = Uri.parse(
    baseUrl,
  ).resolve("/api/news/?page=$page&per_page=$safePerPage");
  return uri.toString();
}

String productsListApi({int page = 1, int perPage = 6, String sort = "featured"}) {
  final safePerPage = perPage.clamp(1, 50);
  final uri = Uri.parse(baseUrl).resolve(
    "/shop/api/products/?page=$page&per_page=$safePerPage&sort=$sort",
  );
  return uri.toString();
}

String searchAnalyticsApi() {
  return Uri.parse(baseUrl).resolve("/search/api/analytics/").toString();
}

String scoreboardFilterApi({String? status, String? sport}) {
  final queryParameters = <String, String>{};
  if (status != null && status.isNotEmpty) {
    queryParameters["status"] = status;
  }
  if (sport != null && sport.isNotEmpty) {
    queryParameters["sport"] = sport;
  }
  final uri = Uri.parse(baseUrl).resolve("/scoreboard/filter/");
  return uri
      .replace(queryParameters: queryParameters.isEmpty ? null : queryParameters)
      .toString();
}
