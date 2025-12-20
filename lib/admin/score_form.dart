import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:sportwatch_ng/config.dart';

class ScoreFormPage extends StatefulWidget {
  final Map<String, dynamic>? initialData;

  const ScoreFormPage({super.key, this.initialData});

  @override
  State<ScoreFormPage> createState() => _ScoreFormPageState();
}

class _ScoreFormPageState extends State<ScoreFormPage> {
  final _formKey = GlobalKey<FormState>();
  late String _tim1;
  late String _tim2;
  int? _skorTim1;
  int? _skorTim2;
  String _sport = 'NBA';
  String _status = 'upcoming';
  String? _logoTim1;
  String? _logoTim2;
  bool _isLoading = false;

  final List<String> _sportOptions = ['NBA', 'EPL', 'NFL', 'MLB', 'NHL'];
  final List<String> _statusOptions = ['upcoming', 'live', 'finished'];

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      final data = widget.initialData!;
      _tim1 = data['tim1'] ?? '';
      _tim2 = data['tim2'] ?? '';
      _skorTim1 = data['skor_tim1'];
      _skorTim2 = data['skor_tim2'];
      _sport = data['sport'] ?? 'NBA';
      _status = data['status'] ?? 'upcoming';
      _logoTim1 = data['logo_tim1'];
      _logoTim2 = data['logo_tim2'];
    } else {
      _tim1 = '';
      _tim2 = '';
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _isLoading = true);
    final request = context.read<CookieRequest>();

    final body = jsonEncode({
      'tim1': _tim1,
      'tim2': _tim2,
      'skor_tim1': _skorTim1 ?? 0,
      'skor_tim2': _skorTim2 ?? 0,
      'sport': _sport,
      'status': _status,
      'logo_tim1': _logoTim1,
      'logo_tim2': _logoTim2,
    });

    try {
      final isEdit = widget.initialData != null;
      final url = isEdit
          ? editScoreApi(widget.initialData!['id'])
          : createScoreApi();

      final response = await request.postJson(url, body);

      if (response['status'] == 'success') {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(isEdit ? 'Score updated' : 'Score created')),
          );
          Navigator.pop(context, true);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${response['message']}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('An error occurred: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.initialData != null ? 'Edit Score' : 'Add Score'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              initialValue: _tim1,
              decoration: const InputDecoration(labelText: 'Team 1 Name'),
              validator: (v) => v!.isEmpty ? 'Required' : null,
              onSaved: (v) => _tim1 = v!,
            ),
            TextFormField(
              initialValue: _tim2,
              decoration: const InputDecoration(labelText: 'Team 2 Name'),
              validator: (v) => v!.isEmpty ? 'Required' : null,
              onSaved: (v) => _tim2 = v!,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: _skorTim1?.toString(),
                    decoration: const InputDecoration(labelText: 'Score 1'),
                    keyboardType: TextInputType.number,
                    onSaved: (v) => _skorTim1 = int.tryParse(v ?? ''),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    initialValue: _skorTim2?.toString(),
                    decoration: const InputDecoration(labelText: 'Score 2'),
                    keyboardType: TextInputType.number,
                    onSaved: (v) => _skorTim2 = int.tryParse(v ?? ''),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              key: ValueKey(_sport),
              initialValue: _sportOptions.contains(_sport)
                  ? _sport
                  : _sportOptions.first,
              decoration: const InputDecoration(labelText: 'Sport'),
              items: _sportOptions
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (v) => setState(() => _sport = v!),
            ),
            DropdownButtonFormField<String>(
              key: ValueKey(_status),
              initialValue: _statusOptions.contains(_status)
                  ? _status
                  : _statusOptions.first,
              decoration: const InputDecoration(labelText: 'Status'),
              items: _statusOptions
                  .map(
                    (s) => DropdownMenuItem(
                      value: s,
                      child: Text(s == 'finished' ? 'Recent' : s),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _status = v!),
            ),
            TextFormField(
              initialValue: _logoTim1,
              decoration: const InputDecoration(labelText: 'Logo Team 1 URL'),
              onSaved: (v) => _logoTim1 = v,
            ),
            TextFormField(
              initialValue: _logoTim2,
              decoration: const InputDecoration(labelText: 'Logo Team 2 URL'),
              onSaved: (v) => _logoTim2 = v,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _save,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
