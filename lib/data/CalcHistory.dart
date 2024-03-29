import 'package:uuid/uuid.dart';

import 'CalcResult.dart';

class CalcHistoryItemData extends CalcResult {
  late String id;

  CalcHistoryItemData({String id = ""}) : super () {
    this.id = const Uuid().v5(
      Uuid.NAMESPACE_NIL,
      "CalcHistoryItemData-$id",
    );
  }

  as(CalcResult? calcResult) {
    if (calcResult != null) {
      inputFactions = calcResult.inputFactions;
      inputValue = calcResult.inputValue;
      outputValue = calcResult.outputValue;
      creationTime = calcResult.creationTime;
      calculatingFunctionInfo = calcResult.calculatingFunctionInfo;
      result = calcResult.result;
    }
  }
}
