import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:sportwatch_ng/main_page.dart';
import 'package:sportwatch_ng/scoreboard/screens/scoreboard_landing_page.dart';
import 'package:sportwatch_ng/search/screens/search_landing_page.dart';
import 'package:sportwatch_ng/shop/screens/shop_landing_page.dart';
import 'package:sportwatch_ng/splash_screen.dart';
import 'package:sportwatch_ng/theme_notifier.dart';
import 'package:sportwatch_ng/user_profile_notifier.dart';
import 'package:sportwatch_ng/card_notifier.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

// Refined Palette: User Specified Blue & Grey
const Color appPrimaryBlue = Color(
  0xFF5D93C8,
); // Serenity Blue (Brighter Anchor)
const Color appBackground = Color(
  0xFFF7F8FA,
); // Neutral Off-White (Shop/Global)
const Color appDarkBackground = Color(0xFF2B3545); // New Dark Background
const Color appSurface = Colors.white; // Pure white for cards in light mode
const Color appBorder = Color(0xFF999999); // Soft Grey Borders
const Color appPrimaryText = Color(0xFF1D1D1F);
const Color appSecondaryText = Color(0xFF8E8E93);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Define the custom ColorScheme
    final lightColorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: appPrimaryBlue,
      onPrimary: Colors.white,
      secondary: appPrimaryBlue.withAlpha((255 * 0.8).round()),
      onSecondary: Colors.white,
      error: const Color(0xFFBA1A1A),
      onError: Colors.white,
      surface: appSurface,
      onSurface: appPrimaryText,
      surfaceContainerHighest: appSecondaryText,
    );

    final darkColorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: appPrimaryBlue,
      onPrimary: Colors.white,
      secondary: appPrimaryBlue.withAlpha((255 * 0.8).round()),
      onSecondary: Colors.white,
      error: const Color(0xFFCF6679),
      onError: Colors.black,
      surface: const Color(0xFF2B3545), // New Dark Background
      onSurface: Colors.white, // New Text Color for contrast
      surfaceContainerHighest: const Color(0xFF547BA6),
    );

    return MultiProvider(
      providers: [
        Provider<CookieRequest>(create: (_) => CookieRequest()),
        ChangeNotifierProvider<ThemeNotifier>(create: (_) => ThemeNotifier()),
        ChangeNotifierProvider<UserProfileNotifier>(
          create: (_) => UserProfileNotifier(),
        ),
        ChangeNotifierProvider<CartNotifier>(create: (_) => CartNotifier()),
      ],
      child: Consumer<ThemeNotifier>(
        builder: (context, themeNotifier, _) {
          return MaterialApp(
            title: 'Sportwatch New Generations',
            debugShowCheckedModeBanner: false,
            theme: _buildTheme(lightColorScheme),
            darkTheme: _buildTheme(darkColorScheme),
            themeMode: themeNotifier.themeMode,
            navigatorObservers: [FlutterSmartDialog.observer],
            home: const SplashGate(),
            routes: {
              '/news': (_) => const MainPage(),
              '/search': (_) => const SearchLandingPage(),
              '/scoreboard': (_) => const ScoreboardLandingPage(),
              '/shop': (_) => const ShopPage(),
            },
            builder: (context, child) {
              child = FlutterSmartDialog.init()(context, child);
              final brightness = Theme.of(context).brightness;
              return ShadTheme(
                data: ShadThemeData(
                  brightness: brightness,
                  colorScheme: brightness == Brightness.dark
                      ? const ShadSlateColorScheme.dark()
                      : const ShadSlateColorScheme.light(),
                ),
                child: ShadToaster(child: child),
              );
            },
          );
        },
      ),
    );
  }
}

ThemeData _buildTheme(ColorScheme colorScheme) {
  final isDark = colorScheme.brightness == Brightness.dark;
  final bgColor = isDark ? appDarkBackground : appBackground;
  // Use slightly transparent version of the strong border for smoother look, or raw if preferred
  final borderColor = appBorder;
  final primaryFont = GoogleFonts.inter().fontFamily;
  final fallbackFonts = <String>[
    GoogleFonts.notoSans().fontFamily ?? 'Noto Sans',
    'Noto Sans',
    'sans-serif',
  ];

  final roundedInputBorder = OutlineInputBorder(
    borderRadius: const BorderRadius.all(Radius.circular(12)),
    borderSide: BorderSide(color: borderColor),
  );

  return ThemeData(
    useMaterial3: true,
    fontFamily: primaryFont,
    fontFamilyFallback: fallbackFonts,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: bgColor,
    appBarTheme: AppBarTheme(
      backgroundColor: colorScheme.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      titleTextStyle: GoogleFonts.inter(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    cardTheme: CardThemeData(
      color: colorScheme.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: borderColor, width: 1),
      ),
      margin: const EdgeInsets.all(8.0),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: roundedInputBorder,
      focusedBorder: roundedInputBorder.copyWith(
        borderSide: BorderSide(color: colorScheme.primary, width: 2),
      ),
      enabledBorder: roundedInputBorder,
      labelStyle: GoogleFonts.inter(
        color: isDark ? Colors.white70 : appSecondaryText,
        fontWeight: FontWeight.normal,
      ),
      hintStyle: GoogleFonts.inter(
        color: (isDark ? Colors.white54 : appSecondaryText).withAlpha(
          (255 * 0.6).round(),
        ),
        fontWeight: FontWeight.normal,
      ),
      filled: true,
      fillColor: isDark
          ? appDarkBackground.withAlpha((255 * 0.5).round())
          : Colors.white,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      selectedItemColor: colorScheme.primary,
      unselectedItemColor: appSecondaryText,
      backgroundColor: colorScheme.surface,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
    textTheme:
        TextTheme(
          displayLarge: GoogleFonts.inter(
            fontSize: 57,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
          displayMedium: GoogleFonts.inter(
            fontSize: 45,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
          displaySmall: GoogleFonts.inter(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
          headlineLarge: GoogleFonts.inter(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
          headlineMedium: GoogleFonts.inter(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
          headlineSmall: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
          titleLarge: GoogleFonts.inter(
            fontSize: 22,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface,
          ),
          titleMedium: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface,
          ),
          titleSmall: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface,
          ),
          bodyLarge: GoogleFonts.inter(
            fontSize: 16,
            color: colorScheme.onSurface,
          ),
          bodyMedium: GoogleFonts.inter(
            fontSize: 14,
            color: colorScheme.onSurface,
          ),
          bodySmall: GoogleFonts.inter(
            fontSize: 12,
            color: colorScheme.onSurface,
          ),
          labelLarge: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface,
          ),
          labelMedium: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface,
          ),
          labelSmall: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface,
          ),
        ).apply(
          bodyColor: colorScheme.onSurface,
          displayColor: colorScheme.onSurface,
        ),
    shadowColor: colorScheme.primary.withValues(alpha: 0.3),
    listTileTheme: ListTileThemeData(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      minVerticalPadding: 0,
      visualDensity: VisualDensity.compact,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  );
}
