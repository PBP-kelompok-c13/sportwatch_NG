import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:sportwatch_ng/shop/models/product_entry.dart';
import 'package:sportwatch_ng/shop/models/constants.dart';
import 'package:sportwatch_ng/user_profile_notifier.dart';

class ProductDetailPage extends StatefulWidget {
  final ProductEntry product;
  final bool isOwner;

  const ProductDetailPage({
    super.key,
    required this.product,
    required this.isOwner,
  });

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  // State untuk rating summary
  late double _ratingAvg;
  late int _ratingCount;

  // State untuk reviews list
  final List<_ProductReview> _reviews = [];
  bool _isLoadingReviews = false;
  bool _hasMoreReviews = true;
  int _currentPage = 1;

  //State untuk form review
  int? _selectedRating;
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  bool _isSubmittingReview = false;
  bool _hasReviewed = false; // dikunci setelah submit berhasil

  @override
  void initState() {
    super.initState();
    _ratingAvg = widget.product.fields.ratingAvg;
    _ratingCount = widget.product.fields.ratingCount;

    // load reviews begitu halaman dibuka
    Future.microtask(() {
      if (!mounted) return;
      final request = context.read<CookieRequest>();
      _fetchReviews(request, reset: true);
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  // models kecil untuk review
  Future<void> _fetchReviews(
    CookieRequest request, {
    bool reset = false,
  }) async {
    if (_isLoadingReviews) return;

    setState(() {
      _isLoadingReviews = true;
      if (reset) {
        _currentPage = 1;
        _reviews.clear();
        _hasMoreReviews = true;
      }
    });

    try {
      if (!_hasMoreReviews) {
        _isLoadingReviews = false;
        return;
      }

      final url =
          "$baseUrl/api/shop/reviews/${widget.product.pk}/?page=$_currentPage";

      final response = await request.get(url);

      final results = (response['results'] as List<dynamic>)
          .cast<Map<String, dynamic>>();

      final newReviews = results.map(_ProductReview.fromJson).toList();

      if (!mounted) return;
      setState(() {
        _reviews.addAll(newReviews);
        _hasMoreReviews = response['has_next'] == true;
        if (_hasMoreReviews) {
          _currentPage += 1;
        }
      });
    } catch (e) {
      // b
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingReviews = false;
        });
      }
    }
  }

  Future<void> _submitReview(CookieRequest request) async {
    if (_isSubmittingReview) return;
    if (_selectedRating == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a rating (1-5).')),
      );
      return;
    }
    if (_titleController.text.trim().isEmpty ||
        _contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title and content cannot be empty.')),
      );
      return;
    }

    setState(() {
      _isSubmittingReview = true;
    });

    try {
      final url =
          "$baseUrl/api/shop/reviews/${widget.product.id}/create-flutter/";

      // create_review expects POST form (bukan JSON)
      final response = await request.post(url, {
        "rating": _selectedRating.toString(),
        "title": _titleController.text.trim(),
        "content": _contentController.text.trim(),
      });
      if (!mounted) return;

      // Kalau backend mengikuti view create_review, response-nya:
      if (response['ok'] == true) {
        final newReviewJson = (response['review'] as Map<String, dynamic>);

        final newReview = _ProductReview(
          user: newReviewJson['user'] as String,
          rating: newReviewJson['rating'] as int,
          title: newReviewJson['title'] as String,
          content: newReviewJson['content'] as String,
          createdAt: DateTime.now(), // backend tidak kirim
        );

        setState(() {
          _reviews.insert(0, newReview);
          _ratingAvg =
              (response['rating_avg'] as num?)?.toDouble() ?? _ratingAvg;
          _ratingCount = response['rating_count'] as int? ?? _ratingCount;
          _hasReviewed = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Review submitted. Thank you!')),
        );

        if (context.mounted) {
          Navigator.pop(context, true); // kasih tahu parent bahwa data berubah
        }
      } else {
        final err = response['errors'] ?? response['error'] ?? 'Unknown error';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit review: $err')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to submit review: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isSubmittingReview = false;
        });
      }
    }
  }

  String _formatPrice(double value) => "Rp ${value.toStringAsFixed(0)}";

  String _buildMetaLine(BuildContext context) {
    final category = widget.product.fields.category;
    final owner = widget.product.owner; // nullable String?

    if (owner != null && owner.isNotEmpty) {
      return "$category • by $owner";
    }
    return category;
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    final profile = context.watch<UserProfileNotifier>();
    final fields = widget.product.fields;
    final hasDiscount = widget.product.salePrice != null;
    final isGuest = profile.isGuest;

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Produk'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // -Image
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: widget.product.thumbnail.isNotEmpty
                  ? Image.network(
                      widget.product.thumbnail,
                      width: double.infinity,
                      height: 220,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stack) => Container(
                        height: 220,
                        color: Colors.grey.shade200,
                        child: const Center(child: Icon(Icons.watch, size: 50)),
                      ),
                    )
                  : Container(
                      height: 220,
                      width: double.infinity,
                      color: Colors.grey.shade200,
                      child: const Center(child: Icon(Icons.watch, size: 50)),
                    ),
            ),

            const SizedBox(height: 16),

            // Cat and owner
            Text(
              _buildMetaLine(context),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 4),

            //
            Text(
              widget.product.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            // Price discount dan stoc
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatPrice(widget.product.finalPrice),
                  style: GoogleFonts.barlowCondensed(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (hasDiscount) ...[
                  const SizedBox(width: 8),
                  Text(
                    _formatPrice(widget.product.price),
                    style: GoogleFonts.barlowCondensed(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "-${widget.product.discountPercent}%",
                      style: GoogleFonts.barlowCondensed(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
                const SizedBox(width: 8),
                if (!widget.product.inStock)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      "Out of stock",
                      style: TextStyle(fontSize: 12, color: Colors.white),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 4),

            //Rating
            Text(
              "Reviews ($_ratingCount) — "
              "${_ratingCount > 0 ? "⭐ ${_ratingAvg.toStringAsFixed(1)}" : "☆☆☆☆☆"}",
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),

            const SizedBox(height: 16),

            // Desc
            Text(
              fields.description,
              style: const TextStyle(fontSize: 14, height: 1.6),
            ),

            const SizedBox(height: 24),

            // Add TO CART BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    (!widget.product.inStock ||
                        widget.isOwner ||
                        profile.isGuest)
                    ? null
                    : () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Fitur keranjang belum diimplementasi.',
                            ),
                          ),
                        );
                      },
                child: Text(
                  !widget.product.inStock
                      ? "Out of Stock"
                      : (widget.isOwner
                            ? "You own this product"
                            : (profile.isGuest
                                  ? "Login to buy"
                                  : "Add to Cart")),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // SECTION REVIEWS
            const Text(
              "Reviews",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            if (_reviews.isEmpty && !_isLoadingReviews)
              const Text(
                "Belum ada review.",
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),

            // List review
            ListView.builder(
              itemCount: _reviews.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final r = _reviews[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${r.user} • ⭐ ${r.rating}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      if (r.title.isNotEmpty)
                        Text(
                          r.title,
                          style: const TextStyle(
                            fontSize: 13,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      const SizedBox(height: 2),
                      Text(r.content, style: const TextStyle(fontSize: 13)),
                      const Divider(),
                    ],
                  ),
                );
              },
            ),

            if (_isLoadingReviews)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_hasMoreReviews)
              TextButton(
                onPressed: () => _fetchReviews(request),
                child: const Text("Load more reviews"),
              ),

            const SizedBox(height: 24),

            // ---------- REVIEW FORM (hanya jika bukan owner & belum review) ----------
            if (!widget.isOwner && !_hasReviewed && !isGuest) ...[
              const Text(
                "Write a review",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              // Rating picker 1–5
              Row(
                children: List.generate(5, (i) {
                  final starValue = i + 1;
                  final selected =
                      _selectedRating != null && _selectedRating! >= starValue;
                  return IconButton(
                    icon: Icon(selected ? Icons.star : Icons.star_border),
                    color: Colors.amber,
                    onPressed: () {
                      setState(() {
                        _selectedRating = starValue;
                      });
                    },
                  );
                }),
              ),

              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: "Title",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: _contentController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: "Content",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmittingReview
                      ? null
                      : () => _submitReview(request),
                  child: Text(
                    _isSubmittingReview ? "Submitting..." : "Submit Review",
                  ),
                ),
              ),
            ] else if (isGuest) ...[
              const Text(
                "Login to write a review.",
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ] else if (widget.isOwner) ...[
              const Text(
                "You cannot review your own product.",
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ] else if (!widget.isOwner && _hasReviewed) ...[
              const Text(
                "You have already reviewed this product.",
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Model kecil untuk review di Flutter
class _ProductReview {
  final String user;
  final int rating;
  final String title;
  final String content;
  final DateTime createdAt;

  _ProductReview({
    required this.user,
    required this.rating,
    required this.title,
    required this.content,
    required this.createdAt,
  });

  factory _ProductReview.fromJson(Map<String, dynamic> json) {
    return _ProductReview(
      user: json['user'] as String,
      rating: json['rating'] as int,
      title: (json['title'] ?? "") as String,
      content: (json['content'] ?? "") as String,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }
}
