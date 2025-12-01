import 'package:flutter/material.dart';
import 'package:sportwatch_ng/scoreboard/widgets/match_card.dart';
import 'package:sportwatch_ng/scoreboard/widgets/section_title.dart';
import 'package:sportwatch_ng/widgets/theme_toggle_button.dart';

class ScoreboardLandingPage extends StatelessWidget {
  const ScoreboardLandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final subtleTextStyle = textTheme.bodySmall?.copyWith(
      color: colorScheme.onSurfaceVariant,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scoreboard'),
        centerTitle: true,
        actions: const [ThemeToggleButton()],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Live Scores & Results',
              style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'PBP C - Score Tracker by Kelompok 13',
              style: subtleTextStyle,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colorScheme.outlineVariant,
                  width: 1,
                ),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    Text(
                      'Status:',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
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
                      color: colorScheme.outlineVariant,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Sports:',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
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
                children: [
                  SectionTitle(
                    title: 'Live Now',
                    color: colorScheme.error,
                  ),
                  const SizedBox(height: 8),
                  const MatchCard(
                    league: 'English Premier League',
                    homeTeam: 'Bayern Munchen',
                    awayTeam: 'Borussia Dortmund',
                    homeScore: 1,
                    awayScore: 0,
                    status: MatchStatus.live,
                  ),
                  const SizedBox(height: 24),
                  SectionTitle(
                    title: 'Recent Results',
                    color: colorScheme.secondary,
                  ),
                  const SizedBox(height: 8),
                  const MatchCard(
                    league: 'English Premier League',
                    homeTeam: 'Real Madrid',
                    awayTeam: 'FC Barcelona',
                    homeScore: 2,
                    awayScore: 1,
                    status: MatchStatus.finished,
                  ),
                  const SizedBox(height: 24),
                  SectionTitle(
                    title: 'Upcoming Match',
                    color: colorScheme.tertiary,
                  ),
                  const SizedBox(height: 8),
                  const MatchCard(
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final backgroundColor = selected
        ? colorScheme.primary
        : (theme.brightness == Brightness.dark
            ? colorScheme.surfaceContainerHighest
            : colorScheme.surfaceContainerHigh);
    final foregroundColor =
        selected ? colorScheme.onPrimary : colorScheme.onSurfaceVariant;
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: foregroundColor,
        ),
      ),
    );
  }
}
