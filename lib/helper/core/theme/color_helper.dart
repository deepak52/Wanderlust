import 'package:flutter/material.dart';

/// Central Design System & Color Palette for Wanderlust
/// Palette: Rich Sky Blue + Teal + Fresh Natural Green + Warm Gold Accents
class AppColorHelper {
  // ==================== 1. BRAND PALETTE ====================
  // Sky Blue
  static const Color skyBlue = Color(0xFF5DBBE8);
  static const Color deepSkyBlue = Color(0xFF2D9FD0);
  static const Color lightSkyBlue = Color(0xFF90D5F7);

  // Teal
  static const Color teal = Color(0xFF238F91);
  static const Color deepTeal = Color(0xFF126B70);
  static const Color darkTeal = Color(0xFF0F5458);

  // Dark Typography & Contrast
  static const Color darkText = Color(0xFF123B4A);
  static const Color darkNavy = Color(0xFF0C2731);
  static const Color subduedText = Color(0xFF4A6D7C);
  static const Color hintText = Color(0xFF7A9CA9);

  // Natural Green (Path A / Success / Outdoor accents)
  static const Color naturalGreen = Color(0xFF67B66A);
  static const Color freshGreen = Color(0xFF8BCB67);
  static const Color deepGreen = Color(0xFF388E3C);

  // Warm Accents (Path B / Sunset / Campfire / Gold Badges)
  static const Color warmGold = Color(0xFFF3C65B);
  static const Color amberGold = Color(0xFFE5A93C);
  static const Color sunsetOrange = Color(0xFFF29B55);

  // Surfaces & Backgrounds
  static const Color softBackground = Color(0xFFEAF7F8);
  static const Color paleBlueSurface = Color(0xFFDDF2FA);
  static const Color cardSurface = Color(0xFFFFFFFF);
  static const Color softCream = Color(0xFFFFF9EC);
  static const Color borderTeal = Color(0xFFCCE8ED);
  static const Color borderSubtle = Color(0xFFE1F0F3);

  // ==================== CHAT REDESIGN PALETTE (Calm • Modern • Dark) ====================
  static const Color chatPrimaryTeal = Color(0xFF0C6B63);
  static const Color chatDeepTeal = Color(0xFF114E52);
  static const Color chatTealGray = Color(0xFF1F2D2F);
  static const Color chatSurfaceDark = Color(0xFF161C1D);
  static const Color chatSurface = Color(0xFF202628);
  static const Color chatSurfaceLight = Color(0xFF2A3133);
  static const Color chatTextPrimary = Color(0xFFE6ECEC);
  static const Color chatTextSecondary = Color(0xFFA5B2B2);
  static const Color chatDivider = Color(0xFF2E3739);
  static const Color chatIncomingBubble = Color(0xFFFFFFFF);
  static const Color chatIncomingText = Color(0xFF1C2323);
  static const Color chatSelectedHighlight = Color(0xFF1A3A37);
  static const Color chatOnlineGreen = Color(0xFF34C759);
  static const Color chatSeenTick = Color(0xFF26C6DA);
  static const Color chatDeliveredTick = Color(0xFFA5B2B2);

  // ==================== 2. PRIMARY & SECONDARY ====================
  static const Color _primaryColor = teal;
  static const Color _primaryLightColor = skyBlue;
  static const Color _primaryDarkColor = deepTeal;

  static const Color _secondaryColor = naturalGreen;
  static const Color _secondaryLightColor = freshGreen;
  static const Color _secondaryDarkColor = deepGreen;

  // Background Colors
  static const Color _scaffoldBackgroundColor = softBackground;
  static const Color _cardBackgroundColor = cardSurface;
  static const Color _dialogBackgroundColor = cardSurface;

  // Text Colors
  static const Color _primaryTextColor = darkText;
  static const Color _secondaryTextColor = subduedText;
  static const Color _disabledTextColor = Color(0xFFB0C4CC);
  static const Color _hintTextColor = hintText;
  static const Color _whiteTextColor = Colors.white;

  // Status Colors
  static const Color _successColor = naturalGreen;
  static const Color _errorColor = Color(0xFFE5574D);
  static const Color _warningColor = sunsetOrange;
  static const Color _infoColor = skyBlue;

  // Border Colors
  static const Color _borderColor = borderTeal;
  static const Color _focusedBorderColor = teal;
  static const Color _errorBorderColor = _errorColor;
  static const Color _disabledBorderColor = borderSubtle;

  // Divider Colors
  static const Color _dividerColor = borderSubtle;

  // Icon Colors
  static const Color _iconColor = darkTeal;
  static const Color _selectedIconColor = teal;
  static const Color _unselectedIconColor = Color(0xFF90ACB8);

  // Switch Colors
  static const Color _switchActiveColor = teal;
  static const Color _switchInactiveColor = Color(0xFFB0C4CC);

  // Checkbox Colors
  static const Color _checkColor = Colors.white;

  // Loader Colors
  static const Color _loaderColor = teal;
  static const Color _loaderSecondaryColor = skyBlue;

  // Circle Avatar
  static const Color _circleAvatarBgColor = paleBlueSurface;

  // Toast
  static const Color _toastMsgColor = darkText;

  // Box Shadow
  static const Color _boxShadowColor = Color(0x1A123B4A);

  // Form Field
  static const Color _pwdFormFieldBorderColor = teal;

  // Custom Colors for Wanderlust
  static const Color _wanderlustBlue = skyBlue;
  static const Color _wanderlustDarkBlue = deepSkyBlue;
  static const Color _wanderlustLightBlue = paleBlueSurface;

  // Chat Colors
  static const Color _chatSentBackground = teal;
  static const Color _chatReceivedBackground = cardSurface;
  static const Color _chatSentText = Colors.white;
  static const Color _chatReceivedText = darkText;

  // Additional colors
  static const Color _transparentColor = Colors.transparent;
  static const Color _buttonColor = teal;
  static const Color _backgroundColor = _scaffoldBackgroundColor;

  // ==================== 3. PUBLIC GETTERS ====================
  static Color get primaryColor => _primaryColor;
  static Color get primaryLightColor => _primaryLightColor;
  static Color get primaryDarkColor => _primaryDarkColor;

  static Color get secondaryColor => _secondaryColor;
  static Color get secondaryLightColor => _secondaryLightColor;
  static Color get secondaryDarkColor => _secondaryDarkColor;

  static Color get scaffoldBackgroundColor => _scaffoldBackgroundColor;
  static Color get cardBackgroundColor => _cardBackgroundColor;
  static Color get dialogBackgroundColor => _dialogBackgroundColor;
  static Color get backgroundColor => _backgroundColor;

  static Color get primaryTextColor => _primaryTextColor;
  static Color get secondaryTextColor => _secondaryTextColor;
  static Color get disabledTextColor => _disabledTextColor;
  static Color get hintTextColor => _hintTextColor;
  static Color get whiteTextColor => _whiteTextColor;
  static Color get textColor => _primaryTextColor;

  static Color get successColor => _successColor;
  static Color get errorColor => _errorColor;
  static Color get warningColor => _warningColor;
  static Color get infoColor => _infoColor;

  static Color get borderColor => _borderColor;
  static Color get focusedBorderColor => _focusedBorderColor;
  static Color get errorBorderColor => _errorBorderColor;
  static Color get disabledBorderColor => _disabledBorderColor;

  static Color get dividerColor => _dividerColor;

  static Color get iconColor => _iconColor;
  static Color get selectedIconColor => _selectedIconColor;
  static Color get unselectedIconColor => _unselectedIconColor;

  static Color get switchActiveColor => _switchActiveColor;
  static Color get switchInactiveColor => _switchInactiveColor;

  static Color get checkColor => _checkColor;

  static Color get loaderColor => _loaderColor;
  static Color get loaderSecondaryColor => _loaderSecondaryColor;

  static Color get circleAvatarBgColor => _circleAvatarBgColor;
  static Color get toastMsgColor => _toastMsgColor;
  static Color get boxShadowColor => _boxShadowColor;
  static Color get pwdFormFieldBorderColor => _pwdFormFieldBorderColor;

  static Color get transparentColor => _transparentColor;
  static Color get buttonColor => _buttonColor;

  static Color get wanderlustBlue => _wanderlustBlue;
  static Color get wanderlustDarkBlue => _wanderlustDarkBlue;
  static Color get wanderlustLightBlue => _wanderlustLightBlue;

  static Color get chatSentBackground => _chatSentBackground;
  static Color get chatReceivedBackground => _chatReceivedBackground;
  static Color get chatSentText => _chatSentText;
  static Color get chatReceivedText => _chatReceivedText;

  static Color get cardColor => cardBackgroundColor;
  static Color get cardTextColor => primaryTextColor;
  static Color get buttonContainerBgColor => primaryColor;
  static Color get readNotification => successColor;
  static Color get unreadNotification => warningColor;
  static Color get dashBoardContainerBgColor => cardBackgroundColor;
  static Color get secondaryBackgroundColor => scaffoldBackgroundColor;
  static Color get warningRedColor => errorColor;
  static Color get warningYellowColor => warningColor;
  static Color get successGreenColor => successColor;
  static Color get warningBackgroundRed => const Color(0xFFFFEBEE);
  static Color get warningBackgroundYellow => const Color(0xFFFFF8E1);
  static Color get successBackgroundGreen => const Color(0xFFE8F5E9);
  static Color get infoBackgroundYellow => const Color(0xFFFFF8E1);
  static Color get infoBorderYellow => warningColor;
  static Color get filterBackgroundColor => primaryColor.withValues(alpha: 0.1);
  static Color get filterInfoBackgroundColor =>
      infoColor.withValues(alpha: 0.1);
  static Color get filterInfoBorderColor => infoColor;
  static Color get backgroundgreyColor => softBackground;

  // Semantic Adventure & Map Route Colors
  static Color get routePrimary => naturalGreen;
  static Color get routePrimaryGlow => freshGreen;
  static Color get routeSecondary => warmGold;
  static Color get routeSecondaryGlow => amberGold;
}
