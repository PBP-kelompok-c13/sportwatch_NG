import 'package:flutter/material.dart';
import 'package:sportwatch_ng/search/models/search_models.dart';

class SearchResultsCard extends StatelessWidget {
  const SearchResultsCard({
    super.key,
    required this.newsResults,
    required this.productResults,
    required this.onViewNews,
    required this.onViewProduct,
  });

  final List<NewsItem> newsResults;
  final List<ProductItem> productResults;
  final ValueChanged<NewsItem> onViewNews;
  final ValueChanged<ProductItem> onViewProduct;

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
            const Text(
              'Hasil Pencarian',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            _NewsResults(newsResults: newsResults, onViewNews: onViewNews),
            const SizedBox(height: 16),
            _ProductResults(productResults: productResults, onViewProduct: onViewProduct),
          ],
        ),
      ),
    );
  }
}

class _NewsResults extends StatelessWidget {
  const _NewsResults({required this.newsResults, required this.onViewNews});

  final List<NewsItem> newsResults;
  final ValueChanged<NewsItem> onViewNews;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Hasil Berita',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            Chip(
              label: Text('${newsResults.length} hasil'),
              backgroundColor: Colors.blue.shade50,
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (newsResults.isEmpty)
          const Text(
            'Belum ada berita yang cocok. Coba ubah filter atau kata kunci.',
            style: TextStyle(color: Colors.grey),
          )
        else
          Column(
            children: newsResults
                .map(
                  (news) => Card(
                    elevation: 1,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      title: Text(news.title),
                      subtitle: Text(_buildNewsSubtitle(news)),
                      trailing: TextButton(
                        onPressed: () => onViewNews(news),
                        child: const Text('Baca'),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
      ],
    );
  }
}

class _ProductResults extends StatelessWidget {
  const _ProductResults({
    required this.productResults,
    required this.onViewProduct,
  });

  final List<ProductItem> productResults;
  final ValueChanged<ProductItem> onViewProduct;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Hasil Produk',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            Chip(
              label: Text('${productResults.length} hasil'),
              backgroundColor: Colors.blue.shade50,
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (productResults.isEmpty)
          const Text(
            'Belum ada produk yang cocok. Coba sesuaikan filter atau harga.',
            style: TextStyle(color: Colors.grey),
          )
        else
          Column(
            children: productResults
                .map(
                  (product) => Card(
                    elevation: 1,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      title: Text(product.name),
                      subtitle: Text(_buildProductSubtitle(product)),
                      leading: Icon(
                        Icons.shopping_bag_outlined,
                        color: product.hasDiscount ? Colors.green : Colors.blueGrey,
                      ),
                      trailing: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        children: [
                          if (product.hasDiscount)
                            const Chip(
                              label: Text('Diskon'),
                              backgroundColor: Color(0xFFE6F4EA),
                              labelStyle: TextStyle(color: Colors.green),
                            ),
                          TextButton(
                            onPressed: () => onViewProduct(product),
                            child: const Text('Lihat'),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
      ],
    );
  }
}

String _buildNewsSubtitle(NewsItem news) {
  final parts = <String>[];
  if (news.category.isNotEmpty) {
    parts.add(news.category);
  }
  if ((news.summary ?? '').isNotEmpty) {
    parts.add(news.summary!);
  } else if ((news.publishedAt ?? '').isNotEmpty) {
    parts.add(news.publishedAt!);
  }
  return parts.join(' | ');
}

String _buildProductSubtitle(ProductItem product) {
  final parts = <String>[];
  parts.add('${product.currency}${product.price.toStringAsFixed(0)}');
  if (product.category.isNotEmpty) {
    parts.add(product.category);
  }
  if (product.discountPercent != null && product.discountPercent! > 0) {
    parts.add('Diskon ${product.discountPercent!.toStringAsFixed(0)}%');
  }
  if (product.stock != null) {
    parts.add('Stok ${product.stock}');
  }
  return parts.join(' | ');
}
