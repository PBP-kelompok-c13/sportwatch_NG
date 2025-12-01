
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sportwatch_ng/scoreboard/models/scoreboard_entry.dart';

class ScoreboardApi {
  final String baseUrl = 'http://localhost:8000/scoreboard/filter/';

  Future<List<ScoreboardMatch>> fetchMatches({
    String? sport,
  }) async {
    final uri = Uri.parse(baseUrl).replace(
      queryParameters: {
        if (sport != null) 'sport': sport,
      },
    );

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
