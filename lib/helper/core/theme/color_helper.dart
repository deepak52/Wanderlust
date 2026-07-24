import 'package:flutter/material.dart';

class AppColorHelper {
  // Primary Colors
  static const Color _primaryColor = Color(0xFF2196F3);
  static const Color _primaryLightColor = Color(0xFF64B5F6);
  static const Color _primaryDarkColor = Color(0xFF1976D2);

  // Secondary Colors
  static const Color _secondaryColor = Color(0xFF03DAC6);
  static const Color _secondaryLightColor = Color(0xFF66FFF9);
  static const Color _secondaryDarkColor = Color(0xFF00A896);

  // Background Colors
  static const Color _scaffoldBackgroundColor = Color(0xFFF5F5F5);
  static const Color _cardBackgroundColor = Colors.white;
  static const Color _dialogBackgroundColor = Colors.white;

  // Text Colors
  static const Color _primaryTextColor = Color(0xFF212121);
  static const Color _secondaryTextColor = Color(0xFF757575);
  static const Color _disabledTextColor = Color(0xFFBDBDBD);
  static const Color _hintTextColor = Color(0xFF9E9E9E);
  static const Color _whiteTextColor = Colors.white;

  // Status Colors
  static const Color _successColor = Color(0xFF4CAF50);
  static const Color _errorColor = Color(0xFFF44336);
  static const Color _warningColor = Color(0xFFFF9800);
  static const Color _infoColor = Color(0xFF2196F3);

  // Border Colors
  static const Color _borderColor = Color(0xFFE0E0E0);
  static const Color _focusedBorderColor = _primaryColor;
  static const Color _errorBorderColor = _errorColor;
  static const Color _disabledBorderColor = Color(0xFFE0E0E0);

  // Divider Colors
  static const Color _dividerColor = Color(0xFFE0E0E0);

  // Icon Colors
  static const Color _iconColor = Color(0xFF757575);
  static const Color _selectedIconColor = _primaryColor;
  static const Color _unselectedIconColor = Color(0xFFBDBDBD);

  // Switch Colors
  static const Color _switchActiveColor = _primaryColor;
  static const Color _switchInactiveColor = Color(0xFFBDBDBD);

  // Checkbox Colors
  static const Color _checkColor = Colors.white;

  // Loader Colors
  static const Color _loaderColor = _primaryColor;
  static const Color _loaderSecondaryColor = _primaryLightColor;

  // Circle Avatar
  static const Color _circleAvatarBgColor = Color(0xFFE3E6F5);

  // Toast
  static const Color _toastMsgColor = Color(0xFF323030);

  // Box Shadow
  static const Color _boxShadowColor = Color(0x1A000000);

  // Form Field
  static const Color _pwdFormFieldBorderColor = Color(0xFF43179F);

  // Custom Colors for Wanderlust
  static const Color _wanderlustBlue = Color(0xFF1E88E5);
  static const Color _wanderlustDarkBlue = Color(0xFF1565C0);
  static const Color _wanderlustLightBlue = Color(0xFFBBDEFB);

  // Chat Colors
  static const Color _chatSentBackground = _primaryColor;
  static const Color _chatReceivedBackground = Color(0xFFE0E0E0);
  static const Color _chatSentText = Colors.white;
  static const Color _chatReceivedText = _primaryTextColor;

  // Additional colors needed by common_widget.dart
  static const Color _transparentColor = Colors.transparent;
  static const Color _buttonColor = _primaryColor;
  static const Color _backgroundColor = _scaffoldBackgroundColor;

  // Dark Theme Colors
  static const Color _darkScaffoldBackground = Color(0xFF121212);
  static const Color _darkCardBackground = Color(0xFF1E1E1E);
  static const Color _darkDialogBackground = Color(0xFF1E1E1E);
  static const Color _darkPrimaryText = Colors.white;
  static const Color _darkSecondaryText = Color(0xFFBDBDBD);
  static const Color _darkDisabledText = Color(0xFF757575);
  static const Color _darkHintText = Color(0xFF9E9E9E);
  static const Color _darkBorderColor = Color(0xFF333333);
  static const Color _darkDividerColor = Color(0xFF333333);
  static const Color _darkIconColor = Color(0xFFBDBDBD);
  static const Color _darkSelectedIconColor = _primaryLightColor;
  static const Color _darkUnselectedIconColor = Color(0xFF757575);
  static const Color _darkSwitchActiveColor = _primaryLightColor;
  static const Color _darkSwitchInactiveColor = Color(0xFF757575);
  static const Color _darkLoaderColor = _primaryLightColor;

  // Public getters for static colors
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
  static Color get textColor => _primaryTextColor; // Alias for primaryTextColor

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

  // Dark theme getters
  static Color get darkScaffoldBackground => _darkScaffoldBackground;
  static Color get darkCardBackground => _darkCardBackground;
  static Color get darkDialogBackground => _darkDialogBackground;
  static Color get darkPrimaryText => _darkPrimaryText;
  static Color get darkSecondaryText => _darkSecondaryText;
  static Color get darkDisabledText => _darkDisabledText;
  static Color get darkHintText => _darkHintText;
  static Color get darkBorderColor => _darkBorderColor;
  static Color get darkDividerColor => _darkDividerColor;
  static Color get darkIconColor => _darkIconColor;
  static Color get darkSelectedIconColor => _darkSelectedIconColor;
  static Color get darkUnselectedIconColor => _darkUnselectedIconColor;
  static Color get darkSwitchActiveColor => _darkSwitchActiveColor;
  static Color get darkSwitchInactiveColor => _darkSwitchInactiveColor;
  static Color get darkLoaderColor => _darkLoaderColor;

  // Additional colors matching Agro-Prod AppColorHelper
  static Color get cardColor => cardBackgroundColor;
  // static Color get focusedBorderColor => primaryColor;  // Already defined above
  // static Color get primaryTextColor => primaryTextColor;  // Already defined above
  // static Color get enabledBorderColor => borderColor;  // Already defined above
  // static Color get disabledBorderColor => disabledBorderColor;  // Already defined above
  // static Color get errorBorderColor => errorBorderColor;  // Already defined above
  // static Color get dividerColor => _dividerColor;  // Already defined above
  // static Color get iconColor => _iconColor;  // Already defined above
  // static Color get selectedIconColor => _selectedIconColor;  // Already defined above
  // static Color get unselectedIconColor => _unselectedIconColor;  // Already defined above
  static Color get cardTextColor => primaryTextColor;
  // static Color get transparentColor => _transparentColor;  // Already defined above
  // static Color get pwdFormFieldBorderColor => _pwdFormFieldBorderColor;  // Already defined above
  // static Color get boxShadowColor => _boxShadowColor;  // Already defined above
  // static Color get circleAvatarBgColor => _circleAvatarBgColor;  // Already defined above
  // static Color get toastMsgColor => _toastMsgColor;  // Already defined above
  // static Color get loaderColor => _loaderColor;  // Already defined above
  // static Color get loaderSecondaryColor => _loaderSecondaryColor;  // Already defined above
  static Color get buttonContainerBgColor => primaryColor;
  static Color get readNotification => successColor;
  static Color get unreadNotification => warningColor;
  static Color get dashBoardContainerBgColor => cardBackgroundColor;
  // static Color get switchActiveColor => _switchActiveColor;  // Already defined above
  // static Color get switchInactiveColor => _switchInactiveColor;  // Already defined above
  // static Color get secondaryColor => _secondaryColor;  // Already defined above
  static Color get secondaryBackgroundColor => scaffoldBackgroundColor;
  static Color get warningRedColor => errorColor;
  static Color get warningYellowColor => warningColor;
  static Color get successGreenColor => successColor;
  static Color get warningBackgroundRed => Color(0xFFFFEBEE);
  static Color get warningBackgroundYellow => Color(0xFFFFF8E1);
  static Color get successBackgroundGreen => Color(0xFFE8F5E9);
  static Color get infoBackgroundYellow => Color(0xFFFFF8E1);
  static Color get infoBorderYellow => warningColor;
  static Color get filterBackgroundColor => primaryColor.withValues(alpha: 0.1);
  static Color get filterInfoBackgroundColor =>
      infoColor.withValues(alpha: 0.1);
  static Color get filterInfoBorderColor => infoColor;
  static Color get backgroundgreyColor => Color(0xFFF5F5F5);
}
