// ignore_for_file: camel_case_types

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import '/data/index.dart';
import '/provider/collect_provider.dart';
import '/component/_time/index.dart';

class HistoryCalcCard extends StatefulWidget {
  final CalcHistoryItemData i;

  const HistoryCalcCard({
    super.key,
    required this.i,
  });

  @override
  State<HistoryCalcCard> createState() => _historyCalcCardState();
}

class _historyCalcCardState extends State<HistoryCalcCard> {
  /// 收藏添加
  void _addCollectModel(CalcResult calcResult) {
    TextEditingController titleController = TextEditingController(
      text: "${FlutterI18n.translate(context, "basic.factions.${calcResult.inputFactions.value}")}-${calcResult.inputValue}",
    );
    TextEditingController remarkController = TextEditingController(
      text: "${calcResult.inputValue} > ${calcResult.outputValue}",
    );

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      clipBehavior: Clip.hardEdge,
      builder: (context) {
        return Consumer<CollectProvider>(
          builder: (BuildContext collectContext, collectData, collectWidget) {
            return Scaffold(
              appBar: AppBar(
                leading: const CloseButton(),
                actions: [
                  IconButton(
                    onPressed: () {
                      if (collectData.hasItem(
                        inputValue: widget.i.inputValue,
                        inputFactions: widget.i.inputFactions,
                        title: titleController.text,
                        remark: remarkController.text,
                      )) {
                        Fluttertoast.showToast(msg: "已存在类似收藏");
                        return;
                      }

                      collectData.add(widget.i, titleController.text, remark: remarkController.text);
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.done),
                  ),
                ],
              ),
              body: ListView(
                children: [
                  TextField(
                    decoration: const InputDecoration(
                      hintText: "标题内容",
                      contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                    ),
                    minLines: 1,
                    maxLines: 1,
                    controller: titleController,
                  ),
                  TextField(
                    decoration: const InputDecoration(
                      hintText: "描述内容",
                      contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                    ),
                    minLines: 4,
                    maxLines: 10,
                    maxLength: 1000,
                    controller: remarkController,
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// 打开历史详情
  void _openHistoryDetail(CalcHistoryItemData calcResult) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      clipBehavior: Clip.hardEdge,
      useRootNavigator: true,
      builder: (context) {
        return Consumer<CollectProvider>(
          builder: (BuildContext collectContext, collectData, collectWidget) {
            return Scaffold(
              appBar: AppBar(
                leading: const CloseButton(),
                actions: [
                  IconButton(
                    onPressed: () {},
                    icon: Icon(collectData.hasAsId(calcResult.id) ? Icons.star : Icons.star_border),
                  ),
                  DropdownButtonHideUnderline(
                    child: DropdownButton(
                      padding: const EdgeInsets.all(5),
                      icon: const Icon(Icons.more_horiz),
                      isDense: true,
                      items: const [
                        DropdownMenuItem(
                          value: 1,
                          child: Text("删除"),
                        ),
                        DropdownMenuItem(
                          value: 2,
                          child: Text("收藏"),
                        ),
                      ],
                      onChanged: (value) {
                        switch (value as int) {
                          case 2:
                            _addCollectModel(widget.i);
                            break;
                        }
                      },
                    ),
                  ),
                ],
              ),
              body: ListView(
                children: [
                  ListTile(
                    title: const Text("结果"),
                    subtitle: Card(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              widget.i.inputValue.toString(),
                              style: const TextStyle(
                                fontSize: 20,
                              ),
                            ),
                            const Icon(Icons.chevron_right),
                            Text(
                              widget.i.outputValue.toString(),
                              style: TextStyle(
                                fontSize: 20,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  ListTile(
                    title: const Text("阵营"),
                    trailing: Text(FlutterI18n.translate(context, "basic.factions.${calcResult.inputFactions.value}")),
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text("使用函数名称"),
                    trailing: Text(calcResult.calculatingFunctionInfo.name),
                  ),
                  ListTile(
                    title: const Text("使用函数版本"),
                    trailing: Text(calcResult.calculatingFunctionInfo.version),
                  ),
                  ListTile(
                    title: const Text("函数作者"),
                    trailing: Text(calcResult.calculatingFunctionInfo.author),
                  ),
                  ListTile(
                    title: const Text("网站"),
                    trailing: Text(calcResult.calculatingFunctionInfo.website),
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text("创建时间"),
                    trailing: TimeWidget(data: calcResult.creationTime.toString()),
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text("结果"),
                    trailing: Text(calcResult.result!.message.toString()),
                  ),
                  ListTile(
                    title: const Text("状态"),
                    trailing: Text(calcResult.result!.code.toString()),
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text("ID"),
                    trailing: Text(calcResult.id.toString()),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  FlutterI18n.translate(context, "basic.factions.${widget.i.inputFactions.value}"),
                  style: const TextStyle(fontWeight: FontWeight.normal),
                ),
                TimeWidget(data: widget.i.creationTime.toString()),
              ],
            ),
          ),
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    widget.i.inputValue,
                    style: const TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                  Text(
                    widget.i.outputValue.toString(),
                    style: TextStyle(
                      fontSize: 20,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      subtitle: Wrap(
        children: [
          if (widget.i.result!.code != 0) Text(widget.i.result!.message.toString()),
        ],
      ),
      onTap: () {
        CalcHistoryItemData calcHistoryItemData = CalcHistoryItemData();
        calcHistoryItemData.as(widget.i);
        _openHistoryDetail(calcHistoryItemData);
      },
    );
  }
}
