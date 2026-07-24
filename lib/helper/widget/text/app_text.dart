// app_text.dart
// Wanderlust App Text Widgets - Following Agro-Prod patterns

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

TextStyle textStyle(
  double size,
  Color color,
  FontWeight fontWeight, {
  String fontFamily = 'Inter',
  double? height,
}) => GoogleFonts.inter(
  textStyle: TextStyle(
    fontFamily: fontFamily,
    fontSize: size,
    fontWeight: fontWeight,
    color: color,
    height: height,
  ),
);

Text appBarText(
  String text, {
  Color color = Colors.white,
  double size = 20,
  FontWeight fontWeight = FontWeight.w600,
  TextAlign textAlign = TextAlign.center,
  TextOverflow overflow = TextOverflow.ellipsis,
  int maxLines = 1,
}) => Text(
  text,
  textAlign: textAlign,
  overflow: overflow,
  maxLines: maxLines,
  style: textStyle(size, color, fontWeight),
);

Text boldLabelText(
  String text, {
  Color color = Colors.white,
  double size = 14,
  TextAlign textAlign = TextAlign.start,
  TextOverflow overflow = TextOverflow.ellipsis,
  int maxLines = 1,
}) => Text(
  text,
  textAlign: textAlign,
  overflow: overflow,
  maxLines: maxLines,
  style: textStyle(size, color, FontWeight.w700),
);

Text semiBoldLabelText(
  String text, {
  Color color = Colors.white,
  double size = 14,
  TextAlign textAlign = TextAlign.start,
  TextOverflow overflow = TextOverflow.ellipsis,
  int maxLines = 1,
}) => Text(
  text,
  textAlign: textAlign,
  overflow: overflow,
  maxLines: maxLines,
  style: textStyle(size, color, FontWeight.w600),
);

Text mediumLabelText(
  String text, {
  Color color = Colors.white,
  double size = 14,
  TextAlign textAlign = TextAlign.start,
  TextOverflow overflow = TextOverflow.ellipsis,
  int maxLines = 1,
}) => Text(
  text,
  textAlign: textAlign,
  overflow: overflow,
  maxLines: maxLines,
  style: textStyle(size, color, FontWeight.w500),
);

Text regularLabelText(
  String text, {
  Color color = Colors.white,
  double size = 14,
  TextAlign textAlign = TextAlign.start,
  TextOverflow overflow = TextOverflow.ellipsis,
  int maxLines = 1,
}) => Text(
  text,
  textAlign: textAlign,
  overflow: overflow,
  maxLines: maxLines,
  style: textStyle(size, color, FontWeight.w400),
);

Text lightLabelText(
  String text, {
  Color color = Colors.white,
  double size = 14,
  TextAlign textAlign = TextAlign.start,
  TextOverflow overflow = TextOverflow.ellipsis,
  int maxLines = 1,
}) => Text(
  text,
  textAlign: textAlign,
  overflow: overflow,
  maxLines: maxLines,
  style: textStyle(size, color, FontWeight.w300),
);

Widget tx700(
  String text, {
  Color color = Colors.white,
  double size = 14,
  TextAlign textAlign = TextAlign.start,
  TextOverflow overflow = TextOverflow.ellipsis,
  int maxLines = 1,
}) => Text(
  text,
  textAlign: textAlign,
  overflow: overflow,
  maxLines: maxLines,
  style: textStyle(size, color, FontWeight.w700),
);

Widget tx600(
  String text, {
  Color color = Colors.white,
  double size = 14,
  TextAlign textAlign = TextAlign.start,
  TextOverflow overflow = TextOverflow.ellipsis,
  int maxLines = 1,
}) => Text(
  text,
  textAlign: textAlign,
  overflow: overflow,
  maxLines: maxLines,
  style: textStyle(size, color, FontWeight.w600),
);

Widget tx500(
  String text, {
  Color color = Colors.white,
  double size = 14,
  TextAlign textAlign = TextAlign.start,
  TextOverflow overflow = TextOverflow.ellipsis,
  int maxLines = 1,
}) => Text(
  text,
  textAlign: textAlign,
  overflow: overflow,
  maxLines: maxLines,
  style: textStyle(size, color, FontWeight.w500),
);

Widget tx400(
  String text, {
  Color color = Colors.white,
  double size = 14,
  TextAlign textAlign = TextAlign.start,
  TextOverflow overflow = TextOverflow.ellipsis,
  int maxLines = 1,
}) => Text(
  text,
  textAlign: textAlign,
  overflow: overflow,
  maxLines: maxLines,
  style: textStyle(size, color, FontWeight.w400),
);

Widget tx300(
  String text, {
  Color color = Colors.white,
  double size = 14,
  TextAlign textAlign = TextAlign.start,
  TextOverflow overflow = TextOverflow.ellipsis,
  int maxLines = 1,
}) => Text(
  text,
  textAlign: textAlign,
  overflow: overflow,
  maxLines: maxLines,
  style: textStyle(size, color, FontWeight.w300),
);

Text labelText(
  String text, {
  Color color = Colors.white,
  double size = 14,
  TextAlign textAlign = TextAlign.start,
  TextOverflow overflow = TextOverflow.ellipsis,
  int maxLines = 1,
}) => Text(
  text,
  textAlign: textAlign,
  overflow: overflow,
  maxLines: maxLines,
  style: textStyle(size, color, FontWeight.w600),
);
