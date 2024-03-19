// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '/constants/app.dart';
import '/data/index.dart';
import 'kit/universal_detection.dart';
import 'theme.dart';

class IncreaseAndDecreaseKeyboard extends StatefulWidget {
  final ValueNotifier<TextEditingController> controller;
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

class _IncreaseAndDecreaseKeyboardState extends State<IncreaseAndDecreaseKeyboard> with KeyboardUniversalDetection {
  // 每次触发加减幅度
  double range = 10;

  @override
  _IncreaseAndDecreaseKeyboardState initState() {
    super.initState().initConfig(controller: widget.controller, factions: widget.inputFactions!);
    return this;
  }

  /// 范围-加减范围按钮
  void _setValue(String type) {
    setState(() {
      switch (type) {
        case "-":
          if (super.value <= super.minimumRange || super.value >= super.maximumRange) {
            super.value = minimumRange.ceil().toString();
            return;
          }

          super.value = (super.value - range).ceil().toString();
          break;
        case "+":
          if ( super.value >= super.maximumRange) {
            super.value = maximumRange.ceil().toString();
            return;
          }

          super.value = (super.value + range).ceil().toString();
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
              onPressed: () => _setValue("+"),
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
              controller: controller.value,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp("[0-9]"))],
              decoration: const InputDecoration(
                hintText: "0",
                isDense: true,
                isCollapsed: false,
                counterText: ""
              ),
              maxLength: maxLength,
              textAlign: TextAlign.center,
              onSubmitted: (value) {
                if (mounted && value.toString().isNotEmpty) {
                  setState(() {
                    double _value = double.parse(value.toString());
                    if (_value > maximumRange || _value < minimumRange) {
                      super.value = median.ceil().toString();
                    }
                  });
                }
              },
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 80,
            child: IconButton.filledTonal(
              onPressed: () => _setValue("-"),
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
