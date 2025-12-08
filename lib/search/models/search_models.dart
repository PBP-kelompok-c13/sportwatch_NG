import 'package:flutter/foundation.dart';

/// Represents a saved search preset configuration.
class SearchPreset {
  SearchPreset({
    required this.id,
    required this.label,
    required this.description,
    required this.searchIn,
    this.query,
    this.newsCategoryId,
    this.productCategoryId,
    this.brandId,
    this.minPrice,
    this.maxPrice,
    this.onlyDiscount = false,
  });

  final String id;
  final String label;
  final String description;
  final String searchIn; // all, news, products
  final String? query;
  final String? newsCategoryId;
  final String? productCategoryId;
  final String? brandId;
  final double? minPrice;
  final double? maxPrice;
  final bool onlyDiscount;

  SearchPreset copyWith({
    String? searchIn,
    String? newsCategoryId,
    String? productCategoryId,
    String? brandId,
    double? minPrice,
    double? maxPrice,
    bool? onlyDiscount,
    String? query,
  }) {
    return SearchPreset(
      id: id,
      label: label,
      description: description,
      searchIn: searchIn ?? this.searchIn,
      query: query ?? this.query,
      newsCategoryId: newsCategoryId ?? this.newsCategoryId,
      productCategoryId: productCategoryId ?? this.productCategoryId,
      brandId: brandId ?? this.brandId,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      onlyDiscount: onlyDiscount ?? this.onlyDiscount,
    );
  }
}

/// Simple data class for a news item result.
@immutable
class NewsItem {
  const NewsItem({
    required this.title,
    required this.category,
    this.summary,
    this.content,
    this.url,
    this.thumbnail,
    this.views,
    this.publishedAt,
  });

  final String title;
  final String category;
  final String? summary;
  final String? content;
  final String? url;
  final String? thumbnail;
  final int? views;
  final String? publishedAt;

  factory NewsItem.fromJson(Map<String, dynamic> json) {
    final summary = json['summary'] as String?;
    final publishedAt = json['published_at'] as String?;
    return NewsItem(
      title: json['title'] as String? ?? '',
      category: json['category'] as String? ?? 'Umum',
      summary: summary ?? publishedAt,
      content: json['content'] as String?,
      url: json['url'] as String?,
      thumbnail: json['thumbnail'] as String?,
      views: (json['views'] as num?)?.toInt(),
      publishedAt: publishedAt,
    );
  }
}

/// Simple data class for a product result.
@immutable
class ProductItem {
  const ProductItem({
    this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.currency,
    this.brand,
    this.hasDiscount = false,
    this.discountPercent,
    this.url,
    this.thumbnail,
    this.stock,
  });

  final String? id;
  final String name;
  final String category;
  final double price;
  final String currency;
  final String? brand;
  final bool hasDiscount;
  final double? discountPercent;
  final String? url;
  final String? thumbnail;
  final int? stock;

  factory ProductItem.fromJson(Map<String, dynamic> json) {
    final discount =
        (json['discount'] as num? ?? json['discount_percent'] as num?)
            ?.toDouble();
    final priceValue =
        json['final_price'] ?? json['price'] ?? json['sale_price'];
    return ProductItem(
      id: json['id']?.toString(),
      name: json['name'] as String? ?? '',
      category: json['category'] as String? ?? '',
      price: (priceValue as num?)?.toDouble() ?? 0,
      currency: json['currency'] as String? ?? 'IDR',
      brand: json['brand'] as String?,
      discountPercent: discount,
      hasDiscount: discount != null && discount > 0,
      url: json['url'] as String?,
      thumbnail: json['thumbnail'] as String?,
      stock: (json['stock'] as num?)?.toInt(),
    );
  }
}

@immutable
class SearchResultsSummary {
  const SearchResultsSummary({
    required this.query,
    required this.scope,
    required this.newsCount,
    required this.productCount,
  });

  final String query;
  final String scope;
  final int newsCount;
  final int productCount;

  factory SearchResultsSummary.fromJson(Map<String, dynamic> json) {
    return SearchResultsSummary(
      query: json['query'] as String? ?? '',
      scope: json['scope'] as String? ?? 'all',
      newsCount: (json['news_count'] as num?)?.toInt() ?? 0,
      productCount: (json['product_count'] as num?)?.toInt() ?? 0,
    );
  }
}

@immutable
class FilterOption {
  const FilterOption({required this.id, required this.name});

  final String id;
  final String name;

  factory FilterOption.fromJson(Map<String, dynamic> json) {
    return FilterOption(
      id: json["id"] as String? ?? "",
      name: json["name"] as String? ?? "",
    );
  }
}
