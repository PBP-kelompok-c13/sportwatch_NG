import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:sportwatch_ng/admin/news_form.dart';
import 'package:sportwatch_ng/config.dart';

class NewsManagementPage extends StatefulWidget {
  const NewsManagementPage({super.key});

  @override
  State<NewsManagementPage> createState() => _NewsManagementPageState();
}

class _NewsManagementPageState extends State<NewsManagementPage> {
  List<dynamic> _news = [];
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _fetchNews();
  }

  Future<void> _fetchNews() async {
    setState(() => _isLoading = true);
    final request = context.read<CookieRequest>();
    try {
      final response = await request.get(newsListApi(page: 1, perPage: 20));
      if (!mounted) return;
      setState(() {
        _news = response['results'] ?? [];
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error fetching news: $e')));
    }
  }

  Future<void> _deleteNews(String id) async {
    final confirm = await showDialog<bool>(
      context: context, 
      builder: (c) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this news?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      )
    );
    
    if (confirm != true || !mounted) return;

    final request = context.read<CookieRequest>();
    try {
      final response = await request.postJson(deleteNewsApi(id), '{}');
      if (!mounted) return;
      if (response['status'] == 'success') {
        _fetchNews();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Deleted successfully')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${response['message']}')));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _navigateForm([Map<String, dynamic>? data]) async {
    final result = await Navigator.push(
      context, 
      MaterialPageRoute(builder: (context) => NewsFormPage(initialData: data))
    );
    if (!mounted) return;
    if (result == true) {
      _fetchNews();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage News'),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator()) 
        : ListView.builder(
            itemCount: _news.length,
            itemBuilder: (context, index) {
              final item = _news[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: item['thumbnail'] != null && item['thumbnail'].toString().isNotEmpty
                      ? Image.network(
                          item['thumbnail'], 
                          width: 50, 
                          height: 50, 
                          fit: BoxFit.cover,
                          errorBuilder: (_,__,___) => const Icon(Icons.article),
                        )
                      : const Icon(Icons.article),
                  title: Text(item['judul'] ?? 'No Title'),
                  subtitle: Text('${item['kategori'] ?? 'General'} • ${item['views']} views'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.edit), onPressed: () => _navigateForm(item)),
                      IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _deleteNews(item['id'])),
                    ],
                  ),
                ),
              );
            },
          ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
