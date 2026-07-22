import 'package:flutter/material.dart';

/// A small, colorblind-safe palette used to give each person a consistent,
/// generated avatar color derived from their name (instead of every avatar
/// sharing one flat tone).
const List<Color> kAvatarPalette = [
  Color(0xFF6750A4),
  Color(0xFF00696B),
  Color(0xFF8C4A2F),
  Color(0xFF4A6363),
  Color(0xFF6B5778),
  Color(0xFF7A5900),
  Color(0xFF3D5AA6),
  Color(0xFF8E4585),
];

Color avatarColorFor(String name) {
  if (name.isEmpty) return kAvatarPalette.first;
  final hash = name.codeUnits.fold<int>(0, (sum, unit) => sum + unit);
  return kAvatarPalette[hash % kAvatarPalette.length];
}
