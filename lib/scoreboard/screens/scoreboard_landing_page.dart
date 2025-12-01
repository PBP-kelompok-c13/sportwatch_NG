import 'package:flutter/material.dart';
import 'package:sportwatch_ng/scoreboard/models/scoreboard_entry.dart';
import 'package:sportwatch_ng/scoreboard/service/scoreboard_api.dart';
import 'package:sportwatch_ng/scoreboard/widgets/match_card.dart';
import 'package:sportwatch_ng/scoreboard/widgets/section_title.dart';
import 'package:sportwatch_ng/widgets/theme_toggle_button.dart';
import 'dart:async';

class ScoreboardLandingPage extends StatefulWidget {
  const ScoreboardLandingPage({super.key});

  @override
  State<ScoreboardLandingPage> createState() => _ScoreboardLandingPageState();
}

class _ScoreboardLandingPageState extends State<ScoreboardLandingPage> {
  final _api = ScoreboardApi();

  String _selectedStatus = 'All';
  String _selectedSport = 'All';
  late Future<List<ScoreboardMatch>> _matchesFuture;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadMatches();

    _refreshTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      _loadMatches(silent: true);
    });
  }


  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _loadMatches({bool silent = false}) {
    final String? sportParam =
    _selectedSport == 'All' ? null : _selectedSport;

    if (silent) {
      _matchesFuture = _api.fetchMatches(
        sport: sportParam,
      );
      setState(() {});
      return;
    }

    setState(() {
      _matchesFuture = _api.fetchMatches(
        sport: sportParam,
      );
    });
  }

  void _onStatusChanged(String label) {
    setState(() {
      _selectedStatus = label;
    });
  }

  void _onSportChanged(String label) {
    setState(() {
      _selectedSport = label;
    });
    _loadMatches();
  }


@override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final subtleTextStyle = textTheme.bodySmall?.copyWith(
      color: colorScheme.onSurfaceVariant,
    );
    final width = MediaQuery.of(context).size.width;
    final isCompact = width < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scoreboard'),
        centerTitle: false,
        actions: const [ThemeToggleButton()],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Live Scores & Results',
              style:
              textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'PBP C - Score Tracker by Kelompok 13',
              style: subtleTextStyle,
            ),
            const SizedBox(height: 16),

            Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colorScheme.outlineVariant,
                  width: 1,
                ),
              ),
              child: isCompact
                  ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Status:',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 8),
                      DropdownButton<String>(
                        value: _selectedStatus,
                        underline: const SizedBox(),
                        items: const [
                          DropdownMenuItem(
                            value: 'All',
                            child: Text('All'),
                          ),
                          DropdownMenuItem(
                            value: 'Live',
                            child: Text('Live'),
                          ),
                          DropdownMenuItem(
                            value: 'Finished',
                            child: Text('Finished'),
                          ),
                          DropdownMenuItem(
                            value: 'Upcoming',
                            child: Text('Upcoming'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) _onStatusChanged(value);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        'Sports:',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 8),
                      DropdownButton<String>(
                        value: _selectedSport,
                        underline: const SizedBox(),
                        items: const [
                          DropdownMenuItem(
                              value: 'All', child: Text('All')),
                          DropdownMenuItem(
                              value: 'NBA', child: Text('NBA')),
                          DropdownMenuItem(
                              value: 'EPL', child: Text('EPL')),
                          DropdownMenuItem(
                              value: 'NFL', child: Text('NFL')),
                          DropdownMenuItem(
                              value: 'MLB', child: Text('MLB')),
                          DropdownMenuItem(
                              value: 'NHL', child: Text('NHL')),
                        ],
                        onChanged: (value) {
                          if (value != null) _onSportChanged(value);
                        },
                      ),
                    ],
                  ),
                ],
              )
                  : SingleChildScrollView(
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
                    FilterPill(
                      label: 'All',
                      selected: _selectedStatus == 'All',
                      onTap: () => _onStatusChanged('All'),
                    ),
                    FilterPill(
                      label: 'Live',
                      selected: _selectedStatus == 'Live',
                      onTap: () => _onStatusChanged('Live'),
                    ),
                    FilterPill(
                      label: 'Finished',
                      selected: _selectedStatus == 'Finished',
                      onTap: () => _onStatusChanged('Finished'),
                    ),
                    FilterPill(
                      label: 'Upcoming',
                      selected: _selectedStatus == 'Upcoming',
                      onTap: () => _onStatusChanged('Upcoming'),
                    ),
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
                    FilterPill(
                      label: 'All',
                      selected: _selectedSport == 'All',
                      onTap: () => _onSportChanged('All'),
                    ),
                    FilterPill(
                      label: 'NBA',
                      selected: _selectedSport == 'NBA',
                      onTap: () => _onSportChanged('NBA'),
                    ),
                    FilterPill(
                      label: 'EPL',
                      selected: _selectedSport == 'EPL',
                      onTap: () => _onSportChanged('EPL'),
                    ),
                    FilterPill(
                      label: 'NFL',
                      selected: _selectedSport == 'NFL',
                      onTap: () => _onSportChanged('NFL'),
                    ),
                    FilterPill(
                      label: 'MLB',
                      selected: _selectedSport == 'MLB',
                      onTap: () => _onSportChanged('MLB'),
                    ),
                    FilterPill(
                      label: 'NHL',
                      selected: _selectedSport == 'NHL',
                      onTap: () => _onSportChanged('NHL'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // List matches
            Expanded(
              child: FutureBuilder<List<ScoreboardMatch>>(
                future: _matchesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Failed to load scores:\n${snapshot.error}',
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  final matches = snapshot.data ?? [];

                  final liveMatches = matches
                      .where((m) => m.status == MatchStatus.live)
                      .toList();
                  final finishedMatches = matches
                      .where((m) => m.status == MatchStatus.finished)
                      .toList();
                  final upcomingMatches = matches
                      .where((m) => m.status == MatchStatus.upcoming)
                      .toList();

                  final showLive =
                      _selectedStatus == 'All' || _selectedStatus == 'Live';
                  final showFinished =
                      _selectedStatus == 'All' || _selectedStatus == 'Finished';
                  final showUpcoming =
                      _selectedStatus == 'All' || _selectedStatus == 'Upcoming';

                  if (matches.isEmpty) {
                    return const Center(
                      child: Text('No matches found'),
                    );
                  }

                  return ListView(
                    children: [
                      if (showLive) ...[
                        Row(
                          children: [
                            SectionTitle(
                              title: 'Live Now',
                              color: colorScheme.error,
                            ),
                            const SizedBox(width: 8),

                            if (liveMatches.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: colorScheme.error.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${liveMatches.length} Live',
                                  style: textTheme.labelSmall?.copyWith(
                                    color: colorScheme.error,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (liveMatches.isEmpty)
                          Text(
                            'No live matches',
                            style: subtleTextStyle,
                          )
                        else
                          ...liveMatches.map(
                                (m) => Padding(
                              padding:
                              const EdgeInsets.only(bottom: 12.0),
                              child: MatchCard(match: m),
                            ),
                          ),
                        const SizedBox(height: 24),
                      ],
                      if (showFinished) ...[
                        SectionTitle(
                          title: 'Recent Results',
                          color: colorScheme.secondary,
                        ),
                        const SizedBox(height: 8),
                        if (finishedMatches.isEmpty)
                          Text(
                            'No recent results',
                            style: subtleTextStyle,
                          )
                        else
                          ...finishedMatches.map(
                                (m) => Padding(
                              padding:
                              const EdgeInsets.only(bottom: 12.0),
                              child: MatchCard(match: m),
                            ),
                          ),
                        const SizedBox(height: 24),
                      ],
                      if (showUpcoming) ...[
                        SectionTitle(
                          title: 'Upcoming Match',
                          color: colorScheme.tertiary,
                        ),
                        const SizedBox(height: 8),
                        if (upcomingMatches.isEmpty)
                          Text(
                            'No upcoming matches',
                            style: subtleTextStyle,
                          )
                        else
                          ...upcomingMatches.map(
                                (m) => Padding(
                              padding:
                              const EdgeInsets.only(bottom: 12.0),
                              child: MatchCard(match: m),
                            ),
                          ),
                      ],
                    ],
                  );
                },
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
  final VoidCallback? onTap;

  const FilterPill({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
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

    return GestureDetector(
      onTap: onTap,
      child: Container(
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
      ),
    );
  }
}
