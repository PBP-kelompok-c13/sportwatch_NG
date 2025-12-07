// lib/screens/product_form_page.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

import 'package:sportwatch_ng/shop/models/constants.dart';
import 'package:sportwatch_ng/shop/models/product_entry.dart';
import 'package:sportwatch_ng/user_profile_notifier.dart';

class ProductFormPage extends StatefulWidget {
  final ProductEntry? product; // null = create, non-null = edit

  const ProductFormPage({super.key, this.product});

  bool get isEdit => product != null;

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

// DTO kecil buat dropdown
class CategoryOption {
  final String id; // UUID category (pk)
  final String name; // label
  final String slug; // slug utk kirim ke API

  CategoryOption({required this.id, required this.name, required this.slug});

  factory CategoryOption.fromJson(Map<String, dynamic> json) => CategoryOption(
    // kalau id/slug dari backend angka / null -> tetap aman
    id: json['id']?.toString() ?? '',
    name: json['name']?.toString() ?? '',
    // kalau slug null, fallback ke id (atau string kosong)
    slug: (json['slug'] ?? json['id'] ?? '').toString(),
  );
}

class BrandOption {
  final String id;
  final String name;
  final String slug;

  BrandOption({required this.id, required this.name, required this.slug});

  factory BrandOption.fromJson(Map<String, dynamic> json) => BrandOption(
    id: json['id']?.toString() ?? '',
    name: json['name']?.toString() ?? '',
    slug: (json['slug'] ?? json['id'] ?? '').toString(),
  );
}

class _ProductFormPageState extends State<ProductFormPage> {
  final _formKey = GlobalKey<FormState>();

  // state form
  String _name = "";
  CategoryOption? _selectedCategory;
  BrandOption? _selectedBrand; // <-- boleh null
  String _description = "";
  double _price = 0;
  double? _salePrice;
  String _currency = "IDR";
  int _stock = 0;
  String _thumbnail = "";
  bool _isFeatured = false;

  // data dropdown
  List<CategoryOption> _categories = [];
  List<BrandOption> _brands = [];
  bool _dropdownLoading = true;

  @override
  void initState() {
    super.initState();
    _initFromProduct();
    _loadDropdownData();
  }

  void _initFromProduct() {
    if (!widget.isEdit) return;
    final f = widget.product!.fields;

    _name = widget.product!.name;
    _description = f.description;
    _price = double.tryParse(f.price) ?? 0;
    _salePrice = f.salePrice != null ? double.tryParse(f.salePrice!) : null;
    _currency = "IDR";
    _stock = f.stock;
    _thumbnail = f.thumbnail;
    _isFeatured = f.isFeatured;
  }

  Future<void> _loadDropdownData() async {
    final request = context.read<CookieRequest>();

    try {
      // GET categories
      final catsRes = await request.get("$baseUrl/shop/api/categories/");
      // GET brands
      final brandsRes = await request.get("$baseUrl/shop/api/brands/");

      final cats = (catsRes as List<dynamic>)
          .map((e) => CategoryOption.fromJson(e))
          .toList();

      final brands = (brandsRes as List<dynamic>)
          .map((e) => BrandOption.fromJson(e))
          .toList();

      CategoryOption? selectedCat;
      BrandOption? selectedBrand;

      if (widget.isEdit) {
        final f = widget.product!.fields;

        // f.category berisi ID category (pk)
        selectedCat = cats.firstWhere(
          (c) => c.id == f.category,
          orElse: () => cats.first,
        );

        if (f.brand != null) {
          selectedBrand = brands.firstWhere(
            (b) => b.id == f.brand,
            orElse: () => brands.first,
          );
        }
      }

      setState(() {
        _categories = cats;
        _brands = brands;
        _selectedCategory = selectedCat;
        _selectedBrand = selectedBrand;
        _dropdownLoading = false;
      });
    } catch (e) {
      setState(() {
        _dropdownLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal load kategori/brand: $e")),
        );
      }
    }
  }

  String _formatPrice(double value) => "Rp ${value.toStringAsFixed(0)}";

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    final profile = context.watch<UserProfileNotifier>(); // ⬅️ NEW

    if (profile.isGuest) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.isEdit ? "Edit Product" : "Add Product"),
          centerTitle: true,
        ),
        body: const Center(
          child: Text(
            'You must login to create or edit products.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEdit ? "Edit Product" : "Add Product"),
        centerTitle: true,
      ),
      body: _dropdownLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // ---------- NAME ----------
                    TextFormField(
                      initialValue: _name,
                      decoration: const InputDecoration(
                        labelText: "Product Name",
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (v) => _name = v,
                      validator: (v) => (v == null || v.isEmpty)
                          ? "Name cannot be empty"
                          : null,
                    ),
                    const SizedBox(height: 12),

                    // ---------- CATEGORY ----------
                    DropdownButtonFormField<CategoryOption>(
                      value: _selectedCategory,
                      decoration: const InputDecoration(
                        labelText: "Category",
                        border: OutlineInputBorder(),
                      ),
                      items: _categories
                          .map(
                            (c) => DropdownMenuItem<CategoryOption>(
                              value: c,
                              child: Text(c.name),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _selectedCategory = v),
                      validator: (v) =>
                          v == null ? "Category is required" : null,
                    ),
                    const SizedBox(height: 12),

                    // ---------- BRAND (OPSIONAL) ----------
                    DropdownButtonFormField<BrandOption?>(
                      value: _selectedBrand, // boleh null
                      decoration: const InputDecoration(
                        labelText: "Brand (optional)",
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        const DropdownMenuItem<BrandOption?>(
                          value: null,
                          child: Text("No brand"),
                        ),
                        ..._brands.map(
                          (b) => DropdownMenuItem<BrandOption?>(
                            value: b,
                            child: Text(b.name),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedBrand = value; // BrandOption? (nullable)
                        });
                      },
                    ),
                    const SizedBox(height: 12),

                    // ---------- STOCK ----------
                    TextFormField(
                      initialValue: _stock.toString(),
                      decoration: const InputDecoration(
                        labelText: "Stock",
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (v) => _stock = int.tryParse(v) ?? 0,
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return "Stock cannot be empty";
                        }
                        if (int.tryParse(v) == null) {
                          return "Stock must be an integer";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    // ---------- DESCRIPTION ----------
                    TextFormField(
                      initialValue: _description,
                      decoration: const InputDecoration(
                        labelText: "Description",
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 4,
                      onChanged: (v) => _description = v,
                      validator: (v) => (v == null || v.isEmpty)
                          ? "Description cannot be empty"
                          : null,
                    ),
                    const SizedBox(height: 12),

                    // ---------- PRICE ----------
                    TextFormField(
                      initialValue: _price > 0 ? _price.toStringAsFixed(0) : "",
                      decoration: const InputDecoration(
                        labelText: "Price",
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (v) =>
                          _price = double.tryParse(v.replaceAll(",", "")) ?? 0,
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return "Price cannot be empty";
                        }
                        if (double.tryParse(v.replaceAll(",", "")) == null) {
                          return "Price must be a number";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    // ---------- SALE PRICE ----------
                    TextFormField(
                      initialValue: _salePrice != null
                          ? _salePrice!.toStringAsFixed(0)
                          : "",
                      decoration: const InputDecoration(
                        labelText: "Sale price (optional)",
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (v) {
                        _salePrice = v.isEmpty
                            ? null
                            : double.tryParse(v.replaceAll(",", ""));
                      },
                    ),
                    const SizedBox(height: 12),

                    // ---------- THUMBNAIL ----------
                    TextFormField(
                      initialValue: _thumbnail,
                      decoration: const InputDecoration(
                        labelText: "Thumbnail URL",
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (v) => _thumbnail = v,
                    ),
                    const SizedBox(height: 12),

                    // ---------- FEATURED ----------
                    SwitchListTile(
                      title: const Text("Mark as featured"),
                      value: _isFeatured,
                      onChanged: (v) {
                        setState(() {
                          _isFeatured = v;
                        });
                      },
                    ),

                    const SizedBox(height: 16),

                    // ---------- SUBMIT BUTTON ----------
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (!_formKey.currentState!.validate()) return;
                          if (_selectedCategory == null) return;

                          final payload = jsonEncode({
                            "name": _name,
                            "category_slug": _selectedCategory!.slug,
                            "brand_slug": _selectedBrand != null
                                ? _selectedBrand!.slug
                                : null,
                            "description": _description,
                            "price": _price,
                            "sale_price": _salePrice,
                            "currency": _currency,
                            "stock": _stock,
                            "thumbnail": _thumbnail,
                            "is_featured": _isFeatured,
                          });

                          final String url = widget.isEdit
                              ? "$baseUrl/shop/api/products/${widget.product!.id}/edit-flutter/"
                              : "$baseUrl/shop/api/create-flutter/";

                          final response = await request.postJson(url, payload);

                          if (!mounted) return;

                          if (response['status'] == 'success') {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  widget.isEdit
                                      ? "Product updated."
                                      : "Product created.",
                                ),
                              ),
                            );
                            Navigator.pop(context, true); // sinyal refresh
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "Failed: ${response['error'] ?? 'Unknown error'}",
                                ),
                              ),
                            );
                          }
                        },
                        child: Text(
                          widget.isEdit ? "Save Changes" : "Save Product",
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
