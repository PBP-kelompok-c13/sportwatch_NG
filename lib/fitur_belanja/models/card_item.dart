class CartItem {
  final int id;
  final int productId;
  final String productName;
  int qty;
  double unitPrice;
  double subtotal;

  CartItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.qty,
    required this.unitPrice,
    required this.subtotal,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json["id"],
      productId: json["product_id"],
      productName: json["product_name"],
      qty: json["qty"],
      unitPrice: json["unit_price"],
      subtotal: json["subtotal"],
    );
  }
}
