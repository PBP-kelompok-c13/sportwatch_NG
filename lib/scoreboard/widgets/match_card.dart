import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sportwatch_ng/scoreboard/models/scoreboard_entry.dart';
import 'package:google_fonts/google_fonts.dart';

class MatchCard extends StatelessWidget {
  final ScoreboardMatch match;

  const MatchCard({super.key, required this.match});

  Color _statusColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (match.status) {
      case MatchStatus.live:
        return colorScheme.error;
      case MatchStatus.finished:
        return colorScheme.secondary;
      case MatchStatus.upcoming:
        return Colors.amber.shade800;
    }
  }

  String _formattedDate() {
    if (match.date == null) return '';
    final local = match.date!.toLocal();
    return DateFormat.yMMMd().add_jm().format(local);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    Color borderColor = colorScheme.outlineVariant;

    switch (match.status) {
      case MatchStatus.live:
        borderColor = colorScheme.error.withValues(alpha: 0.4);
        break;
      case MatchStatus.finished:
        borderColor = colorScheme.secondary.withValues(alpha: 0.4);
        break;
      case MatchStatus.upcoming:
        borderColor = const Color(0xFFF3C76A);
        break;
    }

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: borderColor, width: 1.5),
      ),
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    match.sportDisplay ?? match.sport,
                    style: textTheme.labelSmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _statusColor(context).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(
                    matchStatusToLabel(match.status).toUpperCase(),
                    style: textTheme.labelSmall?.copyWith(
                      color: _statusColor(context),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _TeamInfo(
                    name: match.homeTeam,
                    logoUrl: match.homeLogoUrl,
                    alignRight: false,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        match.homeScore.toString(),
                        style: GoogleFonts.barlowCondensed(
                          textStyle: textTheme.headlineSmall,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          '-',
                          style: textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      Text(
                        match.awayScore.toString(),
                        style: GoogleFonts.barlowCondensed(
                          textStyle: textTheme.headlineSmall,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _TeamInfo(
                    name: match.awayTeam,
                    logoUrl: match.awayLogoUrl,
                    alignRight: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_formattedDate().isNotEmpty)
              Text(
                _formattedDate(),
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TeamInfo extends StatelessWidget {
  final String name;
  final String? logoUrl;
  final bool alignRight;

  const _TeamInfo({
    required this.name,
    required this.logoUrl,
    required this.alignRight,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final rowChildren = <Widget>[
      if (!alignRight && logoUrl != null && logoUrl!.isNotEmpty)
        _TeamLogo(url: logoUrl!),
      if (!alignRight && logoUrl != null && logoUrl!.isNotEmpty)
        const SizedBox(width: 8),
      Flexible(
        child: Text(
          name,
          style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      if (alignRight && logoUrl != null && logoUrl!.isNotEmpty)
        const SizedBox(width: 8),
      if (alignRight && logoUrl != null && logoUrl!.isNotEmpty)
        _TeamLogo(url: logoUrl!),
    ];

    return Row(
      mainAxisAlignment: alignRight
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: rowChildren,
    );
  }
}

class _TeamLogo extends StatelessWidget {
  final String url;

  const _TeamLogo({required this.url});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: Image.network(
        url,
        width: 36,
        height: 36,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          debugPrint('Error loading logo: $url -> $error');
          return const CircleAvatar(
            radius: 18,
            child: Icon(Icons.sports_soccer, size: 18),
          );
        },
      ),
    );
  }
}
