import 'package:flutter/material.dart';
import 'package:sportwatch_ng/search/search_models.dart';
import 'package:sportwatch_ng/search/widgets/featured_product_card.dart';

class FeaturedProductsSection extends StatelessWidget {
  const FeaturedProductsSection({
    super.key,
    required this.products,
    this.onViewAll,
  });

  final List<ProductItem> products;
  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Produk Pilihan SportWatch',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                TextButton(
                  onPressed: onViewAll,
                  child: const Text('Lihat semua produk'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (products.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'Belum ada produk unggulan yang dapat ditampilkan.',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              LayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount = constraints.maxWidth > 800
                      ? 3
                      : constraints.maxWidth > 520
                          ? 2
                          : 1;
                  return GridView.count(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 1.1,
                    children: products
                        .map(
                          (product) => FeaturedProductCard(product: product),
                        )
                        .toList(),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
