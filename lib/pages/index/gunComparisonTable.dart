import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import '../../component/keyboard/index2.dart';
import '../../data/index.dart';
import '../../provider/calc_provider.dart';
import '../../utils/index.dart';

class GunComparisonTablePage extends StatefulWidget {
  const GunComparisonTablePage({
    super.key,
  });

  @override
  State<GunComparisonTablePage> createState() => _GunComparisonTablePageState();
}

class _GunComparisonTablePageState extends State<GunComparisonTablePage> {
  CalcUtil calcUtil = CalcUtil();

  UrlUtil urlUtil = UrlUtil();

  Factions inputFactions = Factions.None;

  TextEditingController controller = TextEditingController(text: "");

  int type = 0;

  /// 配置S

  /// 输入值+-范围
  int valueRange = 10;

  /// 表格对照数量
  /// 默认1600 - 100，此值会被后续动态更新
  int length = 1600 - 100;

  /// 配置E

  @override
  void initState() {
    CalculatingFunction currentCalculatingFunction = ProviderUtil().ofCalc(context).currentCalculatingFunction;
    String firstName = "";

    if (currentCalculatingFunction.child != null) {
      firstName = currentCalculatingFunction.child!.keys.first;
    }

    setState(() {
      // 初始所支持的阵营
      if (Factions.values.where((e) => e.value == firstName).isNotEmpty) inputFactions = Factions.values.where((e) => e.value == firstName).first;
    });
  }

  /// 生成火炮位表格
  List<TableRow> _grFrom(CalcProvider calcData) {
    List<TableRow> list = [];
    Map e = calcData.defaultCalculatingFunction.child![inputFactions.value];
    int maximumRange = e["maximumRange"]; // 最大角度
    int minimumRange = e["minimumRange"]; // 最小角度
    int inputRangValue = controller.text.isEmpty ? -1 : int.parse((controller.text).toString());

    /// 输入值范围表
    if (inputRangValue >= 0) {
      length = (inputRangValue + valueRange) - (inputRangValue - valueRange);

      int start = inputRangValue - valueRange;
      int end = inputRangValue + valueRange;
      int count = start; // 初始赋予开始值 count

      while (count >= start && count <= end) {
        String outputValue = calcUtil.on(inputFactions: inputFactions, inputValue: count, calculatingFunctionInfo: calcData.currentCalculatingFunction).outputValue;
        list.add(TableRow(
          children: [
            TableCell(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Text(
                  "$count",
                  textAlign: TextAlign.end,
                  style: const TextStyle(fontSize: 25),
                ),
              ),
            ),
            TableCell(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Text(
                  outputValue.toString(),
                  style: TextStyle(fontSize: 25, color: Theme.of(context).primaryColor),
                ),
              ),
            ),
          ],
        ));
        count++;
      }
    }

    /// 所有
    if (inputRangValue < 0) {
      int count = minimumRange ?? 100;

      while (count >= minimumRange && count <= maximumRange) {
        String outputValue = calcUtil.on(inputFactions: inputFactions, inputValue: count, calculatingFunctionInfo: calcData.currentCalculatingFunction).outputValue;

        list.add(TableRow(
          children: [
            TableCell(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Text(
                  "$count",
                  textAlign: TextAlign.end,
                  style: const TextStyle(fontSize: 25),
                ),
              ),
            ),
            TableCell(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Text(
                  outputValue.toString(),
                  style: TextStyle(fontSize: 25, color: Theme.of(context).primaryColor),
                ),
              ),
            ),
          ],
        ));
        count++;
      }
    }

    return list;
  }

  /// 打开配置
  void _openSettingModal() {
    showModalBottomSheet<void>(
      context: context,
      clipBehavior: Clip.hardEdge,
      builder: (context) {
        return Scaffold(
          appBar: AppBar(
            leading: const CloseButton(),
          ),
          body: ListView(
            padding: const EdgeInsets.all(10),
            children: [
              TextField(
                controller: TextEditingController(text: valueRange.toString()),
              )
            ],
          ),
        );
      },
    );
  }

  /// 选择阵营
  void _openSelectFactions() {
    showModalBottomSheet<void>(
      context: context,
      clipBehavior: Clip.hardEdge,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, modalSetState) {
          return Consumer<CalcProvider>(
            builder: (context, calcData, widget) {
              return Scaffold(
                appBar: AppBar(
                  leading: const CloseButton(),
                ),
                body: ListView(
                  children: Factions.values.where((i) => i != Factions.None).map((i) {
                    return ListTile(
                      selected: inputFactions.value == i.value,
                      enabled: calcData.currentCalculatingFunction.child!.containsKey(i.value) ,
                      title: Text(FlutterI18n.translate(context, "basic.factions.${i.value}")),
                      trailing: Text(calcData.currentCalculatingFunction.child!.containsKey(i.value) ? "" : "不支持"),
                      onTap: () {
                        if (!calcData.currentCalculatingFunction.child!.containsKey(i.value)) {
                          Fluttertoast.showToast(msg: "当前${calcData.currentCalculatingFunctionName}函数,不支持该阵营,请切换其他函数");
                          return;
                        }

                        setState(() {
                          inputFactions = i;
                        });
                        modalSetState(() {});

                        Future.delayed(const Duration(milliseconds: 600)).then((value) {
                          Navigator.pop(context);
                        });
                      },
                    );
                  }).toList(),
                ),
              );
            },
          );
        });
      },
    );
  }

  /// 范围-加减范围按钮
  void _setValue(String type, calcData) {
    Map e = calcData.defaultCalculatingFunction.child![inputFactions.value];
    int maximumRange = e["maximumRange"]; // 最大角度
    int minimumRange = e["minimumRange"]; // 最小角度

    int input = int.parse(controller.text.isEmpty ? minimumRange.toString() : controller.text);

    setState(() {
      switch (type) {
        case "-":
          if (input > minimumRange) {
            controller.text = (input - 10).toString();
          } else {
            controller.text = minimumRange.toString();
          }
          break;
        case "+":
          if (input > maximumRange) {
            controller.text = (input + 10).toString();
          } else {
            controller.text = maximumRange.toString();
          }
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CalcProvider>(
      builder: (context, calcData, widget) {
        return Column(
          children: [
            Container(
              color: Theme.of(context).primaryColor.withOpacity(.1),
              child: Table(
                children: const [
                  TableRow(
                    children: [
                      TableCell(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                          child: Text("米", textAlign: TextAlign.end),
                        ),
                      ),
                      TableCell(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                          child: Text("角度"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: ListView(
                children: [
                  Table(
                    border: TableBorder.symmetric(
                        inside: BorderSide(
                      width: 1,
                      style: BorderStyle.solid,
                      color: Theme.of(context).primaryColor.withOpacity(.1),
                    )),
                    children: _grFrom(calcData),
                  )
                ],
              ),
            ),

            /// tool
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      if (type == 0)
                        type = 1;
                      else if (type == 1) type = 0;
                    });
                  },
                  icon: Icon(
                    type == 0 ? Icons.keyboard : Icons.front_hand_sharp,
                  ),
                ),
                Wrap(
                  children: [
                    GestureDetector(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          child: Wrap(
                            runAlignment: WrapAlignment.center,
                            children: [
                              Text(FlutterI18n.translate(context, "basic.factions.${inputFactions.value}")),
                              const Icon(Icons.arrow_drop_down),
                            ],
                          ),
                        ),
                      ),
                      onTap: () => _openSelectFactions(),
                    ),
                    const SizedBox(width: 5),
                    GestureDetector(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          child: Wrap(
                            runAlignment: WrapAlignment.center,
                            children: [
                              Text(calcData.currentCalculatingFunctionName),
                              const Icon(Icons.arrow_drop_down),
                            ],
                          ),
                        ),
                      ),
                      onTap: () => {
                        UrlUtil().opEnPage(context, "/calculatingFunctionConfig"),
                      },
                    ),
                  ],
                ),
                const Expanded(flex: 1, child: SizedBox()),
                IconButton(
                  onPressed: () {
                    _openSettingModal();
                  },
                  icon: const Icon(
                    Icons.settings,
                  ),
                ),
              ],
            ),

            const Divider(height: 1, thickness: 1),

            /// 控制器
            if (type == 0)
              Container(
                color: Theme.of(context).primaryColor.withOpacity(.2),
                height: 200,
                margin: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                      width: 80,
                      child: IconButton.filledTonal(
                        onPressed: () {
                          _setValue("+", calcData);
                        },
                        icon: const Icon(
                          Icons.arrow_upward,
                          size: 40,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 100,
                      child: TextField(
                        controller: controller,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp("[0-9]"))],
                        decoration: const InputDecoration(
                          hintText: "0",
                          isDense: true,
                          // border: InputBorder.none,
                          isCollapsed: false,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 80,
                      child: IconButton.filledTonal(
                        onPressed: () {
                          _setValue("-", calcData);
                        },
                        icon: const Icon(
                          Icons.arrow_downward,
                          size: 40,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              Column(
                children: [
                  Container(
                    color: Theme.of(context).primaryColor.withOpacity(.2),
                    child: Row(
                      children: [
                        const SizedBox(width: 50),
                        Expanded(
                          flex: 1,
                          child: TextField(
                            readOnly: true,
                            controller: controller,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [FilteringTextInputFormatter.allow(RegExp("[0-9]"))],
                            decoration: const InputDecoration(
                              hintText: "0",
                              isDense: true,
                              // border: InputBorder.none,
                              isCollapsed: false,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              controller.text = "";
                            });
                          },
                          icon: const Icon(Icons.clear),
                        ),
                      ],
                    ),
                  ),

                  /// 键盘
                  SizedBox(
                    height: 380,
                    child: NumberKeyboardWidget(
                      theme: NumberKeyboardTheme(),
                      onSubmit: () {
                        setState(() {});
                        // historyData.add(_calcSubmit(calcData));
                      },
                      controller: controller,
                    ),
                  ),
                ],
              )
          ],
        );
      },
    );
  }
}
