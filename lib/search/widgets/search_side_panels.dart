import 'package:flutter/material.dart';
import 'package:sportwatch_ng/search/models/search_models.dart';

class SearchSidePanels extends StatelessWidget {
  const SearchSidePanels({
    super.key,
    required this.presets,
    required this.selectedPresetId,
    required this.onPresetSelected,
    required this.onEditPreset,
    required this.onDeletePreset,
    required this.recentSearches,
    required this.trendingProducts,
    required this.trendingNews,
  });

  final List<SearchPreset> presets;
  final String? selectedPresetId;
  final ValueChanged<SearchPreset> onPresetSelected;
  final ValueChanged<SearchPreset> onEditPreset;
  final ValueChanged<SearchPreset> onDeletePreset;
  final List<String> recentSearches;
  final List<ProductItem> trendingProducts;
  final List<NewsItem> trendingNews;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _PresetPanel(
          presets: presets,
          selectedPresetId: selectedPresetId,
          onPresetSelected: onPresetSelected,
          onEditPreset: onEditPreset,
          onDeletePreset: onDeletePreset,
        ),
        const SizedBox(height: 12),
        _RecentSearchPanel(recentSearches: recentSearches),
        const SizedBox(height: 12),
        _TrendingPanel(
          trendingProducts: trendingProducts,
          trendingNews: trendingNews,
        ),
      ],
    );
  }
}

class _PresetPanel extends StatelessWidget {
  const _PresetPanel({
    required this.presets,
    required this.selectedPresetId,
    required this.onPresetSelected,
    required this.onEditPreset,
    required this.onDeletePreset,
  });

  final List<SearchPreset> presets;
  final String? selectedPresetId;
  final ValueChanged<SearchPreset> onPresetSelected;
  final ValueChanged<SearchPreset> onEditPreset;
  final ValueChanged<SearchPreset> onDeletePreset;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Preset Pencarian',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            if (presets.isEmpty)
              const Text(
                'Belum ada preset tersedia.',
                style: TextStyle(color: Colors.grey),
              )
            else
              Column(
                children: presets
                    .map(
                      (preset) => Card(
                        color: preset.id == selectedPresetId
                            ? Colors.blue.shade50
                            : null,
                        child: ListTile(
                          title: Text(preset.label),
                          subtitle: Text(
                            preset.description.isEmpty
                                ? 'Tanpa deskripsi'
                                : preset.description,
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, size: 20),
                                tooltip: 'Edit preset',
                                onPressed: () => onEditPreset(preset),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  size: 20,
                                ),
                                tooltip: 'Hapus preset',
                                onPressed: () => onDeletePreset(preset),
                              ),
                              const Icon(Icons.chevron_right),
                            ],
                          ),
                          onTap: () => onPresetSelected(preset),
                        ),
                      ),
                    )
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }
}

class _RecentSearchPanel extends StatelessWidget {
  const _RecentSearchPanel({required this.recentSearches});

  final List<String> recentSearches;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pencarian Terakhir',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            if (recentSearches.isEmpty)
              const Text(
                'Belum ada pencarian.',
                style: TextStyle(color: Colors.grey),
              )
            else
              Column(
                children: recentSearches
                    .map(
                      (item) => ListTile(
                        dense: true,
                        leading: const Icon(Icons.history, size: 20),
                        title: Text(
                          item,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }
}

class _TrendingPanel extends StatelessWidget {
  const _TrendingPanel({
    required this.trendingProducts,
    required this.trendingNews,
  });

  final List<ProductItem> trendingProducts;
  final List<NewsItem> trendingNews;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Trending di Shop',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            ...trendingProducts.map(
              (product) => ListTile(
                dense: true,
                leading: const Icon(Icons.trending_up),
                title: Text(product.name),
                subtitle: Text(product.category),
              ),
            ),
            const Divider(height: 20),
            const Text(
              'Trending di Berita',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            ...trendingNews.map(
              (news) => ListTile(
                dense: true,
                leading: const Icon(Icons.article_outlined),
                title: Text(news.title),
                subtitle: Text(news.category),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
