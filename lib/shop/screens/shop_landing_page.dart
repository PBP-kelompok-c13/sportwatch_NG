// lib/screens/shop_landing_page.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

import 'package:sportwatch_ng/shop/models/product_entry.dart';
import 'package:sportwatch_ng/shop/models/constants.dart';
import 'package:sportwatch_ng/shop/screens/product_detail_page.dart';
import 'package:sportwatch_ng/shop/screens/product_form_page.dart';
import 'package:sportwatch_ng/shop/widgets/product_entry_card.dart';
import 'package:sportwatch_ng/user_profile_notifier.dart';
import 'package:sportwatch_ng/card_notifier.dart';
import 'package:sportwatch_ng/fitur_belanja/screens/cart_page.dart';

// Helper function untuk format angka dengan pemisah ribuan
String formatCurrency(double value) {
  final formatted = value.toStringAsFixed(0);
  final buffer = StringBuffer();
  final chars = formatted.split('').toList();
  
  for (int i = 0; i < chars.length; i++) {
    buffer.write(chars[i]);
    final remainingDigits = chars.length - i - 1;
    if (remainingDigits > 0 && remainingDigits % 3 == 0) {
      buffer.write(',');
    }
  }
  
  return buffer.toString();
}

class ShopPage extends StatefulWidget {
  const ShopPage({super.key});

  @override
  State<ShopPage> createState() => _ShopPageState();
}

// 🔹 Model kecil buat filter kategori
class CategoryFilter {
  final String key; // misal: 'all', 'accessories'
  final String label;
  final String? categoryId; // null = tidak filter by category

  const CategoryFilter({
    required this.key,
    required this.label,
    this.categoryId,
  });
}

class _ShopPageState extends State<ShopPage> {
  late Future<List<ProductEntry>> _futureProducts;

  void _showOwnerActions(BuildContext context, ProductEntry product) async {
    final request = context.read<CookieRequest>();

    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit product'),
                onTap: () async {
                  Navigator.pop(context);

                  final changed = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProductFormPage(product: product),
                    ),
                  );

                  if (changed == true) {
                    _refresh();
                  }
                },
              ),

              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete product'),
                onTap: () async {
                  Navigator.pop(context);

                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Delete product'),
                      content: Text('Yakin ingin menghapus "${product.name}"?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text(
                            'Delete',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );

                  if (!context.mounted) return;

                  if (confirm == true) {
                    try {
                      final messenger = ScaffoldMessenger.of(context);
                      final response = await request.post(
                        "$baseUrl/shop/api/products/${product.id}/delete-flutter/",
                        {}, // body kosong saja
                      );

                      if (!context.mounted) return;

                      if (response["status"] == "success") {
                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text("Product berhasil dihapus."),
                          ),
                        );
                        _refresh(); // reload list produk
                      } else {
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(
                              "Gagal menghapus: ${response['error'] ?? 'Unknown error'}",
                            ),
                          ),
                        );
                      }
                    } catch (e) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text("Error: $e")));
                    }
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  bool _showFeaturedOnly = false;
  bool _showMyProductsOnly = false;

  // 🔹 Daftar kategori (mapping dari UUID di JSON kamu)
  //   Dari JSON yang kamu kirim:
  //   - Accessories  : ff590d73-32c7-4df3-9ec6-2c7cfff40a31
  //   - Apparel      : 22a687ec-7639-4bf8-9504-c17801ad30fe
  //   - Equipment    : 5d90d643-4b2d-4912-9f23-a1509d773240
  //   - Footwears    : b995dd2e-b0b3-481b-ad34-76f234f4dad6
  //   - Jerseys      : 4987be29-da54-4c01-93fa-51c63c268d24
  //   - Uncategorized: sisa kategori yang bukan 5 di atas
  // lib/screens/shop_landing_page.dart

  // 1) CategoryFilter: use category *name* as categoryId
  final List<CategoryFilter> _categoryFilters = const [
    CategoryFilter(key: 'all', label: 'All'),

    CategoryFilter(
      key: 'accessories',
      label: 'Accessories',
      categoryId: 'Accessories', // <--- NAME, not UUID
    ),
    CategoryFilter(key: 'apparel', label: 'Apparel', categoryId: 'Apparel'),
    CategoryFilter(
      key: 'equipment',
      label: 'Equipment',
      categoryId: 'Equipment',
    ),
    CategoryFilter(
      key: 'footwears',
      label: 'Footwears',
      categoryId: 'Footwears',
    ),
    CategoryFilter(key: 'jerseys', label: 'Jerseys', categoryId: 'Jerseys'),

    CategoryFilter(key: 'uncategorized', label: 'Uncategorized'),
  ];

  // 2) Known category IDs: also use names
  late final Set<String> _knownCategoryIds = {
    'Accessories',
    'Apparel',
    'Equipment',
    'Footwears',
    'Jerseys',
  };

  int _selectedCategoryIndex = 0;

  @override
  void initState() {
    super.initState();
    final request = context.read<CookieRequest>();
    _futureProducts = _fetchProducts(request);
  }

  Future<List<ProductEntry>> _fetchProducts(CookieRequest request) async {
    final response = await request.get("$baseUrl/shop/json/");
    final encoded = jsonEncode(response); // response = List<dynamic>
    return productEntryFromJson(encoded);
  }

  void _refresh() {
    final request = context.read<CookieRequest>();
    setState(() {
      _futureProducts = _fetchProducts(request);
    });
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    final profile = context.watch<UserProfileNotifier>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.add),
          onPressed: () async {
            if (profile.isGuest) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('You must login to create products.'),
                ),
              );
              return;
            }

            final created = await Navigator.push<bool>(
              context,
              MaterialPageRoute(builder: (_) => const ProductFormPage()),
            );
            if (created == true) {
              _refresh();
            }
          },
        ),
        title: const Text('Shop'),
        centerTitle: true,
        elevation: 0,

        actions: [
          Consumer<CartNotifier>(
            builder: (context, cart, child) {
              return Badge(
                label: Text('${cart.itemCount}'),
                isLabelVisible: cart.itemCount > 0,
                child: IconButton(
                  icon: const Icon(Icons.shopping_cart),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CartPage()),
                    );
                    // TODO: Navigate ke CartPage
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(builder: (_) => const CartPage()),
                    // );
                    
                    // Sementara tampilkan info
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Cart: ${cart.itemCount} items, Total: Rp ${formatCurrency(cart.totalPrice)}',
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'SportWatch Shop',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),

              // 🔹 TEMPORARY DEBUG WIDGET
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: profile.isGuest
                      ? Colors.red.shade100
                      : Colors.green.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  profile.isGuest
                      ? 'You are currently browsing as GUEST'
                      : 'Logged in as ${profile.username}',
                  style: TextStyle(
                    fontSize: 12,
                    color: profile.isGuest
                        ? Colors.red.shade800
                        : Colors.green.shade800,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              const Text(
                'Temukan perangkat dan aksesoris SportWatch kamu di sini.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 16),

              // 🔹 SCROLLABLE CATEGORY FILTER (ganti search bar)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(_categoryFilters.length, (index) {
                    final filter = _categoryFilters[index];
                    final selected = index == _selectedCategoryIndex;

                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(filter.label),
                        selected: selected,
                        onSelected: (_) {
                          setState(() {
                            _selectedCategoryIndex = index;
                          });
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 12),

              // 🔹 Filter chips (featured & my products) + reload
              Row(
                children: [
                  FilterChip(
                    label: const Text("Featured only"),
                    selected: _showFeaturedOnly,
                    onSelected: (v) {
                      setState(() {
                        _showFeaturedOnly = v;
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text("My products"),
                    selected: _showMyProductsOnly,
                    onSelected: (v) {
                      if (profile.isGuest) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Login to see your products.'),
                          ),
                        );
                        return;
                      }

                      debugPrint('jsonData: ${request.jsonData}');
                      setState(() {
                        _showMyProductsOnly = v;
                      });
                    },
                  ),

                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _refresh,
                    icon: const Icon(Icons.refresh),
                    label: const Text("Reload"),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 🔹 Product grid
              Expanded(
                child: FutureBuilder<List<ProductEntry>>(
                  future: _futureProducts,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Terjadi error: ${snapshot.error}',
                          textAlign: TextAlign.center,
                        ),
                      );
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return _EmptyState();
                    }

                    List<ProductEntry> products = snapshot.data!;

                    // 1️⃣ Category filter
                    final selectedFilter =
                        _categoryFilters[_selectedCategoryIndex];

                    if (selectedFilter.key == 'uncategorized') {
                      // kategori yang BUKAN 5 kategori utama di atas
                      products = products
                          .where(
                            (p) =>
                                !_knownCategoryIds.contains(p.fields.category),
                          )
                          .toList();
                    } else if (selectedFilter.categoryId != null) {
                      products = products
                          .where(
                            (p) =>
                                p.fields.category == selectedFilter.categoryId,
                          )
                          .toList();
                    }
                    // kalau 'all' -> gak diapa-apain

                    // 2️⃣ Featured filter
                    if (_showFeaturedOnly) {
                      products = products.where((p) => p.isFeatured).toList();
                    }

                    // 3️⃣ My products filter (by created_by)
                    if (_showMyProductsOnly) {
                      final jsonData = request.jsonData;

                      final rawId =
                          jsonData['id'] ??
                          jsonData['user_id'] ??
                          jsonData['pk'];

                      int? currentUserId;
                      if (rawId is int) {
                        currentUserId = rawId;
                      } else if (rawId is String) {
                        currentUserId = int.tryParse(rawId);
                      }

                      if (currentUserId != null) {
                        products = products
                            .where(
                              (p) =>
                                  p.fields.createdBy != null &&
                                  p.fields.createdBy == currentUserId,
                            )
                            .toList();
                      } else {
                        products = [];
                      }
                    }

                    if (products.isEmpty) {
                      return _EmptyState(
                        message:
                            "Tidak ada produk yang cocok dengan filter / kategori.",
                      );
                    }

                    return GridView.builder(
                      itemCount: products.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 0.6,
                          ),
                      itemBuilder: (context, index) {
                        final product = products[index];
                        final jsonData = request.jsonData;
                        final rawId =
                            jsonData['id'] ??
                            jsonData['user_id'] ??
                            jsonData['pk'];

                        int? currentUserId;
                        if (rawId is int) {
                          currentUserId = rawId;
                        } else if (rawId is String) {
                          currentUserId = int.tryParse(rawId);
                        }

                        final bool isOwner =
                            currentUserId != null &&
                            product.fields.createdBy == currentUserId;
                        return ProductEntryCard(
                          product: product,
                          onCardTap: () async {
                            final changed = await Navigator.push<bool>(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ProductDetailPage(
                                  product: product,
                                  isOwner: isOwner,
                                ),
                              ),
                            );

                            if (changed == true) {
                              _refresh(); // ini method yang sudah kamu punya untuk reload _futureProducts
                            }
                          },
                          onAddToCart: () {
                            // TODO: nanti isi logika add to cart di sini
                            // misalnya pakai Provider / request.post ke Django
                            final cart = context.read<CartNotifier>();
                            // Tambahkan product ke cart
                            cart.addItem(
                              product.pk, // Product ID
                              product.name, // Product Name
                              product.price, // Price (already double)
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "${product.name} ditambahkan ke cart",
                                ),
                              ),
                            );
                          },
                          isOwner: isOwner,
                          isGuest: profile.isGuest,
                          onLongPress: isOwner
                              ? () => _showOwnerActions(context, product)
                              : null,
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;

  const _EmptyState({this.message = 'Belum ada produk yang tersedia.'});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.shopping_bag_outlined, size: 48),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          const Text(
            'Bagian ini akan terisi otomatis ketika data berhasil di-fetch.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
