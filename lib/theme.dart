import "package:flutter/material.dart";

class MaterialTheme {
  final TextTheme textTheme;

  const MaterialTheme(this.textTheme);

  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff565f67),
      surfaceTint: Color(0xff565f67),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xffe4edf6),
      onPrimaryContainer: Color(0xff626b73),
      secondary: Color(0xff5c5f62),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xffdee0e3),
      onSecondaryContainer: Color(0xff606366),
      tertiary: Color(0xff655b67),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xfff6e8f6),
      onTertiaryContainer: Color(0xff716773),
      error: Color(0xffba1a1a),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffffdad6),
      onErrorContainer: Color(0xff93000a),
      surface: Color(0xfffcf9f9),
      onSurface: Color(0xff1b1b1c),
      onSurfaceVariant: Color(0xff44474a),
      outline: Color(0xff74777b),
      outlineVariant: Color(0xffc4c7ca),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff303031),
      inversePrimary: Color(0xffbec8d0),
      primaryFixed: Color(0xffdbe4ec),
      onPrimaryFixed: Color(0xff141d23),
      primaryFixedDim: Color(0xffbec8d0),
      onPrimaryFixedVariant: Color(0xff3f484f),
      secondaryFixed: Color(0xffe1e2e6),
      onSecondaryFixed: Color(0xff191c1f),
      secondaryFixedDim: Color(0xffc4c7ca),
      onSecondaryFixedVariant: Color(0xff44474a),
      tertiaryFixed: Color(0xffecdeec),
      onTertiaryFixed: Color(0xff201923),
      tertiaryFixedDim: Color(0xffcfc2d0),
      onTertiaryFixedVariant: Color(0xff4d444f),
      surfaceDim: Color(0xffdcd9da),
      surfaceBright: Color(0xfffcf9f9),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff6f3f3),
      surfaceContainer: Color(0xfff0eded),
      surfaceContainerHigh: Color(0xffeae7e8),
      surfaceContainerHighest: Color(0xffe4e2e2),
    );
  }

  ThemeData light() {
    return theme(lightScheme());
  }

  static ColorScheme lightMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff2e373e),
      surfaceTint: Color(0xff565f67),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff656e76),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff33363a),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff6a6d71),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff3c333e),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff746a76),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff740006),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffcf2c27),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfffcf9f9),
      onSurface: Color(0xff111112),
      onSurfaceVariant: Color(0xff33373a),
      outline: Color(0xff4f5356),
      outlineVariant: Color(0xff6a6d71),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff303031),
      inversePrimary: Color(0xffbec8d0),
      primaryFixed: Color(0xff656e76),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff4d565d),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff6a6d71),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff525558),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff746a76),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff5b525d),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffc8c6c6),
      surfaceBright: Color(0xfffcf9f9),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff6f3f3),
      surfaceContainer: Color(0xffeae7e8),
      surfaceContainerHigh: Color(0xffdfdcdc),
      surfaceContainerHighest: Color(0xffd3d1d1),
    );
  }

  ThemeData lightMediumContrast() {
    return theme(lightMediumContrastScheme());
  }

  static ColorScheme lightHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff242d34),
      surfaceTint: Color(0xff565f67),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff414a51),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff292c2f),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff46494d),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff312934),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff4f4651),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff600004),
      onError: Color(0xffffffff),
      errorContainer: Color(0xff98000a),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfffcf9f9),
      onSurface: Color(0xff000000),
      onSurfaceVariant: Color(0xff000000),
      outline: Color(0xff292d30),
      outlineVariant: Color(0xff46494d),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff303031),
      inversePrimary: Color(0xffbec8d0),
      primaryFixed: Color(0xff414a51),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff2b343b),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff46494d),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff303336),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff4f4651),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff38303a),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffbab8b8),
      surfaceBright: Color(0xfffcf9f9),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff3f0f0),
      surfaceContainer: Color(0xffe4e2e2),
      surfaceContainerHigh: Color(0xffd6d4d4),
      surfaceContainerHighest: Color(0xffc8c6c6),
    );
  }

  ThemeData lightHighContrast() {
    return theme(lightHighContrastScheme());
  }

  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffffffff),
      surfaceTint: Color(0xffbec8d0),
      onPrimary: Color(0xff293138),
      primaryContainer: Color(0xffdbe4ec),
      onPrimaryContainer: Color(0xff5c656d),
      secondary: Color(0xffc4c7ca),
      onSecondary: Color(0xff2d3134),
      secondaryContainer: Color(0xff494c4f),
      onSecondaryContainer: Color(0xffb9bcbf),
      tertiary: Color(0xffffffff),
      onTertiary: Color(0xff362e38),
      tertiaryContainer: Color(0xffecdeec),
      onTertiaryContainer: Color(0xff6b616d),
      error: Color(0xffffb4ab),
      onError: Color(0xff690005),
      errorContainer: Color(0xff93000a),
      onErrorContainer: Color(0xffffdad6),
      surface: Color(0xff131314),
      onSurface: Color(0xffe4e2e2),
      onSurfaceVariant: Color(0xffc4c7ca),
      outline: Color(0xff8e9195),
      outlineVariant: Color(0xff44474a),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe4e2e2),
      inversePrimary: Color(0xff565f67),
      primaryFixed: Color(0xffdbe4ec),
      onPrimaryFixed: Color(0xff141d23),
      primaryFixedDim: Color(0xffbec8d0),
      onPrimaryFixedVariant: Color(0xff3f484f),
      secondaryFixed: Color(0xffe1e2e6),
      onSecondaryFixed: Color(0xff191c1f),
      secondaryFixedDim: Color(0xffc4c7ca),
      onSecondaryFixedVariant: Color(0xff44474a),
      tertiaryFixed: Color(0xffecdeec),
      onTertiaryFixed: Color(0xff201923),
      tertiaryFixedDim: Color(0xffcfc2d0),
      onTertiaryFixedVariant: Color(0xff4d444f),
      surfaceDim: Color(0xff131314),
      surfaceBright: Color(0xff393939),
      surfaceContainerLowest: Color(0xff0e0e0f),
      surfaceContainerLow: Color(0xff1b1b1c),
      surfaceContainer: Color(0xff1f1f20),
      surfaceContainerHigh: Color(0xff2a2a2a),
      surfaceContainerHighest: Color(0xff353535),
    );
  }

  ThemeData dark() {
    return theme(darkScheme());
  }

  static ColorScheme darkMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffffffff),
      surfaceTint: Color(0xffbec8d0),
      onPrimary: Color(0xff293138),
      primaryContainer: Color(0xffdbe4ec),
      onPrimaryContainer: Color(0xff404950),
      secondary: Color(0xffdadce0),
      onSecondary: Color(0xff232629),
      secondaryContainer: Color(0xff8e9194),
      onSecondaryContainer: Color(0xff000000),
      tertiary: Color(0xffffffff),
      onTertiary: Color(0xff362e38),
      tertiaryContainer: Color(0xffecdeec),
      onTertiaryContainer: Color(0xff4e4550),
      error: Color(0xffffd2cc),
      onError: Color(0xff540003),
      errorContainer: Color(0xffff5449),
      onErrorContainer: Color(0xff000000),
      surface: Color(0xff131314),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffdadce0),
      outline: Color(0xffafb2b6),
      outlineVariant: Color(0xff8e9194),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe4e2e2),
      inversePrimary: Color(0xff404950),
      primaryFixed: Color(0xffdbe4ec),
      onPrimaryFixed: Color(0xff091218),
      primaryFixedDim: Color(0xffbec8d0),
      onPrimaryFixedVariant: Color(0xff2e373e),
      secondaryFixed: Color(0xffe1e2e6),
      onSecondaryFixed: Color(0xff0e1214),
      secondaryFixedDim: Color(0xffc4c7ca),
      onSecondaryFixedVariant: Color(0xff33363a),
      tertiaryFixed: Color(0xffecdeec),
      onTertiaryFixed: Color(0xff150f18),
      tertiaryFixedDim: Color(0xffcfc2d0),
      onTertiaryFixedVariant: Color(0xff3c333e),
      surfaceDim: Color(0xff131314),
      surfaceBright: Color(0xff454445),
      surfaceContainerLowest: Color(0xff070708),
      surfaceContainerLow: Color(0xff1d1d1e),
      surfaceContainer: Color(0xff282828),
      surfaceContainerHigh: Color(0xff333233),
      surfaceContainerHighest: Color(0xff3e3d3e),
    );
  }

  ThemeData darkMediumContrast() {
    return theme(darkMediumContrastScheme());
  }

  static ColorScheme darkHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffffffff),
      surfaceTint: Color(0xffbec8d0),
      onPrimary: Color(0xff000000),
      primaryContainer: Color(0xffdbe4ec),
      onPrimaryContainer: Color(0xff222b32),
      secondary: Color(0xffeef0f4),
      onSecondary: Color(0xff000000),
      secondaryContainer: Color(0xffc0c3c6),
      onSecondaryContainer: Color(0xff080c0e),
      tertiary: Color(0xffffffff),
      onTertiary: Color(0xff000000),
      tertiaryContainer: Color(0xffecdeec),
      onTertiaryContainer: Color(0xff2f2731),
      error: Color(0xffffece9),
      onError: Color(0xff000000),
      errorContainer: Color(0xffffaea4),
      onErrorContainer: Color(0xff220001),
      surface: Color(0xff131314),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffffffff),
      outline: Color(0xffeef0f4),
      outlineVariant: Color(0xffc0c3c7),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe4e2e2),
      inversePrimary: Color(0xff404950),
      primaryFixed: Color(0xffdbe4ec),
      onPrimaryFixed: Color(0xff000000),
      primaryFixedDim: Color(0xffbec8d0),
      onPrimaryFixedVariant: Color(0xff091218),
      secondaryFixed: Color(0xffe1e2e6),
      onSecondaryFixed: Color(0xff000000),
      secondaryFixedDim: Color(0xffc4c7ca),
      onSecondaryFixedVariant: Color(0xff0e1214),
      tertiaryFixed: Color(0xffecdeec),
      onTertiaryFixed: Color(0xff000000),
      tertiaryFixedDim: Color(0xffcfc2d0),
      onTertiaryFixedVariant: Color(0xff150f18),
      surfaceDim: Color(0xff131314),
      surfaceBright: Color(0xff505050),
      surfaceContainerLowest: Color(0xff000000),
      surfaceContainerLow: Color(0xff1f1f20),
      surfaceContainer: Color(0xff303031),
      surfaceContainerHigh: Color(0xff3b3b3c),
      surfaceContainerHighest: Color(0xff474747),
    );
  }

  ThemeData darkHighContrast() {
    return theme(darkHighContrastScheme());
  }

  ThemeData theme(ColorScheme colorScheme) => ThemeData(
        useMaterial3: true,
        brightness: colorScheme.brightness,
        colorScheme: colorScheme,
        textTheme: textTheme.apply(
          bodyColor: colorScheme.onSurface,
          displayColor: colorScheme.onSurface,
        ),
        scaffoldBackgroundColor: colorScheme.surface,
        canvasColor: colorScheme.surface,
      );

  List<ExtendedColor> get extendedColors => [];
}

class ExtendedColor {
  final Color seed, value;
  final ColorFamily light;
  final ColorFamily lightHighContrast;
  final ColorFamily lightMediumContrast;
  final ColorFamily dark;
  final ColorFamily darkHighContrast;
  final ColorFamily darkMediumContrast;

  const ExtendedColor({
    required this.seed,
    required this.value,
    required this.light,
    required this.lightHighContrast,
    required this.lightMediumContrast,
    required this.dark,
    required this.darkHighContrast,
    required this.darkMediumContrast,
  });
}

class ColorFamily {
  const ColorFamily({
    required this.color,
    required this.onColor,
    required this.colorContainer,
    required this.onColorContainer,
  });

  final Color color;
  final Color onColor;
  final Color colorContainer;
  final Color onColorContainer;
}
