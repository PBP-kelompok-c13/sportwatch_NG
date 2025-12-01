
enum MatchStatus {
  live,
  finished,
  upcoming,
}

MatchStatus matchStatusFromString(String value) {
  switch (value.toLowerCase()) {
    case 'live':
      return MatchStatus.live;
    case 'finished':
      return MatchStatus.finished;
    case 'upcoming':
      return MatchStatus.upcoming;
    default:
      return MatchStatus.upcoming;
  }
}

String matchStatusToLabel(MatchStatus status) {
  switch (status) {
    case MatchStatus.live:
      return 'Live';
    case MatchStatus.finished:
      return 'Finished';
    case MatchStatus.upcoming:
      return 'Upcoming';
  }
}

class ScoreboardMatch {
  final int id;
  final String homeTeam;
  final String awayTeam;
  final int homeScore;
  final int awayScore;
  final String sport; // kode: EPL / NBA / ...
  final String? sportDisplay; // "English Premier League"
  final MatchStatus status;
  final DateTime? date;
  final String? homeLogoUrl;
  final String? awayLogoUrl;

  ScoreboardMatch({
    required this.id,
    required this.homeTeam,
    required this.awayTeam,
    required this.homeScore,
    required this.awayScore,
    required this.sport,
    required this.status,
    this.sportDisplay,
    this.date,
    this.homeLogoUrl,
    this.awayLogoUrl,
  });

  factory ScoreboardMatch.fromJson(Map<String, dynamic> json) {
    return ScoreboardMatch(
      id: json['id'] as int,
      homeTeam: json['tim1'] as String,
      awayTeam: json['tim2'] as String,
      homeScore: json['skor_tim1'] as int,
      awayScore: json['skor_tim2'] as int,
      sport: json['sport'] as String,
      sportDisplay: json['sport_display'] as String?,
      status: matchStatusFromString(json['status'] as String),
      date: json['tanggal'] != null
          ? DateTime.tryParse(json['tanggal'] as String)
          : null,
      homeLogoUrl: json['logo_tim1'] as String?,
      awayLogoUrl: json['logo_tim2'] as String?,
    );
  }
}
