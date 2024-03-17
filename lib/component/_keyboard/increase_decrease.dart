// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '/constants/app.dart';
import '/data/index.dart';
import 'theme.dart';

class IncreaseAndDecreaseKeyboard extends StatefulWidget {
  final TextEditingController controller;
  late KeyboardTheme theme;
  final Function onSubmit;
  final Factions? inputFactions;

  IncreaseAndDecreaseKeyboard({
    Key? key,
    KeyboardTheme? theme,
    required this.onSubmit,
    required this.controller,
    this.inputFactions,
  }) : super(key: key) {
    this.theme = theme ?? KeyboardTheme();
  }

  @override
  State<IncreaseAndDecreaseKeyboard> createState() => _IncreaseAndDecreaseKeyboardState();
}

class _IncreaseAndDecreaseKeyboardState extends State<IncreaseAndDecreaseKeyboard> {
  /// 范围-加减范围按钮
  void _setValue(String type) {
    CalculatingFunctionChild e = App.provider.ofCalc(context).defaultCalculatingFunction.childValue(widget.inputFactions!)!;
    int maximumRange = e.maximumRange; // 最大角度
    int minimumRange = e.minimumRange; // 最小角度

    int input = int.parse(widget.controller.text.isEmpty ? minimumRange.toString() : widget.controller.text);

    setState(() {
      switch (type) {
        case "-":
          if (input > minimumRange) {
            widget.controller.text = (input - 10).toString();
          } else {
            widget.controller.text = minimumRange.toString();
          }
          break;
        case "+":
          if (input > maximumRange) {
            widget.controller.text = (input + 10).toString();
          } else {
            widget.controller.text = maximumRange.toString();
          }
          break;
      }
    });

    widget.onSubmit();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      // padding: widget.theme.padding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          SizedBox(
            width: 80,
            child: IconButton.filledTonal(
              onPressed: () {
                _setValue("+");
              },
              icon: const Icon(
                Icons.arrow_upward,
                size: 40,
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 100,
            child: TextField(
              controller: widget.controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp("[0-9]"))],
              decoration: const InputDecoration(
                hintText: "0",
                isDense: true,
                // border: InputBorder.none,
                isCollapsed: false,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 80,
            child: IconButton.filledTonal(
              onPressed: () {
                _setValue("-");
              },
              icon: const Icon(
                Icons.arrow_downward,
                size: 40,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
