import 'dart:ui' show DisplayFeatureType;
import 'package:flutter/material.dart';

/// Breakpoints:
/// Phone      < 600dp
/// Foldable   600–839dp  (fold open, Galaxy Fold unfolded half, etc.)
/// Tablet     840–1199dp
/// Large      ≥ 1200dp   (large tablets, foldables fully open)
class Responsive {
  Responsive._();

  static double width(BuildContext context) => MediaQuery.sizeOf(context).width;
  static double height(BuildContext context) => MediaQuery.sizeOf(context).height;

  static bool isPhone(BuildContext context) => width(context) < 600;
  static bool isFoldable(BuildContext context) {
    final w = width(context);
    return w >= 600 && w < 840;
  }
  static bool isTablet(BuildContext context) => width(context) >= 840;
  static bool isLarge(BuildContext context) => width(context) >= 1200;

  // True when a physical hinge/fold is reported (Samsung Fold, Surface Duo)
  static bool hasFoldHinge(BuildContext context) {
    return MediaQuery.of(context).displayFeatures.any((f) =>
        f.type == DisplayFeatureType.hinge || f.type == DisplayFeatureType.fold);
  }

  // Whether to show side navigation rail instead of bottom nav
  static bool useSideNav(BuildContext context) => width(context) >= 600;

  // Horizontal content padding
  static double hp(BuildContext context) {
    final w = width(context);
    if (w >= 1200) return 40.0;
    if (w >= 840) return 28.0;
    if (w >= 600) return 22.0;
    return 16.0;
  }

  // Max content width for large displays (centres content)
  static double maxWidth(BuildContext context) {
    final w = width(context);
    if (w >= 1200) return 1000.0;
    return double.infinity;
  }

  // Number of columns for quick-action grids
  static int gridCols(BuildContext context, {int phone = 4, int fold = 6, int tablet = 8}) {
    if (isLarge(context)) return tablet;
    if (isTablet(context)) return fold + 1; // 7
    if (isFoldable(context)) return fold;
    return phone;
  }

  // Adaptive font scale (relative to phone baseline)
  static double fontScale(BuildContext context) {
    final w = width(context);
    if (w >= 1200) return 1.15;
    if (w >= 840) return 1.08;
    if (w >= 600) return 1.04;
    return 1.0;
  }

  // Wrap child in a centred max-width container for large screens
  static Widget constrained(BuildContext context, Widget child) {
    final max = maxWidth(context);
    if (max == double.infinity) return child;
    return Center(child: ConstrainedBox(constraints: BoxConstraints(maxWidth: max), child: child));
  }

  // Pick value by screen class
  static T value<T>(BuildContext context, {
    required T phone,
    T? fold,
    required T tablet,
    T? large,
  }) {
    if (isLarge(context)) return large ?? tablet;
    if (isTablet(context)) return tablet;
    if (isFoldable(context)) return fold ?? tablet;
    return phone;
  }
}
