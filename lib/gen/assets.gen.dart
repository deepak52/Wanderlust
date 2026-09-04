// dart format width=80

/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use,directives_ordering,implicit_dynamic_list_literal,unnecessary_import

import 'package:flutter/widgets.dart';

class $AssetsIconsGen {
  const $AssetsIconsGen();

  /// File path: assets/icons/app_icon.png
  AssetGenImage get appIcon => const AssetGenImage('assets/icons/app_icon.png');

  /// File path: assets/icons/appbarIcon.png
  AssetGenImage get appbarIcon =>
      const AssetGenImage('assets/icons/appbarIcon.png');

  /// File path: assets/icons/notitficationIcon.png
  AssetGenImage get notitficationIcon =>
      const AssetGenImage('assets/icons/notitficationIcon.png');

  /// File path: assets/icons/warning.png
  AssetGenImage get warning => const AssetGenImage('assets/icons/warning.png');

  /// List of all assets
  List<AssetGenImage> get values => [
    appIcon,
    appbarIcon,
    notitficationIcon,
    warning,
  ];
}

class $AssetsImagesGen {
  const $AssetsImagesGen();

  /// File path: assets/images/loginBg.png
  AssetGenImage get loginBg => const AssetGenImage('assets/images/loginBg.png');

  /// File path: assets/images/wanderlust.png
  AssetGenImage get muziris => const AssetGenImage('assets/images/wanderlust.png');

  /// File path: assets/images/muziriswhite.png
  AssetGenImage get muziriswhite =>
      const AssetGenImage('assets/images/muziriswhite.png');

  /// File path: assets/images/splashBg1.png
  AssetGenImage get splashBg1 =>
      const AssetGenImage('assets/images/splashBg1.png');

  /// File path: assets/images/splashBg4.png
  AssetGenImage get splashBg4 =>
      const AssetGenImage('assets/images/splashBg4.png');

  /// File path: assets/images/wanderlust.jpeg
  AssetGenImage get wanderlust =>
      const AssetGenImage('assets/images/wanderlust.jpeg');

  /// File path: assets/images/wanderlustlogoUp.png
  AssetGenImage get wanderlustlogoUp =>
      const AssetGenImage('assets/images/wanderlustlogoUp.png');

  /// List of all assets
  List<AssetGenImage> get values => [
    loginBg,
    muziris,
    muziriswhite,
    splashBg1,
    splashBg4,
    wanderlust,
    wanderlustlogoUp,
  ];
}

class $AssetsSoundsGen {
  const $AssetsSoundsGen();

  /// File path: assets/sounds/recive.mp3
  String get recive => 'assets/sounds/recive.mp3';

  /// File path: assets/sounds/send.wav
  String get send => 'assets/sounds/send.wav';

  /// List of all assets
  List<String> get values => [recive, send];
}

abstract final class Assets {
  static const $AssetsIconsGen icons = $AssetsIconsGen();
  static const $AssetsImagesGen images = $AssetsImagesGen();
  static const $AssetsSoundsGen sounds = $AssetsSoundsGen();
}

class AssetGenImage {
  const AssetGenImage(
    this._assetName, {
    this.size,
    this.flavors = const {},
    this.animation,
  });

  final String _assetName;

  final Size? size;
  final Set<String> flavors;
  final AssetGenImageAnimation? animation;

  Image image({
    Key? key,
    AssetBundle? bundle,
    ImageFrameBuilder? frameBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    double? scale,
    double? width,
    double? height,
    Color? color,
    Animation<double>? opacity,
    BlendMode? colorBlendMode,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = true,
    bool isAntiAlias = false,
    String? package,
    FilterQuality filterQuality = FilterQuality.medium,
    int? cacheWidth,
    int? cacheHeight,
  }) {
    return Image.asset(
      _assetName,
      key: key,
      bundle: bundle,
      frameBuilder: frameBuilder,
      errorBuilder: errorBuilder,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      scale: scale,
      width: width,
      height: height,
      color: color,
      opacity: opacity,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      isAntiAlias: isAntiAlias,
      package: package,
      filterQuality: filterQuality,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
    );
  }

  ImageProvider provider({AssetBundle? bundle, String? package}) {
    return AssetImage(_assetName, bundle: bundle, package: package);
  }

  String get path => _assetName;

  String get keyName => _assetName;
}

class AssetGenImageAnimation {
  const AssetGenImageAnimation({
    required this.isAnimation,
    required this.duration,
    required this.frames,
  });

  final bool isAnimation;
  final Duration duration;
  final int frames;
}
