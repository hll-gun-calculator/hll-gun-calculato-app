// ignore_for_file: must_be_immutable, file_names

import 'package:flutter/material.dart';

import '../../data/index.dart';
import 'theme.dart';

class IndependentDigitKeyboard extends StatefulWidget {
  final TextEditingController controller;
  late KeyboardTheme theme;
  final Function onSubmit;
  final Factions? inputFactions;

  IndependentDigitKeyboard({
    super.key,
    KeyboardTheme? theme,
    required this.onSubmit,
    required this.controller,
    this.inputFactions,
  }) : super() {
    this.theme = theme ?? KeyboardTheme();
  }

  @override
  State<IndependentDigitKeyboard> createState() => _IndependentDigitKeyboardState();
}

class _IndependentDigitKeyboardState extends State<IndependentDigitKeyboard> {
  int numberLength = 4;
  int numberLengthMax = 5;
  int numberLengthMin = 3;

  List<TextEditingController> list = [];

  @override
  void initState() {
    _initKeyboard();
    super.initState();
  }

  /// 初始键盘
  void _initKeyboard() {
    var text = widget.controller.text;

    if (text.isEmpty) {
      _setNumberLength(number: numberLength);
      return;
    }

    if (text.length > numberLength) {
      _setNumberLength(number: numberLength, defaultValue: "9");
    } else {
      _setNumberLength(number: text.length, value: text);
    }
  }

  /// 更新值
  void _updataValue() {
    var value = num.parse(list.map((e) => e.text).toList().join('')).toString();
    widget.controller.text = value;
    widget.onSubmit();
  }

  /// 设置长度
  void _setNumberLength({int? number, String? defaultValue = "0", String? value}) {
    list = List.generate(number ?? numberLength, (index) {
      return TextEditingController(text: value?[index] ?? defaultValue);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      padding: widget.theme.padding,
      child: Row(
        children: [
          ...list.asMap().entries.map(
                (e) => Flexible(
                  flex: 1,
                  child: Card(
                    child: Column(
                      children: [
                        IconButton(
                          onPressed: () {
                            setState(() {
                              num value = num.parse(e.value.text);
                              if (value >= 0 && value < 9) {
                                e.value.text = (value + 1).toString();
                              }

                              if (value == 9 && list.length < numberLengthMax) {
                                list.insert(0, TextEditingController(text: "1"));
                                e.value.text = "0";
                              }

                              // print(e.key - 1);
                              if (value == 9 && e.key - 1 >= 0 && list[e.key - 1].text == "0") {
                                list[e.key - 1].text = "1";
                                e.value.text = "0";
                              }
                            });
                            _updataValue();
                          },
                          icon: const Icon(Icons.add),
                        ),
                        Expanded(
                          flex: 1,
                          child: Center(
                            child: Container(
                              color: Theme.of(context).colorScheme.primary.withOpacity(.1),
                              child: Center(
                                child: Text(
                                  e.value.text,
                                  style: const TextStyle(fontSize: 20),
                                ),
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              num value = num.parse(e.value.text);
                              if (value > 0 && value <= 9) {
                                e.value.text = (value - 1).toString();
                              }

                              // 检查当前右边第一个是否0，则递减9
                              // 检查左边是否全0，否则不是完整数，不递减右边9
                              if (value == 0 && e.key + 1 <= list.length - 1 && list[e.key + 1].text == "0" && list.sublist(0, e.key).every((v) => v.text == "0")) {
                                list[e.key + 1].text = "9";
                                e.value.text = "0";
                              }
                            });
                            _updataValue();
                          },
                          icon: const Icon(Icons.remove),
                        ),
                        const Divider(thickness: 1),
                        PopupMenuButton(
                          icon: const Icon(Icons.more_horiz),
                          itemBuilder: (BuildContext context) {
                            return [
                              if (list.length < numberLengthMax)
                                PopupMenuItem(
                                  value: "gunDescription",
                                  child: const Row(
                                    children: [Icon(Icons.add), Text("添加")],
                                  ),
                                  onTap: () {
                                    setState(() {
                                      list.insert(0, TextEditingController(text: "0"));
                                    });
                                  },
                                ),
                              if (list.length > numberLengthMin)
                                PopupMenuItem(
                                  value: "delete",
                                  child: const Row(
                                    children: [Icon(Icons.delete), Text("删除")],
                                  ),
                                  onTap: () {
                                    setState(() {
                                      list.removeAt(e.key);
                                    });
                                  },
                                ),
                            ];
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
        ],
      ),
    );
  }
}
