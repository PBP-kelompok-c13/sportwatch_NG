// lib/widgets/product_entry_card.dart
import 'package:flutter/material.dart';
import 'package:sportwatch_ng/shop/models/product_entry.dart';

class ProductEntryCard extends StatelessWidget {
  final ProductEntry product;

  /// Tap seluruh card → lihat detail
  final VoidCallback onCardTap;

  /// Tap tombol → add to cart
  final VoidCallback onAddToCart;

  /// apakah current user adalah pemilik produk
  final bool isOwner;

  final bool isGuest;

  final VoidCallback? onLongPress;

  const ProductEntryCard({
    super.key,
    required this.product,
    required this.onCardTap,
    required this.onAddToCart,
    required this.isOwner,
    required this.isGuest,
    this.onLongPress,
  });

  String _formatPrice(double value) => "Rp ${value.toStringAsFixed(0)}";

  @override
  Widget build(BuildContext context) {
    final fields = product.fields;
    final hasDiscount = product.salePrice != null;

    return InkWell(
      onTap: onCardTap,
      onLongPress: onLongPress,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==== Thumbnail + SALE badge (mirip web) ====
            AspectRatio(
              aspectRatio: 4 / 3,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      child: product.thumbnail.isNotEmpty
                          ? Image.network(
                              product.thumbnail,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stack) =>
                                  Container(
                                    color: Colors.grey.shade200,
                                    child: const Center(
                                      child: Icon(Icons.watch, size: 40),
                                    ),
                                  ),
                            )
                          : Container(
                              color: Colors.grey.shade200,
                              child: const Center(
                                child: Icon(Icons.watch, size: 40),
                              ),
                            ),
                    ),
                  ),
                  if (hasDiscount)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          "Sale",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                  if (!product.inStock)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          "Out of Stock",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // ==== Text info (category, name, rating, owner, price) ====
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category
                  if (fields.category.isNotEmpty)
                    Text(
                      fields.category,
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  const SizedBox(height: 2),

                  // Name
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),

                  // Rating
                  if (fields.ratingCount > 0)
                    Text(
                      "⭐ ${fields.ratingAvg.toStringAsFixed(1)} "
                      "(${fields.ratingCount})",
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    )
                  else
                    const Text(
                      "No reviews yet",
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),

                  // Owner (jika ada)
                  if (product.owner != null && product.owner!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      "by ${product.owner}",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11, color: Colors.blue),
                    ),
                  ],

                  // Price + discount highlight bisa scroll
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _formatPrice(product.finalPrice),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        if (hasDiscount) ...[
                          const SizedBox(width: 4),
                          Text(
                            _formatPrice(product.price),
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "-${product.discountPercent}%",
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Add to cart / Your product
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: (!product.inStock || isOwner)
                          ? null
                          : onAddToCart,
                      icon: const Icon(Icons.add_shopping_cart),
                      label: Text(
                        isOwner
                            ? "Your product"
                            : (isGuest ? "Login to buy" : "Add to Cart"),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
