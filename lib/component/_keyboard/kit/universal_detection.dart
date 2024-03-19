import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hll_gun_calculator/data/Factions.dart';

import '../../../constants/app.dart';
import '../../../provider/calc_provider.dart';

enum KeyboardUniversalDetectionNotificationType { None, Error, Succeed }

/// 键盘通用检测
@optionalTypeArgs
mixin KeyboardUniversalDetection<T extends StatefulWidget> on State<T> {
  // 最大数字长度
  int maxLength = 6;

  // 默认最小值
  final double defaultNumberMin = 100;

  // 默认最大值
  final double defaultNumberMax = 1600;

  late double minimumRange = defaultNumberMin;

  num get minimumRangeAsNumber => num.parse(minimumRange.toString());

  late double maximumRange = defaultNumberMax;

  num get maximumRangeAsNumber => num.parse(maximumRange.toString());

  late ValueNotifier<TextEditingController> controller = ValueNotifier(TextEditingController(text: "0"));

  late Factions factions = Factions.None;

  late CalcProvider calc;

  @override
  KeyboardUniversalDetection initState() {
    calc = App.provider.ofCalc(context);
    // assert(controller == null, "未设置TextEditingController控制器，请spuer.initState().initController(controller)");
    super.initState();
    return this;
  }

  /// 键盘通知
  /// 需重写，来接受通知
  ///
  @protected
  void onNotification(KeyboardUniversalDetectionNotificationType code, {message = ''}) {}

  /// 初始配置
  void initConfig({
    required controller,
    Factions factions = Factions.None,
  }) {
    this.controller = controller;
    // this.controller.value.addListener(() {
    //   // 监听变动
    //   print('11');
    // });

    if (factions != null) {
      this.factions = factions;
      minimumRange = double.parse(calc.currentCalculatingFunction.childValue(factions)!.minimumRange.toString());
      maximumRange = double.parse(calc.currentCalculatingFunction.childValue(factions)!.maximumRange.toString());
    }
  }

  /// [minimumRange]和[maximumRange]中位数
  num get median {
    List<double> numbers = [minimumRange, maximumRange];
    numbers.sort();
    int count = numbers.length;

    if (count % 2 == 0) {
      double middle1 = numbers[count ~/ 2 - 1];
      double middle2 = numbers[count ~/ 2];
      return (middle1 + middle2) / 2;
    }

    return numbers[count ~/ 2];
  }

  double get medianAsDouble => double.parse(median.toString());

  /// 是否超出范围
  bool get isCurrentNumberExceedRange {
    return value < minimumRange && value > maximumRange;
  }

  /// 上个预期值是否超出, 不在范围内为true
  bool canLastNumberExceedRange (dynamic value) {
    return this.value - double.parse(value.toString()) < minimumRange;
  }

  /// 下个预期值是否超出, 不在范围内为true
  bool canNextNumberExceedRange (dynamic value) {
    return this.value + double.parse(value.toString()) > maximumRange;
  }

  /// 是否初始过配置
  bool get isInitConfig => controller == null && factions == null;

  num get value => controller.value.text.isEmpty ? 0 : num.parse(controller.value.text);

  double get valueAsDouble => double.parse(value.toString());

  set value(dynamic value) {
    num _value = num.parse(value.toString());

    if (value.toString().isEmpty) {
      onNotification(KeyboardUniversalDetectionNotificationType.Error, message: '文本空的');
      return;
    }
    if (value.toString().length > maxLength) {
      onNotification(KeyboardUniversalDetectionNotificationType.Error, message: '超出数字最大长度');
      return;
    }
    if (_value < minimumRange && _value > maximumRange) {
      onNotification(KeyboardUniversalDetectionNotificationType.Error, message: '超出范围');
      return;
    }
    // test
    if (_value == 1599) {
      onNotification(KeyboardUniversalDetectionNotificationType.Error, message: 'test');
      return;
    }

    controller.value.text = value.toString();
  }
}
