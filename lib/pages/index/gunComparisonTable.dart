import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:provider/provider.dart';

import '/component/_keyboard/index.dart';
import '/provider/collect_provider.dart';
import '/constants/app.dart';
import '/data/index.dart';
import '/provider/calc_provider.dart';

class GunComparisonTablePage extends StatefulWidget {
  const GunComparisonTablePage({
    super.key,
  });

  @override
  State<GunComparisonTablePage> createState() => _GunComparisonTablePageState();
}

class _GunComparisonTablePageState extends State<GunComparisonTablePage> with AutomaticKeepAliveClientMixin {
  Factions inputFactions = Factions.None;

  ValueNotifier<TextEditingController> _textController = ValueNotifier(TextEditingController());

  // 火炮表格
  List gunCalcTable = [];

  // 范围选择器状态
  bool rangeSelectorStatus = false;

  FocusNode focusNode = FocusNode();

  GlobalKey<KeyboardWidgetState> keyboardWidgetKey = GlobalKey<KeyboardWidgetState>();

  /// 配置S

  /// 输入值+-范围
  int valueRange = 10;

  /// 建议范围滚动
  ScrollController rangeSelectorListViewController = ScrollController();

  /// 表格对照数量
  /// 默认1600 - 100，此值会被后续动态更新
  int length = 1600 - 100;

  /// 配置E

  @override
  void initState() {
    CalculatingFunction currentCalculatingFunction = App.provider.ofCalc(context).currentCalculatingFunction;
    Factions firstName = Factions.None;

    firstName = currentCalculatingFunction.child.keys.first;

    setState(() {
      // 初始所支持的阵营
      if (Factions.values.where((e) => e == firstName).isNotEmpty) inputFactions = Factions.values.where((e) => e == firstName).first;
    });

    _generateTableData();
    super.initState();
  }

  /// 处理回退
  void handleBackspace() {
    final currentText = _textController.value.text;
    final selection = _textController.value.selection;
    if (selection.baseOffset != selection.extentOffset) {
      final newText = currentText.replaceRange(
        selection.baseOffset,
        selection.extentOffset,
        '',
      );
      _textController.value.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(
          offset: selection.baseOffset,
        ),
      );
    } else if (selection.baseOffset > 0) {
      final newText = currentText.replaceRange(
        selection.baseOffset - 1,
        selection.baseOffset,
        '',
      );
      _textController.value.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(
          offset: selection.baseOffset - 1,
        ),
      );
    }

    setState(() {});
  }

  /// 生成火炮数据
  void _generateTableData() {
    List list = [];
    CalcProvider calcData = App.provider.ofCalc(context);
    CalculatingFunctionChild e = calcData.defaultCalculatingFunction.childValue(inputFactions)!;
    int maximumRange = e.maximumRange; // 最大角度
    int minimumRange = e.minimumRange; // 最小角度
    int inputRangValue = _textController.value.text.isEmpty ? -1 : int.parse((_textController.value.text).toString());

    /// 输入值范围表
    if (inputRangValue >= 0) {
      length = (inputRangValue + valueRange) - (inputRangValue - valueRange);

      num start = inputRangValue - valueRange;
      num end = inputRangValue + valueRange;
      num count = start; // 初始赋予开始值 count

      while (count >= start && count <= end) {
        CalcResult calcResult = App.calc.on(
          inputFactions: inputFactions,
          inputValue: count,
          calculatingFunctionInfo: calcData.currentCalculatingFunction,
        );

        list.add([count, calcResult.outputValue]);
        count++;
      }
    }

    /// 所有
    if (inputRangValue < 0) {
      int count = minimumRange;

      while (count >= minimumRange && count <= maximumRange) {
        CalcResult calcResult = App.calc.on(
          inputFactions: inputFactions,
          inputValue: count,
          calculatingFunctionInfo: calcData.currentCalculatingFunction,
        );

        list.add([count, calcResult.outputValue]);
        count++;
      }
    }

    setState(() {
      gunCalcTable = list;
    });
  }

  /// 打开配置
  void _openSettingModal() {
    TextEditingController valueRangeController = TextEditingController(text: valueRange.toString());

    valueRangeController.addListener(() {
      if (valueRangeController.text.isEmpty) {
        valueRange = 10;
      } else {
        valueRange = int.parse(valueRangeController.text);
      }
    });

    showModalBottomSheet<void>(
      context: context,
      clipBehavior: Clip.hardEdge,
      useSafeArea: true,
      builder: (context) {
        return Scaffold(
          appBar: AppBar(
            leading: const CloseButton(),
          ),
          body: ListView(
            children: [
              TextField(
                decoration: const InputDecoration(
                  hintText: "0",
                  labelText: "区间",
                  helperText: "用户输入值时，取该正负区间的范围结果",
                  contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                ),
                keyboardType: TextInputType.number,
                controller: valueRangeController,
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
      useSafeArea: true,
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
                      enabled: calcData.currentCalculatingFunction.hasChildValue(i),
                      title: Text(FlutterI18n.translate(context, "basic.factions.${i.value}")),
                      trailing: Text(calcData.currentCalculatingFunction.hasChildValue(i) ? "" : "不支持"),
                      onTap: () {
                        if (!calcData.currentCalculatingFunction.hasChildValue(i)) {
                          return;
                        }

                        setState(() {
                          inputFactions = i;
                        });
                        modalSetState(() {});

                        Future.delayed(const Duration(milliseconds: 500)).then((value) {
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

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Consumer2<CalcProvider, CollectProvider>(
      builder: (context, calcData, collectData, widget) {
        return SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              /// table header
              Container(
                color: Theme.of(context).primaryColor.withOpacity(.1),
                child: Table(
                  children: const [
                    TableRow(
                      children: [
                        TableCell(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                            child: Text("距离", textAlign: TextAlign.end),
                          ),
                        ),
                        TableCell(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                            child: Text("MIL"),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              /// table content
              Expanded(
                flex: 1,
                child: ListView.separated(
                  padding: EdgeInsets.zero,
                  itemCount: gunCalcTable.length,
                  itemBuilder: (context, index) {
                    List gunItem = gunCalcTable[index];

                    return Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Container(
                            color: Theme.of(context).primaryColor.withOpacity(.03),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  if (gunItem[0].toString().trim() == _textController.value.text.trim())
                                    const SizedBox(
                                      child: Icon(Icons.search),
                                      width: 40,
                                    ),
                                  Text(
                                    "${gunItem[0]}",
                                    style: TextStyle(
                                      color: gunItem[0].toString().trim() == _textController.value.text.trim() ? Theme.of(context).colorScheme.primary : null,
                                      fontSize: 25,
                                      fontWeight: gunItem[0].toString().trim() == _textController.value.text.trim() ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    "${gunItem[1]}",
                                    style: TextStyle(
                                      fontSize: 25,
                                      color: Theme.of(context).primaryColor,
                                      fontWeight: gunItem[0].toString().trim() == _textController.value.text.trim() ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                ),
                                Text(
                                  "MIL",
                                  style: TextStyle(color: Theme.of(context).primaryColor.withOpacity(.4)),
                                ),
                                // IconButton(
                                //   onPressed: () {
                                //     String title = "${gunItem[1].inputValue} -> ${gunItem[1].outputValue}";
                                //     collectData.add(gunItem[1], title, remark: "来自火炮表格的收藏, $title");
                                //   },
                                //   icon: Icon(Icons.star_border, color: Colors.yellow.shade800),
                                // ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return const Opacity(
                      opacity: .5,
                      child: Divider(height: 1),
                    );
                  },
                ),
              ),

              /// tool
              Row(
                children: [
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
                          App.url.opEnPage(context, "/calculatingFunctionConfig").then((value) {
                            setState(() {
                              inputFactions = App.provider.ofCalc(context).currentCalculatingFunction.child.keys.first;
                            });
                          }),
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

              /// 范围选择器
              AnimatedContainer(
                clipBehavior: Clip.hardEdge,
                duration: const Duration(milliseconds: 350),
                color: Theme.of(context).primaryColor.withOpacity(.2),
                padding: const EdgeInsets.only(left: 20, right: 5),
                height: rangeSelectorStatus ? null : 50,
                constraints: const BoxConstraints(maxHeight: 50 * 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 1,
                      child: Scrollbar(
                        child: ListView(
                          controller: rangeSelectorListViewController,
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          physics: rangeSelectorStatus ? const AlwaysScrollableScrollPhysics() : const NeverScrollableScrollPhysics(),
                          children: [
                            /// 区间首选
                            Wrap(
                              spacing: 5,
                              runSpacing: rangeSelectorStatus ? 0 : 5,
                              runAlignment: WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              direction: Axis.horizontal,
                              clipBehavior: Clip.hardEdge,
                              children: [
                                if (!rangeSelectorStatus)
                                  const SizedBox(
                                    width: 35,
                                    height: 40,
                                    child: Icon(
                                      Icons.numbers,
                                      size: 20,
                                    ),
                                  ),

                                /// 展开文本框
                                if (rangeSelectorStatus)
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width,
                                    child: TextField(
                                      readOnly: true,
                                      showCursor: true,
                                      decoration: const InputDecoration(hintText: "(可选)输入区间中间值", contentPadding: EdgeInsets.symmetric(horizontal: 10)),
                                      controller: _textController.value,
                                    ),
                                  ),

                                /// 收起的文本框
                                if (!rangeSelectorStatus)
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width - 10 - 170,
                                    child: TextField(
                                      readOnly: true,
                                      showCursor: true,
                                      decoration: const InputDecoration.collapsed(hintText: "(可选)输入区间中间值"),
                                      controller: _textController.value,
                                      onTap: () {
                                        keyboardWidgetKey.currentState?.openKeyboard();
                                      },
                                    ),
                                  ),
                                if (!rangeSelectorStatus)
                                  IconButton(
                                    visualDensity: VisualDensity.compact,
                                    onPressed: _textController.value.text.isEmpty
                                        ? null
                                        : () {
                                            handleBackspace();
                                            _generateTableData();
                                          },
                                    icon: const Icon(Icons.backspace, size: 18),
                                  ),
                              ],
                            ),

                            /// 区间提示
                            if (rangeSelectorStatus)
                              Row(
                                children: [
                                  const SizedBox(
                                    width: 35,
                                    height: 40,
                                    child: Icon(
                                      Icons.lightbulb_outline,
                                      size: 20,
                                    ),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.symmetric(vertical: 4),
                                    child: const Text("区间建议"),
                                  ),
                                ],
                              ),

                            const SizedBox(height: 2),

                            /// 区间首选
                            Wrap(
                              spacing: 10,
                              runSpacing: rangeSelectorStatus ? 0 : 5,
                              runAlignment: WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              direction: Axis.horizontal,
                              clipBehavior: Clip.hardEdge,
                              children: [
                                /// 其他区间
                                ...[1, 2, 3, 4, 5]
                                    .map((e) => FilterChip(
                                          label: const Wrap(
                                            children: [
                                              // Text("${(int.parse(_textController.text) - valueRange)}"),
                                              Icon(Icons.remove, size: 13),
                                              // Text("${(int.parse(_textController.text) + valueRange)}"),
                                            ],
                                          ),
                                          onSelected: (bool value) {},
                                          visualDensity: VisualDensity.compact,
                                        ))
                                    .toList(),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                    const VerticalDivider(thickness: 1),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          rangeSelectorStatus = !rangeSelectorStatus;
                        });

                        rangeSelectorListViewController.jumpTo(0);
                      },
                      icon: Icon(rangeSelectorStatus ? Icons.keyboard_arrow_down_sharp : Icons.lightbulb_outline),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, thickness: 2),

              /// 键盘
              KeyboardWidget(
                key: keyboardWidgetKey,
                spatialName: "home_gun_comparison_table",
                onSubmit: () {
                  setState(() {});
                  _generateTableData();
                },
                initializePackup: true,
                initializeKeyboardType: KeyboardType.IncreaseAndDecrease,
                inputFactions: inputFactions,
                controller: _textController,
              ),

              Container(
                height: MediaQuery.of(context).viewPadding.bottom,
                color: Theme.of(context).primaryColor.withOpacity(.2),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
