import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_workers/utils/debouncer.dart';

import '../../../helper/core/theme/color_helper.dart';
import '../../widget/common_widget.dart';
import '../text/app_text.dart';

// ignore: must_be_immutable
class TextFormWidget extends StatelessWidget {
  final String? label;
  final String? hint;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final FocusNode? nextFocusNode;
  final VoidCallback? onFieldSubmitted;
  final int? minLines;
  final int? maxLines;
  final int? maxLength;
  final bool optional;
  final FocusNode? focusNode;
  final bool enabled;
  final Function(String)? onTextChanged;
  final IconData? prefixIcon;
  final Color? prefixIconColor;
  final IconData? suffixIcon;
  final VoidCallback? suffixIconPressed;
  final bool readOnly;
  final TextAlign textAlign;
  final Color? textColor;
  final VoidCallback? onSampleClicked;
  final double? height;
  final bool digitsOnly;
  final bool decimalDigits;
  final VoidCallback? onClickcallback;
  final bool obscureText;
  final bool showIncrementButton;
  final Function(bool increment)? onIncrementChanged;
  List<TextInputFormatter>? inputFormatters;
  TextInputType? textInputType;
  final TextInputAction? textInputAction;

  final RxBool? rxObscureText;
  final bool enableObscureToggle;

  TextFormWidget({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.validator,
    this.nextFocusNode,
    this.onFieldSubmitted,
    this.maxLength,
    this.minLines,
    this.maxLines = 1,
    this.optional = false,
    this.enabled = true,
    this.focusNode,
    this.onTextChanged,
    this.prefixIcon,
    this.prefixIconColor,
    this.suffixIcon,
    this.suffixIconPressed,
    this.readOnly = false,
    this.textAlign = TextAlign.start,
    this.textColor,
    this.onSampleClicked,
    this.height,
    this.digitsOnly = false,
    this.decimalDigits = false,
    this.obscureText = false,
    this.showIncrementButton = false,
    this.onIncrementChanged,
    this.onClickcallback,
    this.inputFormatters,
    this.textInputType,
    this.textInputAction,
    this.rxObscureText,
    this.enableObscureToggle = false,
  });
  Debouncer debouncer = Debouncer(delay: const Duration(milliseconds: 500));

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if ((label?.isNotEmpty) == true)
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: labelText("$label ${optional ? '(Optional)' : '*'}"),
        ),
      _textFormField(
        decoration: _normalFieldDecoration(),
        context: context,
        newMaxlength: maxLength,
        inputFormatters: inputFormatters,
      ),
    ],
  );

  InputDecoration _normalFieldDecoration() => InputDecoration(
    contentPadding: const EdgeInsets.all(8),
    border: _border(color: AppColorHelper.borderColor),
    labelText: '',
    counterText: '',
    hintText: hint ?? '',
    enabledBorder: _border(color: AppColorHelper.borderColor),
    disabledBorder: _border(color: AppColorHelper.borderColor),
    errorBorder: _border(color: AppColorHelper.errorColor),
    focusedBorder: _border(color: AppColorHelper.focusedBorderColor),
    filled: true,
    fillColor: AppColorHelper.cardColor,
    errorStyle: TextStyle(color: AppColorHelper.errorColor),
    prefixIcon:
        prefixIcon == null
            ? null
            : iconWidget(prefixIcon!, color: prefixIconColor, size: 14),
    suffixIcon:
        enableObscureToggle
            ? Obx(
              () => iconWidget(
                rxObscureText!.value
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
                color: AppColorHelper.primaryTextColor.withValues(alpha: 0.5),
                size: 14,
                onPressed: () => rxObscureText!.value = !rxObscureText!.value,
              ),
            )
            : suffixIcon == null
            ? null
            : iconWidget(suffixIcon!, onPressed: suffixIconPressed),
  );

  Widget _textFormField({
    required InputDecoration decoration,
    required BuildContext context,
    List<TextInputFormatter>? inputFormatters,
    int? newMaxlength,
  }) {
    if (digitsOnly && inputFormatters == null) {
      inputFormatters = [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
        LengthLimitingTextInputFormatter(maxLength ?? 10),
      ];
    }
    if (decimalDigits && inputFormatters == null) {
      inputFormatters = [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
        LengthLimitingTextInputFormatter(maxLength ?? 10),
      ];
    }
    if (!digitsOnly &&
        !decimalDigits &&
        inputFormatters == null &&
        maxLength != null) {
      inputFormatters = [LengthLimitingTextInputFormatter(maxLength!)];
    }

    Widget widget = TextFormField(
      enabled: enabled,
      readOnly: readOnly,
      focusNode: focusNode,
      controller: controller,
      maxLines: maxLines,
      minLines: minLines,
      maxLength: newMaxlength,
      decoration: decoration,
      validator: validator,
      textAlign: textAlign,
      obscureText: rxObscureText?.value ?? obscureText,
      style: TextStyle(color: textColor ?? AppColorHelper.primaryTextColor),
      maxLengthEnforcement: MaxLengthEnforcement.none,
      keyboardType: textInputType ?? TextInputType.name,
      textInputAction:
          textInputAction ??
          (nextFocusNode != null ? TextInputAction.next : TextInputAction.done),
      inputFormatters: inputFormatters,
      onChanged: (value) {
        debouncer.call(() {
          if (onTextChanged != null) onTextChanged!(value);
        });
      },
      onFieldSubmitted: (_) {
        if (nextFocusNode != null) {
          FocusScope.of(context).requestFocus(nextFocusNode);
        }
        onFieldSubmitted ?? ();
      },
    );
    if (readOnly && onClickcallback != null) {
      widget = Stack(
        children: [
          widget,
          InkWell(
            onTap: onClickcallback,
            child: Container(height: 54, padding: const EdgeInsets.all(16)),
          ),
        ],
      );
    }
    if (showIncrementButton) {
      widget = Stack(
        children: [
          widget,
          Positioned(
            right: 1,
            top: 0,
            bottom: 0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                iconWidget(
                  Icons.arrow_drop_up_rounded,
                  size: 24,
                  onPressed: () {
                    if (onIncrementChanged != null) {
                      onIncrementChanged!(true);
                    }
                  },
                ),
                iconWidget(
                  Icons.arrow_drop_down_rounded,
                  size: 24,
                  onPressed: () {
                    if (onIncrementChanged != null) {
                      onIncrementChanged!(false);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      );
    }
    return height != null ? SizedBox(height: height, child: widget) : widget;
  }

  _border({required Color color}) => OutlineInputBorder(
    borderSide: _borderSide(color: color),
    borderRadius: _borderRadius(),
  );
  _borderSide({required Color color}) => BorderSide(color: color);
  _borderRadius() => BorderRadius.circular(2);
}
