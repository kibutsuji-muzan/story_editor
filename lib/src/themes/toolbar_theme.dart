import 'package:flutter/material.dart';

class ToolbarTheme {
  final Color barColor;
  final double iconSize;
  final Color activeIconColor;
  final Color inactiveIconColor;
  final BorderRadiusGeometry barBorderRadius;
  final double barMaxHeightFactor;
  final double blurSigma;
  final Duration animationDuration;
  final Size buttonSize;
  final Color buttonBackgroundColor;
  final Color buttonDisabledBackgroundColor;
  final Color buttonHoverColor;
  final Color buttonHighlightColor;
  final double buttonElevation;
  final EdgeInsetsGeometry buttonMargin;

  const ToolbarTheme({
    this.barColor = const Color(0x55000000), // Colors.black.withAlpha(85)
    this.iconSize = 18.0,
    this.activeIconColor = Colors.black,
    this.inactiveIconColor = Colors.black54,
    this.barBorderRadius = const BorderRadius.all(Radius.circular(100)),
    this.barMaxHeightFactor = 0.6,
    this.blurSigma = 1.0,
    this.animationDuration = const Duration(milliseconds: 100),
    this.buttonSize = const Size(35, 35),
    this.buttonBackgroundColor = Colors.white,
    this.buttonDisabledBackgroundColor = Colors.white,
    this.buttonHoverColor = Colors.white12,
    this.buttonHighlightColor = Colors.white24,
    this.buttonElevation = 2.0,
    this.buttonMargin = const EdgeInsets.all(4),
  });
}
