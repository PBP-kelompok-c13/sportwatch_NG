// lib/shop/widgets/product_entry_card.dart
// GANTI SEMUA ISI FILE INI

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sportwatch_ng/card_notifier.dart';
import 'package:sportwatch_ng/shop/models/product_entry.dart';

class ProductEntryCard extends StatelessWidget {
  final ProductEntry product;
  final VoidCallback? onCardTap;
  final VoidCallback? onAddToCart;
  final bool isOwner;
  final bool isGuest;
  final VoidCallback? onLongPress;

  const ProductEntryCard({
    super.key,
    required this.product,
    this.onCardTap,
    this.onAddToCart,
    this.isOwner = false,
    this.isGuest = false,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<CartNotifier>(
      builder: (context, cart, child) {
        // Cek apakah product sudah ada di cart
        final isInCart = cart.isInCart(product.pk);
        final quantity = cart.getQuantity(product.pk);

        return Card(
          clipBehavior: Clip.antiAlias,
          elevation: 2,
          child: InkWell(
            onTap: onCardTap,
            onLongPress: onLongPress,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sale badge (jika ada)
                Stack(
                  children: [
                    // Product Image
                    AspectRatio(
                      aspectRatio: 1,
                      child: product.thumbnail.isNotEmpty
                          ? Image.network(
                              product.thumbnail,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: Colors.grey[300],
                                child: const Icon(
                                  Icons.watch,
                                  size: 48,
                                  color: Colors.grey,
                                ),
                              ),
                            )
                          : Container(
                              color: Colors.grey[300],
                              child: const Icon(
                                Icons.watch,
                                size: 48,
                                color: Colors.grey,
                              ),
                            ),
                    ),
                    
                    // Sale badge
                    if (product.discountPercent > 0)
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
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Sale',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),

                // Product Info
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Product Name
                        Text(
                          product.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),

                        // Price
                        Text(
                          'Rp ${product.price.toStringAsFixed(0)}',
                          style: TextStyle(
                            color: Colors.blue[700],
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        
                        const Spacer(),

                        // ========================================
                        // TOMBOL ADD TO CART / QUANTITY CONTROL + REMOVE
                        // ========================================
                        if (isGuest)
                          // Guest: disabled button
                          SizedBox(
                            width: double.infinity,
                            height: 32,
                            child: ElevatedButton(
                              onPressed: null,
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.zero,
                              ),
                              child: const Text(
                                'Login first',
                                style: TextStyle(fontSize: 11),
                              ),
                            ),
                          )
                        else if (isInCart)
                          // SUDAH DI CART: Tampilkan kontrol quantity + tombol remove
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Baris 1: Quantity Control (- dan +)
                              Container(
                                height: 32,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.blue),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    // Tombol KURANG (-)
                                    Expanded(
                                      child: InkWell(
                                        onTap: () {
                                          cart.decreaseQuantity(product.pk);
                                          
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                quantity > 1
                                                    ? 'Quantity dikurangi'
                                                    : '${product.name} dihapus dari cart',
                                              ),
                                              duration: const Duration(milliseconds: 800),
                                            ),
                                          );
                                        },
                                        child: Container(
                                          alignment: Alignment.center,
                                          child: const Icon(
                                            Icons.remove,
                                            size: 18,
                                            color: Colors.blue,
                                          ),
                                        ),
                                      ),
                                    ),
                                    
                                    // QUANTITY
                                    Container(
                                      width: 40,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        border: Border(
                                          left: BorderSide(color: Colors.blue),
                                          right: BorderSide(color: Colors.blue),
                                        ),
                                      ),
                                      child: Text(
                                        '$quantity',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: Colors.blue,
                                        ),
                                      ),
                                    ),
                                    
                                    // Tombol TAMBAH (+)
                                    Expanded(
                                      child: InkWell(
                                        onTap: () {
                                          cart.addItem(
                                            product.pk,
                                            product.name,
                                            product.price,
                                          );
                                          
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Quantity ditambah'),
                                              duration: Duration(milliseconds: 800),
                                            ),
                                          );
                                        },
                                        child: Container(
                                          alignment: Alignment.center,
                                          child: const Icon(
                                            Icons.add,
                                            size: 18,
                                            color: Colors.blue,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              
                              const SizedBox(height: 4),
                              
                              // Baris 2: Tombol REMOVE (Merah)
                              SizedBox(
                                width: double.infinity,
                                height: 28,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    // Tampilkan dialog konfirmasi
                                    showDialog(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: const Text('Remove from cart?'),
                                        content: Text(
                                          'Hapus "${product.name}" dari cart?',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(ctx),
                                            child: const Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              cart.removeItem(product.pk);
                                              Navigator.pop(ctx);
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    '${product.name} dihapus dari cart',
                                                  ),
                                                ),
                                              );
                                            },
                                            child: const Text(
                                              'Remove',
                                              style: TextStyle(color: Colors.red),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.zero,
                                  ),
                                  icon: const Icon(Icons.delete, size: 14),
                                  label: const Text(
                                    'Remove',
                                    style: TextStyle(fontSize: 11),
                                  ),
                                ),
                              ),
                            ],
                          )
                        else
                          // BELUM DI CART: Tombol Add to Cart
                          SizedBox(
                            width: double.infinity,
                            height: 32,
                            child: ElevatedButton.icon(
                              onPressed: onAddToCart,
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.zero,
                              ),
                              icon: const Icon(Icons.add_shopping_cart, size: 14),
                              label: const Text(
                                'Add to Cart',
                                style: TextStyle(fontSize: 11),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}