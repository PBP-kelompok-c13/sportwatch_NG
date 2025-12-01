import 'package:flutter/material.dart';
import 'package:sportwatch_ng/search/models/search_models.dart';

class FeaturedProductCard extends StatelessWidget {
  const FeaturedProductCard({super.key, required this.product});

  final ProductItem product;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.blueGrey.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.image, size: 48, color: Colors.blueGrey),
              ),
            ),
            const SizedBox(height: 8),
            Text(product.name, style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(product.category, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 4),
            Text(
              '${product.currency}${product.price.toStringAsFixed(0)}',
              style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.green),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {},
              child: const Text('Lihat detail'),
            ),
          ],
        ),
      ),
    );
  }
}
