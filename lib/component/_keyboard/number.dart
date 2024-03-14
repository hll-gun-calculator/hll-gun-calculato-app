// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';

import 'theme.dart';

class NumberKeyboardWidget extends StatelessWidget {
  final TextEditingController controller;
  final Function onSubmit;
  late KeyboardTheme theme;

  NumberKeyboardWidget({
    Key? key,
    KeyboardTheme? theme,
    required this.onSubmit,
    required this.controller,
  }) : super(key: key) {
    this.theme = theme ?? KeyboardTheme();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: theme.padding,
      child: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        removeBottom: true,
        child: GridView(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            mainAxisExtent: 65,
          ),
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
