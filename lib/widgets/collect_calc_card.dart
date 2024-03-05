import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:hll_emplacement_calculator/component/_time/index.dart';
import 'package:hll_emplacement_calculator/data/CalcResult.dart';
import 'package:hll_emplacement_calculator/data/Collect.dart';
import 'package:provider/provider.dart';

import '../provider/collect_provider.dart';

class collectCalcCard extends StatefulWidget {
  final CollectItemData i;

  const collectCalcCard({
    super.key,
    required this.i,
  });

  @override
  State<collectCalcCard> createState() => _historyCalcCardState();
}

class _historyCalcCardState extends State<collectCalcCard> {
  /// 打开收藏详情
  void _openCollectDetail(CollectItemData collectItemData) {
    TextEditingController title = TextEditingController(text: collectItemData.title);
    TextEditingController remark = TextEditingController(text: collectItemData.remark);

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
                  DropdownButton(
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.more_horiz),
                    items: [
                      const DropdownMenuItem(
                        value: 1,
                        child: Text("删除"),
                      ),
                      // DropdownMenuItem(
                      //   value: 2,
                      //   child: Text(collectData.hasAsId(collectItemData.id) ? "删除收藏" : "收藏"),
                      // ),
                    ],
                    onChanged: (value) {
                      switch (value as int) {
                        case 1:
                          collectData.deleteAsId(collectItemData.id);
                          break;
                        case 2:
                          break;
                      }
                    },
                  ),
                ],
              ),
              body: ListView(
                children: [
                  ListTile(
                    title: const Text("结果"),
                    subtitle: Card(
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
                  const ListTile(
                    title: Text("标题"),
                  ),
                  TextField(
                    decoration: const InputDecoration(
                      hintText: "标题内容",
                      contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                    ),
                    minLines: 1,
                    maxLines: 1,
                    controller: title,
                  ),
                  const ListTile(
                    title: Text("描述"),
                  ),
                  TextField(
                    decoration: const InputDecoration(
                      hintText: "描述内容",
                      contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                    ),
                    minLines: 2,
                    maxLines: 4,
                    maxLength: 1000,
                    controller: remark,
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text("阵营"),
                    trailing: Text(FlutterI18n.translate(context, "basic.factions.${collectItemData.inputFactions.value}")),
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text("使用函数名称"),
                    trailing: Text(collectItemData.calculatingFunctionInfo.name),
                  ),
                  ListTile(
                    title: const Text("使用函数版本"),
                    trailing: Text(collectItemData.calculatingFunctionInfo.version),
                  ),
                  ListTile(
                    title: const Text("函数作者"),
                    trailing: Text(collectItemData.calculatingFunctionInfo.author),
                  ),
                  ListTile(
                    title: const Text("网站"),
                    trailing: Text(collectItemData.calculatingFunctionInfo.website),
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text("创建时间"),
                    trailing: TimeWidget(data: collectItemData.creationTime.toString()),
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text("结果"),
                    trailing: Text(collectItemData.result!.message.toString()),
                  ),
                  ListTile(
                    title: const Text("状态"),
                    trailing: Text(collectItemData.result!.code.toString()),
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text("ID"),
                    trailing: Text(collectItemData.id),
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
    return InkWell(
      child: ListTile(
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.i.title,
                    style: const TextStyle(fontWeight: FontWeight.normal),
                  ),
                  Text(
                    widget.i.remark,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
            Card(
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
      ),
      onTap: () {
        _openCollectDetail(widget.i);
      },
    );
  }
}
