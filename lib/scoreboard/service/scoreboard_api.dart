import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sportwatch_ng/config.dart' as app_config;

import '../models/scoreboard_entry.dart';

class ScoreboardApi {
  Future<List<ScoreboardMatch>> fetchMatches({String? sport}) async {
    final uri = Uri.parse(app_config.scoreboardFilterApi(sport: sport));

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
