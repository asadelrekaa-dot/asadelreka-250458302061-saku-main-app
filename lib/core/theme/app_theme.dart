import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: SakuColors.blue300,
      ).copyWith(
        primary: SakuColors.blue300,
        surface: SakuColors.white,
      ),
      scaffoldBackgroundColor: SakuColors.blue50,
    );

    return base.copyWith(
      textTheme: base.textTheme.apply(
        bodyColor: SakuColors.black,
        displayColor: SakuColors.black,
        fontFamily: 'Roboto',
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: SakuColors.neutral50,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 15,
        ),
        hintStyle: const TextStyle(
          color: SakuColors.neutral300,
          fontSize: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: SakuColors.neutral300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: SakuColors.neutral300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(
            color: SakuColors.blue300,
            width: 1.4,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: SakuColors.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: SakuColors.danger, width: 1.4),
        ),
      ),
    );
  }
}
