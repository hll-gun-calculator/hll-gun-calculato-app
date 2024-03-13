import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:hll_gun_calculator/component/_keyboard/increase_decrease.dart';
import 'package:hll_gun_calculator/component/_keyboard/number.dart';
import 'package:hll_gun_calculator/component/_keyboard/slider.dart';

import '../../data/Factions.dart';
import 'theme.dart';

enum KeyboardType { Number, Slider, IncreaseAndDecrease }

class KeyboardWidget extends StatefulWidget {
  final TextEditingController controller;
  final Function onSubmit;
  final Factions? inputFactions;
  final KeyboardType? initializeKeyboardType;

  KeyboardWidget({
    Key? key,
    KeyboardTheme? theme,
    required this.onSubmit,
    required this.controller,
    this.inputFactions = Factions.None,
    this.initializeKeyboardType,
  }) : super(key: key) {}

  @override
  State<KeyboardWidget> createState() => _KeyboardWidgetState();
}

class _KeyboardWidgetState extends State<KeyboardWidget> {
  late KeyboardType selectKeyboards;
  late Map keyboards;

  @override
  void initState() {
    super.initState();
    selectKeyboards =  widget.initializeKeyboardType ?? KeyboardType.Number;
    keyboards = {
      KeyboardType.Number: NumberKeyboardWidget(
        onSubmit: widget.onSubmit,
        controller: widget.controller,
        theme: KeyboardTheme(
          padding: const EdgeInsets.only(
            top: 5,
            right: 20,
            left: 20,
            bottom: kBottomNavigationBarHeight + 5,
          ),
        ),
      ),
      KeyboardType.Slider: SliderKeyboaed(
        theme: KeyboardTheme(
          padding: const EdgeInsets.only(
            top: 5,
            right: 20,
            left: 20,
            bottom: kBottomNavigationBarHeight + 5,
          ),
        ),
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
    };
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
                    .map(
                      (e) => GestureDetector(
                        onTap: () {
                          modalSetState(() {
                            selectKeyboards = e;
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
                              Text(e.name.toString()),
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

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColor.withOpacity(.2),
      child: Stack(
        children: [
          Positioned(
            left: 15,
            bottom: 15,
            child: IconButton(
              onPressed: () => _openModal(context),
              icon: const Icon(Icons.settings),
            ),
          ),
          keyboards[selectKeyboards],
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
