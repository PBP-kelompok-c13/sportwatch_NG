import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sportwatch_ng/config.dart' as cfg;

import '../models/scoreboard_entry.dart';

class ScoreboardApi {
  late final String endpoint =
      '${cfg.baseUrl}/scoreboard/filter/'; // reuse backend base URL

  Future<List<ScoreboardMatch>> fetchMatches({
    String? sport,
    String? status,
  }) async {
    final params = <String, String>{};
    if (sport != null) params['sport'] = sport;
    if (status != null) params['status'] = status;

    final uri = Uri.parse(
      endpoint,
    ).replace(queryParameters: params.isEmpty ? null : params);

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to load matches: ${response.statusCode}');
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final List scoresJson = decoded['scores'] as List;

    return scoresJson
        .map((e) => ScoreboardMatch.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
