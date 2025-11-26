import 'package:flutter/material.dart';

class ShopPage extends StatelessWidget {
  const ShopPage({super.key});

  // Sementara: dummy data sebagai placeholder
  final List<Map<String, dynamic>> _dummyProducts = const [
    {
      'name': 'SportWatch Basic',
      'price': 'Rp 299.000',
      'description': 'Jam tangan olahraga untuk pemula',
    },
    {
      'name': 'SportWatch Pro',
      'price': 'Rp 599.000',
      'description': 'Fitur GPS & heart-rate monitor',
    },
    {
      'name': 'SportWatch Ultra',
      'price': 'Rp 899.000',
      'description': 'Baterai tahan lama, waterproof',
    },
    {
      'name': 'Sport Band',
      'price': 'Rp 99.000',
      'description': 'Band pengganti berbagai warna',
    },
  ];

  @override
  Widget build(BuildContext context) {
    // ❗ Nanti kalau data dari backend kosong, kamu bisa ubah jadi [] untuk test "no data"
    final products = _dummyProducts; // TODO: ganti dengan data dari API/backend

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Judul + subtitle
              const Text(
                'SportWatch Shop',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                'Temukan perangkat dan aksesoris SportWatch kamu di sini.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 16),

              // Search bar (belum perlu fungsi)
              TextField(
                decoration: InputDecoration(
                  hintText: 'Cari produk…',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Conditional UI: kalau tidak ada produk
              if (products.isEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.shopping_bag_outlined, size: 48),
                        SizedBox(height: 8),
                        Text(
                          'Belum ada produk yang tersedia.',
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Bagian ini akan terisi otomatis ketika data berhasil di-fetch.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                )
              else
                // Grid produk (placeholder)
                Expanded(
                  child: GridView.builder(
                    itemCount: products.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.7,
                        ),
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return _ProductCard(
                        name: product['name'],
                        price: product['price'],
                        description: product['description'],
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

// Card produk placeholder
class _ProductCard extends StatelessWidget {
  final String name;
  final String price;
  final String description;

  const _ProductCard({
    required this.name,
    required this.price,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Placeholder gambar produk
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: const Icon(Icons.watch, size: 48),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  price,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: nanti hubungkan ke detail produk / add to cart
                    },
                    child: const Text('Lihat Detail'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
