import 'package:flutter/material.dart';

/// A utility class for responsive sizing based on screen dimensions.
/// Provides helper methods for width, height, and font size scaling.
class Sizer {
  static MediaQueryData? _mediaQueryData;
  static double? _screenWidth;
  static double? _screenHeight;
  static double? _defaultPixelRatio;
  static double? _statusBarHeight;
  static double? _bottomBarHeight;
  static double? _textScaleFactor;

  /// Initialize the sizer with the build context.
  /// Call this in the build method of your root widget or in main.dart.
  static void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    _screenWidth = _mediaQueryData!.size.width;
    _screenHeight = _mediaQueryData!.size.height;
    _defaultPixelRatio = _mediaQueryData!.devicePixelRatio;
    _statusBarHeight = _mediaQueryData!.padding.top;
    _bottomBarHeight = _mediaQueryData!.padding.bottom;
    _textScaleFactor = _mediaQueryData!.textScaler.scale(1);
  }

  // Getters
  static MediaQueryData get mediaQueryData => _mediaQueryData!;
  static double get screenWidth => _screenWidth!;
  static double get screenHeight => _screenHeight!;
  static double get defaultPixelRatio => _defaultPixelRatio!;
  static double get statusBarHeight => _statusBarHeight!;
  static double get bottomBarHeight => _bottomBarHeight!;
  static double get textScaleFactor => _textScaleFactor!;

  /// Returns the width as a percentage of the screen width.
  static double width(double percentage) {
    return _screenWidth! * (percentage / 100);
  }

  /// Returns the height as a percentage of the screen height.
  static double height(double percentage) {
    return _screenHeight! * (percentage / 100);
  }

  /// Returns a responsive font size based on screen width.
  /// Scales the font size proportionally to a base width of 375 (iPhone 8).
  static double sp(double fontSize) {
    final scaleFactor = _screenWidth! / 375;
    return fontSize * scaleFactor;
  }

  /// Returns a responsive width based on a base width of 375.
  static double wp(double width) {
    final scaleFactor = _screenWidth! / 375;
    return width * scaleFactor;
  }

  /// Returns a responsive height based on a base height of 812.
  static double hp(double height) {
    final scaleFactor = _screenHeight! / 812;
    return height * scaleFactor;
  }

  /// Returns the smaller dimension (width or height) scaled.
  static double minSp(double fontSize) {
    final scaleFactor =
        (_screenWidth! < _screenHeight! ? _screenWidth! : _screenHeight!) / 375;
    return fontSize * scaleFactor;
  }

  /// Returns true if the device is in landscape mode.
  static bool isLandscape() {
    return _mediaQueryData!.orientation == Orientation.landscape;
  }

  /// Returns true if the device is a tablet (width >= 600).
  static bool isTablet() {
    return _screenWidth! >= 600;
  }

  /// Returns the available height (screen height - status bar - bottom bar).
  static double get availableHeight {
    return _screenHeight! - _statusBarHeight! - _bottomBarHeight!;
  }

  /// Returns the available width (screen width - padding).
  static double get availableWidth {
    return _screenWidth! -
        _mediaQueryData!.padding.left -
        _mediaQueryData!.padding.right;
  }

  /// Returns a responsive radius value.
  static double radius(double value) {
    return wp(value);
  }

  /// Returns a responsive padding/margin value.
  static double spacing(double value) {
    return wp(value);
  }

  /// Returns the keyboard height if visible.
  static double get keyboardHeight {
    return _mediaQueryData!.viewInsets.bottom;
  }

  /// Returns true if keyboard is visible.
  static bool get isKeyboardVisible {
    return _mediaQueryData!.viewInsets.bottom > 0;
  }
}

/// Extension methods for easier usage.
extension SizerExtensions on num {
  /// Responsive width percentage.
  double get w => Sizer.width(toDouble());

  /// Responsive height percentage.
  double get h => Sizer.height(toDouble());

  /// Responsive font size (sp).
  double get sp => Sizer.sp(toDouble());

  /// Responsive width (wp).
  double get wp => Sizer.wp(toDouble());

  /// Responsive height (hp).
  double get hp => Sizer.hp(toDouble());

  /// Responsive radius.
  double get r => Sizer.radius(toDouble());

  /// Responsive spacing.
  double get s => Sizer.spacing(toDouble());
}

/// Helper functions for quick access.
double width(double percentage) => Sizer.width(percentage);
double height(double percentage) => Sizer.height(percentage);
double sp(double fontSize) => Sizer.sp(fontSize);
double wp(double width) => Sizer.wp(width);
double hp(double height) => Sizer.hp(height);
double radius(double value) => Sizer.radius(value);
double spacing(double value) => Sizer.spacing(value);
