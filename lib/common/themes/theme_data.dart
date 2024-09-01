import 'package:flutter/material.dart';
import 'package:joys_calendar/common/configs/colors.dart';
import 'package:joys_calendar/common/configs/fonts.dart';

class JoysCalendarThemeData {
  static const _lightFillColor = Colors.black;
  static const _darkFillColor = Colors.white;
  static final Color _lightFocusColor = Colors.black.withOpacity(0.12);

  static TextStyle lightText = const TextStyle(
    color: AppColors.black,
    fontFamily: AppFonts.circularStd,
  );

  static ThemeData lightThemeData =
      themeData(lightColorScheme, _lightFocusColor);

  static ThemeData themeData(ColorScheme colorScheme, Color focusColor) {
    return ThemeData(
      colorScheme: colorScheme,
      textTheme: _textTheme,
      // Matches manifest.json colors and background color.
      primaryColor: const Color(0xFF030303),
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.background,
        elevation: 0,
        iconTheme: IconThemeData(color: colorScheme.primary),
      ),
      iconTheme: IconThemeData(color: colorScheme.onPrimary),
      canvasColor: colorScheme.background,
      scaffoldBackgroundColor: colorScheme.background,
      highlightColor: Colors.transparent,
      focusColor: focusColor,
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Color.alphaBlend(
          _lightFillColor.withOpacity(0.80),
          _darkFillColor,
        ),
        contentTextStyle: _textTheme.titleMedium!.apply(color: _darkFillColor),
      ),
      dividerColor: Colors.grey[300],
    );
  }

  static ColorScheme lightColorScheme = ColorScheme(
    primary: Colors.green,
    primaryContainer: Colors.teal,
    secondary: Color(0xFFEFF3F3),
    background: Color(0xFFE6EBEB),
    surface: Color(0xFFFAFBFB),
    error: _lightFillColor,
    onError: _lightFillColor,
    onPrimary: _lightFillColor,
    onSecondary: Colors.teal,
    onSurface: Colors.teal,
    onBackground: Colors.teal,
    brightness: Brightness.light,
  );

  static const _regular = FontWeight.w400;
  static const _medium = FontWeight.w500;
  static const _semiBold = FontWeight.w600;
  static const _bold = FontWeight.w700;

  static final TextTheme _textTheme = TextTheme(
    headlineMedium: lightText.copyWith(fontWeight: _bold, fontSize: 20.0),
    bodySmall: lightText.copyWith(fontWeight: _semiBold, fontSize: 16.0),
    headlineSmall: lightText.copyWith(fontWeight: _medium, fontSize: 16.0),
    titleMedium: lightText.copyWith(fontWeight: _medium, fontSize: 16.0),
    labelSmall: lightText.copyWith(fontWeight: _regular, fontSize: 10.0),
    bodyLarge: lightText.copyWith(fontWeight: _regular, fontSize: 14.0),
    titleSmall: lightText.copyWith(fontWeight: _medium, fontSize: 14.0),
    bodyMedium: lightText.copyWith(fontWeight: _regular, fontSize: 16.0),
    titleLarge: lightText.copyWith(fontWeight: _bold, fontSize: 16.0),
    labelLarge: lightText.copyWith(fontWeight: _semiBold, fontSize: 14.0),
  );

  static TextTheme get calendarTextTheme => _textTheme;
}
