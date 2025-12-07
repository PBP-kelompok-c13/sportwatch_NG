part of 'search_landing_page.dart';

Future<SearchPreset?> showPresetSheet({
  required BuildContext context,
  SearchPreset? initialPreset,
  required String scope,
  required List<FilterOption> newsCategories,
  required String? selectedNewsCategoryId,
  required String? productCategoryId,
  required String? brandId,
  required String minPriceText,
  required String maxPriceText,
  required bool onlyDiscount,
  required List<FilterOption> productCategories,
  required List<FilterOption> brandOptions,
}) async {
  final controller = _PresetSheetController(
    initialPreset: initialPreset,
    scope: scope,
    newsCategories: newsCategories,
    selectedNewsCategoryId: selectedNewsCategoryId,
    productCategoryId: productCategoryId,
    brandId: brandId,
    minPriceText: minPriceText,
    maxPriceText: maxPriceText,
    onlyDiscount: onlyDiscount,
    productCategories: productCategories,
    brandOptions: brandOptions,
  );

  final result = await controller.show(context);
  controller.dispose();
  return result;
}

class _PresetSheetController {
  _PresetSheetController({
    required this.scope,
    required this.newsCategories,
    required this.selectedNewsCategoryId,
    required this.productCategoryId,
    required this.brandId,
    required this.minPriceText,
    required this.maxPriceText,
    required this.onlyDiscount,
    required this.productCategories,
    required this.brandOptions,
    this.initialPreset,
  });

  final SearchPreset? initialPreset;
  final String scope;
  final List<FilterOption> newsCategories;
  final String? selectedNewsCategoryId;
  final String? productCategoryId;
  final String? brandId;
  final String minPriceText;
  final String maxPriceText;
  final bool onlyDiscount;
  final List<FilterOption> productCategories;
  final List<FilterOption> brandOptions;

  late final TextEditingController labelController = TextEditingController(
    text: initialPreset?.label ?? '',
  );
  late final TextEditingController descController = TextEditingController(
    text: initialPreset?.description ?? '',
  );
  late final TextEditingController minController = TextEditingController(
    text: initialPreset?.minPrice?.toStringAsFixed(0) ?? minPriceText,
  );
  late final TextEditingController maxController = TextEditingController(
    text: initialPreset?.maxPrice?.toStringAsFixed(0) ?? maxPriceText,
  );

  String _scopeValue = '';
  String? _newsValue;
  String? _productValue;
  String? _brandValue;
  bool _discountValue = false;
  String? _errorText;

  Future<SearchPreset?> show(BuildContext context) async {
    _scopeValue = initialPreset?.searchIn ?? scope;
    _newsValue = initialPreset?.newsCategoryId ?? selectedNewsCategoryId;
    _productValue = initialPreset?.productCategoryId ?? productCategoryId;
    _brandValue = initialPreset?.brandId ?? brandId;
    _discountValue = initialPreset?.onlyDiscount ?? onlyDiscount;

    final result = await showModalBottomSheet<SearchPreset>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                left: 16,
                right: 16,
                top: 16,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      initialPreset == null ? 'Buat Preset' : 'Edit Preset',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
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
                    DropdownButtonFormField<String>(
                      key: ValueKey('modal-scope-$_scopeValue'),
                      initialValue: _scopeValue,
                      decoration: const InputDecoration(
                        labelText: 'Scope default',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'all', child: Text('Semua')),
                        DropdownMenuItem(
                          value: 'news',
                          child: Text('Hanya berita'),
                        ),
                        DropdownMenuItem(
                          value: 'products',
                          child: Text('Hanya produk'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setModalState(() => _scopeValue = value);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String?>(
                      key: ValueKey('modal-news-$_newsValue'),
                      initialValue: _newsValue,
                      decoration: const InputDecoration(
                        labelText: 'Kategori berita default',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('Semua'),
                        ),
                        ...newsCategories.map(
                          (option) => DropdownMenuItem<String?>(
                            value: option.id,
                            child: Text(option.name),
                          ),
                        ),
                      ],
                      onChanged: (value) =>
                          setModalState(() => _newsValue = value),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String?>(
                      key: ValueKey('modal-product-$_productValue'),
                      initialValue: _productValue,
                      decoration: const InputDecoration(
                        labelText: 'Kategori produk default',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('Semua'),
                        ),
                        ...productCategories.map(
                          (option) => DropdownMenuItem<String?>(
                            value: option.id,
                            child: Text(option.name),
                          ),
                        ),
                      ],
                      onChanged: (value) =>
                          setModalState(() => _productValue = value),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String?>(
                      key: ValueKey('modal-brand-$_brandValue'),
                      initialValue: _brandValue,
                      decoration: const InputDecoration(
                        labelText: 'Brand default',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('Semua'),
                        ),
                        ...brandOptions.map(
                          (option) => DropdownMenuItem<String?>(
                            value: option.id,
                            child: Text(option.name),
                          ),
                        ),
                      ],
                      onChanged: (value) =>
                          setModalState(() => _brandValue = value),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: minController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Harga minimum default',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: maxController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Harga maksimum default',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Switch(
                          value: _discountValue,
                          onChanged: (value) =>
                              setModalState(() => _discountValue = value),
                        ),
                        const Text('Hanya tampilkan diskon secara default'),
                      ],
                    ),
                    if (_errorText != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        _errorText!,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ],
                    const SizedBox(height: 16),
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
                            final preset = _buildPreset();
                            if (preset == null) {
                              setModalState(() {});
                              return;
                            }
                            Navigator.of(context).pop(preset);
                          },
                          child: const Text('Simpan Preset'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
    return result;
  }

  SearchPreset? _buildPreset() {
    final label = labelController.text.trim();
    if (label.isEmpty) {
      _errorText = 'Nama preset wajib diisi.';
      return null;
    }
    final minValue = _parsePrice(minController.text);
    final maxValue = _parsePrice(maxController.text);
    if (minValue != null && maxValue != null && minValue > maxValue) {
      _errorText = 'Harga minimum tidak boleh lebih besar dari maksimum.';
      return null;
    }
    _errorText = null;
    return SearchPreset(
      id: initialPreset?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      label: label,
      description: descController.text.trim(),
      searchIn: _scopeValue,
      newsCategoryId: _newsValue,
      productCategoryId: _productValue,
      brandId: _brandValue,
      minPrice: minValue,
      maxPrice: maxValue,
      onlyDiscount: _discountValue,
      query: initialPreset?.query,
    );
  }

  double? _parsePrice(String input) {
    if (input.trim().isEmpty) return null;
    return double.tryParse(input.replaceAll('.', '').replaceAll(',', '.'));
  }

  void dispose() {
    labelController.dispose();
    descController.dispose();
    minController.dispose();
    maxController.dispose();
  }
}
