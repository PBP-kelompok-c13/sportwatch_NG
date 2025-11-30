import 'package:flutter/material.dart';
import 'package:sportwatch_ng/scoreboard/widgets/match_card.dart';
import 'package:sportwatch_ng/scoreboard/widgets/section_title.dart';

class ScoreboardLandingPage extends StatelessWidget {
  const ScoreboardLandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scoreboard'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Live Scores & Results',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'PBP C — Score Tracker by Kelompok 13',
              style: TextStyle(
                fontSize: 12,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.grey.shade300,
                  width: 1,
                ),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    const Text(
                      'Status:',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const FilterPill(label: 'All', selected: true),
                    const FilterPill(label: 'Live'),
                    const FilterPill(label: 'Finished'),
                    const FilterPill(label: 'Upcoming'),
                    const SizedBox(width: 12),
                    Container(
                      height: 20,
                      width: 1,
                      color: Colors.grey.shade300,
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Sports:',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const FilterPill(label: 'All', selected: true),
                    const FilterPill(label: 'NBA'),
                    const FilterPill(label: 'EPL'),
                    const FilterPill(label: 'NFL'),
                    const FilterPill(label: 'MLB'),
                    const FilterPill(label: 'NHL'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: ListView(
                children: const [
                  SectionTitle(title: 'Live Now', color: Colors.red),
                  SizedBox(height: 8),
                  MatchCard(
                    league: 'English Premier League',
                    homeTeam: 'Bayern Munchen',
                    awayTeam: 'Borussia Dortmund',
                    homeScore: 1,
                    awayScore: 0,
                    status: MatchStatus.live,
                  ),

                  SizedBox(height: 24),

                  SectionTitle(title: 'Recent Results', color: Colors.grey),
                  SizedBox(height: 8),
                  MatchCard(
                    league: 'English Premier League',
                    homeTeam: 'Real Madrid',
                    awayTeam: 'FC Barcelona',
                    homeScore: 2,
                    awayScore: 1,
                    status: MatchStatus.finished,
                  ),
                  SizedBox(height: 24),

                  SectionTitle(title: 'Upcoming Match', color: Colors.yellow),
                  SizedBox(height: 8),
                  MatchCard(
                    league: 'English Premier League',
                    homeTeam: 'Al Nassr',
                    awayTeam: 'Arsenal',
                    homeScore: 0,
                    awayScore: 0,
                    status: MatchStatus.upcoming,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FilterPill extends StatelessWidget {
  final String label;
  final bool selected;

  const FilterPill({
    super.key,
    required this.label,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: selected ? Colors.black : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: selected ? Colors.white : Colors.black87,
        ),
      ),
    );
  }
}
