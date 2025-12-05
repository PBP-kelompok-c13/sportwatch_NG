import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:sportwatch_ng/config.dart';

class ProductFormPage extends StatefulWidget {
  final Map<String, dynamic>? initialData;

  const ProductFormPage({super.key, this.initialData});

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _description;
  double? _price;
  double? _salePrice;
  int _stock = 0;
  String? _thumbnail;
  bool _isFeatured = false;

  String? _selectedCategorySlug;
  String? _selectedBrandSlug;
  
  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> _brands = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      final data = widget.initialData!;
      _name = data['name'] ?? '';
      // Description might not be in the list item, handling that gracefully
      _description = data['description'] ?? ''; 
      _price = (data['price'] as num?)?.toDouble();
      _salePrice = (data['sale_price'] as num?)?.toDouble();
      _stock = data['stock'] ?? 0; // List might not have stock
      _thumbnail = data['thumbnail'];
      _isFeatured = data['is_featured'] == true; // List might not have this
      
      // Usually list items have category name not slug, but let's see. 
      // For now, we might need to just let user pick again if we can't map back.
      // But wait, we can try to match name? Or just leave empty.
      // Ideally, we should fetch detail first. But for MVP let's rely on what we have or re-select.
    } else {
      _name = '';
      _description = '';
    }
    _fetchOptions();
  }

  Future<void> _fetchOptions() async {
    final request = context.read<CookieRequest>();
    try {
      final catRes = await request.get(Uri.parse(baseUrl).resolve("/shop/api/categories/").toString());
      final brandRes = await request.get(Uri.parse(baseUrl).resolve("/shop/api/brands/").toString());
      
      if (mounted) {
        setState(() {
          _categories = List<Map<String, dynamic>>.from(catRes);
          _brands = List<Map<String, dynamic>>.from(brandRes);
          
          // Try to match initial category name to slug if provided
          if (widget.initialData != null && widget.initialData!['category'] != null) {
             final catName = widget.initialData!['category'];
             final found = _categories.firstWhere((c) => c['name'] == catName, orElse: () => {});
             if (found.isNotEmpty) _selectedCategorySlug = found['slug'];
          }
        });
      }
    } catch (e) {
      // ignore errors
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _isLoading = true);
    final request = context.read<CookieRequest>();

    final body = jsonEncode({
      'name': _name,
      'description': _description,
      'price': _price,
      'sale_price': _salePrice,
      'stock': _stock,
      'thumbnail': _thumbnail,
      'category_slug': _selectedCategorySlug,
      'brand_slug': _selectedBrandSlug,
      'is_featured': _isFeatured,
      'currency': 'IDR',
    });

    try {
      final isEdit = widget.initialData != null;
      final url = isEdit 
          ? editProductApi(widget.initialData!['id'].toString()) 
          : createProductApi();
      
      final response = await request.postJson(url, body);

      if (response['status'] == 'success') {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(isEdit ? 'Product updated' : 'Product created')),
          );
          Navigator.pop(context, true);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${response['error'] ?? response['message']}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.initialData != null ? 'Edit Product' : 'Add Product'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              initialValue: _name,
              decoration: const InputDecoration(labelText: 'Product Name'),
              validator: (v) => v!.isEmpty ? 'Required' : null,
              onSaved: (v) => _name = v!,
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: _description,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
              onSaved: (v) => _description = v ?? '',
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: _price?.toString(),
                    decoration: const InputDecoration(labelText: 'Price'),
                    keyboardType: TextInputType.number,
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                    onSaved: (v) => _price = double.tryParse(v ?? ''),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    initialValue: _salePrice?.toString(),
                    decoration: const InputDecoration(labelText: 'Sale Price'),
                    keyboardType: TextInputType.number,
                    onSaved: (v) => _salePrice = double.tryParse(v ?? ''),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: _stock.toString(),
              decoration: const InputDecoration(labelText: 'Stock'),
              keyboardType: TextInputType.number,
              onSaved: (v) => _stock = int.tryParse(v ?? '') ?? 0,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedCategorySlug,
              decoration: const InputDecoration(labelText: 'Category'),
              items: _categories.map((c) => DropdownMenuItem(
                value: c['slug'] as String, 
                child: Text(c['name'])
              )).toList(),
              onChanged: (v) => setState(() => _selectedCategorySlug = v),
              validator: (v) => v == null ? 'Required' : null,
            ),
            const SizedBox(height: 16),
             DropdownButtonFormField<String>(
              value: _selectedBrandSlug,
              decoration: const InputDecoration(labelText: 'Brand'),
              items: _brands.map((b) => DropdownMenuItem(
                value: b['slug'] as String, 
                child: Text(b['name'])
              )).toList(),
              onChanged: (v) => setState(() => _selectedBrandSlug = v),
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: _thumbnail,
              decoration: const InputDecoration(labelText: 'Thumbnail URL'),
              onSaved: (v) => _thumbnail = v,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Featured Product?'),
              value: _isFeatured,
              onChanged: (v) => setState(() => _isFeatured = v),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _save,
              child: _isLoading ? const CircularProgressIndicator() : const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
