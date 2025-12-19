import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';

// Use localhost instead of 127.0.0.1 for the web build so the browser treats
// the Flutter dev server and Django backend as the same site. This ensures
// session cookies are sent with cross-origin requests during local testing.
const String _webBaseUrl = "http://localhost:8000";
const String _androidEmulatorBaseUrl = "http://10.0.2.2:8000";
const String _desktopBaseUrl = "http://127.0.0.1:8000";
const String _productionBaseUrl =
    "https://faiz-yusuf-sportwatch.pbp.cs.ui.ac.id";

String _resolveBaseUrl() {
  const override = String.fromEnvironment("SPORTWATCH_BASE_URL");
  if (override.isNotEmpty) {
    return override;
  }
  const useProduction = bool.fromEnvironment("SPORTWATCH_USE_PROD");
  if (useProduction || kReleaseMode) {
    return _productionBaseUrl;
  }
  if (kIsWeb) {
    return _webBaseUrl;
  }
  if (Platform.isAndroid) {
    return _androidEmulatorBaseUrl;
  }
  return _desktopBaseUrl;
}

final String baseUrl = _resolveBaseUrl();

String _authPath(String suffix) {
  final cleaned = suffix.startsWith('/') ? suffix.substring(1) : suffix;
  return "$baseUrl/api/auth/$cleaned";
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

String searchResultsUrl(Map<String, String> queryParameters) {
  final base = Uri.parse(baseUrl).resolve("/api/search/results/");
  if (queryParameters.isEmpty) {
    return base.toString();
  }
  return base.replace(queryParameters: queryParameters).toString();
}

String searchFilterOptionsUrl() {
  return Uri.parse(baseUrl).resolve("/api/search/filter-options/").toString();
}

String featuredProductsUrl({int page = 1}) {
  final uri = Uri.parse(
    baseUrl,
  ).resolve("/api/shop/products/?sort=featured&page=$page");
  return uri.toString();
}

String productsListApi({
  int page = 1,
  int perPage = 6,
  String sort = "featured",
}) {
  final safePerPage = perPage.clamp(1, 50);
  final uri = Uri.parse(
    baseUrl,
  ).resolve("/api/shop/products/?page=$page&per_page=$safePerPage&sort=$sort");
  return uri.toString();
}

String searchAnalyticsApi() {
  return Uri.parse(baseUrl).resolve("/api/search/analytics/").toString();
}

String scoreboardFilterApi({String? status, String? sport}) {
  final queryParameters = <String, String>{};
  if (status != null && status.isNotEmpty) {
    queryParameters["status"] = status;
  }
  if (sport != null && sport.isNotEmpty) {
    queryParameters["sport"] = sport;
  }
  final uri = Uri.parse(baseUrl).resolve("/api/scoreboard/");
  return uri
      .replace(
        queryParameters: queryParameters.isEmpty ? null : queryParameters,
      )
      .toString();
}

// --- News CRUD ---
String createNewsApi() {
  return Uri.parse(baseUrl).resolve("/api/news/create-flutter/").toString();
}

String editNewsApi(String id) {
  return Uri.parse(baseUrl).resolve("/api/news/$id/edit-flutter/").toString();
}

String deleteNewsApi(String id) {
  return Uri.parse(baseUrl).resolve("/api/news/$id/delete-flutter/").toString();
}

String reactToNewsApi(String id) {
  return Uri.parse(baseUrl).resolve("/api/news/$id/react/").toString();
}

String newsCommentsApi(String id) {
  return Uri.parse(baseUrl).resolve("/api/news/$id/comments/").toString();
}

String createCommentApi(String id) {
  return Uri.parse(baseUrl).resolve("/api/news/$id/comment/create/").toString();
}

// --- Scoreboard CRUD ---
String createScoreApi() {
  return Uri.parse(
    baseUrl,
  ).resolve("/api/scoreboard/create/").toString();
}

String editScoreApi(Object id) {
  final safeId = Uri.encodeComponent(id.toString());
  return Uri.parse(
    baseUrl,
  ).resolve("/api/scoreboard/$safeId/edit/").toString();
}

String deleteScoreApi(Object id) {
  final safeId = Uri.encodeComponent(id.toString());
  return Uri.parse(
    baseUrl,
  ).resolve("/api/scoreboard/$safeId/delete/").toString();
}

// --- Shop CRUD ---
String createProductApi() {
  return Uri.parse(baseUrl).resolve("/api/shop/products/create/").toString();
}

String editProductApi(String id) {
  return Uri.parse(
    baseUrl,
  ).resolve("/api/shop/products/$id/edit/").toString();
}

String deleteProductApi(String id) {
  return Uri.parse(
    baseUrl,
  ).resolve("/api/shop/products/$id/delete/").toString();
}
