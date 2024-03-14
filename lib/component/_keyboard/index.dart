import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:hll_gun_calculator/component/_keyboard/increase_decrease.dart';
import 'package:hll_gun_calculator/component/_keyboard/number.dart';
import 'package:hll_gun_calculator/component/_keyboard/slider.dart';

import '../../constants/app.dart';
import '../../data/Factions.dart';
import 'Independent_digit.dart';
import 'theme.dart';

enum KeyboardType { None, Number, Slider, IncreaseAndDecrease, IndependentDigit }

class KeyboardWidget extends StatefulWidget {
  final String spatialName;
  final TextEditingController controller;
  final FocusNode? focusNode;
  final Function onSubmit;
  final Factions? inputFactions;
  final KeyboardType? initializeKeyboardType;

  KeyboardWidget({
    Key? key,
    KeyboardTheme? theme,
    this.spatialName = "none",
    required this.onSubmit,
    required this.controller,
    this.focusNode,
    this.inputFactions = Factions.None,
    this.initializeKeyboardType,
  });

  @override
  State<KeyboardWidget> createState() => _KeyboardWidgetState();
}

class _KeyboardWidgetState extends State<KeyboardWidget> {
  late KeyboardType selectKeyboards = KeyboardType.None;
  late Map keyboards;
  bool keyboardSwitchValue = true;

  @override
  void initState() {
    // 初始键盘列表
    keyboards = {
      KeyboardType.None: Container(
        height: 200,
        child: const Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 30,
                width: 30,
                child: CircularProgressIndicator(),
              ),
              SizedBox(height: 15),
              Opacity(
                opacity: .5,
                child: Icon(Icons.keyboard, size: 18),
              ),
            ],
          ),
        ),
      ),
      KeyboardType.Number: NumberKeyboardWidget(
        onSubmit: widget.onSubmit,
        controller: widget.controller,
        theme: KeyboardTheme(
          padding: const EdgeInsets.only(
            top: 5,
            right: 20,
            left: 20,
            bottom: 10,
          ),
        ),
      ),
      KeyboardType.Slider: SliderKeyboard(
        theme: KeyboardTheme(
          padding: const EdgeInsets.only(
            top: 5,
            right: 20,
            left: 20,
            bottom: kBottomNavigationBarHeight + 5,
          ),
        ),
        inputFactions: widget.inputFactions,
        onSubmit: widget.onSubmit,
        controller: widget.controller,
      ),
      KeyboardType.IncreaseAndDecrease: IncreaseAndDecreaseKeyboard(
        theme: KeyboardTheme(
          padding: const EdgeInsets.only(
            top: 5,
            right: 20,
            left: 20,
            bottom: kBottomNavigationBarHeight + 5,
          ),
        ),
        inputFactions: widget.inputFactions,
        onSubmit: widget.onSubmit,
        controller: widget.controller,
      ),
      KeyboardType.IndependentDigit: IndependentDigitKeyboard(
        theme: KeyboardTheme(
          padding: const EdgeInsets.only(
            top: 5,
            right: 20,
            left: 20,
            bottom: 5,
          ),
        ),
        onSubmit: widget.onSubmit,
        controller: widget.controller,
      ),
    };
    initKeyboard();

    super.initState();
  }

  /// 初始键盘
  void initKeyboard() async {
    dynamic keyboardStorageValue = await App.config.getAttr("keyboard.${widget.spatialName}");

    if (mounted) {
      setState(() {
        if (keyboardStorageValue is bool && !keyboardStorageValue || keyboardStorageValue == null) {
          selectKeyboards = widget.initializeKeyboardType ?? KeyboardType.Number;
        } else {
          Iterable<KeyboardType> _keyboard = KeyboardType.values.where((i) => i.name == keyboardStorageValue);
          selectKeyboards = _keyboard.isEmpty ? widget.initializeKeyboardType ?? KeyboardType.Number : _keyboard.first;
        }
      });
    }
  }

  /// 键盘改变事件
  void _changeKeyboardEvent() {
    App.config.updateAttr("keyboard.${widget.spatialName}", selectKeyboards.name);
  }

  /// 选择键盘
  void _openModal(context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      clipBehavior: Clip.hardEdge,
      useRootNavigator: true,
      builder: (context) {
        return StatefulBuilder(builder: (modalContext, modalSetState) {
          return Scaffold(
            appBar: AppBar(),
            body: GridView(
              padding: const EdgeInsets.all(15),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
              ),
              children: [
                ...KeyboardType.values
                    .skipWhile((value) => value == KeyboardType.None)
                    .map(
                      (e) => GestureDetector(
                        onTap: () {
                          modalSetState(() {
                            selectKeyboards = e;
                            _changeKeyboardEvent();
                          });
                          setState(() {
                            Navigator.of(modalContext).pop();
                          });
                        },
                        child: Card(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                "assets/images/keyboard/${e.name}.png",
                                height: 100,
                              ),
                              const SizedBox(height: 5),
                              Text(FlutterI18n.translate(context, "basic.keyboards.${e.name}")),
                            ],
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ],
            ),
          );
        });
      },
    );
  }

  /// 键盘开关
  void _keyboardSwitch() {
    if (widget.focusNode != null) {
      widget.focusNode!.unfocus();
    }

    setState(() {
      keyboardSwitchValue = !keyboardSwitchValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColor.withOpacity(.2),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRect(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              height: keyboardSwitchValue ? null : 0,
              child: keyboards[selectKeyboards],
            ),
          ),
          if (keyboardSwitchValue) const Divider(height: 1, thickness: 1),
          Row(
            children: [
              IconButton(
                onPressed: () => _openModal(context),
                icon: const Icon(Icons.settings),
              ),
              const Expanded(flex: 1, child: SizedBox()),
              IconButton(
                onPressed: () => _keyboardSwitch(),
                icon: Icon(keyboardSwitchValue ? Icons.arrow_drop_down_outlined : Icons.arrow_drop_up),
              )
            ],
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
