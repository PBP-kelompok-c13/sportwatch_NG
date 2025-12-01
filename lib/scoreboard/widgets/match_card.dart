import 'package:flutter/material.dart';

enum MatchStatus {
  live,
  finished,
  upcoming,
}

class MatchCard extends StatelessWidget {
  final String homeTeam;
  final String awayTeam;
  final int homeScore;
  final int awayScore;
  final String league;
  final MatchStatus status;

  const MatchCard({
    super.key,
    required this.homeTeam,
    required this.awayTeam,
    required this.homeScore,
    required this.awayScore,
    required this.league,
    this.status = MatchStatus.live,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: status == MatchStatus.upcoming
            ? Border.all(
          color: Colors.yellow.shade500,
          width: 2,
        )
            : null,
        boxShadow: [
          BoxShadow(
            blurRadius: 6,
            offset: const Offset(0, 3),
            color: Colors.black.withValues(alpha: 0.05),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              league,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                homeTeam,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),

              Text(
                '$homeScore  -  $awayScore',
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),

              Text(
                awayTeam,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Align(
            alignment: Alignment.centerRight,
            child: _buildStatusBadge(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    switch (status) {
      case MatchStatus.live:
        return _badge("LIVE", Colors.red.shade400, Colors.white);

      case MatchStatus.finished:
        return _badge("FT", Colors.blueGrey.shade800, Colors.white);

      case MatchStatus.upcoming:
        return _badge("SOON", Colors.yellow.shade500, Colors.black87);
    }
  }

  Widget _badge(String text, Color bg, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
