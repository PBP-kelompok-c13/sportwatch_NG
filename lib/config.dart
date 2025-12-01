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

String searchResultsUrl(Map<String, String> queryParameters) {
  final base = Uri.parse(baseUrl).resolve("/search/api/results/");
  if (queryParameters.isEmpty) {
    return base.toString();
  }
  return base.replace(queryParameters: queryParameters).toString();
}

String searchFilterOptionsUrl() {
  return Uri.parse(baseUrl).resolve("/search/api/filter-options/").toString();
}

String featuredProductsUrl({int page = 1}) {
  final uri = Uri.parse(baseUrl).resolve("/shop/api/products/?sort=featured&page=$page");
  return uri.toString();
}
