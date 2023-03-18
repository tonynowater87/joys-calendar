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
        contentTextStyle: _textTheme.subtitle1!.apply(color: _darkFillColor),
      ),
    );
  }

  static ColorScheme lightColorScheme = ColorScheme(
    primary: Colors.green,
    primaryContainer: Color(0xFF117378),
    secondary: Color(0xFFEFF3F3),
    background: Color(0xFFE6EBEB),
    surface: Color(0xFFFAFBFB),
    error: _lightFillColor,
    onError: _lightFillColor,
    onPrimary: _lightFillColor,
    onSecondary: Colors.teal.shade900,
    onSurface: Colors.teal.shade900,
    onBackground: Colors.teal.shade900,
    brightness: Brightness.light,
  );

  static const _regular = FontWeight.w400;
  static const _medium = FontWeight.w500;
  static const _semiBold = FontWeight.w600;
  static const _bold = FontWeight.w700;

  static final TextTheme _textTheme = TextTheme(
    headline4: lightText.copyWith(fontWeight: _bold, fontSize: 20.0),
    caption: lightText.copyWith(fontWeight: _semiBold, fontSize: 16.0),
    headline5: lightText.copyWith(fontWeight: _medium, fontSize: 16.0),
    subtitle1: lightText.copyWith(fontWeight: _medium, fontSize: 16.0),
    overline: lightText.copyWith(fontWeight: _regular, fontSize: 10.0),
    bodyText1: lightText.copyWith(fontWeight: _regular, fontSize: 14.0),
    subtitle2: lightText.copyWith(fontWeight: _medium, fontSize: 14.0),
    bodyText2: lightText.copyWith(fontWeight: _regular, fontSize: 16.0),
    headline6: lightText.copyWith(fontWeight: _bold, fontSize: 16.0),
    button: lightText.copyWith(fontWeight: _semiBold, fontSize: 14.0),
  );

  static TextTheme get calendarTextTheme => _textTheme;
}
