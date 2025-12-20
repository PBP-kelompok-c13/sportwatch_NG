import 'package:flutter/material.dart';
import 'package:sportwatch_ng/admin/product_form.dart' as admin;
import 'package:sportwatch_ng/shop/models/product_entry.dart';

/// Bridge widget so the shop flow can reuse the admin product form.
class ProductFormPage extends StatelessWidget {
  final ProductEntry? product;

  const ProductFormPage({super.key, this.product});

  Map<String, dynamic>? _mapProduct(ProductEntry product) {
    final fields = product.fields;
    return {
      'id': product.pk,
      'name': fields.name,
      'description': fields.description,
      'price': double.tryParse(fields.price),
      'sale_price': fields.salePrice != null
          ? double.tryParse(fields.salePrice!)
          : null,
      'stock': fields.stock,
      'thumbnail': fields.thumbnail,
      'category': fields.category,
      'brand': fields.brand,
      'is_featured': fields.isFeatured,
    };
  }

<<<<<<< HEAD
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
                      initialValue: _selectedCategory,
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
                      initialValue: _selectedBrand, // boleh null
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
                            "brand_slug": _selectedBrand?.slug,
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

                          final messenger = ScaffoldMessenger.of(context);
                          final navigator = Navigator.of(context);

                          final response = await request.postJson(url, payload);

                          if (!context.mounted) return;

                          if (response['status'] == 'success') {
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text(
                                  widget.isEdit
                                      ? "Product updated."
                                      : "Product created.",
                                ),
                              ),
                            );
                            navigator.pop(true); // sinyal refresh
                          } else {
                            messenger.showSnackBar(
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
=======
  @override
  Widget build(BuildContext context) {
    return admin.ProductFormPage(
      initialData: product != null ? _mapProduct(product!) : null,
>>>>>>> 6991bf4205772456801fc2974e5369408dba6248
    );
  }
}
