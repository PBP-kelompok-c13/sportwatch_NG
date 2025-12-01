import 'package:flutter/material.dart';
import 'package:sportwatch_ng/search/search_models.dart';

class SearchFiltersCard extends StatelessWidget {
  const SearchFiltersCard({
    super.key,
    required this.queryController,
    required this.minPriceController,
    required this.maxPriceController,
    required this.searchIn,
    required this.onScopeChanged,
    required this.newsCategories,
    required this.selectedNewsCategoryId,
    required this.onNewsCategoryChanged,
    required this.productCategories,
    required this.selectedProductCategoryId,
    required this.onProductCategoryChanged,
    required this.brandOptions,
    required this.selectedBrandId,
    required this.onBrandChanged,
    required this.onlyDiscount,
    required this.onDiscountChanged,
    required this.presets,
    required this.selectedPresetId,
    required this.onPresetChanged,
    required this.onPresetApplied,
    required this.onCreatePreset,
    required this.onPerformSearch,
  });

  final TextEditingController queryController;
  final TextEditingController minPriceController;
  final TextEditingController maxPriceController;
  final String searchIn;
  final ValueChanged<String> onScopeChanged;
  final List<FilterOption> newsCategories;
  final String? selectedNewsCategoryId;
  final ValueChanged<String?> onNewsCategoryChanged;
  final List<FilterOption> productCategories;
  final String? selectedProductCategoryId;
  final ValueChanged<String?> onProductCategoryChanged;
  final List<FilterOption> brandOptions;
  final String? selectedBrandId;
  final ValueChanged<String?> onBrandChanged;
  final bool onlyDiscount;
  final ValueChanged<bool> onDiscountChanged;
  final List<SearchPreset> presets;
  final String? selectedPresetId;
  final ValueChanged<String?> onPresetChanged;
  final ValueChanged<SearchPreset> onPresetApplied;
  final VoidCallback onCreatePreset;
  final VoidCallback onPerformSearch;

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
              'Filter Pencarian',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Wrap(
              runSpacing: 12,
              spacing: 12,
              children: [
                SizedBox(
                  width: 360,
                  child: TextField(
                    controller: queryController,
                    decoration: const InputDecoration(
                      labelText: 'Kata kunci',
                      hintText: 'Cari berita, produk, atau kata kunci lain...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(
                  width: 200,
                  child: DropdownButtonFormField<String>(
                    key: ValueKey('scope-$searchIn'),
                    initialValue: searchIn,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('Cari di: Semua')),
                      DropdownMenuItem(value: 'news', child: Text('Cari di: Berita')),
                      DropdownMenuItem(value: 'products', child: Text('Cari di: Produk')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        onScopeChanged(value);
                      }
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              runSpacing: 12,
              spacing: 12,
              children: [
                SizedBox(
                  width: 220,
                  child: DropdownButtonFormField<String?>(
                    key: ValueKey('news-$selectedNewsCategoryId'),
                    initialValue: selectedNewsCategoryId,
                    isExpanded: true,
                    items: _buildFilterOptions(newsCategories),
                    onChanged: onNewsCategoryChanged,
                    decoration: const InputDecoration(
                      labelText: 'Kategori Berita',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(
                  width: 220,
                  child: DropdownButtonFormField<String?>(
                    key: ValueKey('product-$selectedProductCategoryId'),
                    initialValue: selectedProductCategoryId,
                    isExpanded: true,
                    items: _buildFilterOptions(productCategories),
                    onChanged: onProductCategoryChanged,
                    decoration: const InputDecoration(
                      labelText: 'Kategori Produk',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(
                  width: 220,
                  child: DropdownButtonFormField<String?>(
                    key: ValueKey('brand-$selectedBrandId'),
                    initialValue: selectedBrandId,
                    isExpanded: true,
                    items: _buildFilterOptions(brandOptions),
                    onChanged: onBrandChanged,
                    decoration: const InputDecoration(
                      labelText: 'Brand',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SizedBox(
                  width: 180,
                  child: TextField(
                    controller: minPriceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Harga Minimum',
                      hintText: '0',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(
                  width: 180,
                  child: TextField(
                    controller: maxPriceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Harga Maksimum',
                      hintText: '1000000',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Switch(
                      value: onlyDiscount,
                      onChanged: onDiscountChanged,
                    ),
                    const Text('Hanya tampilkan diskon'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SizedBox(
                  width: 240,
                  child: DropdownButtonFormField<String?>(
                    key: ValueKey('preset-$selectedPresetId'),
                    initialValue: selectedPresetId,
                    isExpanded: true,
                    items: [
                      const DropdownMenuItem<String?>(value: null, child: Text('Tanpa preset')),
                      ...presets.map(
                        (preset) => DropdownMenuItem<String?>(
                          value: preset.id,
                          child: Text(preset.label),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      onPresetChanged(value);
                      if (value == null) return;
                      final preset = _findPresetById(value);
                      if (preset != null) {
                        onPresetApplied(preset);
                      }
                    },
                    decoration: const InputDecoration(
                      labelText: 'Preset pencarian',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                OutlinedButton(
                  onPressed: onCreatePreset,
                  child: const Text('Buat Preset'),
                ),
                FilledButton(
                  onPressed: onPerformSearch,
                  child: const Text('Cari Sekarang'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<DropdownMenuItem<String?>> _buildFilterOptions(List<FilterOption> options) {
    return [
      const DropdownMenuItem<String?>(value: null, child: Text('Semua')),
      ...options.map(
        (option) => DropdownMenuItem<String?>(
          value: option.id,
          child: Text(option.name),
        ),
      ),
    ];
  }
  SearchPreset? _findPresetById(String id) {
    for (final preset in presets) {
      if (preset.id == id) {
        return preset;
      }
    }
    return null;
  }
}
