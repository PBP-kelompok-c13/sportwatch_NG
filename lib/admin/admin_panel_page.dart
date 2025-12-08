import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:sportwatch_ng/admin/news_management_page.dart';
import 'package:sportwatch_ng/admin/product_management_page.dart';
import 'package:sportwatch_ng/admin/score_management_page.dart';
import 'package:sportwatch_ng/admin/search_admin_page.dart';
import 'package:sportwatch_ng/config.dart';
import 'package:sportwatch_ng/user_profile_notifier.dart';
import 'package:sportwatch_ng/widgets/theme_toggle_button.dart';

class AdminPanelPage extends StatefulWidget {
  const AdminPanelPage({super.key});

  @override
  State<AdminPanelPage> createState() => _AdminPanelPageState();
}

class _AdminPanelPageState extends State<AdminPanelPage> {
  Future<_AdminDashboardData>? _dashboardFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_dashboardFuture == null) {
      // Defer loading until after first frame to avoid notifying providers
      // during build (profile.refresh triggers notifyListeners).
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() {
          _dashboardFuture = _loadDashboard();
        });
      });
    }
  }

  Future<_AdminDashboardData> _loadDashboard() async {
    final request = context.read<CookieRequest>();
    final profile = context.read<UserProfileNotifier>();
    if (!request.loggedIn) {
      throw _AdminAccessDenied();
    }

    // Best-effort refresh; keep going with cached login data if the
    // profile endpoint redirects to the login page.
    try {
      await profile.refresh(request);
    } catch (_) {}

    final isStaff =
        profile.isStaff || _asBool(request.getJsonData()['is_staff']);
    if (!isStaff) {
      throw _AdminAccessDenied();
    }

    final newsResponse =
        await _safeGetMap(request, newsListApi(page: 1, perPage: 5));
    final newsTotalResponse =
        await _safeGetMap(request, newsListApi(page: 1, perPage: 1));
    final analyticsResponse =
        await _safeGetMap(request, searchAnalyticsApi());
    final productResponse = await _safeGetMap(
      request,
      productsListApi(page: 1, perPage: 6, sort: "featured"),
    );
    final liveScoresResponse =
        await _safeGetMap(request, scoreboardFilterApi(status: 'live'));
    final finishedScoresResponse =
        await _safeGetMap(request, scoreboardFilterApi(status: 'recent'));
    final upcomingScoresResponse =
        await _safeGetMap(request, scoreboardFilterApi(status: 'upcoming'));

    final newsList = _asList(newsResponse['results'])
        .map((item) => AdminNewsItem.fromJson(_asMap(item)))
        .toList();
    final productList = _asList(productResponse['results'])
        .map((item) => AdminProductItem.fromJson(_asMap(item)))
        .toList();

    return _AdminDashboardData(
      news: newsList,
      totalNews: _asInt(
        newsTotalResponse['total_count'],
        fallback: newsList.length,
      ),
      analytics: AdminAnalytics.fromJson(analyticsResponse),
      products: productList,
      totalProducts: _asInt(
        productResponse['total_count'],
        fallback: productList.length,
      ),
      liveMatches: _asList(liveScoresResponse['scores'])
          .map((item) => AdminMatchItem.fromJson(_asMap(item), status: 'live'))
          .toList(),
      finishedMatches: _asList(finishedScoresResponse['scores'])
          .map(
            (item) => AdminMatchItem.fromJson(_asMap(item), status: 'recent'),
          )
          .toList(),
      upcomingMatches: _asList(upcomingScoresResponse['scores'])
          .map(
            (item) => AdminMatchItem.fromJson(_asMap(item), status: 'upcoming'),
          )
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        actions: const [ThemeToggleButton()],
      ),
      body: FutureBuilder<_AdminDashboardData>(
        future: _dashboardFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            final error = snapshot.error;
            String message;
            if (error is _AdminAccessDenied) {
              message = 'You do not have permission to view this dashboard.';
            } else {
              message = 'Failed to load admin data. Please try again later.';
            }
            return _buildErrorState(context, message);
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data!;
          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _dashboardFuture = _loadDashboard();
              });
              await _dashboardFuture;
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildHeader(context, data),
                const SizedBox(height: 16),
                _buildQuickActions(context),
                const SizedBox(height: 16),
                _buildStatsGrid(context, data),
                const SizedBox(height: 16),
                _SearchAnalyticsCard(analytics: data.analytics),
                const SizedBox(height: 16),
                _NewsSection(news: data.news),
                const SizedBox(height: 16),
                _ProductSection(products: data.products),
                const SizedBox(height: 16),
                _ScoreboardSection(
                  live: data.liveMatches,
                  upcoming: data.upcomingMatches,
                  finished: data.finishedMatches,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, _AdminDashboardData data) {
    final profile = context.watch<UserProfileNotifier>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hello, ${profile.username.isNotEmpty ? profile.username : 'Administrator'}',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(
          'Here is the latest snapshot of SportWatch backend activity.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
           style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ActionChip(
              avatar: const Icon(Icons.newspaper),
              label: const Text('Manage News'),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NewsManagementPage())),
            ),
            ActionChip(
              avatar: const Icon(Icons.shopping_bag),
              label: const Text('Manage Products'),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductManagementPage())),
            ),
            ActionChip(
              avatar: const Icon(Icons.scoreboard),
              label: const Text('Manage Scoreboard'),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ScoreManagementPage())),
            ),
            ActionChip(
              avatar: const Icon(Icons.search),
              label: const Text('Search Analytics'),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SearchAdminPage()),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsGrid(BuildContext context, _AdminDashboardData data) {
    final cards = [
      _StatCardData(
        label: 'Published News',
        value: data.totalNews.toString(),
        icon: Icons.newspaper,
        color: Colors.blue,
      ),
      _StatCardData(
        label: 'Active Products',
        value: data.totalProducts.toString(),
        icon: Icons.shopping_bag,
        color: Colors.green,
      ),
      _StatCardData(
        label: 'Live Matches',
        value: data.liveMatches.length.toString(),
        icon: Icons.sports_soccer,
        color: Colors.red,
      ),
      _StatCardData(
        label: 'Upcoming',
        value: data.upcomingMatches.length.toString(),
        icon: Icons.schedule,
        color: Colors.amber,
      ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 800
            ? 4
            : constraints.maxWidth > 600
            ? 2
            : 1;
        return GridView.count(
          crossAxisCount: crossAxisCount,
          childAspectRatio: 3.2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          children: cards.map((card) => _OverviewStatCard(data: card)).toList(),
        );
      },
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.lock_outline,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}

class AdminNewsItem {
  final String id;
  final String title;
  final String category;
  final bool isPublished;
  final int views;
  final DateTime publishedAt;

  AdminNewsItem({
    required this.id,
    required this.title,
    required this.category,
    required this.isPublished,
    required this.views,
    required this.publishedAt,
  });

  factory AdminNewsItem.fromJson(Map<String, dynamic> json) {
    return AdminNewsItem(
      id: json['id']?.toString() ?? '',
      title: json['judul']?.toString() ?? '-',
      category: json['kategori']?.toString() ?? 'General',
      isPublished: json['is_published'] == true,
      views: (json['views'] as num?)?.toInt() ?? 0,
      publishedAt:
          DateTime.tryParse(json['tanggal_dibuat']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}

class AdminProductItem {
  final String id;
  final String name;
  final String? category;
  final double price;
  final double? salePrice;
  final bool inStock;

  AdminProductItem({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.salePrice,
    required this.inStock,
  });

  factory AdminProductItem.fromJson(Map<String, dynamic> json) {
    return AdminProductItem(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '-',
      category: json['category']?.toString(),
      price: (json['price'] as num?)?.toDouble() ?? 0,
      salePrice: (json['sale_price'] as num?)?.toDouble(),
      inStock: json['in_stock'] == true,
    );
  }
}

class AdminMatchItem {
  final String team1;
  final String team2;
  final String status;
  final String sport;
  final int? score1;
  final int? score2;

  AdminMatchItem({
    required this.team1,
    required this.team2,
    required this.status,
    required this.sport,
    this.score1,
    this.score2,
  });

  factory AdminMatchItem.fromJson(
    Map<String, dynamic> json, {
    required String status,
  }) {
    return AdminMatchItem(
      team1: json['tim1']?.toString() ?? '-',
      team2: json['tim2']?.toString() ?? '-',
      status: status,
      sport:
          json['sport_display']?.toString() ?? json['sport']?.toString() ?? '',
      score1: (json['skor_tim1'] as num?)?.toInt(),
      score2: (json['skor_tim2'] as num?)?.toInt(),
    );
  }
}

class AdminAnalytics {
  final List<AdminQueryStat> topQueries;
  final List<ScopeStat> scopeBreakdown;

  AdminAnalytics({required this.topQueries, required this.scopeBreakdown});

  factory AdminAnalytics.fromJson(Map<String, dynamic> json) {
    final topQueries = (json['top_queries'] as List<dynamic>? ?? [])
        .map((item) => AdminQueryStat.fromJson(item))
        .toList();
    final scopes = (json['scope_breakdown'] as List<dynamic>? ?? [])
        .map((item) => ScopeStat.fromJson(item))
        .toList();
    return AdminAnalytics(topQueries: topQueries, scopeBreakdown: scopes);
  }
}

class AdminQueryStat {
  final String keyword;
  final int total;

  AdminQueryStat({required this.keyword, required this.total});

  factory AdminQueryStat.fromJson(Map<String, dynamic> json) {
    return AdminQueryStat(
      keyword: json['keyword']?.toString() ?? '-',
      total: (json['total'] as num?)?.toInt() ?? 0,
    );
  }
}

class ScopeStat {
  final String scope;
  final int total;

  ScopeStat({required this.scope, required this.total});

  factory ScopeStat.fromJson(Map<String, dynamic> json) {
    return ScopeStat(
      scope: json['scope']?.toString() ?? '-',
      total: (json['total'] as num?)?.toInt() ?? 0,
    );
  }
}

class _AdminDashboardData {
  final List<AdminNewsItem> news;
  final int totalNews;
  final AdminAnalytics analytics;
  final List<AdminProductItem> products;
  final int totalProducts;
  final List<AdminMatchItem> liveMatches;
  final List<AdminMatchItem> finishedMatches;
  final List<AdminMatchItem> upcomingMatches;

  _AdminDashboardData({
    required this.news,
    required this.totalNews,
    required this.analytics,
    required this.products,
    required this.totalProducts,
    required this.liveMatches,
    required this.finishedMatches,
    required this.upcomingMatches,
  });
}

class _AdminAccessDenied implements Exception {}

Future<Map<String, dynamic>> _safeGetMap(
  CookieRequest request,
  String url,
) async {
  try {
    final response = await request.get(url);
    if (response is Map<String, dynamic>) {
      return response;
    }
  } catch (_) {}
  return const {};
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  return {};
}

List<dynamic> _asList(dynamic value) {
  if (value is List<dynamic>) return value;
  return const [];
}

int _asInt(dynamic value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) {
    final parsed = int.tryParse(value);
    if (parsed != null) return parsed;
  }
  return fallback;
}

bool _asBool(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final lower = value.toLowerCase();
    return lower == 'true' || lower == '1' || lower == 'yes';
  }
  return false;
}

class _OverviewStatCard extends StatelessWidget {
  final _StatCardData data;

  const _OverviewStatCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final backgroundColor = theme.brightness == Brightness.dark
        ? colorScheme.surfaceContainerHighest
        : colorScheme.surfaceContainerHigh;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: data.color.withAlpha((0.15 * 255).round()),
            child: Icon(data.icon, color: data.color),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data.value,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              Text(
                data.label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCardData {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  _StatCardData({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
}

class _SearchAnalyticsCard extends StatelessWidget {
  final AdminAnalytics analytics;

  const _SearchAnalyticsCard({required this.analytics});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Search Analytics',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: analytics.topQueries
                  .map(
                    (item) => Chip(
                      avatar: const Icon(Icons.trending_up, size: 16),
                      label: Text('${item.keyword} (${item.total})'),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: analytics.scopeBreakdown
                  .map(
                    (scope) => Column(
                      children: [
                        Text(
                          scope.total.toString(),
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          scope.scope.toUpperCase(),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _NewsSection extends StatelessWidget {
  final List<AdminNewsItem> news;

  const _NewsSection({required this.news});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Latest News Submissions',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            if (news.isEmpty)
              const Text('No published news yet.')
            else
              Column(
                children: news
                    .map(
                      (item) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          item.isPublished
                              ? Icons.check_circle
                              : Icons.schedule,
                          color: item.isPublished
                              ? Colors.green
                              : Colors.orange,
                        ),
                        title: Text(item.title),
                        subtitle: Text(
                          '${item.category} • ${item.views} views',
                        ),
                        trailing: Text(
                          '${item.publishedAt.day}/${item.publishedAt.month}/${item.publishedAt.year}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    )
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }
}

class _ProductSection extends StatelessWidget {
  final List<AdminProductItem> products;

  const _ProductSection({required this.products});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Featured Products',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            if (products.isEmpty)
              const Text('No products to display.')
            else
              Column(
                children: products
                    .map(
                      (item) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primaryContainer,
                          child: const Icon(Icons.watch),
                        ),
                        title: Text(item.name),
                        subtitle: Text(item.category ?? 'Uncategorised'),
                        trailing: Text(
                          item.salePrice != null
                              ? 'Rp${item.salePrice!.toStringAsFixed(0)}'
                              : 'Rp${item.price.toStringAsFixed(0)}',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                    )
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }
}

class _ScoreboardSection extends StatelessWidget {
  final List<AdminMatchItem> live;
  final List<AdminMatchItem> upcoming;
  final List<AdminMatchItem> finished;

  const _ScoreboardSection({
    required this.live,
    required this.upcoming,
    required this.finished,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Scoreboard Snapshot',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            _buildMatchList(context, 'Live', live, Colors.red),
            const SizedBox(height: 12),
            _buildMatchList(context, 'Upcoming', upcoming, Colors.blue),
            const SizedBox(height: 12),
            _buildMatchList(context, 'Recent', finished, Colors.green),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchList(
    BuildContext context,
    String title,
    List<AdminMatchItem> matches,
    Color accent,
  ) {
    if (matches.isEmpty) {
      return Text('$title: No data');
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.sports, size: 16, color: accent),
            const SizedBox(width: 6),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...matches
            .take(3)
            .map(
              (match) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text('${match.team1} vs ${match.team2}')),
                    Text(
                      match.score1 != null && match.score2 != null
                          ? '${match.score1} - ${match.score2}'
                          : match.status.toUpperCase(),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
      ],
    );
  }
}
