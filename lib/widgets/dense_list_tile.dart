import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DenseListTile extends StatelessWidget {
  final String label;
  final String? value;
  final VoidCallback? onTap;
  final Widget? leading;
  final bool showArrow;
  final bool enabled;

  const DenseListTile({
    super.key,
    required this.label,
    this.value,
    this.onTap,
    this.leading,
    this.showArrow = true,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final onSurface = colorScheme.onSurface;

    return InkWell(
      onTap: enabled ? onTap : null,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.5,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: [
              if (leading != null) ...[
                IconTheme(
                  data: IconThemeData(
                    size: 20,
                    color: onSurface.withValues(alpha: 0.8),
                  ),
                  child: leading!,
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: onSurface,
                  ),
                ),
              ),
              if (value != null)
                Text(
                  value!,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: onSurface.withValues(alpha: 0.6),
                  ),
                ),
              if (showArrow) ...[
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right,
                  size: 16,
                  color: onSurface.withValues(alpha: 0.4),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
