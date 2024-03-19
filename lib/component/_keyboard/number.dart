// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:hll_gun_calculator/component/_keyboard/kit/universal_detection.dart';

import '../../data/index.dart';
import 'theme.dart';

class NumberKeyboardWidget extends StatefulWidget {
  final ValueNotifier<TextEditingController> controller;
  final Function onSubmit;
  late KeyboardTheme theme;
  final Factions? inputFactions;

  NumberKeyboardWidget({
    Key? key,
    KeyboardTheme? theme,
    required this.onSubmit,
    required this.controller,
    this.inputFactions,
  }) : super(key: key) {
    this.theme = theme ?? KeyboardTheme();
  }

  @override
  State<NumberKeyboardWidget> createState() => _NumberKeyboardWidgetState();
}

class _NumberKeyboardWidgetState extends State<NumberKeyboardWidget> with KeyboardUniversalDetection {
  @override
  _NumberKeyboardWidgetState initState() {
    super.initState().initConfig(controller: widget.controller, factions: widget.inputFactions!);
    return this;
  }

  void _onPressed(int number) {
    if (super.value.toString().length > maxLength) return;

    super.value = "${super.value}$number";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: widget.theme.padding,
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
            ...List.generate(9, (index) => index + 1).map(
              (number) => NumberButton(
                number: number,
                size: widget.theme.buttonSize,
                color: widget.theme.buttonColor,
                onPressed: () => _onPressed(number),
              ),
            ),
            Container(),
            NumberButton(
              number: 0,
              size: widget.theme.buttonSize,
              color: widget.theme.buttonColor,
              onPressed: () => _onPressed(0),
            ),
            // this button is used to submit the entered value
            IconButton.filled(
              onPressed: () => widget.onSubmit(),
              icon: const Icon(Icons.done_rounded),
              iconSize: widget.theme.buttonSize,
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
  final Function onPressed;

  const NumberButton({
    Key? key,
    required this.number,
    required this.size,
    required this.color,
    required this.onPressed,
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
        onPressed: () => onPressed(),
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
