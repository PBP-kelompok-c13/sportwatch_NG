part of 'search_landing_page.dart';

class _SearchLandingPageState extends State<SearchLandingPage> with AutomaticKeepAliveClientMixin {
  static _SearchPageSnapshot? _lastSnapshot;
  final TextEditingController _queryController = TextEditingController();
  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();
  final Map<String, ProductEntry> _productEntryCache = {};

  String _searchIn = 'all';
  String? _selectedNewsCategoryId;
  String? _selectedProductCategoryId;
  String? _selectedBrandId;
  bool _onlyDiscount = false;
  String? _selectedPresetId;

  late List<SearchPreset> _presets;
  late List<NewsItem> _trendingNews;
  late List<ProductItem> _trendingProducts;
  late List<ProductItem> _featuredProducts;
  List<FilterOption> _newsCategoryOptions = [];
  List<FilterOption> _productCategoryOptions = [];
  List<FilterOption> _brandOptions = [];
  List<NewsItem> _filteredNews = [];
  List<ProductItem> _filteredProducts = [];
  List<String> _recentSearches = [];
  SearchResultsSummary? _serverSummary;
  bool _loadingResults = false;
  String? _resultsError;

  @override
  void initState() {
    super.initState();
    final snapshot = _lastSnapshot;
    if (snapshot != null) {
      _restoreFromSnapshot(snapshot);
    } else {
      _seedData();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFilterOptions();
      _loadFeaturedProducts();
      _performSearch();
    });
  }

  @override
  void dispose() {
    _lastSnapshot = _SearchPageSnapshot(
      query: _queryController.text,
      minPrice: _minPriceController.text,
      maxPrice: _maxPriceController.text,
      searchIn: _searchIn,
      newsCategoryId: _selectedNewsCategoryId,
      productCategoryId: _selectedProductCategoryId,
      brandId: _selectedBrandId,
      onlyDiscount: _onlyDiscount,
      selectedPresetId: _selectedPresetId,
      presets: List<SearchPreset>.from(_presets),
      trendingNews: List<NewsItem>.from(_trendingNews),
      trendingProducts: List<ProductItem>.from(_trendingProducts),
      featuredProducts: List<ProductItem>.from(_featuredProducts),
      newsCategoryOptions: List<FilterOption>.from(_newsCategoryOptions),
      productCategoryOptions: List<FilterOption>.from(_productCategoryOptions),
      brandOptions: List<FilterOption>.from(_brandOptions),
      filteredNews: List<NewsItem>.from(_filteredNews),
      filteredProducts: List<ProductItem>.from(_filteredProducts),
      recentSearches: List<String>.from(_recentSearches),
      serverSummary: _serverSummary,
      resultsError: _resultsError,
    );
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
        onlyDiscount: true,
      ),
      SearchPreset(
        id: 'preset-2',
        label: 'Berita Terkini',
        description: 'Lihat berita olahraga terbaru',
        searchIn: 'news',
      ),
      SearchPreset(
        id: 'preset-3',
        label: 'Lari Premium',
        description: 'Sepatu lari brand populer',
        searchIn: 'products',
        minPrice: 500000,
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

    _featuredProducts = [];
  }

  Future<void> _performSearch() async {
    final request = context.read<CookieRequest>();
    await _fetchSearchResults(request);
  }

  Future<void> _loadFilterOptions() async {
    final request = context.read<CookieRequest>();
    try {
      final response = await request.get(searchFilterOptionsUrl());
      final newsCategories = (response['news_categories'] as List<dynamic>? ?? [])
          .map((item) => FilterOption.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
      final categories = (response['product_categories'] as List<dynamic>? ?? [])
          .map((item) => FilterOption.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
      final brands = (response['brands'] as List<dynamic>? ?? [])
          .map((item) => FilterOption.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
      if (!mounted) return;
      setState(() {
        _newsCategoryOptions = newsCategories;
        _productCategoryOptions = categories;
        _brandOptions = brands;
        if (_selectedNewsCategoryId != null &&
            _newsCategoryOptions.indexWhere((opt) => opt.id == _selectedNewsCategoryId) == -1) {
          _selectedNewsCategoryId = null;
        }
        if (_selectedProductCategoryId != null &&
            _productCategoryOptions.indexWhere((opt) => opt.id == _selectedProductCategoryId) == -1) {
          _selectedProductCategoryId = null;
        }
        if (_selectedBrandId != null &&
            _brandOptions.indexWhere((opt) => opt.id == _selectedBrandId) == -1) {
          _selectedBrandId = null;
        }
      });
    } catch (e) {
      // silently fail; keep previous static options
    }
  }

  Future<void> _loadFeaturedProducts() async {
    final request = context.read<CookieRequest>();
    try {
      final response = await request.get(featuredProductsUrl());
      final results = (response['results'] as List<dynamic>? ?? [])
          .map((item) => ProductItem.fromJson(Map<String, dynamic>.from(item as Map)))
          .take(3)
          .toList();
      if (!mounted) return;
      setState(() {
        _featuredProducts = results;
      });
    } catch (_) {
      // ignore failures; keep current featured products
    }
  }

  void _restoreFromSnapshot(_SearchPageSnapshot snapshot) {
    _queryController.text = snapshot.query;
    _minPriceController.text = snapshot.minPrice;
    _maxPriceController.text = snapshot.maxPrice;
    _searchIn = snapshot.searchIn;
    _selectedNewsCategoryId = snapshot.newsCategoryId;
    _selectedProductCategoryId = snapshot.productCategoryId;
    _selectedBrandId = snapshot.brandId;
    _onlyDiscount = snapshot.onlyDiscount;
    _selectedPresetId = snapshot.selectedPresetId;
    _presets = List<SearchPreset>.from(snapshot.presets);
    _trendingNews = List<NewsItem>.from(snapshot.trendingNews);
    _trendingProducts = List<ProductItem>.from(snapshot.trendingProducts);
    _featuredProducts = List<ProductItem>.from(snapshot.featuredProducts);
    _newsCategoryOptions = List<FilterOption>.from(snapshot.newsCategoryOptions);
    _productCategoryOptions = List<FilterOption>.from(snapshot.productCategoryOptions);
    _brandOptions = List<FilterOption>.from(snapshot.brandOptions);
    _filteredNews = List<NewsItem>.from(snapshot.filteredNews);
    _filteredProducts = List<ProductItem>.from(snapshot.filteredProducts);
    _recentSearches = List<String>.from(snapshot.recentSearches);
    _serverSummary = snapshot.serverSummary;
    _resultsError = snapshot.resultsError;
    _loadingResults = false;
  }

  double? _parsePrice(String input) {
    if (input.trim().isEmpty) return null;
    return double.tryParse(input.replaceAll('.', '').replaceAll(',', '.'));
  }

  String? _formatPriceForRequest(String input) {
    final parsed = _parsePrice(input);
    if (parsed == null) return null;
    return parsed.toStringAsFixed(0);
  }

  String _buildSummary() {
    final parts = <String>[];
    if (_queryController.text.isNotEmpty) {
      parts.add('Kata kunci: "${_queryController.text}"');
    }
    parts.add('Scope: ${_labelForScope(_searchIn)}');
    final selectedNews = _findOptionById(_newsCategoryOptions, _selectedNewsCategoryId);
    if (selectedNews != null) parts.add('Kategori berita: ${selectedNews.name}');
    final selectedCategory = _findOptionById(_productCategoryOptions, _selectedProductCategoryId);
    if (selectedCategory != null) parts.add('Kategori produk: ${selectedCategory.name}');
    final selectedBrand = _findOptionById(_brandOptions, _selectedBrandId);
    if (selectedBrand != null) parts.add('Brand: ${selectedBrand.name}');
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

  String _effectiveSummaryText() {
    final base = _buildSummary();
    if (_serverSummary == null) {
      return base;
    }
    final serverPart =
        'Server menemukan ${_serverSummary!.newsCount} berita & ${_serverSummary!.productCount} produk.';
    return '$base\n$serverPart';
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

  Map<String, String> _buildSearchQueryParams() {
    final params = <String, String>{};
    final query = _queryController.text.trim();
    if (query.isNotEmpty) {
      params['query'] = query;
    }
    params['search_in'] = _searchIn;
    final minPrice = _formatPriceForRequest(_minPriceController.text);
    final maxPrice = _formatPriceForRequest(_maxPriceController.text);
    if (minPrice != null) params['min_price'] = minPrice;
    if (maxPrice != null) params['max_price'] = maxPrice;
    if (_selectedNewsCategoryId != null) params['news_category'] = _selectedNewsCategoryId!;
    if (_selectedProductCategoryId != null) params['product_category'] = _selectedProductCategoryId!;
    if (_selectedBrandId != null) params['brand'] = _selectedBrandId!;
    if (_onlyDiscount) params['only_discount'] = 'true';
    return params;
  }

  Future<void> _fetchSearchResults(CookieRequest request) async {
    final params = _buildSearchQueryParams();
    setState(() {
      _loadingResults = true;
      _resultsError = null;
    });
    try {
      final url = searchResultsUrl(params);
      final response = await request.get(url);
      final data = Map<String, dynamic>.from(response as Map);
      final newsList = (data['news'] as List<dynamic>? ?? [])
          .map((item) => NewsItem.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
      final productList = (data['products'] as List<dynamic>? ?? [])
          .map((item) => ProductItem.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
      final summaryData = data['summary'] as Map<String, dynamic>?;
      final summary = summaryData != null ? SearchResultsSummary.fromJson(summaryData) : null;
      final recentList = _mapRecentEntries(data['recent'] as List<dynamic>? ?? []);
      if (!mounted) return;
      setState(() {
        _filteredNews = newsList;
        _filteredProducts = productList;
        _serverSummary = summary;
        _recentSearches = recentList;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _resultsError = e.toString();
        _serverSummary = null;
      });
    } finally {
      if (mounted) {
        setState(() {
          _loadingResults = false;
        });
      }
    }
  }

  List<String> _mapRecentEntries(List<dynamic> entries) {
    return entries
        .map((item) => Map<String, dynamic>.from(item as Map))
        .map(_recentEntryToText)
        .where((text) => text.isNotEmpty)
        .toList();
  }

  String _recentEntryToText(Map<String, dynamic> entry) {
    final query = (entry['query'] as String? ?? '').trim();
    final scope = _labelForScope(entry['scope'] as String? ?? 'all');
    final newsCount = (entry['news_count'] as num?)?.toInt() ?? 0;
    final productCount = (entry['product_count'] as num?)?.toInt() ?? 0;
    final base = query.isEmpty ? '(tanpa kata kunci)' : query;
    return '$base • $scope ($newsCount berita, $productCount produk)';
  }

  FilterOption? _findOptionById(List<FilterOption> options, String? id) {
    if (id == null) return null;
    try {
      return options.firstWhere((option) => option.id == id);
    } catch (_) {
      return null;
    }
  }

  void _applyPreset(SearchPreset preset) {
    setState(() {
      _selectedPresetId = preset.id;
      _searchIn = preset.searchIn;
      _selectedNewsCategoryId = preset.newsCategoryId;
      _selectedProductCategoryId = preset.productCategoryId;
      _selectedBrandId = preset.brandId;
      _onlyDiscount = preset.onlyDiscount;
      _minPriceController.text = preset.minPrice?.toStringAsFixed(0) ?? '';
      _maxPriceController.text = preset.maxPrice?.toStringAsFixed(0) ?? '';
      _queryController.text = preset.query ?? '';
    });
    _performSearch();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Preset "${preset.label}" diterapkan')),
    );
  }

  Widget _buildResultsContent() {
    if (_loadingResults) {
      return const Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
        child: SizedBox(
          height: 220,
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }
    if (_resultsError != null) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Gagal memuat hasil pencarian',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                _resultsError ?? '-',
                style: const TextStyle(color: Colors.redAccent),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _performSearch,
                  child: const Text('Coba lagi'),
                ),
              ),
            ],
          ),
        ),
      );
    }
    return SearchResultsCard(
      newsResults: _filteredNews,
      productResults: _filteredProducts,
      onViewNews: _showNewsDialog,
      onViewProduct: _openProductDetail,
    );
  }

  Future<void> _openPresetSheet([SearchPreset? preset]) async {
    final result = await showPresetSheet(
      context: context,
      initialPreset: preset,
      scope: _searchIn,
      newsCategories: _newsCategoryOptions,
      selectedNewsCategoryId: _selectedNewsCategoryId,
      productCategoryId: _selectedProductCategoryId,
      brandId: _selectedBrandId,
      minPriceText: _minPriceController.text,
      maxPriceText: _maxPriceController.text,
      onlyDiscount: _onlyDiscount,
      productCategories: _productCategoryOptions,
      brandOptions: _brandOptions,
    );
    if (!mounted) {
      return;
    }

    if (result != null) {
      if (preset != null) {
        setState(() {
          final index = _presets.indexWhere((p) => p.id == result.id);
          if (index != -1) {
            _presets[index] = result;
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Preset "${result.label}" diperbarui')),
        );
      } else {
        setState(() {
          _presets = [result, ..._presets];
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Preset "${result.label}" ditambahkan')),
        );
      }
    }
  }

  void _showNewsDialog(NewsItem news) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(news.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              news.content ?? news.summary ?? 'Konten berita tidak tersedia.',
              maxLines: 12,
              overflow: TextOverflow.ellipsis,
            ),
            if ((news.publishedAt ?? '').isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Terbit: ${news.publishedAt}',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
            if ((news.url ?? '').isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Sumber: ${news.url}',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeletePreset(SearchPreset preset) async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Hapus preset?'),
            content: Text('Apakah kamu yakin ingin menghapus preset "${preset.label}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Batal'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Hapus'),
              ),
            ],
          ),
        ) ??
        false;
    if (!mounted) return;
    if (!confirmed) return;
    setState(() {
      _presets.removeWhere((p) => p.id == preset.id);
      if (_selectedPresetId == preset.id) {
        _selectedPresetId = null;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Preset "${preset.label}" dihapus')),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('SportWatch Search'),
        actions: const [ThemeToggleButton()],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 900;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SearchHeaderCard(),
                const SizedBox(height: 16),
                SearchFiltersCard(
                  queryController: _queryController,
                  minPriceController: _minPriceController,
                  maxPriceController: _maxPriceController,
                  searchIn: _searchIn,
                  onScopeChanged: (value) => setState(() => _searchIn = value),
                  newsCategories: _newsCategoryOptions,
                  selectedNewsCategoryId: _selectedNewsCategoryId,
                  onNewsCategoryChanged: (value) => setState(() => _selectedNewsCategoryId = value),
                  productCategories: _productCategoryOptions,
                  selectedProductCategoryId: _selectedProductCategoryId,
                  onProductCategoryChanged: (value) => setState(() => _selectedProductCategoryId = value),
                  brandOptions: _brandOptions,
                  selectedBrandId: _selectedBrandId,
                  onBrandChanged: (value) => setState(() => _selectedBrandId = value),
                  onlyDiscount: _onlyDiscount,
                  onDiscountChanged: (value) => setState(() => _onlyDiscount = value),
                  presets: _presets,
                  selectedPresetId: _selectedPresetId,
                  onPresetChanged: (value) => setState(() => _selectedPresetId = value),
                  onPresetApplied: _applyPreset,
                  onCreatePreset: () => _openPresetSheet(),
                  onPerformSearch: _performSearch,
                ),
                const SizedBox(height: 16),
                SearchSummaryCard(summaryText: _effectiveSummaryText()),
                const SizedBox(height: 16),
                if (isWide)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: _buildResultsContent(),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: SearchSidePanels(
                          presets: _presets,
                          selectedPresetId: _selectedPresetId,
                          onPresetSelected: _applyPreset,
                          onEditPreset: _openPresetSheet,
                          onDeletePreset: _confirmDeletePreset,
                          recentSearches: _recentSearches,
                          trendingProducts: _trendingProducts,
                          trendingNews: _trendingNews,
                        ),
                      ),
                    ],
                  )
                else
                  Column(
                    children: [
                      _buildResultsContent(),
                      const SizedBox(height: 16),
                      SearchSidePanels(
                        presets: _presets,
                        selectedPresetId: _selectedPresetId,
                        onPresetSelected: _applyPreset,
                        onEditPreset: _openPresetSheet,
                        onDeletePreset: _confirmDeletePreset,
                        recentSearches: _recentSearches,
                        trendingProducts: _trendingProducts,
                        trendingNews: _trendingNews,
                      ),
                    ],
                  ),
                const SizedBox(height: 16),
                FeaturedProductsSection(
                  products: _featuredProducts,
                  onViewAll: () {},
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;

  Future<void> _openProductDetail(ProductItem product) async {
    final productId = product.id;
    if (productId == null || productId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Produk ini belum memiliki detail lengkap.')),
      );
      return;
    }
    final request = context.read<CookieRequest>();
    try {
      final entry = await _getProductEntryById(productId, request);
      if (!mounted) return;
      if (entry == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Detail produk tidak dapat ditemukan.')),
        );
        return;
      }
      final currentUserId = _resolveCurrentUserId(request);
      final isOwner = currentUserId != null && entry.fields.createdBy == currentUserId;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProductDetailPage(
            product: entry,
            isOwner: isOwner,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal membuka detail produk: $e')),
      );
    }
  }

  Future<ProductEntry?> _getProductEntryById(String id, CookieRequest request) async {
    final cached = _productEntryCache[id];
    if (cached != null) {
      return cached;
    }
    final response = await request.get('$baseUrl/shop/json/');
    if (response is! List) {
      return null;
    }
    final List<dynamic> items = response;
    for (final item in items) {
      if (item is! Map<String, dynamic>) continue;
      final entry = ProductEntry.fromJson(item);
      _productEntryCache[entry.pk] = entry;
    }
    return _productEntryCache[id];
  }

  int? _resolveCurrentUserId(CookieRequest request) {
    final rawId = request.jsonData['id'] ?? request.jsonData['user_id'] ?? request.jsonData['pk'];
    if (rawId is int) return rawId;
    if (rawId is String) return int.tryParse(rawId);
    return null;
  }
}
