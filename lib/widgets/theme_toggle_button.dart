import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sportwatch_ng/theme_notifier.dart';

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, themeNotifier, _) {
        final isDark = themeNotifier.isDark;
        final scheme = Theme.of(context).colorScheme;
        final gradientColors = isDark
            ? const [Color(0xFF0F172A), Color(0xFF1E3A8A)]
            : const [Color(0xFF60A5FA), Color(0xFFFDE68A)];

        return Tooltip(
          message: isDark ? 'Switch to light mode' : 'Switch to dark mode',
          child: Semantics(
            button: true,
            toggled: isDark,
            label: 'Toggle theme',
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: themeNotifier.toggle,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeOutCubic,
                  width: 44,
                  height: 44,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: gradientColors,
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: scheme.onSurface.withAlpha((0.08 * 255).round()),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (isDark
                                ? Colors.black
                                : const Color(0xFF60A5FA))
                            .withAlpha((0.28 * 255).round()),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          switchInCurve: Curves.easeOutBack,
                          switchOutCurve: Curves.easeInBack,
                          child: Icon(
                            key: ValueKey(isDark),
                            isDark
                                ? Icons.nightlight_round
                                : Icons.wb_sunny_rounded,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 6,
                        left: 7,
                        child: AnimatedOpacity(
                          opacity: isDark ? 1 : 0,
                          duration: const Duration(milliseconds: 250),
                          child: const Icon(
                            Icons.auto_awesome,
                            size: 12,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 4,
                        right: 6,
                        child: AnimatedOpacity(
                          opacity: isDark ? 0 : 1,
                          duration: const Duration(milliseconds: 250),
                          child: const Icon(
                            Icons.cloud,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
