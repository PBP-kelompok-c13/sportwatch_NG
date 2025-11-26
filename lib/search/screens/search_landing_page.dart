import 'package:flutter/material.dart';

class SearchLandingPage extends StatefulWidget {
  const SearchLandingPage({super.key});

  @override
  State<SearchLandingPage> createState() => _SearchLandingPageState();
}

class _SearchLandingPageState extends State<SearchLandingPage> {
  final TextEditingController _queryController = TextEditingController();
  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();

  String _searchIn = 'all';
  String? _newsCategory;
  String? _productCategory;
  String? _brand;
  bool _onlyDiscount = false;
  String? _selectedPresetId;

  late List<SearchPreset> _presets;
  late List<NewsItem> _allNews;
  late List<ProductItem> _allProducts;
  late List<NewsItem> _trendingNews;
  late List<ProductItem> _trendingProducts;
  late List<ProductItem> _featuredProducts;
  List<NewsItem> _filteredNews = [];
  List<ProductItem> _filteredProducts = [];
  List<String> _recentSearches = [];

  @override
  void initState() {
    super.initState();
    _seedData();
    _performSearch();
  }

  @override
  void dispose() {
    _queryController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  void _seedData() {
    _presets = [
      SearchPreset(
        id: 'preset-1',
        label: 'Diskon Sepak Bola',
        description: 'Cari produk sepak bola dengan diskon',
        searchIn: 'products',
        productCategory: 'Sepak Bola',
        onlyDiscount: true,
      ),
      SearchPreset(
        id: 'preset-2',
        label: 'Berita Terkini',
        description: 'Lihat berita olahraga terbaru',
        searchIn: 'news',
        newsCategory: 'Umum',
      ),
      SearchPreset(
        id: 'preset-3',
        label: 'Lari Premium',
        description: 'Sepatu lari brand populer',
        searchIn: 'products',
        productCategory: 'Lari',
        brand: 'SwiftRun',
        minPrice: 500000,
      ),
    ];

    _allNews = [
      NewsItem(
        title: 'Derby Panas Liga Utama',
        category: 'Sepak Bola',
        summary: 'Hasil dan analisis lengkap derby akhir pekan.',
      ),
      NewsItem(
        title: 'Tips Latihan Lari 10K',
        category: 'Lari',
        summary: 'Program latihan 4 minggu untuk pemula hingga menengah.',
      ),
      NewsItem(
        title: 'Basket: Final Wilayah Timur',
        category: 'Basket',
        summary: 'Statistik kunci dan momen penting gim penentuan.',
      ),
      NewsItem(
        title: 'Umum: Jadwal Siaran Pekan Ini',
        category: 'Umum',
        summary: 'Rangkuman jadwal siaran olahraga terlengkap.',
      ),
    ];

    _allProducts = [
      ProductItem(
        name: 'Sepatu Bola Velocity X',
        category: 'Sepak Bola',
        price: 899000,
        currency: 'Rp',
        hasDiscount: true,
      ),
      ProductItem(
        name: 'Sepatu Lari SwiftRun Pro',
        category: 'Lari',
        price: 1299000,
        currency: 'Rp',
        brand: 'SwiftRun',
        hasDiscount: false,
      ),
      ProductItem(
        name: 'Jersey Basket City Lights',
        category: 'Basket',
        price: 749000,
        currency: 'Rp',
        hasDiscount: true,
      ),
      ProductItem(
        name: 'Smartwatch SportWatch Lite',
        category: 'Wearable',
        price: 1999000,
        currency: 'Rp',
        hasDiscount: false,
      ),
    ];

    _trendingProducts = [
      ProductItem(
        name: 'Sepatu Futsal Street Grip',
        category: 'Sepak Bola',
        price: 659000,
        currency: 'Rp',
        hasDiscount: true,
      ),
      ProductItem(
        name: 'Headband Running Breeze',
        category: 'Lari',
        price: 99000,
        currency: 'Rp',
        hasDiscount: false,
      ),
    ];

    _trendingNews = [
      NewsItem(
        title: 'Breaking: Transfer Spektakuler',
        category: 'Sepak Bola',
        summary: 'Spekulasi bursa transfer semakin panas.',
      ),
      NewsItem(
        title: 'Rekap Maraton Dunia',
        category: 'Lari',
        summary: 'Catatan waktu terbaik dan strategi pemenang.',
      ),
    ];

    _featuredProducts = [
      ProductItem(
        name: 'SportWatch Prime',
        category: 'Wearable',
        price: 2499000,
        currency: 'Rp',
        hasDiscount: true,
      ),
      ProductItem(
        name: 'Kaos Latihan AeroDry',
        category: 'Training',
        price: 289000,
        currency: 'Rp',
        hasDiscount: false,
      ),
      ProductItem(
        name: 'Tas Gym Compact',
        category: 'Aksesori',
        price: 349000,
        currency: 'Rp',
        hasDiscount: false,
      ),
    ];
  }

  void _performSearch() {
    final query = _queryController.text.trim().toLowerCase();
    final minPrice = _parsePrice(_minPriceController.text);
    final maxPrice = _parsePrice(_maxPriceController.text);

    final filteredNews = _allNews.where((item) {
      if (_searchIn == 'products') return false;
      if (_newsCategory != null && _newsCategory!.isNotEmpty && item.category != _newsCategory) {
        return false;
      }
      if (query.isEmpty) return true;
      return item.title.toLowerCase().contains(query) || item.summary.toLowerCase().contains(query);
    }).toList();

    final filteredProducts = _allProducts.where((item) {
      if (_searchIn == 'news') return false;
      if (_productCategory != null && _productCategory!.isNotEmpty && item.category != _productCategory) {
        return false;
      }
      if (_brand != null && _brand!.isNotEmpty && item.brand != null && item.brand != _brand) {
        return false;
      }
      if (_onlyDiscount && !item.hasDiscount) return false;
      if (minPrice != null && item.price < minPrice) return false;
      if (maxPrice != null && item.price > maxPrice) return false;
      if (query.isEmpty) return true;
      return item.name.toLowerCase().contains(query) || item.category.toLowerCase().contains(query);
    }).toList();

    setState(() {
      _filteredNews = filteredNews;
      _filteredProducts = filteredProducts;
      _updateRecentSearches();
    });
  }

  double? _parsePrice(String input) {
    if (input.trim().isEmpty) return null;
    return double.tryParse(input.replaceAll('.', '').replaceAll(',', '.'));
  }

  String _buildSummary() {
    final parts = <String>[];
    if (_queryController.text.isNotEmpty) {
      parts.add('Kata kunci: \"${_queryController.text}\"');
    }
    parts.add('Scope: ${_labelForScope(_searchIn)}');
    if (_newsCategory?.isNotEmpty == true) parts.add('Kategori berita: $_newsCategory');
    if (_productCategory?.isNotEmpty == true) parts.add('Kategori produk: $_productCategory');
    if (_brand?.isNotEmpty == true) parts.add('Brand: $_brand');
    if (_onlyDiscount) parts.add('Hanya diskon');
    final minPrice = _minPriceController.text.trim();
    final maxPrice = _maxPriceController.text.trim();
    if (minPrice.isNotEmpty) parts.add('Min Rp$minPrice');
    if (maxPrice.isNotEmpty) parts.add('Max Rp$maxPrice');

    if (parts.isEmpty) {
      return 'Mulai pencarian untuk melihat hasil yang sesuai dengan filter kamu.';
    }
    return parts.join(' | ');
  }

  String _labelForScope(String value) {
    switch (value) {
      case 'news':
        return 'Berita';
      case 'products':
        return 'Produk';
      default:
        return 'Semua';
    }
  }

  void _updateRecentSearches() {
    final summary = _buildSummary();
    if (summary.startsWith('Mulai')) return;
    if (_recentSearches.contains(summary)) {
      _recentSearches.remove(summary);
    }
    _recentSearches.insert(0, summary);
    if (_recentSearches.length > 5) {
      _recentSearches = _recentSearches.sublist(0, 5);
    }
  }

  void _applyPreset(SearchPreset preset) {
    setState(() {
      _selectedPresetId = preset.id;
      _searchIn = preset.searchIn;
      _newsCategory = preset.newsCategory;
      _productCategory = preset.productCategory;
      _brand = preset.brand;
      _onlyDiscount = preset.onlyDiscount;
      _minPriceController.text = preset.minPrice?.toStringAsFixed(0) ?? '';
      _maxPriceController.text = preset.maxPrice?.toStringAsFixed(0) ?? '';
      _queryController.text = preset.query ?? '';
    });
    _performSearch();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Preset \"${preset.label}\" diterapkan')),
    );
  }

  Future<void> _openPresetSheet() async {
    final labelController = TextEditingController();
    final descController = TextEditingController();
    final result = await showModalBottomSheet<SearchPreset>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Buat Preset',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: labelController,
                decoration: const InputDecoration(
                  labelText: 'Nama preset',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descController,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi (opsional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Batal'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      if (labelController.text.trim().isEmpty) {
                        return;
                      }
                      final preset = SearchPreset(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        label: labelController.text.trim(),
                        description: descController.text.trim(),
                        searchIn: _searchIn,
                        newsCategory: _newsCategory,
                        productCategory: _productCategory,
                        brand: _brand,
                        minPrice: _parsePrice(_minPriceController.text),
                        maxPrice: _parsePrice(_maxPriceController.text),
                        onlyDiscount: _onlyDiscount,
                        query: _queryController.text.trim(),
                      );
                      Navigator.of(context).pop(preset);
                    },
                    child: const Text('Simpan Preset'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );

    if (result != null) {
      setState(() {
        _presets = [result, ..._presets];
      });
      _applyPreset(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('SportWatch Search'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 900;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HeaderCard(theme: theme),
                const SizedBox(height: 16),
                _buildFiltersCard(),
                const SizedBox(height: 16),
                _buildSummaryCard(),
                const SizedBox(height: 16),
                isWide
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 3, child: _buildResultsCard()),
                          const SizedBox(width: 16),
                          Expanded(flex: 2, child: _buildSidePanels()),
                        ],
                      )
                    : Column(
                        children: [
                          _buildResultsCard(),
                          const SizedBox(height: 16),
                          _buildSidePanels(),
                        ],
                      ),
                const SizedBox(height: 16),
                _buildFeaturedSection(),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFiltersCard() {
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
                    controller: _queryController,
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
                    value: _searchIn,
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('Cari di: Semua')),
                      DropdownMenuItem(value: 'news', child: Text('Cari di: Berita')),
                      DropdownMenuItem(value: 'products', child: Text('Cari di: Produk')),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        _searchIn = value;
                      });
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
                    value: _newsCategory,
                    items: _buildOptions(['', 'Umum', 'Sepak Bola', 'Lari', 'Basket']),
                    onChanged: (v) => setState(() => _newsCategory = _emptyToNull(v)),
                    decoration: const InputDecoration(
                      labelText: 'Kategori Berita',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(
                  width: 220,
                  child: DropdownButtonFormField<String?>(
                    value: _productCategory,
                    items: _buildOptions(['', 'Sepak Bola', 'Lari', 'Basket', 'Wearable', 'Training', 'Aksesori']),
                    onChanged: (v) => setState(() => _productCategory = _emptyToNull(v)),
                    decoration: const InputDecoration(
                      labelText: 'Kategori Produk',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(
                  width: 220,
                  child: DropdownButtonFormField<String?>(
                    value: _brand,
                    items: _buildOptions(['', 'SwiftRun', 'SportWatch', 'AeroFit']),
                    onChanged: (v) => setState(() => _brand = _emptyToNull(v)),
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
                    controller: _minPriceController,
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
                    controller: _maxPriceController,
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
                      value: _onlyDiscount,
                      onChanged: (v) => setState(() => _onlyDiscount = v),
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
                    value: _selectedPresetId,
                    items: [
                      const DropdownMenuItem<String?>(value: null, child: Text('Tanpa preset')),
                      ..._presets.map(
                        (preset) => DropdownMenuItem<String?>(
                          value: preset.id,
                          child: Text(preset.label),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedPresetId = value;
                      });
                      final preset = _presets.firstWhere(
                        (p) => p.id == value,
                        orElse: () => SearchPreset(id: '', label: '', description: '', searchIn: 'all'),
                      );
                      if (preset.id.isNotEmpty) {
                        _applyPreset(preset);
                      }
                    },
                    decoration: const InputDecoration(
                      labelText: 'Preset pencarian',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                OutlinedButton(
                  onPressed: _openPresetSheet,
                  child: const Text('Buat Preset'),
                ),
                FilledButton(
                  onPressed: _performSearch,
                  child: const Text('Cari Sekarang'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<DropdownMenuItem<String?>> _buildOptions(List<String> options) {
    return options
        .map(
          (value) => DropdownMenuItem<String?>(
            value: value,
            child: Text(value.isEmpty ? 'Semua' : value),
          ),
        )
        .toList();
  }

  String? _emptyToNull(String? value) => (value == null || value.isEmpty) ? null : value;

  Widget _buildSummaryCard() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.blue),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _buildSummary(),
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsCard() {
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
            _buildNewsResults(),
            const SizedBox(height: 16),
            _buildProductResults(),
          ],
        ),
      ),
    );
  }

  Widget _buildNewsResults() {
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
              label: Text('${_filteredNews.length} hasil'),
              backgroundColor: Colors.blue.shade50,
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_filteredNews.isEmpty)
          const Text(
            'Belum ada berita yang cocok. Coba ubah filter atau kata kunci.',
            style: TextStyle(color: Colors.grey),
          )
        else
          Column(
            children: _filteredNews
                .map(
                  (news) => Card(
                    elevation: 1,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      title: Text(news.title),
                      subtitle: Text('${news.category} • ${news.summary}'),
                      trailing: TextButton(
                        onPressed: () {},
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

  Widget _buildProductResults() {
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
              label: Text('${_filteredProducts.length} hasil'),
              backgroundColor: Colors.blue.shade50,
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_filteredProducts.isEmpty)
          const Text(
            'Belum ada produk yang cocok. Coba sesuaikan filter atau harga.',
            style: TextStyle(color: Colors.grey),
          )
        else
          Column(
            children: _filteredProducts
                .map(
                  (product) => Card(
                    elevation: 1,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      title: Text(product.name),
                      subtitle: Text('${product.category} • ${product.currency}${product.price.toStringAsFixed(0)}'),
                      leading: Icon(
                        Icons.shopping_bag_outlined,
                        color: product.hasDiscount ? Colors.green : Colors.blueGrey,
                      ),
                      trailing: product.hasDiscount
                          ? const Chip(
                              label: Text('Diskon'),
                              backgroundColor: Color(0xFFE6F4EA),
                              labelStyle: TextStyle(color: Colors.green),
                            )
                          : null,
                    ),
                  ),
                )
                .toList(),
          ),
      ],
    );
  }

  Widget _buildSidePanels() {
    return Column(
      children: [
        _buildPresetPanel(),
        const SizedBox(height: 12),
        _buildRecentPanel(),
        const SizedBox(height: 12),
        _buildTrendingPanel(),
      ],
    );
  }

  Widget _buildPresetPanel() {
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
            Column(
              children: _presets
                  .map(
                    (preset) => Card(
                      color: preset.id == _selectedPresetId ? Colors.blue.shade50 : null,
                      child: ListTile(
                        title: Text(preset.label),
                        subtitle: Text(preset.description.isEmpty ? 'Tanpa deskripsi' : preset.description),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _applyPreset(preset),
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

  Widget _buildRecentPanel() {
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
            if (_recentSearches.isEmpty)
              const Text('Belum ada pencarian.', style: TextStyle(color: Colors.grey))
            else
              Column(
                children: _recentSearches
                    .map(
                      (item) => ListTile(
                        dense: true,
                        leading: const Icon(Icons.history, size: 20),
                        title: Text(item, maxLines: 2, overflow: TextOverflow.ellipsis),
                      ),
                    )
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendingPanel() {
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
            ..._trendingProducts.map(
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
            ..._trendingNews.map(
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

  Widget _buildFeaturedSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Produk Pilihan SportWatch',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('Lihat semua produk'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = constraints.maxWidth > 800
                    ? 3
                    : constraints.maxWidth > 520
                        ? 2
                        : 1;
                return GridView.count(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1.1,
                  children: _featuredProducts
                      .map(
                        (product) => _FeaturedProductCard(product: product),
                      )
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Temukan Segalanya di SportWatch',
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'Cari berita olahraga terkini, produk incaran, atau simpan preset pencarian favoritmu.',
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeaturedProductCard extends StatelessWidget {
  const _FeaturedProductCard({required this.product});

  final ProductItem product;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.blueGrey.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.image, size: 48, color: Colors.blueGrey),
              ),
            ),
            const SizedBox(height: 8),
            Text(product.name, style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(product.category, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 4),
            Text(
              '${product.currency}${product.price.toStringAsFixed(0)}',
              style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.green),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {},
              child: const Text('Lihat detail'),
            ),
          ],
        ),
      ),
    );
  }
}

class SearchPreset {
  SearchPreset({
    required this.id,
    required this.label,
    required this.description,
    required this.searchIn,
    this.query,
    this.newsCategory,
    this.productCategory,
    this.brand,
    this.minPrice,
    this.maxPrice,
    this.onlyDiscount = false,
  });

  final String id;
  final String label;
  final String description;
  final String searchIn; // all, news, products
  final String? query;
  final String? newsCategory;
  final String? productCategory;
  final String? brand;
  final double? minPrice;
  final double? maxPrice;
  final bool onlyDiscount;
}

class NewsItem {
  NewsItem({
    required this.title,
    required this.category,
    required this.summary,
  });

  final String title;
  final String category;
  final String summary;
}

class ProductItem {
  ProductItem({
    required this.name,
    required this.category,
    required this.price,
    required this.currency,
    this.brand,
    this.hasDiscount = false,
  });

  final String name;
  final String category;
  final double price;
  final String currency;
  final String? brand;
  final bool hasDiscount;
}
