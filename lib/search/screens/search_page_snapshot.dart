part of 'search_landing_page.dart';

class _SearchPageSnapshot {
  _SearchPageSnapshot({
    required this.query,
    required this.minPrice,
    required this.maxPrice,
    required this.searchIn,
    required this.newsCategoryId,
    required this.newsCategoryOptions,
    required this.productCategoryId,
    required this.brandId,
    required this.onlyDiscount,
    required this.selectedPresetId,
    required this.presets,
    required this.trendingNews,
    required this.trendingProducts,
    required this.featuredProducts,
    required this.productCategoryOptions,
    required this.brandOptions,
    required this.filteredNews,
    required this.filteredProducts,
    required this.recentSearches,
    required this.serverSummary,
    required this.resultsError,
  });

  final String query;
  final String minPrice;
  final String maxPrice;
  final String searchIn;
  final String? newsCategoryId;
  final List<FilterOption> newsCategoryOptions;
  final String? productCategoryId;
  final String? brandId;
  final bool onlyDiscount;
  final String? selectedPresetId;
  final List<SearchPreset> presets;
  final List<NewsItem> trendingNews;
  final List<ProductItem> trendingProducts;
  final List<ProductItem> featuredProducts;
  final List<FilterOption> productCategoryOptions;
  final List<FilterOption> brandOptions;
  final List<NewsItem> filteredNews;
  final List<ProductItem> filteredProducts;
  final List<String> recentSearches;
  final SearchResultsSummary? serverSummary;
  final String? resultsError;
}
