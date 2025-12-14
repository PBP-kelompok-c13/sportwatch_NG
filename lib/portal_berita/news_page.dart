import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:sportwatch_ng/admin/admin_panel_page.dart';
import 'package:sportwatch_ng/config.dart';
import 'package:sportwatch_ng/portal_berita/news_entry.dart';
import 'package:sportwatch_ng/portal_berita/news_entry_card.dart';
import 'package:sportwatch_ng/portal_berita/news_detail_page.dart';
import 'package:sportwatch_ng/user_profile_notifier.dart';
import 'package:sportwatch_ng/login_sheet.dart';
import 'package:sportwatch_ng/widgets/theme_toggle_button.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({super.key});

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  List<NewsEntry> _newsEntries = [];
  bool _loadingNews = false;
  String? _newsError;
  bool _loggingOut = false;
  bool _asBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final normalized = value.toLowerCase();
      return normalized == 'true' ||
          normalized == '1' ||
          normalized == 'yes' ||
          normalized == 'y';
    }
    return false;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final request = context.read<CookieRequest>();
      _fetchNews(request);
    });
  }

  List<dynamic> _extractNewsList(dynamic payload) {
    if (payload is List) {
      return payload;
    }
    if (payload is Map<String, dynamic>) {
      final candidates = [
        payload['results'],
        payload['data'],
        payload['items'],
      ];
      for (final candidate in candidates) {
        if (candidate is List) {
          return candidate;
        }
      }
    }
    throw const FormatException('Unexpected news API response shape');
  }

  Future<void> _fetchNews(CookieRequest request) async {
    if (mounted) {
      setState(() {
        _loadingNews = true;
        _newsError = null;
      });
    }
    try {
      final response = await request.get(newsListApi());
      final List<dynamic> rawResults = _extractNewsList(response);
      final entries = rawResults
          .map(
            (item) => NewsEntry.fromJson(
              Map<String, dynamic>.from(item as Map<String, dynamic>),
            ),
          )
          .toList();
      if (mounted) {
        setState(() {
          _newsEntries = entries;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _newsError = e.toString();
          _newsEntries = [];
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _loadingNews = false;
        });
      }
    }
  }

  Future<void> _handleLogout(
    CookieRequest request,
    UserProfileNotifier profile,
  ) async {
    if (_loggingOut) return;
    setState(() {
      _loggingOut = true;
    });
    final messenger = ScaffoldMessenger.of(context);
    try {
      final response = await request.logout(logoutUrl);
      final message = response['message'] ?? 'Logged out.';
      profile.enterGuestMode();
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
    } catch (_) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Failed to log out. Please try again.')),
        );
    } finally {
      if (mounted) {
        setState(() {
          _loggingOut = false;
        });
      }
    }
  }

  void _openNews(NewsEntry entry) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NewsDetailPage(news: entry)),
    );
  }

  int _totalReactions(NewsEntry entry) {
    return entry.reactionSummary.fold<int>(0, (sum, r) => sum + r.count);
  }

  NewsEntry? _selectFeatured(List<NewsEntry> entries) {
    if (entries.isEmpty) return null;
    return entries.reduce((best, candidate) {
      final bestScore = _totalReactions(best);
      final candidateScore = _totalReactions(candidate);
      if (candidateScore != bestScore) {
        return candidateScore > bestScore ? candidate : best;
      }
      return candidate.views > best.views ? candidate : best;
    });
  }

  Widget _buildSquareThumbItem(BuildContext context, NewsEntry entry) {
    final theme = ShadTheme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: () => _openNews(entry),
      child: SizedBox(
        width: 160,
        child: ShadCard(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: entry.thumbnail.isNotEmpty
                      ? Image.network(
                          buildProxyImageUrl(entry.thumbnail),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                color: colorScheme.muted,
                                child: Icon(
                                  Icons.image_not_supported_outlined,
                                  color: colorScheme.mutedForeground,
                                ),
                              ),
                        )
                      : Container(
                          color: colorScheme.muted,
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            color: colorScheme.mutedForeground,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                entry.judul,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.p.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              ShadBadge.secondary(child: Text(entry.kategori.toUpperCase())),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedCard(BuildContext context, NewsEntry entry) {
    final theme = ShadTheme.of(context);
    final colorScheme = theme.colorScheme;
    final totalReactions = _totalReactions(entry);

    return GlassContainer(
      opacity: 0.1,
      blur: 15,
      borderRadius: BorderRadius.circular(18),
      border: Border.fromBorderSide(BorderSide.none),
      shadowStrength: 4,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => _openNews(entry),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: SizedBox(
                      width: 104,
                      height: 104,
                      child: entry.thumbnail.isNotEmpty
                          ? Image.network(
                              buildProxyImageUrl(entry.thumbnail),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                    color: colorScheme.muted,
                                    child: Icon(
                                      Icons.image_not_supported_outlined,
                                      color: colorScheme.mutedForeground,
                                    ),
                                  ),
                            )
                          : Container(
                              color: colorScheme.muted,
                              child: Icon(
                                Icons.image_not_supported_outlined,
                                color: colorScheme.mutedForeground,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShadBadge(child: const Text('Most Reactions')),
                        const SizedBox(height: 10),
                        Text(
                          entry.judul,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.h4,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          entry.penulis?.toString().isNotEmpty == true
                              ? entry.penulis.toString()
                              : 'Unknown Author',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.small.copyWith(
                            color: colorScheme.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Avatar Stack + Count Row
              Row(
                children: [
                  SizedBox(
                    height: 24,
                    width: 52, // Enough for 3 overlapping avatars
                    child: Stack(
                      children: [
                        for (int i = 0; i < 3; i++)
                          Positioned(
                            left: i * 14.0,
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: colorScheme.background,
                                border: Border.all(
                                  color: colorScheme.background,
                                  width: 1.5,
                                ),
                              ),
                              child: CircleAvatar(
                                backgroundColor: colorScheme.primary.withAlpha(
                                  (0.2 + (i * 0.2) * 255).round(),
                                ),
                                child: Icon(
                                  Icons.person,
                                  size: 14,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  ShadBadge.outline(child: Text('$totalReactions reactions')),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                entry.konten,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.p.copyWith(
                  color: colorScheme.mutedForeground,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ), // This closes InkWell and its child (Padding), then closes the child parameter of GlassContainer.
    ); // This closes GlassContainer and ends the return statement.
  }

  Widget _buildServiceGridItem(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onTap,
  ) {
    final theme = ShadTheme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Icon(
                icon,
                size: 28,
                color: const Color(0xFF5D93C8), // Serenity Blue
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: theme.textTheme.small.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHome(CookieRequest request) {
    if (_loadingNews) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_newsError != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Failed to load news:\n$_newsError',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            ShadButton(
              onPressed: () => _fetchNews(request),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final entries = List<NewsEntry>.from(_newsEntries);
    final featured = _selectFeatured(entries);
    final hot =
        entries.where((e) => featured == null || e.id != featured.id).toList()
          ..sort((a, b) => b.views.compareTo(a.views));
    final newest =
        entries.where((e) => featured == null || e.id != featured.id).toList()
          ..sort((a, b) => b.tanggalDibuat.compareTo(a.tanggalDibuat));
    final profile = context.watch<UserProfileNotifier>();
    final userData = request.getJsonData();
    final isStaff =
        !profile.isGuest && (profile.isStaff || _asBool(userData['is_staff']));

    final fallbackUsername = userData['username']?.toString() ?? '';
    final username = profile.isGuest
        ? 'Guest'
        : profile.username.isNotEmpty
        ? profile.username
        : (fallbackUsername.isNotEmpty ? fallbackUsername : 'User');
    final greeting = profile.isGuest
        ? 'Welcome, Guest'
        : 'Welcome back, $username';

    final serviceTiles = <Widget>[
      _buildServiceGridItem(
        context,
        'Shop',
        Icons.shopping_bag_outlined,
        () => Navigator.pushNamed(context, '/shop'),
      ),
      _buildServiceGridItem(
        context,
        'Scoreboard',
        Icons.scoreboard_outlined,
        () => Navigator.pushNamed(context, '/scoreboard'),
      ),
      _buildServiceGridItem(
        context,
        'News',
        Icons.newspaper_outlined,
        () {}, // Already on News page
      ),
      _buildServiceGridItem(
        context,
        'Search',
        Icons.search,
        () => Navigator.pushNamed(context, '/search'),
      ),
      if (isStaff)
        _buildServiceGridItem(
          context,
          'Admin',
          Icons.admin_panel_settings_outlined,
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AdminPanelPage()),
          ),
        ),
    ];

    return RefreshIndicator(
      onRefresh: () => _fetchNews(request),
      child: CustomScrollView(
        slivers: [
          // 1. Header Row (Welcome Guest + Login Link)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(greeting, style: ShadTheme.of(context).textTheme.h4),
                  if (profile.isGuest)
                    TextButton(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(24),
                            ),
                          ),
                          backgroundColor: Colors.white,
                          builder: (context) => const LoginSheet(),
                        );
                      },
                      child: const Text(
                        "Login / Register",
                        style: TextStyle(
                          color: Color(0xFF5D93C8),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // 2. Service Grid (Buttons)
          SliverPadding(
            padding: const EdgeInsets.only(bottom: 20),
            sliver: SliverToBoxAdapter(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: serviceTiles,
                ),
              ),
            ),
          ),

          // 3. Feature Block (The large Golf news card)
          if (featured != null)
            SliverToBoxAdapter(child: _buildFeaturedCard(context, featured)),

          // 4. Horizontal Lists (Hot News)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
              child: Row(
                children: [
                  Text('Hot News', style: ShadTheme.of(context).textTheme.h4),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 280,
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                scrollDirection: Axis.horizontal,
                itemCount: hot.take(10).length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final entry = hot[index];
                  return _buildSquareThumbItem(context, entry);
                },
              ),
            ),
          ),

          // See what's new
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: Text(
                "See what's new",
                style: ShadTheme.of(context).textTheme.h4,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 280,
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                scrollDirection: Axis.horizontal,
                itemCount: newest.take(10).length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final entry = newest[index];
                  return _buildSquareThumbItem(context, entry);
                },
              ),
            ),
          ),

          // All News
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(
                'All News',
                style: ShadTheme.of(context).textTheme.h4,
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final entry = entries[index];
              return NewsEntryCard(news: entry, onTap: () => _openNews(entry));
            }, childCount: entries.length),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    final profile = context.watch<UserProfileNotifier>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('SportWatch'),
        actions: [
          if (!profile.isGuest)
            ShadButton.ghost(
              onPressed: () => _handleLogout(request, profile),
              child: _loggingOut
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.logout, size: 20),
            ),
          const ThemeToggleButton(),
        ],
      ),
      body: _buildHome(request),
    );
  }
}
