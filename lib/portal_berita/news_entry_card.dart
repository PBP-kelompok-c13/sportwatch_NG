import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:sportwatch_ng/config.dart';
import 'package:sportwatch_ng/portal_berita/news_entry.dart';
import 'package:timeago/timeago.dart' as timeago;

const double _kCardMarginHorizontal = 16.0;
const double _kCardMarginVertical = 12.0;
const double _kCardElevation = 4.0;
const double _kCardBorderRadius = 12.0;
const double _kImageHeight = 180.0;
const double _kFeaturedBadgeTop = 12.0;
const double _kFeaturedBadgeRight = 12.0;
const double _kFeaturedBadgePaddingHorizontal = 12.0;
const double _kFeaturedBadgePaddingVertical = 6.0;
const double _kFeaturedBadgeBorderRadius = 20.0;
const double _kFeaturedBadgeIconSize = 14.0;
const double _kFeaturedBadgeIconTextSpacing = 4.0;
const double _kFeaturedBadgeFontSize = 12.0;
const double _kContentPadding = 16.0;
const double _kCategoryTagPaddingHorizontal = 8.0;
const double _kCategoryTagPaddingVertical = 4.0;
const double _kCategoryTagBorderRadius = 4.0;
const double _kCategoryTagFontSize = 11.0;
const double _kTitleSpacing = 8.0;
const double _kAuthorDateSpacing = 8.0;

class NewsEntryCard extends StatefulWidget {
  final NewsEntry news;
  final VoidCallback onTap;

  const NewsEntryCard({super.key, required this.news, required this.onTap});

  @override
  State<NewsEntryCard> createState() => _NewsEntryCardState();
}

class _NewsEntryCardState extends State<NewsEntryCard> {
  late List<ReactionSummary> _reactionSummary;
  String? _userReaction;
  bool _isReacting = false;

  @override
  void initState() {
    super.initState();
    _reactionSummary = widget.news.reactionSummary;
    _userReaction = widget.news.userReaction;
  }

  @override
  void didUpdateWidget(covariant NewsEntryCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.news != oldWidget.news) {
      _reactionSummary = widget.news.reactionSummary;
      _userReaction = widget.news.userReaction;
    }
  }

  Future<void> _handleReaction(
    String reactionKey,
    CookieRequest request,
  ) async {
    if (_isReacting) return;
    if (!request.loggedIn) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please login to react')));
      return;
    }

    setState(() {
      _isReacting = true;
    });

    // Optimistic update
    final previousUserReaction = _userReaction;
    final previousSummary = _reactionSummary
        .map((e) => ReactionSummary.fromJson(e.toJson()))
        .toList();

    setState(() {
      if (_userReaction == reactionKey) {
        // Remove reaction
        _userReaction = null;
        for (var summary in _reactionSummary) {
          if (summary.key == reactionKey) {
            summary.count = (summary.count - 1).clamp(0, 999999);
          }
        }
      } else {
        // Change or add reaction
        if (_userReaction != null) {
          // Decrement previous
          for (var summary in _reactionSummary) {
            if (summary.key == _userReaction) {
              summary.count = (summary.count - 1).clamp(0, 999999);
            }
          }
        }
        // Increment new
        _userReaction = reactionKey;
        for (var summary in _reactionSummary) {
          if (summary.key == reactionKey) {
            summary.count++;
          }
        }
      }
    });

    try {
      final response = await request.post(reactToNewsApi(widget.news.id), {
        'reaction': reactionKey,
      });

      if (response['status'] == 'ok') {
        // Update with server data to be sure
        if (mounted) {
          setState(() {
            _userReaction = response['user_reaction'];
            _reactionSummary = List<ReactionSummary>.from(
              response['reactions'].map((x) => ReactionSummary.fromJson(x)),
            );
          });
        }
      } else {
        throw Exception(response['error'] ?? 'Unknown error');
      }
    } catch (e) {
      // Revert on error
      if (mounted) {
        setState(() {
          _userReaction = previousUserReaction;
          _reactionSummary = previousSummary;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Failed to react: $e')));
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isReacting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final mutedColor = colorScheme.onSurfaceVariant;
    final request = context.watch<CookieRequest>();

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: _kCardMarginHorizontal,
        vertical: _kCardMarginVertical,
      ),
      elevation: _kCardElevation,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_kCardBorderRadius),
      ),
      child: InkWell(
        onTap: widget.onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            Stack(
              children: [
                SizedBox(
                  height: _kImageHeight,
                  width: double.infinity,
                  child: widget.news.thumbnail.isNotEmpty
                      ? Image.network(
                          buildProxyImageUrl(widget.news.thumbnail),
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value:
                                    loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                color: colorScheme.surfaceContainerHighest,
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.broken_image,
                                        size: 40,
                                        color: mutedColor,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "Image Error",
                                        style: TextStyle(color: mutedColor),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                        )
                      : Container(
                          color: colorScheme.surfaceContainerHighest,
                          child: Center(
                            child: Icon(
                              Icons.image_not_supported_outlined,
                              size: 48,
                              color: mutedColor,
                            ),
                          ),
                        ),
                ),
                if (widget.news.isPublished)
                  Positioned(
                    top: _kFeaturedBadgeTop,
                    right: _kFeaturedBadgeRight,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: _kFeaturedBadgePaddingHorizontal,
                        vertical: _kFeaturedBadgePaddingVertical,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.secondary,
                        borderRadius: BorderRadius.circular(
                          _kFeaturedBadgeBorderRadius,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.star,
                            size: _kFeaturedBadgeIconSize,
                            color: colorScheme.onSecondary,
                          ),
                          SizedBox(width: _kFeaturedBadgeIconTextSpacing),
                          Text(
                            'Featured',
                            style: TextStyle(
                              color: colorScheme.onSecondary,
                              fontWeight: FontWeight.bold,
                              fontSize: _kFeaturedBadgeFontSize,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),

            // Content Section
            Padding(
              padding: const EdgeInsets.all(_kContentPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category Tag
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: _kCategoryTagPaddingHorizontal,
                      vertical: _kCategoryTagPaddingVertical,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withAlpha(
                        (0.15 * 255).round(),
                      ),
                      borderRadius: BorderRadius.circular(
                        _kCategoryTagBorderRadius,
                      ),
                    ),
                    child: Text(
                      widget.news.kategori.toUpperCase(),
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontSize: _kCategoryTagFontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: _kTitleSpacing),

                  // Title
                  Text(
                    widget.news.judul,
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: _kAuthorDateSpacing),

                  // Author and Date
                  Row(
                    children: [
                      Text(
                        widget.news.penulis ?? "Unknown Author",
                        style: textTheme.bodySmall?.copyWith(color: mutedColor),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        timeago.format(widget.news.tanggalDibuat),
                        style: textTheme.bodySmall?.copyWith(color: mutedColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Content Preview
                  Text(
                    widget.news.konten,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodyMedium?.copyWith(
                      color: mutedColor,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Reactions Bar
                  SizedBox(
                    height: 40,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _reactionSummary.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final reaction = _reactionSummary[index];
                        final isSelected = _userReaction == reaction.key;
                        return Material(
                          color: isSelected
                              ? colorScheme.primaryContainer
                              : colorScheme.surfaceContainerHighest.withValues(
                                  alpha: 0.5,
                                ),
                          borderRadius: BorderRadius.circular(20),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () => _handleReaction(reaction.key, request),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    reaction.emoji,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${reaction.count}',
                                    style: TextStyle(
                                      color: isSelected
                                          ? colorScheme.onPrimaryContainer
                                          : colorScheme.onSurfaceVariant,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
