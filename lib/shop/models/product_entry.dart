// lib/models/product_entry.dart
import 'dart:convert';

List<ProductEntry> productEntryFromJson(String str) => List<ProductEntry>.from(
  json.decode(str).map((x) => ProductEntry.fromJson(x)),
);

String productEntryToJson(List<ProductEntry> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ProductEntry {
  final Model model;
  final String pk; // UUID string
  final Fields fields;

  ProductEntry({required this.model, required this.pk, required this.fields});

  factory ProductEntry.fromJson(Map<String, dynamic> json) => ProductEntry(
    model: modelValues.map[json["model"]]!,
    pk: json["pk"],
    fields: Fields.fromJson(json["fields"]),
  );

  Map<String, dynamic> toJson() => {
    "model": modelValues.reverse[model],
    "pk": pk,
    "fields": fields.toJson(),
  };

  // ===== Convenience getters for UI =====
  String? get owner => fields.ownerUsername;
  String get id => pk;
  String get name => fields.name;
  String get description => fields.description;
  String get thumbnail => fields.thumbnail;
  String get currency => fields.currency == Currency.idr ? "IDR" : "IDR";
  bool get isFeatured => fields.isFeatured;
  bool get inStock => fields.stock > 0 && fields.status == Status.active;
  double get price =>
      double.tryParse(fields.price) ??
      0; // price and salePrice come as String from JSON
  double? get salePrice => double.tryParse(fields.salePrice ?? '');
  double get finalPrice => salePrice ?? price;

  int get discountPercent {
    if (salePrice == null || price <= 0) return 0;
    return ((1 - (salePrice! / price)) * 100).round();
  }
}

class Fields {
  final DateTime createdAt;
  final DateTime updatedAt;
  final int? createdBy;
  final String? ownerUsername;
  final String category;
  final String? brand;
  final String name;
  final String slug;
  final String description;
  final String price;
  final String? salePrice;
  final Currency currency;
  final int stock;
  final int totalSold;
  final String thumbnail;
  final bool isFeatured;
  final Status status;
  final double ratingAvg;
  final int ratingCount;

  Fields({
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    required this.ownerUsername,
    required this.category,
    required this.brand,
    required this.name,
    required this.slug,
    required this.description,
    required this.price,
    required this.salePrice,
    required this.currency,
    required this.stock,
    required this.totalSold,
    required this.thumbnail,
    required this.isFeatured,
    required this.status,
    required this.ratingAvg,
    required this.ratingCount,
  });

  factory Fields.fromJson(Map<String, dynamic> json) => Fields(
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
    createdBy: json["created_by"],
    ownerUsername: json["owner_username"],
    category: json["category"],
    brand: json["brand"],
    name: json["name"],
    slug: json["slug"],
    description: json["description"],
    price: json["price"].toString(),
    salePrice: json["sale_price"]?.toString(),
    currency: currencyValues.map[json["currency"]]!,
    stock: json["stock"],
    totalSold: json["total_sold"],
    thumbnail: json["thumbnail"],
    isFeatured: json["is_featured"],
    status: statusValues.map[json["status"]]!,
    ratingAvg: (json["rating_avg"] as num).toDouble(),
    ratingCount: json["rating_count"],
  );

  Map<String, dynamic> toJson() => {
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
    "created_by": createdBy,
    "owner_username": ownerUsername,
    "category": category,
    "brand": brand,
    "name": name,
    "slug": slug,
    "description": description,
    "price": price,
    "sale_price": salePrice,
    "currency": currencyValues.reverse[currency],
    "stock": stock,
    "total_sold": totalSold,
    "thumbnail": thumbnail,
    "is_featured": isFeatured,
    "status": statusValues.reverse[status],
    "rating_avg": ratingAvg,
    "rating_count": ratingCount,
  };
}

enum Currency { idr }

final currencyValues = EnumValues({"IDR": Currency.idr});

enum Status { active }

final statusValues = EnumValues({"active": Status.active});

enum Model { shopProduct }

final modelValues = EnumValues({"shop.product": Model.shopProduct});

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
