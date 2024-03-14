// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';

import '../../constants/app.dart';
import '../../data/index.dart';
import 'theme.dart';

class SliderKeyboard extends StatefulWidget {
  final TextEditingController controller;
  final Function onSubmit;
  late KeyboardTheme theme;
  final Factions? inputFactions;

  SliderKeyboard({
    super.key,
    KeyboardTheme? theme,
    required this.onSubmit,
    required this.controller,
    this.inputFactions,
  }) : super() {
    this.theme = theme ?? KeyboardTheme();
  }

  @override
  State<SliderKeyboard> createState() => _SliderKeyboaedState();
}

class _SliderKeyboaedState extends State<SliderKeyboard> {
  double numberMin = 100;
  double numberMax = 1600;
  double o = 0;
  double t = 50; // 小幅度值
  double t_o = 50; // 小幅度初始值, 不改变

  @override
  void initState() {
    CalculatingFunctionChild? calculatingFunctionChild = App.provider.ofCalc(context).currentCalculatingFunction.childValue(widget.inputFactions!);
    setState(() {
      numberMin = double.parse(calculatingFunctionChild!.minimumRange.toString());
      numberMax = double.parse(calculatingFunctionChild.maximumRange.toString());
      o = _calcCenterNumber();
    });
    super.initState();
  }

  /// 获取中间数
  double _calcCenterNumber() {
    List<double> numbers = [numberMin, numberMax];
    numbers.sort();
    int count = numbers.length;

    if (count % 2 == 0) {
      double middle1 = numbers[count ~/ 2 - 1];
      double middle2 = numbers[count ~/ 2];
      return (middle1 + middle2) / 2;
    } else {
      return numbers[count ~/ 2];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          /// 全值滑动
          Container(
            margin: EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              children: [
                RawChip(
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                  label: Text(numberMin.toStringAsFixed(0).toString()),
                  onPressed: () {
                    setState(() {
                      o = numberMin;
                    });
                  },
                ),
                Expanded(
                  child: Center(
                    child: ActionChip(
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                      label: Text(_calcCenterNumber().toStringAsFixed(0).toString()),
                      onPressed: () {
                        setState(() {
                          o = _calcCenterNumber();
                        });
                      },
                    ),
                  ),
                ),
                RawChip(
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                  label: Text(numberMax.toStringAsFixed(0).toString()),
                  onPressed: () {
                    setState(() {
                      o = numberMax;
                    });
                  },
                ),
              ],
            ),
          ),
          Slider(
            min: numberMin,
            max: numberMax,
            value: o,
            label: o.toStringAsFixed(0),
            thumbColor: Theme.of(context).colorScheme.primary,
            activeColor: Theme.of(context).colorScheme.primary.withOpacity(.2),
            inactiveColor: Theme.of(context).colorScheme.primary.withOpacity(.2),
            onChangeEnd: (v) {
              widget.controller.text = v.ceil().toString();
            },
            onChanged: (v) {
              setState(() {
                o = v;
              });
            },
          ),
          const SizedBox(height: 10),

          /// 小幅度滑动
          Row(
            children: [
              IconButton(
                onPressed: () {
                  double value = double.parse(widget.controller.text.isEmpty ? "0" : widget.controller.text);

                  if ((o -= 50) < numberMin) return;

                  setState(() {
                    widget.controller.text = (value - 50).toString();
                    o -= 50;
                  });
                },
                icon: const Icon(Icons.remove),
              ),
              Expanded(
                flex: 1,
                child: Slider(
                  min: 0,
                  max: 100,
                  divisions: 100,
                  value: t,
                  label: (t - 50.0).toStringAsFixed(0),
                  thumbColor: Theme.of(context).colorScheme.primary,
                  activeColor: Theme.of(context).colorScheme.primary.withOpacity(.2),
                  inactiveColor: Theme.of(context).colorScheme.primary.withOpacity(.2),
                  onChangeEnd: (v) {
                    double value = v as double;
                    double outInputValue = value - 50.0;

                    setState(() {
                      t = t_o;
                      o = o + outInputValue;

                      widget.controller.text = o.toStringAsFixed(0).toString();
                    });
                  },
                  onChanged: (v) {
                    setState(() {
                      t = v;
                    });
                  },
                ),
              ),
              IconButton(
                onPressed: () {
                  double value = double.parse(widget.controller.text.isEmpty ? "0" : widget.controller.text);

                  if ((o += 50) > numberMax) return;

                  setState(() {
                    widget.controller.text = (value + 50).toString();
                    o += 50;
                  });
                },
                icon: const Icon(Icons.add),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
