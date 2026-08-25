import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mdreader/utils/constants.dart';

void main() {
  group('预设主题配色', () {
    test('深浅色主题数量与命名保持稳定', () {
      expect(AppConstants.darkThemeSchemes, hasLength(6));
      expect(AppConstants.lightThemeSchemes, hasLength(5));

      final darkNames = AppConstants.darkThemeSchemes.map((s) => s.name);
      final lightNames = AppConstants.lightThemeSchemes.map((s) => s.name);
      expect(darkNames.toSet(), hasLength(darkNames.length));
      expect(lightNames.toSet(), hasLength(lightNames.length));
    });

    test('所有主题颜色均不透明且背景与表面色不同', () {
      for (final scheme in AppConstants.darkThemeSchemes) {
        _expectOpaqueSchemeColors(scheme.name, scheme.background, scheme.surface);
        expect(scheme.background, isNot(equals(scheme.surface)));
      }
      for (final scheme in AppConstants.lightThemeSchemes) {
        _expectOpaqueSchemeColors(scheme.name, scheme.background, scheme.surface);
        expect(scheme.background, isNot(equals(scheme.surface)));
      }
    });

    test('主文字在背景与表面上均满足 WCAG AA 对比度', () {
      for (final scheme in AppConstants.darkThemeSchemes) {
        _expectReadableText(
          scheme.name,
          scheme.text,
          scheme.background,
          scheme.surface,
          minimumContrast: 4.5,
        );
      }
      for (final scheme in AppConstants.lightThemeSchemes) {
        _expectReadableText(
          scheme.name,
          scheme.text,
          scheme.background,
          scheme.surface,
          minimumContrast: 4.5,
        );
      }
    });

    test('次要文字在背景与表面上保持可读', () {
      for (final scheme in AppConstants.darkThemeSchemes) {
        _expectReadableText(
          scheme.name,
          scheme.textSecondary,
          scheme.background,
          scheme.surface,
          minimumContrast: 3.0,
        );
      }
      for (final scheme in AppConstants.lightThemeSchemes) {
        _expectReadableText(
          scheme.name,
          scheme.textSecondary,
          scheme.background,
          scheme.surface,
          minimumContrast: 3.0,
        );
      }
    });
  });
}

void _expectOpaqueSchemeColors(
  String name,
  Color background,
  Color surface,
) {
  expect(background.toARGB32() >>> 24, 255, reason: '$name 背景色不透明');
  expect(surface.toARGB32() >>> 24, 255, reason: '$name 表面色不透明');
}

void _expectReadableText(
  String name,
  Color text,
  Color background,
  Color surface, {
  required double minimumContrast,
}) {
  final onBackground = _contrastRatio(text, background);
  final onSurface = _contrastRatio(text, surface);
  expect(
    onBackground,
    greaterThanOrEqualTo(minimumContrast),
    reason: '$name 文字在背景上的对比度不足: $onBackground',
  );
  expect(
    onSurface,
    greaterThanOrEqualTo(minimumContrast),
    reason: '$name 文字在表面上的对比度不足: $onSurface',
  );
}

double _contrastRatio(Color a, Color b) {
  final lighter = math.max(_relativeLuminance(a), _relativeLuminance(b));
  final darker = math.min(_relativeLuminance(a), _relativeLuminance(b));
  return (lighter + 0.05) / (darker + 0.05);
}

double _relativeLuminance(Color color) {
  final argb = color.toARGB32();
  double linearize(int channel) {
    final value = channel / 255;
    return value <= 0.03928
        ? value / 12.92
        : math.pow((value + 0.055) / 1.055, 2.4).toDouble();
  }

  final r = linearize((argb >> 16) & 0xFF);
  final g = linearize((argb >> 8) & 0xFF);
  final b = linearize(argb & 0xFF);
  return 0.2126 * r + 0.7152 * g + 0.0722 * b;
}
