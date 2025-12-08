import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

import 'package:sportwatch_ng/config.dart';
import 'package:sportwatch_ng/widgets/theme_toggle_button.dart';

class SearchAdminPage extends StatefulWidget {
  const SearchAdminPage({super.key});

  @override
  State<SearchAdminPage> createState() => _SearchAdminPageState();
}

class _SearchAdminPageState extends State<SearchAdminPage> {
  late Future<_SearchAnalyticsData> _futureAnalytics;

  @override
  void initState() {
    super.initState();
    final request = context.read<CookieRequest>();
    _futureAnalytics = _fetchAnalytics(request);
  }

  Future<_SearchAnalyticsData> _fetchAnalytics(CookieRequest request) async {
    final url = searchAnalyticsApi();
    final response = await request.get(url);
    if (response is! Map<String, dynamic>) {
      throw Exception('Server mengembalikan response non-JSON, pastikan Anda login sebagai staff.');
    }
    if (response.containsKey('error')) {
      final code = response['code']?.toString() ?? '';
      final message = response['error']?.toString() ?? 'Unknown error';
      throw Exception('[$code] $message');
    }
    return _SearchAnalyticsData.fromJson(response);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Admin'),
        actions: const [ThemeToggleButton()],
      ),
      body: FutureBuilder<_SearchAnalyticsData>(
        future: _futureAnalytics,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _buildError(snapshot.error);
          }
          final data = snapshot.data!;
          if (data.topQueries.isEmpty && data.scopeBreakdown.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Belum ada data pencarian yang tercatat.\n'
                  'Cobalah gunakan fitur pencarian di aplikasi dulu.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSummaryHeader(data),
              const SizedBox(height: 16),
              _TopQueriesCard(queries: data.topQueries),
              const SizedBox(height: 16),
              _ScopeBreakdownCard(scopes: data.scopeBreakdown),
            ],
          );
        },
      ),
    );
  }

  Widget _buildError(Object? error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off, size: 48, color: Colors.redAccent),
            const SizedBox(height: 12),
            Text(
              'Gagal memuat data analytics search.\n${error ?? 'Unknown error'}',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryHeader(_SearchAnalyticsData data) {
    final totalQueries =
        data.topQueries.fold<int>(0, (sum, q) => sum + q.total);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ringkasan Pencarian',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Total query tercatat: $totalQueries',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: data.scopeBreakdown
                  .map(
                    (s) => Chip(
                      label: Text('${_scopeLabel(s.scope)} (${s.total})'),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  String _scopeLabel(String raw) {
    switch (raw) {
      case 'all':
        return 'Semua';
      case 'news':
        return 'Berita';
      case 'products':
        return 'Produk';
      default:
        return raw;
    }
  }
}

class _SearchAnalyticsData {
  _SearchAnalyticsData({
    required this.topQueries,
    required this.scopeBreakdown,
  });

  final List<_QueryStat> topQueries;
  final List<_ScopeStat> scopeBreakdown;

  factory _SearchAnalyticsData.fromJson(Map<String, dynamic> json) {
    final topQueries = (json['top_queries'] as List<dynamic>? ?? [])
        .map((item) => _QueryStat.fromJson(item as Map<String, dynamic>))
        .toList();
    final scopes = (json['scope_breakdown'] as List<dynamic>? ?? [])
        .map((item) => _ScopeStat.fromJson(item as Map<String, dynamic>))
        .toList();
    return _SearchAnalyticsData(
      topQueries: topQueries,
      scopeBreakdown: scopes,
    );
  }
}

class _QueryStat {
  _QueryStat({required this.keyword, required this.total});

  final String keyword;
  final int total;

  factory _QueryStat.fromJson(Map<String, dynamic> json) {
    return _QueryStat(
      keyword: json['keyword']?.toString() ?? '-',
      total: (json['total'] as num?)?.toInt() ?? 0,
    );
  }
}

class _ScopeStat {
  _ScopeStat({required this.scope, required this.total});

  final String scope;
  final int total;

  factory _ScopeStat.fromJson(Map<String, dynamic> json) {
    return _ScopeStat(
      scope: json['scope']?.toString() ?? '-',
      total: (json['total'] as num?)?.toInt() ?? 0,
    );
  }
}

class _TopQueriesCard extends StatelessWidget {
  const _TopQueriesCard({required this.queries});

  final List<_QueryStat> queries;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Top Search Queries',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            if (queries.isEmpty)
              const Text(
                'Belum ada query populer.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              )
            else
              ...List.generate(queries.length, (index) {
                final q = queries[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    radius: 14,
                    child: Text('${index + 1}'),
                  ),
                  title: Text(q.keyword),
                  trailing: Text('${q.total}x'),
                );
              }),
          ],
        ),
      ),
    );
  }
}

class _ScopeBreakdownCard extends StatelessWidget {
  const _ScopeBreakdownCard({required this.scopes});

  final List<_ScopeStat> scopes;

  @override
  Widget build(BuildContext context) {
    final total =
        scopes.fold<int>(0, (previousValue, element) => previousValue + element.total);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Scope Breakdown',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            if (scopes.isEmpty)
              const Text(
                'Belum ada data scope pencarian.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              )
            else
              Column(
                children: scopes.map((s) {
                  final percent =
                      total > 0 ? (s.total / total * 100).toStringAsFixed(1) : '0.0';
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(_scopeLabel(s.scope)),
                    subtitle: LinearProgressIndicator(
                      value: total > 0 ? s.total / total : 0,
                    ),
                    trailing: Text('$percent%'),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  String _scopeLabel(String raw) {
    switch (raw) {
      case 'all':
        return 'Semua';
      case 'news':
        return 'Berita';
      case 'products':
        return 'Produk';
      default:
        return raw;
    }
  }
}
