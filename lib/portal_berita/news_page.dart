import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:sportwatch_ng/config.dart';
import 'package:sportwatch_ng/portal_berita/news_entry.dart';
import 'package:sportwatch_ng/portal_berita/news_entry_card.dart';
import 'package:sportwatch_ng/widgets/theme_toggle_button.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({super.key});

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  List<NewsEntry> _newsEntries = [];
  bool _loadingNews = false;
  String? _newsError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final request = context.read<CookieRequest>();
      _fetchNews(request);
    });
  }

  Future<void> _fetchNews(CookieRequest request) async {
    setState(() {
      _loadingNews = true;
      _newsError = null;
    });
    try {
      final response = await request.get(newsListApi());
      final List<dynamic> rawResults = response['results'] as List<dynamic>;
      final entries = rawResults
          .map(
            (item) => NewsEntry.fromJson(
              Map<String, dynamic>.from(item as Map<String, dynamic>),
            ),
          )
          .toList();
      setState(() {
        _newsEntries = entries;
      });
    } catch (e) {
      setState(() {
        _newsError = e.toString();
        _newsEntries = [];
      });
    } finally {
      if (mounted) {
        setState(() {
          _loadingNews = false;
        });
      }
    }
  }

  void _openNews(NewsEntry entry) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(entry.judul),
        content: Text(
          entry.konten,
          maxLines: 12,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsList(CookieRequest request) {
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
            ElevatedButton(
              onPressed: () => _fetchNews(request),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_newsEntries.isEmpty) {
      return const Center(child: Text('No published news yet.'));
    }

    return RefreshIndicator(
      onRefresh: () => _fetchNews(request),
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 12, bottom: 24),
        itemCount: _newsEntries.length,
        itemBuilder: (context, index) {
          final entry = _newsEntries[index];
          return NewsEntryCard(news: entry, onTap: () => _openNews(entry));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('News Portal'),
        actions: const [ThemeToggleButton()],
      ),
      body: _buildNewsList(request),
    );
  }
}
