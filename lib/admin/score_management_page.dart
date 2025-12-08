import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:sportwatch_ng/admin/score_form.dart';
import 'package:sportwatch_ng/config.dart';

class ScoreManagementPage extends StatefulWidget {
  const ScoreManagementPage({super.key});

  @override
  State<ScoreManagementPage> createState() => _ScoreManagementPageState();
}

class _ScoreManagementPageState extends State<ScoreManagementPage> {
  List<dynamic> _scores = [];
  bool _isLoading = true;
  String _currentFilter = 'upcoming'; // live, upcoming, recent

  @override
  void initState() {
    super.initState();
    _fetchScores();
  }

  Future<void> _fetchScores() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    final request = context.read<CookieRequest>();
    try {
      final response = await request.get(scoreboardFilterApi(status: _currentFilter));
      if (!mounted) return;
      setState(() {
        _scores = response['scores'] ?? [];
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      final messenger = ScaffoldMessenger.of(context);
      messenger.showSnackBar(SnackBar(content: Text('Error fetching scores: $e')));
    }
  }

  Future<void> _deleteScore(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this match?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    
    if (!mounted || confirm != true) return;

    final request = context.read<CookieRequest>();
    final messenger = ScaffoldMessenger.of(context);
    try {
      final response = await request.postJson(deleteScoreApi(id), '{}');
      if (!mounted) return;
      if (response['status'] == 'success') {
        if (!mounted) return;
        await _fetchScores();
        messenger.showSnackBar(const SnackBar(content: Text('Deleted successfully')));
      } else {
        messenger.showSnackBar(SnackBar(content: Text('Error: ${response['message']}')));
      }
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _navigateForm([Map<String, dynamic>? data]) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ScoreFormPage(initialData: data)),
    );
    if (!mounted) return;
    if (result == true) {
      _fetchScores();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Scoreboard'),
        actions: [
          DropdownButton<String>(
            value: _currentFilter,
            dropdownColor: Theme.of(context).colorScheme.surfaceContainerHigh,
            items: const [
              DropdownMenuItem(value: 'live', child: Text('Live')),
              DropdownMenuItem(value: 'upcoming', child: Text('Upcoming')),
              DropdownMenuItem(value: 'recent', child: Text('Recent')),
            ],
            onChanged: (v) {
              if (v != null) {
                setState(() => _currentFilter = v);
                _fetchScores();
              }
            },
            underline: Container(),
            icon: const Icon(Icons.filter_list),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _scores.length,
              itemBuilder: (context, index) {
                final score = _scores[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ListTile(
                    title: Text('${score['tim1']} vs ${score['tim2']}'),
                    subtitle: Text(
                      '${score['sport']} • ${score['status']} • ${score['skor_tim1'] ?? 0}-${score['skor_tim2'] ?? 0}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _navigateForm(score),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteScore(score['id']),
                        ),
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
