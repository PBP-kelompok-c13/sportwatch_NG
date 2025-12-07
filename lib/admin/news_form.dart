import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:sportwatch_ng/config.dart';

class NewsFormPage extends StatefulWidget {
  final Map<String, dynamic>? initialData;

  const NewsFormPage({super.key, this.initialData});

  @override
  State<NewsFormPage> createState() => _NewsFormPageState();
}

class _NewsFormPageState extends State<NewsFormPage> {
  final _formKey = GlobalKey<FormState>();
  late String _judul;
  late String _konten;
  String? _thumbnail;
  String? _sumber;
  String? _kategori;
  bool _isPublished = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      final data = widget.initialData!;
      _judul = data['judul'] ?? '';
      _konten = data['konten'] ?? '';
      _thumbnail = data['thumbnail'];
      _sumber = data['sumber'];
      _kategori = data['kategori'];
      _isPublished = data['is_published'] == true;
    } else {
      _judul = '';
      _konten = '';
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _isLoading = true);
    final request = context.read<CookieRequest>();

    final body = jsonEncode({
      'judul': _judul,
      'konten': _konten,
      'thumbnail': _thumbnail,
      'sumber': _sumber,
      'kategori': _kategori,
      'is_published': _isPublished,
    });

    try {
      final isEdit = widget.initialData != null;
      final url = isEdit
          ? editNewsApi(widget.initialData!['id'].toString())
          : createNewsApi();

      final response = await request.postJson(url, body);

      if (response['status'] == 'success') {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(isEdit ? 'News updated' : 'News created')),
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
        title: Text(widget.initialData != null ? 'Edit News' : 'Add News'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              initialValue: _judul,
              decoration: const InputDecoration(labelText: 'Title'),
              validator: (v) => v!.isEmpty ? 'Required' : null,
              onSaved: (v) => _judul = v!,
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: _konten,
              decoration: const InputDecoration(labelText: 'Content'),
              maxLines: 5,
              validator: (v) => v!.isEmpty ? 'Required' : null,
              onSaved: (v) => _konten = v!,
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: _kategori,
              decoration: const InputDecoration(
                labelText: 'Category (e.g. Football, Transfer)',
              ),
              onSaved: (v) => _kategori = v,
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: _thumbnail,
              decoration: const InputDecoration(labelText: 'Thumbnail URL'),
              onSaved: (v) => _thumbnail = v,
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: _sumber,
              decoration: const InputDecoration(labelText: 'Source (optional)'),
              onSaved: (v) => _sumber = v,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Publish immediately?'),
              value: _isPublished,
              onChanged: (v) => setState(() => _isPublished = v),
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
