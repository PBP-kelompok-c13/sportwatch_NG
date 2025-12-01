import 'package:flutter/material.dart';

enum MatchStatus { live, finished, upcoming }

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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: status == MatchStatus.upcoming
              ? colorScheme.tertiary
              : colorScheme.outlineVariant,
          width: status == MatchStatus.upcoming ? 2 : 1,
        ),
        boxShadow: theme.brightness == Brightness.light
            ? [
                BoxShadow(
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                  color: colorScheme.shadow.withAlpha((0.05 * 255).round()),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              league,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                homeTeam,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '$homeScore  -  $awayScore',
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                awayTeam,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: _buildStatusBadge(context),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (status) {
      case MatchStatus.live:
        return _badge(context, 'LIVE', colorScheme.error, colorScheme.onError);
      case MatchStatus.finished:
        return _badge(
          context,
          'FT',
          colorScheme.secondary,
          colorScheme.onSecondary,
        );
      case MatchStatus.upcoming:
        return _badge(
          context,
          'SOON',
          colorScheme.tertiaryContainer,
          colorScheme.onTertiaryContainer,
        );
    }
  }

  Widget _badge(
    BuildContext context,
    String text,
    Color background,
    Color foreground,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: foreground,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
