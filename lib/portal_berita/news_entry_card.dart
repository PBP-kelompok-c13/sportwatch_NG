import 'package:flutter/material.dart';
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
const double _kContentPreviewSpacing = 12.0;
const double _kReadMoreSpacing = 4.0;
const double _kReadMoreIconSize = 16.0;

class NewsEntryCard extends StatelessWidget {
  final NewsEntry news;
  final VoidCallback onTap;

  const NewsEntryCard({super.key, required this.news, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final mutedColor = colorScheme.onSurfaceVariant;

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: _kCardMarginHorizontal,
        vertical: _kCardMarginVertical,
      ),
      elevation: _kCardElevation,
      clipBehavior: Clip.antiAlias, // Clips content to card borders
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_kCardBorderRadius),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section with Featured Badge Overlay
            Stack(
              children: [
                SizedBox(
                  height: _kImageHeight,
                  width: double.infinity,
                  child: news.thumbnail.isNotEmpty
                      ? Image.network(
                          buildProxyImageUrl(news.thumbnail),
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
                // Featured Badge
                if (news.isPublished)
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
                      color: colorScheme.primary.withAlpha((0.15 * 255).round()),
                      borderRadius: BorderRadius.circular(
                        _kCategoryTagBorderRadius,
                      ),
                    ),
                    child: Text(
                      news.kategori.toUpperCase(),
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
                    news.judul,
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
                        news.penulis ?? "Unknown Author",
                        style: textTheme.bodySmall?.copyWith(
                          color: mutedColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        timeago.format(news.tanggalDibuat),
                        style: textTheme.bodySmall?.copyWith(
                          color: mutedColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Content Preview
                  Text(
                    news.konten,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodyMedium?.copyWith(
                      color: mutedColor,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: _kContentPreviewSpacing),

                  // Read More Indicator
                  Row(
                    children: [
                      Text(
                        "Read more",
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: _kReadMoreSpacing),
                      Icon(
                        Icons.arrow_forward,
                        size: _kReadMoreIconSize,
                        color: colorScheme.primary,
                      ),
                    ],
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
