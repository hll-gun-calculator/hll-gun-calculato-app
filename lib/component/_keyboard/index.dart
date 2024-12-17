

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:hll_gun_calculator/component/_keyboard/speech.dart';
import '/component/_keyboard/increase_decrease.dart';
import '/component/_keyboard/number.dart';
import '/component/_keyboard/slider.dart';

import '/constants/app.dart';
import '/data/Factions.dart';
import 'Independent_digit.dart';
import 'protogenesis.dart';
import 'theme.dart';

enum KeyboardType { None, Protogenesis, Number, Slider, Speech, IncreaseAndDecrease, IndependentDigit }

class KeyboardWidget extends StatefulWidget {
  // 空间名称
  final String spatialName;

  // 控制器
  final ValueNotifier<TextEditingController> controller;

  // focus
  final FocusNode? focusNode;

  // 确认事件
  final Function onSubmit;

  // 阵营
  final Factions? inputFactions;

  // 初始键盘类型
  final KeyboardType? initializeKeyboardType;

  // 初始是否收起键盘
  final bool initializePackup;

  KeyboardWidget({
    Key? key,
    KeyboardTheme? theme,
    this.spatialName = "none",
    required this.onSubmit,
    required this.controller,
    this.focusNode,
    this.inputFactions = Factions.None,
    this.initializeKeyboardType,
    this.initializePackup = false,
  });

  @override
  State<KeyboardWidget> createState() => KeyboardWidgetState();
}

class KeyboardWidgetState extends State<KeyboardWidget> {
  late KeyboardType selectKeyboards = KeyboardType.None;
  late Map keyboards;
  bool keyboardSwitchValue = true;

  @override
  void initState() {
    // 初始键盘列表
    keyboards = {
      KeyboardType.Protogenesis: ProtogenesisKeyboardWidget(
        onSubmit: widget.onSubmit,
        controller: widget.controller,
      ),
      KeyboardType.None: const SizedBox(
        height: 200,
        child: Center(
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
        theme: KeyboardTheme(
          padding: const EdgeInsets.only(
            top: 5,
            right: 20,
            left: 20,
            bottom: 10,
          ),
        ),
        inputFactions: widget.inputFactions,
        onSubmit: widget.onSubmit,
        controller: widget.controller,
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
      KeyboardType.Speech: SpeechKeyboard(
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
        inputFactions: widget.inputFactions,
        onSubmit: widget.onSubmit,
        controller: widget.controller,
      ),
    };
    initKeyboard();

    super.initState();
  }

  /// 初始键盘
  void initKeyboard() async {
    dynamic keyboardStorageSelectValue = await App.config.getAttr("keyboard.${widget.spatialName}.select");
    dynamic keyboardStorageStatusValue = await App.config.getAttr("keyboard.${widget.spatialName}.status", defaultValue: widget.initializePackup);

    if (mounted) {
      setState(() {
        // 初始键盘类型
        if (keyboardStorageSelectValue is bool && !keyboardStorageSelectValue || keyboardStorageSelectValue == null) {
          selectKeyboards = widget.initializeKeyboardType ?? KeyboardType.Number;
        } else {
          Iterable<KeyboardType> _keyboard = KeyboardType.values.where((i) => i.name == keyboardStorageSelectValue);
          selectKeyboards = _keyboard.isEmpty ? widget.initializeKeyboardType ?? KeyboardType.Number : _keyboard.first;
        }

        // 初始键盘是否开启状态
        if (keyboardStorageStatusValue is bool) {
          keyboardSwitchValue = keyboardStorageStatusValue;
        }
      });
    }
  }

  /// 展开键盘
  void openKeyboard() {
    setState(() {
      keyboardSwitchValue = true;
    });
  }

  /// 键盘改变事件
  void _changeKeyboardEvent() {
    App.config.updateAttr("keyboard.${widget.spatialName}.select", selectKeyboards.name);
  }

  /// 选择键盘
  void _openModal(context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      clipBehavior: Clip.hardEdge,
      useRootNavigator: true,
      useSafeArea: true,
      builder: (context) {
        return StatefulBuilder(builder: (modalContext, modalSetState) {
          return Scaffold(
            appBar: AppBar(
              title: Text(FlutterI18n.translate(context, "basic.keyboard.title")),
            ),
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
                          color: selectKeyboards.name == e.name ? Theme.of(context).colorScheme.primary.withOpacity(.5) : Theme.of(context).cardTheme.color,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (e != KeyboardType.Protogenesis)
                                Image.asset(
                                  "assets/images/keyboard/${e.name}.png",
                                  height: 100,
                                ),
                              const SizedBox(height: 5),
                              Text(FlutterI18n.translate(context, "basic.keyboard.child.${e.name}")),
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

    App.config.updateAttr("keyboard.${widget.spatialName}.status", keyboardSwitchValue);
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
                onPressed: keyboardSwitchValue ? () => _openModal(context) : null,
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
