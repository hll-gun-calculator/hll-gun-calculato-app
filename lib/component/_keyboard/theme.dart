
import 'package:flutter/material.dart';

class KeyboardTheme {
  final double buttonSize;
  final Color buttonColor;
  final Color iconColor;
  late EdgeInsets padding;

  NumberKeyboardNumberButtonTheme? numberButtonTheme;
  NumberKeyboardFeaturButtonTheme? featureButtonTheme;

  KeyboardTheme({
    this.buttonSize = 50,
    this.buttonColor = Colors.transparent,
    this.iconColor = Colors.transparent,
    EdgeInsets? padding,
    this.numberButtonTheme,
    this.featureButtonTheme,
  }) {
    this.padding = padding ?? const EdgeInsets.symmetric(vertical: 20, horizontal: 20);
  }
}

class NumberKeyboardNumberButtonTheme {
  final Color? color;
  final TextStyle? textStyle;

  NumberKeyboardNumberButtonTheme({
    this.color,
    this.textStyle,
  });
}

class NumberKeyboardFeaturButtonTheme {
  final Color? color;
  final TextStyle? textStyle;

  NumberKeyboardFeaturButtonTheme({
    this.color,
    this.textStyle,
  });
}
