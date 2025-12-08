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
      'sale_price':
          fields.salePrice != null ? double.tryParse(fields.salePrice!) : null,
      'stock': fields.stock,
      'thumbnail': fields.thumbnail,
      'category': fields.category,
      'brand': fields.brand,
      'is_featured': fields.isFeatured,
    };
  }

  @override
  Widget build(BuildContext context) {
    return admin.ProductFormPage(
      initialData: product != null ? _mapProduct(product!) : null,
    );
  }
}
