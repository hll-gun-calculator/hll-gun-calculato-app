import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import '/component/_empty/index.dart';
import '/component/_keyboard/index.dart';
import '/data/index.dart';
import '/provider/calc_provider.dart';
import '/provider/history_provider.dart';
import '/widgets/hisroy_calc_card.dart';
import '/constants/app.dart';
import '/provider/collect_provider.dart';

class CalcPage extends HomeAppWidget {
  CalcPage({super.key});

  @override
  State<CalcPage> createState() => _CalcPageState();
}

class _CalcPageState extends State<CalcPage> with AutomaticKeepAliveClientMixin {
  ValueNotifier<TextEditingController> _textController = ValueNotifier(TextEditingController(text: ""));

  FocusNode focusNode = FocusNode();

  Factions inputFactions = Factions.None;

  String outputValue = "";

  // 预选
  List primarySelectionList = [];

  // 快速操作加减, TRUE: 复杂，FALSE: 简单
  bool isQuickOperation = false;

  /// 输入控制 S
  // 是否完成输入操作
  bool isCompleteInputOperation = false;

  // 定时器延迟
  int count = 10;

  /// 输入控制 E

  @override
  void initState() {
    _initFactions();
    _initQuickOperation();
    super.initState();
  }

  /// 初始快速操作加减面板
  void _initQuickOperation() async {
    bool status = await App.config.getAttr("gunCalc.quickOperation", defaultValue: false);
    setState(() {
      isQuickOperation = status;
    });
  }

  /// 初始阵营
  void _initFactions() {
    CalculatingFunction currentCalculatingFunction = App.provider.ofCalc(context).currentCalculatingFunction;
    Factions firstName = Factions.None;

    firstName = currentCalculatingFunction.child.keys.first;

    setState(() {
      // 初始所支持的阵营
      if (Factions.values.where((e) => e == firstName).isNotEmpty) inputFactions = Factions.values.where((e) => e == firstName).first;
    });
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

  /// 擦除计算
  void _clearCalc() {
    setState(() {
      _textController.value.text = "";
      outputValue = "";
    });
  }

  /// 展开历史列表
  void _openHistoryModel(HistoryProvider historyData) {
    showModalBottomSheet<void>(
      context: context,
      clipBehavior: Clip.hardEdge,
      useSafeArea: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (modalContext, modalSetStatus) {
            return Scaffold(
              appBar: AppBar(
                leading: const CloseButton(),
              ),
              body: historyData.list.isNotEmpty
                  ? Scrollbar(
                      child: ListView(
                        dragStartBehavior: DragStartBehavior.down,
                        children: historyData.sort().list.map((i) {
                          return HistoryCalcCard(
                            i: i,
                            onEventUpdata: () => modalSetStatus(() {}),
                          );
                        }).toList(),
                      ),
                    )
                  : const Center(
                      child: EmptyWidget(),
                    ),
            );
          },
        );
      },
    );
  }

  /// 计算
  CalcResult _calcSubmit(CalcProvider calcData) {
    CalcResult result = App.calc.on(
      inputFactions: inputFactions,
      inputValue: _textController.value.text,
      calculatingFunctionInfo: calcData.currentCalculatingFunction,
    );

    if (result.result!.code != 0) {
      Fluttertoast.showToast(
        msg: result.result!.message.toString(),
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
      );
    }

    if (result.result!.code == 0) {
      setState(() {
        outputValue = result.outputValue;
      });
    }

    return result;
  }

  /// 处理回退
  void _handleBackspace() {
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

  /// 处理输入定时器
  /// 当用户输入值停止操作后开始计时，超出特定时间再次输入将清空输入值，否则继续在待输入框内输入
  void _handInputTimer() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      count--;
      isCompleteInputOperation = false;
      if (count <= 0) {
        isCompleteInputOperation = true;
        timer.cancel();
      }
    });
  }

  void _switchQuickOperationPanel() {
    setState(() {
      isQuickOperation = !isQuickOperation;
      App.config.updateAttr("gunCalc.quickOperation", isQuickOperation);
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Consumer3<CalcProvider, HistoryProvider, CollectProvider>(
      builder: (consumerContext, calcData, historyData, collectData, consumerWidget) {
        return Column(
          children: <Widget>[
            Expanded(
              flex: 1,
              child: ListView(
                reverse: true,
                children: [
                  /// 当前计算
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            TextFormField(
                              readOnly: true,
                              showCursor: true,
                              style: const TextStyle(fontSize: 50),
                              decoration: const InputDecoration.collapsed(hintText: "0"),
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: [FilteringTextInputFormatter.allow(RegExp("[0-9]"))],
                              maxLines: 3,
                              minLines: 1,
                              autocorrect: true,
                              autofocus: true,
                              textAlign: TextAlign.end,
                              controller: _textController.value,
                              focusNode: focusNode,
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              validator: (value) {
                                if (value!.isEmpty) return null;
                                if (num.parse(value.toString()) > 1600) return "超出限制, 数字应该在100-1600";
                                if (num.parse(value.toString()) < 100) return "小于限制, 数字应该在100-1600";
                                return null;
                              },
                            ),
                            const SizedBox(height: 5),

                            /// 快速加减
                            if (isQuickOperation)
                              Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      ...[100, 50, 10, 5]
                                          .map((e) => ActionChip(
                                                label: Text(e.toString()),
                                                visualDensity: VisualDensity.compact,
                                                padding: EdgeInsets.zero,
                                                onPressed: () {
                                                  num minimumRange = calcData.currentCalculatingFunction.child[inputFactions]!.minimumRange;
                                                  if (_textController.value.text.isNotEmpty && num.parse(_textController.value.text.toString()) > minimumRange) {
                                                    setState(() {
                                                      _textController.value.text = (num.parse(_textController.value.text.toString()) - e).toString();
                                                    });
                                                  } else {
                                                    setState(() {
                                                      _textController.value.text = minimumRange.toString();
                                                    });
                                                  }
                                                  _calcSubmit(calcData);
                                                },
                                              ))
                                          .toList(),
                                      const SizedBox(width: 5),
                                      IconButton.filledTonal(
                                        enableFeedback: true,
                                        icon: const Icon(Icons.remove),
                                        padding: EdgeInsets.zero,
                                        visualDensity: VisualDensity.compact,
                                        onPressed: () {
                                          num minimumRange = calcData.currentCalculatingFunction.child[inputFactions]!.minimumRange;
                                          if (_textController.value.text.isNotEmpty && num.parse(_textController.value.text.toString()) > minimumRange) {
                                            setState(() {
                                              _textController.value.text = (num.parse(_textController.value.text.toString()) - 1).toString();
                                            });
                                          } else {
                                            setState(() {
                                              _textController.value.text = minimumRange.toString();
                                            });
                                          }
                                          _calcSubmit(calcData);
                                        },
                                      ),
                                      SizedBox(
                                        width: 40,
                                        child: Text(
                                          FlutterI18n.translate(context, "gunCalc.meter"),
                                          textAlign: TextAlign.right,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      ...[100, 50, 10, 5]
                                          .map((e) => ActionChip(
                                                label: Text(e.toString()),
                                                visualDensity: VisualDensity.compact,
                                                padding: EdgeInsets.zero,
                                                onPressed: () {
                                                  num maximumRange = calcData.currentCalculatingFunction.child[inputFactions]!.maximumRange;
                                                  if (_textController.value.text.isNotEmpty && num.parse(_textController.value.text.toString()) < maximumRange) {
                                                    setState(() {
                                                      _textController.value.text = (num.parse(_textController.value.text.toString()) + e).toString();
                                                    });
                                                  } else {
                                                    setState(() {
                                                      _textController.value.text = maximumRange.toString();
                                                    });
                                                  }
                                                  _calcSubmit(calcData);
                                                },
                                              ))
                                          .toList(),
                                      const SizedBox(width: 5),
                                      IconButton.filledTonal(
                                        icon: const Icon(Icons.add),
                                        padding: EdgeInsets.zero,
                                        visualDensity: VisualDensity.compact,
                                        onPressed: () {
                                          num maximumRange = calcData.currentCalculatingFunction.child[inputFactions]!.maximumRange;
                                          if (_textController.value.text.isNotEmpty && num.parse(_textController.value.text.toString()) < maximumRange) {
                                            setState(() {
                                              _textController.value.text = (num.parse(_textController.value.text.toString()) + 1).toString();
                                            });
                                          } else {
                                            _textController.value.text = maximumRange.toString();
                                          }
                                          _calcSubmit(calcData);
                                        },
                                      ),
                                      const SizedBox(width: 40),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.keyboard_arrow_up),
                                        padding: EdgeInsets.zero,
                                        visualDensity: VisualDensity.compact,
                                        onPressed: () => _switchQuickOperationPanel(),
                                      ),
                                      const SizedBox(width: 40),
                                    ],
                                  ),
                                ],
                              )
                            else
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton.filledTonal(
                                    enableFeedback: true,
                                    icon: const Icon(Icons.remove),
                                    padding: EdgeInsets.zero,
                                    visualDensity: VisualDensity.compact,
                                    onPressed: () {
                                      num minimumRange = calcData.currentCalculatingFunction.child[inputFactions]!.minimumRange;
                                      if (_textController.value.text.isNotEmpty && num.parse(_textController.value.text.toString()) > minimumRange) {
                                        setState(() {
                                          _textController.value.text = (num.parse(_textController.value.text.toString()) - 1).toString();
                                        });
                                      } else {
                                        setState(() {
                                          _textController.value.text = minimumRange.toString();
                                        });
                                      }
                                      _calcSubmit(calcData);
                                    },
                                  ),
                                  IconButton.filledTonal(
                                    icon: const Icon(Icons.add),
                                    padding: EdgeInsets.zero,
                                    visualDensity: VisualDensity.compact,
                                    onPressed: () {
                                      num maximumRange = calcData.currentCalculatingFunction.child[inputFactions]!.maximumRange;
                                      if (_textController.value.text.isNotEmpty && num.parse(_textController.value.text.toString()) < maximumRange) {
                                        setState(() {
                                          _textController.value.text = (num.parse(_textController.value.text.toString()) + 1).toString();
                                        });
                                      } else {
                                        _textController.value.text = maximumRange.toString();
                                      }
                                      _calcSubmit(calcData);
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.more_vert),
                                    padding: EdgeInsets.zero,
                                    visualDensity: VisualDensity.compact,
                                    onPressed: () => _switchQuickOperationPanel(),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(FlutterI18n.translate(context, "gunCalc.meter")),
                                ],
                              ),
                            TextField(
                              readOnly: true,
                              showCursor: false,
                              style: const TextStyle(fontSize: 50).copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              decoration: InputDecoration(
                                counterText: FlutterI18n.translate(context, "gunCalc.result"),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                                hintText: "0",
                              ),
                              textAlign: TextAlign.end,
                              keyboardType: TextInputType.number,
                              controller: TextEditingController(text: outputValue),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            /// tool
            Row(
              children: [
                IconButton(
                  onPressed: () => _openHistoryModel(historyData),
                  icon: const Icon(Icons.history),
                ),
                Flexible(
                  flex: 1,
                  child: SizedBox(
                    height: 30,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        RawChip(
                          onPressed: () => _openSelectFactions(),
                          padding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                          avatar: const Icon(Icons.flag),
                          label: Row(
                            children: [
                              Text(FlutterI18n.translate(context, "basic.factions.${inputFactions.value}")),
                              const Icon(Icons.keyboard_arrow_down_outlined, size: 18),
                            ],
                          ),
                        ),
                        const SizedBox(width: 5),
                        RawChip(
                          onPressed: () {
                            App.url.opEnPage(context, "/calculatingFunctionConfig").then((value) {
                              setState(() {
                                inputFactions = App.provider.ofCalc(context).currentCalculatingFunction.child.keys.first;
                              });
                            });
                          },
                          padding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                          avatar: const Icon(Icons.functions),
                          label: Row(
                            children: [
                              Text(calcData.currentCalculatingFunctionName),
                              const Icon(Icons.keyboard_arrow_down_outlined, size: 18),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // const Expanded(flex: 1, child: SizedBox()),
                IconButton(
                  onPressed: () {
                    _handleBackspace();
                  },
                  icon: const Icon(Icons.backspace),
                ),
                IconButton(
                  onPressed: _textController.value.text.isNotEmpty ? () => _clearCalc() : null,
                  icon: const Icon(Icons.delete),
                ),
              ],
            ),
            const Divider(height: 1, thickness: 1),

            /// 预选建议
            AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              clipBehavior: Clip.hardEdge,
              color: Theme.of(context).primaryColor.withOpacity(.2),
              height: collectData.primarySelection(_textController.value.text).isNotEmpty ? 80 : 0,
              width: MediaQuery.of(context).size.width,
              child: OverflowBox(
                alignment: Alignment.bottomCenter,
                maxHeight: 80,
                minHeight: 0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 1,
                      child: Scrollbar(
                        child: ListView(
                          shrinkWrap: true,
                          padding: const EdgeInsets.only(left: 20, top: 8, right: 20, bottom: 4),
                          scrollDirection: Axis.horizontal,
                          children: collectData
                              .primarySelection(_textController.value.text)
                              .map((e) => Container(
                                    margin: const EdgeInsets.only(right: 5),
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(50 / 3),
                                        ),
                                      ),
                                      child: Container(
                                        constraints: const BoxConstraints(
                                          maxWidth: 130,
                                          minWidth: 100,
                                        ),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Wrap(
                                              children: [
                                                if (e.title.isNotEmpty)
                                                  Text(
                                                    e.title,
                                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  )
                                                else
                                                  Text(
                                                    e.id,
                                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Text(e.inputValue),
                                                const SizedBox(width: 25, child: Icon(Icons.arrow_right_alt_sharp, size: 15)),
                                                Chip(
                                                  label: Text(
                                                    e.outputValue,
                                                    style: TextStyle(color: Theme.of(context).colorScheme.primary),
                                                  ),
                                                  visualDensity: const VisualDensity(vertical: -4, horizontal: -4),
                                                  padding: EdgeInsets.zero,
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _textController.value.text = e.inputValue;
                                          _calcSubmit(calcData);
                                        });
                                      },
                                    ),
                                  ))
                              .toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            /// 键盘
            KeyboardWidget(
              spatialName: widget.name,
              initializePackup: true,
              initializeKeyboardType: KeyboardType.Number,
              onSubmit: () {
                if (_textController.value.text.isEmpty) return;

                if (isCompleteInputOperation) {
                  setState(() {
                    isCompleteInputOperation = false;
                    _clearCalc();
                  });
                  return;
                }

                // 处理输入定时器
                _handInputTimer();

                // 计算结果 且添加到历史
                historyData.add(_calcSubmit(calcData));
              },
              controller: _textController,
            ),

            Container(
              height: MediaQuery.of(context).viewPadding.bottom,
              color: Theme.of(context).primaryColor.withOpacity(.2),
            ),
          ],
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
