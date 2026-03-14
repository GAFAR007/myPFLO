import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color _ink = Color(0xFF16212A);
  static const Color _paper = Color(0xFFF5EFE5);
  static const Color _paperRaised = Color(0xFFFFFBF5);
  static const Color _teal = Color(0xFF0B6E69);
  static const Color _mint = Color(0xFFBFE4DE);
  static const Color _copper = Color(0xFFBA6436);
  static const Color _copperSoft = Color(0xFFF2D3BE);
  static const Color _darkSurface = Color(0xFF101920);
  static const Color _darkRaised = Color(0xFF17232C);
  static const Color _darkText = Color(0xFFF5EFE5);

  static ThemeData light() {
    const scheme = ColorScheme(
      brightness: Brightness.light,
      primary: _teal,
      onPrimary: Color(0xFFF8FBFA),
      primaryContainer: _mint,
      onPrimaryContainer: Color(0xFF0A302D),
      secondary: _copper,
      onSecondary: Color(0xFFFFF8F3),
      secondaryContainer: _copperSoft,
      onSecondaryContainer: Color(0xFF5C2A0D),
      tertiary: Color(0xFF845D15),
      onTertiary: Color(0xFFFFF8ED),
      tertiaryContainer: Color(0xFFF1E0B6),
      onTertiaryContainer: Color(0xFF4F390B),
      error: Color(0xFFB3261E),
      onError: Colors.white,
      errorContainer: Color(0xFFF9DEDC),
      onErrorContainer: Color(0xFF410E0B),
      surface: _paper,
      onSurface: _ink,
      onSurfaceVariant: Color(0xFF566572),
      outline: Color(0xFFBCC6D0),
      outlineVariant: Color(0xFFD7DEE5),
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: Color(0xFF1F2A33),
      onInverseSurface: Color(0xFFF4F0EA),
      inversePrimary: Color(0xFF7ED3C7),
      surfaceTint: _teal,
    );

    return _buildTheme(
      scheme: scheme,
      background: _paper,
      raisedSurface: _paperRaised,
    );
  }

  static ThemeData dark() {
    const scheme = ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xFF66D0C3),
      onPrimary: Color(0xFF072D2A),
      primaryContainer: Color(0xFF104440),
      onPrimaryContainer: Color(0xFFD2F3EE),
      secondary: Color(0xFFF0AE78),
      onSecondary: Color(0xFF4A230D),
      secondaryContainer: Color(0xFF6B3719),
      onSecondaryContainer: Color(0xFFFFE6D3),
      tertiary: Color(0xFFE4CC86),
      onTertiary: Color(0xFF44320A),
      tertiaryContainer: Color(0xFF624915),
      onTertiaryContainer: Color(0xFFFFECB6),
      error: Color(0xFFF2B8B5),
      onError: Color(0xFF601410),
      errorContainer: Color(0xFF8C1D18),
      onErrorContainer: Color(0xFFF9DEDC),
      surface: _darkSurface,
      onSurface: _darkText,
      onSurfaceVariant: Color(0xFFB8C4CF),
      outline: Color(0xFF76828C),
      outlineVariant: Color(0xFF33404A),
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: Color(0xFFEAE5DE),
      onInverseSurface: Color(0xFF16212A),
      inversePrimary: _teal,
      surfaceTint: Color(0xFF66D0C3),
    );

    return _buildTheme(
      scheme: scheme,
      background: _darkSurface,
      raisedSurface: _darkRaised,
    );
  }

  static ThemeData _buildTheme({
    required ColorScheme scheme,
    required Color background,
    required Color raisedSurface,
  }) {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
    );

    final bodyText = GoogleFonts.manropeTextTheme(
      base.textTheme,
    ).apply(bodyColor: scheme.onSurface, displayColor: scheme.onSurface);

    final textTheme = bodyText.copyWith(
      displayLarge: GoogleFonts.spaceGrotesk(
        fontSize: 68,
        fontWeight: FontWeight.w700,
        letterSpacing: -2.6,
        height: 0.94,
        color: scheme.onSurface,
      ),
      displayMedium: GoogleFonts.spaceGrotesk(
        fontSize: 54,
        fontWeight: FontWeight.w700,
        letterSpacing: -2.0,
        height: 0.97,
        color: scheme.onSurface,
      ),
      displaySmall: GoogleFonts.spaceGrotesk(
        fontSize: 42,
        fontWeight: FontWeight.w700,
        letterSpacing: -1.4,
        height: 1.0,
        color: scheme.onSurface,
      ),
      headlineLarge: GoogleFonts.spaceGrotesk(
        fontSize: 34,
        fontWeight: FontWeight.w700,
        letterSpacing: -1.0,
        height: 1.05,
        color: scheme.onSurface,
      ),
      headlineMedium: GoogleFonts.spaceGrotesk(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.8,
        color: scheme.onSurface,
      ),
      titleLarge: GoogleFonts.spaceGrotesk(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
        color: scheme.onSurface,
      ),
      titleMedium: GoogleFonts.spaceGrotesk(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        color: scheme.onSurface,
      ),
      labelLarge: GoogleFonts.spaceGrotesk(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
        color: scheme.onSurface,
      ),
      bodyLarge: GoogleFonts.manrope(
        fontSize: 18,
        height: 1.55,
        fontWeight: FontWeight.w500,
        color: scheme.onSurface,
      ),
      bodyMedium: GoogleFonts.manrope(
        fontSize: 16,
        height: 1.55,
        fontWeight: FontWeight.w500,
        color: scheme.onSurface,
      ),
      bodySmall: GoogleFonts.manrope(
        fontSize: 13,
        height: 1.45,
        fontWeight: FontWeight.w500,
        color: scheme.onSurfaceVariant,
      ),
    );

    return base.copyWith(
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: background.withValues(alpha: 0.92),
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: textTheme.titleMedium,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: raisedSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
      drawerTheme: DrawerThemeData(
        backgroundColor: raisedSurface,
        surfaceTintColor: Colors.transparent,
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant.withValues(alpha: 0.75),
        thickness: 1,
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: scheme.primaryContainer.withValues(alpha: 0.55),
        selectedColor: scheme.secondaryContainer,
        disabledColor: scheme.surface.withValues(alpha: 0.85),
        labelStyle: textTheme.bodySmall?.copyWith(
          color: scheme.onSurface,
          fontWeight: FontWeight.w700,
        ),
        side: BorderSide.none,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.secondary,
          foregroundColor: scheme.onSecondary,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.onSurface,
          side: BorderSide(color: scheme.outline),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: scheme.primary,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: scheme.onSurface,
          backgroundColor: scheme.primaryContainer.withValues(alpha: 0.42),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: raisedSurface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide(color: scheme.primary, width: 1.4),
        ),
        labelStyle: textTheme.bodyMedium?.copyWith(
          color: scheme.onSurfaceVariant,
        ),
        prefixIconColor: scheme.onSurfaceVariant,
      ),
    );
  }
}
