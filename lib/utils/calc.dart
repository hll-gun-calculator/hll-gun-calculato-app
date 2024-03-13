import 'dart:math';
import 'dart:ui';

import 'package:dartfx/dartfx.dart';

import '../constants/api.dart';
import '../data/index.dart';

class CalcUtil {
  /// 计算MIL
  CalcResult on({
    required Factions inputFactions,
    required dynamic inputValue,
    required CalculatingFunction calculatingFunctionInfo,
  }) {
    try {
      CalculatingFunctionChild expression;
      dynamic outputValue;
      CalcResultStatus result = CalcResultStatus(message: "成功", code: 0);

      if (calculatingFunctionInfo.hasChildValue(inputFactions)) {
        expression = calculatingFunctionInfo.child[inputFactions]!;
      } else {
        Factions newInputFactions = calculatingFunctionInfo.child.keys.first;
        expression = calculatingFunctionInfo.child[newInputFactions]!;
        result = CalcResultStatus(message: "初始新的默认阵营", code: 0);
        return CalcResult(result: result);
      }
      String fun = expression.fun;
      Map<String, dynamic> envs = Map.from(expression.envs);

      if (inputFactions == Factions.None) {
        result = CalcResultStatus(message: "请选择阵营", code: 1000);
        return CalcResult(result: result);
      }

      if (calculatingFunctionInfo.child.isEmpty) {
        result = CalcResultStatus(message: "此函数包没有配置阵营函数", code: 1100);
        return CalcResult(result: result);
      }

      if (calculatingFunctionInfo.child.isEmpty) {
        result = CalcResultStatus(message: "此${calculatingFunctionInfo.name}函数包没有配置任何阵营函数", code: 1101);
        return CalcResult(result: result);
      }

      if (calculatingFunctionInfo.child.isEmpty) {
        result = CalcResultStatus(message: "此${calculatingFunctionInfo.name}函数包没有配置任何函数公式，无法计算结果", code: 1102);
        return CalcResult(result: result);
      }

      if (!calculatingFunctionInfo.hasChildValue(inputFactions)) {
        result = CalcResultStatus(message: "此${calculatingFunctionInfo.name}函数包没有配置${inputFactions.value}函数公式，无法计算结果", code: 1103);
        return CalcResult(result: result);
      }

      // todo 从fun取“{}”,再检查envs缺少
      if (envs.isEmpty) {
        result = CalcResultStatus(message: "此${calculatingFunctionInfo.name}函数包配置${inputFactions.value}变量，公式无效", code: 1104);
        return CalcResult(result: result);
      }

      if (fun == "") {
        result = CalcResultStatus(message: "此${calculatingFunctionInfo.name}函数包配置${inputFactions.value}函数公式无效", code: 1105);
        return CalcResult(result: result);
      }

      if (result.code == 0) {
        envs.addAll({"inputValue": inputValue});

        if (expression.envs == null) {
          result = CalcResultStatus(message: "函数为空", code: 1200);
          return CalcResult(result: result);
        }

        for (var i in envs.entries) {
          fun = fun.replaceAll("{${i.key}}", num.parse(i.value.toString()).toString());
        }

        outputValue = fx(fun).toString();
        outputValue = num.parse(outputValue).ceil().toString();
      }

      return CalcResult(
        inputFactions: inputFactions,
        inputValue: inputValue.toString(),
        outputValue: outputValue,
        calculatingFunctionInfo: calculatingFunctionInfo,
        result: result,
      );
    } catch (e) {
      if (Config.env == Env.DEV) rethrow;
      CalcResultStatus result = CalcResultStatus(message: e.toString(), code: -1);

      return CalcResult(
        inputFactions: inputFactions,
        inputValue: inputValue.toString(),
        result: result,
      );
    }
  }

  /// 计算角度
  MapGunResult onAngle(Offset inputOffset, Offset targetOffset) {
    var angle = atan2(targetOffset.dy - inputOffset.dy, targetOffset.dx - inputOffset.dx);
    var angleInDegrees = angle * 180 / pi;

    return MapGunResult(
      inputOffset: inputOffset,
      targetOffset: targetOffset,
      outputAngle: angleInDegrees,
    );
  }
}
