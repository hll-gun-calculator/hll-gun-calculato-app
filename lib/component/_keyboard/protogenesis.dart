import 'package:flutter/material.dart';

import 'theme.dart';

class ProtogenesisKeyboardWidget extends StatelessWidget {
  final ValueNotifier<TextEditingController> controller;
  final Function onSubmit;
  late KeyboardTheme theme;

  ProtogenesisKeyboardWidget({
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
      height: 80,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Center(
        child: TextField(
          controller: controller.value,
          onChanged: (v) => onSubmit(),
          decoration: const InputDecoration.collapsed(hintText: "0"),
          style: const TextStyle(
            fontSize: 30
          ),
          textInputAction: TextInputAction.done,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
