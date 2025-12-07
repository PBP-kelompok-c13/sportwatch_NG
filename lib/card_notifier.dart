// lib/cart_notifier.dart

import 'package:flutter/foundation.dart';

class CartItem {
  final String productId;
  final String productName;
  final double price;
  int quantity;

  CartItem({
    required this.productId,
    required this.productName,
    required this.price,
    this.quantity = 1,
  });
}

class CartNotifier extends ChangeNotifier {
  final Map<String, CartItem> _items = {};

  // Getter untuk ambil semua items
  Map<String, CartItem> get items => {..._items};

  // Getter untuk jumlah total item
  int get itemCount {
    return _items.values.fold(0, (sum, item) => sum + item.quantity);
  }

  // Getter untuk total harga
  double get totalPrice {
    return _items.values.fold(
      0.0,
      (sum, item) => sum + (item.price * item.quantity),
    );
  }

  // Method untuk tambah item ke cart
  void addItem(String productId, String productName, double price) {
    if (_items.containsKey(productId)) {
      // Jika sudah ada, tambah quantity
      _items[productId]!.quantity++;
    } else {
      // Jika belum ada, buat baru
      _items[productId] = CartItem(
        productId: productId,
        productName: productName,
        price: price,
      );
    }
    notifyListeners(); // Update UI otomatis
  }

  // Method untuk kurangi quantity
  void decreaseQuantity(String productId) {
    if (!_items.containsKey(productId)) return;

    if (_items[productId]!.quantity > 1) {
      _items[productId]!.quantity--;
    } else {
      _items.remove(productId);
    }
    notifyListeners();
  }

  // Method untuk update quantity langsung
  void updateQuantity(String productId, int newQuantity) {
    if (!_items.containsKey(productId)) return;

    if (newQuantity > 0) {
      _items[productId]!.quantity = newQuantity;
    } else {
      _items.remove(productId);
    }
    notifyListeners();
  }

  // Method untuk hapus item dari cart
  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  // Method untuk clear semua cart
  void clear() {
    _items.clear();
    notifyListeners();
  }

  // Method untuk cek apakah product sudah ada di cart
  bool isInCart(String productId) {
    return _items.containsKey(productId);
  }

  // Method untuk ambil quantity product tertentu
  int getQuantity(String productId) {
    return _items[productId]?.quantity ?? 0;
  }
}