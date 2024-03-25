import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hll_gun_calculator/component/_keyboard/kit/universal_detection.dart';

import '/data/index.dart';
import 'theme.dart';

class SliderKeyboard extends StatefulWidget {
  final ValueNotifier<TextEditingController> controller;
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

class _SliderKeyboaedState extends State<SliderKeyboard> with KeyboardUniversalDetection {
  // 上滑动-原值
  double originalValue = 0;
  double fineAdjustmentValue = 50; // 微调值
  double originalFineAdjustmentValue = 50; // 小幅度初始值, 不改变

  // 每次触发加减幅度
  double range = 50;

  @override
  _SliderKeyboaedState initState() {
    super.initState().initConfig(controller: widget.controller, factions: widget.inputFactions!);
    controller.value.addListener(() {
      if (mounted) {
        setState(() {
          originalValue = double.parse(super.value.toString());
        });
      }
    });
    double value = controller.value.text.isEmpty ? super.medianAsDouble : super.valueAsDouble; // 初始滑动条值

    // 初始上滑动-原值
    if (value > maximumRange) {
      originalValue = maximumRange;
    } else if (value < minimumRange) {
      originalValue = minimumRange;
    } else {
      originalValue = value;
    }

    return this;
  }

  @override
  void onNotification(KeyboardUniversalDetectionNotificationType code, {message = ''}) {
    Fluttertoast.showToast(msg: message);
    super.onNotification(code, message: message);
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
            margin: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              children: [
                RawChip(
                  padding: EdgeInsets.zero,
                  visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                  label: Text(defaultNumberMin.toStringAsFixed(0).toString()),
                  onPressed: () {
                    value = minimumRange;
                  },
                ),
                Expanded(
                  child: Center(
                    child: ActionChip(
                      padding: EdgeInsets.zero,
                      visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                      label: Text(super.median.toStringAsFixed(0).toString()),
                      onPressed: () {
                        setState(() {
                          originalValue = super.medianAsDouble;
                          value = super.median;
                        });
                      },
                    ),
                  ),
                ),
                RawChip(
                  padding: EdgeInsets.zero,
                  visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                  label: Text(defaultNumberMax.toStringAsFixed(0).toString()),
                  onPressed: () {
                    value = maximumRange;
                  },
                ),
              ],
            ),
          ),
          Slider(
            min: minimumRange,
            max: maximumRange,
            value: originalValue,
            label: originalValue.toStringAsFixed(0),
            thumbColor: Theme.of(context).colorScheme.primary,
            activeColor: Theme.of(context).colorScheme.primary.withOpacity(.2),
            inactiveColor: Theme.of(context).colorScheme.primary.withOpacity(.2),
            onChangeEnd: (v) {
              super.value = v.ceil().toString();
              widget.onSubmit();
            },
            onChanged: (v) {
              setState(() {
                originalValue = v;
              });
            },
          ),
          const SizedBox(height: 10),

          /// 小幅度滑动
          Row(
            children: [
              const SizedBox(width: 30),
              Expanded(
                flex: 1,
                child: AnimatedOpacity(
                  opacity: super.isCurrentNumberExceedRange ? .2 : 1,
                  duration: const Duration(microseconds: 350),
                  child: Slider(
                    min: 0,
                    max: 100,
                    divisions: 100,
                    value: fineAdjustmentValue,
                    label: (fineAdjustmentValue - range).toStringAsFixed(0),
                    thumbColor: Theme.of(context).colorScheme.primary,
                    activeColor: Theme.of(context).colorScheme.primary.withOpacity(.2),
                    inactiveColor: Theme.of(context).colorScheme.primary.withOpacity(.2),
                    onChangeEnd: (v) {
                      double value = v as double;
                      double outInputValue = value - range;

                      // 检查改变后的值是否在安全范围内
                      if (outInputValue.isNegative && super.canLastNumberExceedRange(range)) {
                        setState(() {
                          fineAdjustmentValue = 100 / 2;
                          super.value = minimumRange;
                        });
                        return;
                      }
                      else if (outInputValue.isNegative == false && super.canNextNumberExceedRange(range)) {
                        setState(() {
                          fineAdjustmentValue = 100 / 2;
                          super.value = maximumRange;
                        });
                        return;
                      }

                      setState(() {
                        // 释放，还原
                        fineAdjustmentValue =  100 / 2;
                        originalValue = originalValue + outInputValue;
                        super.value = originalValue.toStringAsFixed(0).toString();
                      });

                      widget.onSubmit();
                    },
                    onChanged: (v) {
                      setState(() {
                        fineAdjustmentValue = v;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(width: 30),
            ],
          ),
        ],
      ),
    );
  }
}
