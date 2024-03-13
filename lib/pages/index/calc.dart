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

class calcPage extends StatefulWidget {
  const calcPage({super.key});

  @override
  State<calcPage> createState() => _calcPageState();
}

class _calcPageState extends State<calcPage> with AutomaticKeepAliveClientMixin {
  TextEditingController _textController = TextEditingController(text: "");

  FocusNode focusNode = FocusNode();

  Factions inputFactions = Factions.None;

  String outputValue = "";

  // 预选
  List primarySelectionList = [];

  @override
  void initState() {
    CalculatingFunction currentCalculatingFunction = App.provider.ofCalc(context).currentCalculatingFunction;
    Factions firstName = Factions.None;

    if (currentCalculatingFunction.child != null) {
      firstName = currentCalculatingFunction.child.keys.first;
    }

    setState(() {
      // 初始所支持的阵营
      if (Factions.values.where((e) => e == firstName).isNotEmpty) inputFactions = Factions.values.where((e) => e == firstName).first;
    });

    super.initState();
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
      _textController.text = "";
      outputValue = "";
    });
  }

  /// 展开历史列表
  void _openHistoryModel(HistoryProvider historyData) {
    showModalBottomSheet<void>(
      context: context,
      clipBehavior: Clip.hardEdge,
      builder: (BuildContext context) {
        return Scaffold(
          appBar: AppBar(
            leading: const CloseButton(),
          ),
          body: historyData.list.isNotEmpty
              ? Scrollbar(
                  child: ListView(
                    dragStartBehavior: DragStartBehavior.down,
                    children: historyData.sort().list.map((i) {
                      return HistoryCalcCard(i: i);
                    }).toList(),
                  ),
                )
              : const Center(
                  child: EmptyWidget(),
                ),
        );
      },
    );
  }

  /// 计算
  CalcResult _calcSubmit(CalcProvider calcData) {
    CalcResult result = App.calc.on(
      inputFactions: inputFactions,
      inputValue: _textController.text,
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
  void handleBackspace() {
    final currentText = _textController.text;
    final selection = _textController.selection;
    if (selection.baseOffset != selection.extentOffset) {
      final newText = currentText.replaceRange(
        selection.baseOffset,
        selection.extentOffset,
        '',
      );
      _textController.value = TextEditingValue(
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
      _textController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(
          offset: selection.baseOffset - 1,
        ),
      );
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Consumer3<CalcProvider, HistoryProvider, CollectProvider>(
      builder: (consumerContext, calcData, historyData, collectData, widget) {
        return Column(
          children: <Widget>[
            Expanded(
              flex: 1,
              child: InkWell(
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
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.zero,
                                  hintText: "0",
                                ),
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                inputFormatters: [FilteringTextInputFormatter.allow(RegExp("[0-9]"))],
                                maxLines: 3,
                                minLines: 1,
                                autocorrect: true,
                                autofocus: true,
                                textAlign: TextAlign.end,
                                controller: _textController,
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
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton.filledTonal(
                                    enableFeedback: true,
                                    icon: const Icon(Icons.remove),
                                    onPressed: () {
                                      num minimumRange = calcData.currentCalculatingFunction.child[inputFactions]!.minimumRange;
                                      if (_textController.text.isNotEmpty && num.parse(_textController.text.toString()) > minimumRange) {
                                        setState(() {
                                          _textController.text = (num.parse(_textController.text.toString()) - 1).toString();
                                        });
                                      } else {
                                        setState(() {
                                          _textController.text = minimumRange.toString();
                                        });
                                      }
                                      _calcSubmit(calcData);
                                    },
                                  ),
                                  IconButton.filledTonal(
                                    icon: const Icon(Icons.add),
                                    onPressed: () {
                                      num maximumRange = calcData.currentCalculatingFunction.child[inputFactions]!.maximumRange;
                                      if (_textController.text.isNotEmpty && num.parse(_textController.text.toString()) < maximumRange) {
                                        setState(() {
                                          _textController.text = (num.parse(_textController.text.toString()) + 1).toString();
                                        });
                                      } else {
                                        _textController.text = maximumRange.toString();
                                      }
                                      _calcSubmit(calcData);
                                    },
                                  ),
                                  const SizedBox(width: 10),
                                  const Text("米"),
                                ],
                              ),
                              TextField(
                                readOnly: true,
                                showCursor: false,
                                style: const TextStyle(fontSize: 50).copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                decoration: const InputDecoration(
                                  counterText: '角度 (结果)',
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
                onLongPress: () => _openSelectFactions(),
              ),
            ),

            /// tool
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    _openHistoryModel(historyData);
                  },
                  icon: const Icon(Icons.history),
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
                    handleBackspace();
                  },
                  icon: const Icon(Icons.backspace),
                ),
                IconButton(
                  onPressed: () {
                    _clearCalc();
                  },
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
              height: collectData.primarySelection(_textController.text).isNotEmpty ? 80 : 0,
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
                              .primarySelection(_textController.text)
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
                                                const SizedBox(child: Icon(Icons.arrow_right_alt_sharp, size: 15), width: 25),
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
                                          _textController.text = e.inputValue;
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
              onSubmit: () => historyData.add(_calcSubmit(calcData)),
              controller: _textController,
            ),
          ],
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
