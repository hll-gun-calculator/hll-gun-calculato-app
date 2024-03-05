import 'package:flutter/material.dart';

// KeyPad widget
// This widget is reusable and its buttons are customizable (color, size)
class NumberKeyboardWidget extends StatelessWidget {
  final TextEditingController controller;
  final Function onSubmit;
  late NumberKeyboardTheme theme;

  NumberKeyboardWidget({
    Key? key,
    NumberKeyboardTheme? theme,
    required this.onSubmit,
    required this.controller,
  }) : super(key: key) {
    this.theme = theme ?? NumberKeyboardTheme();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColor.withOpacity(.2),
      padding: theme.padding,
      child: GridView(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 15, mainAxisSpacing: 15, mainAxisExtent: 70),
        children: [
          NumberButton(
            number: 1,
            size: theme.buttonSize,
            color: theme.buttonColor,
            controller: controller,
          ),
          NumberButton(
            number: 2,
            size: theme.buttonSize,
            color: theme.buttonColor,
            controller: controller,
          ),
          NumberButton(
            number: 3,
            size: theme.buttonSize,
            color: theme.buttonColor,
            controller: controller,
          ),
          NumberButton(
            number: 4,
            size: theme.buttonSize,
            color: theme.buttonColor,
            controller: controller,
          ),
          NumberButton(
            number: 5,
            size: theme.buttonSize,
            color: theme.buttonColor,
            controller: controller,
          ),
          NumberButton(
            number: 6,
            size: theme.buttonSize,
            color: theme.buttonColor,
            controller: controller,
          ),
          NumberButton(
            number: 7,
            size: theme.buttonSize,
            color: theme.buttonColor,
            controller: controller,
          ),
          NumberButton(
            number: 8,
            size: theme.buttonSize,
            color: theme.buttonColor,
            controller: controller,
          ),
          NumberButton(
            number: 9,
            size: theme.buttonSize,
            color: theme.buttonColor,
            controller: controller,
          ),
          Container(),
          NumberButton(
            number: 0,
            size: theme.buttonSize,
            color: theme.buttonColor,
            controller: controller,
          ),
          // this button is used to submit the entered value
          IconButton.filled(
            onPressed: () => onSubmit(),
            icon: const Icon(Icons.done_rounded),
            iconSize: theme.buttonSize,
          ),
        ],
      ),
    );
  }
}

// define NumberButton widget
// its shape is round
class NumberButton extends StatelessWidget {
  final int number;
  final double size;
  final Color color;
  final TextEditingController controller;

  const NumberButton({
    Key? key,
    required this.number,
    required this.size,
    required this.color,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(size / 3),
          ),
        ),
        onPressed: () {
          controller.text += number.toString();
        },
        child: Center(
          child: Text(
            number.toString(),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
          ),
        ),
      ),
    );
  }
}

class NumberKeyboardTheme {
  final double buttonSize;
  final Color buttonColor;
  final Color iconColor;
  late EdgeInsets padding;

  NumberKeyboardNumberButtonTheme? numberButtonTheme;
  NumberKeyboardFeaturButtonTheme? featureButtonTheme;

  NumberKeyboardTheme({
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
