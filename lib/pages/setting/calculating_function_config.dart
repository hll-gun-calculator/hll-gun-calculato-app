import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hll_emplacement_calculator/main.dart';
import 'package:hll_emplacement_calculator/provider/calc_provider.dart';
import 'package:hll_emplacement_calculator/utils/index.dart';
import 'package:provider/provider.dart';

import '../../data/index.dart';

/// [计算函数配置]
/// 从服务器获取计算函数
///
/// 函数结构:
/// {
///  方程名称: 内置
///  版本: 0.0.1
///  child: {
///   美军: {
///     方程:
///   },
///   英军: {
///    ...
///   }
///   ...
///
///  }
/// }
///
/// 每次计算结果内都会保存计算函数信息，作为最终结果，如果计算函数更新，
/// 那么可以在计算日志长按‘重新计算’对当前对应米数、阵营、地图重新计算结果，并再次保存上面信息
class CalculatingFunctionPage extends StatefulWidget {
  const CalculatingFunctionPage({super.key});

  @override
  State<CalculatingFunctionPage> createState() => _calculatingFunctionPageState();
}

class _calculatingFunctionPageState extends State<CalculatingFunctionPage> {
  CalcUtil calcUtil = CalcUtil();

  String _currentCalculatingFunctionName = "";

  @override
  void initState() {
    _currentCalculatingFunctionName = ProviderUtil().ofCalc(context).currentCalculatingFunctionName;
    super.initState();
  }

  /// 查看配置详情
  void _openConfigDetail(CalculatingFunction i) {
    showModalBottomSheet<void>(
      context: context,
      clipBehavior: Clip.hardEdge,
      useRootNavigator: true,
      builder: (context) {
        return Scaffold(
          appBar: AppBar(
            leading: const CloseButton(),
          ),
          body: ListView(
            children: [
              ListTile(
                title: const Text("名称"),
                trailing: Text(i.name),
              ),
              ListTile(
                title: const Text("版本"),
                trailing: Text(i.version),
              ),
              ListTile(
                title: const Text("网站"),
                trailing: Text(i.website),
              ),
              ListTile(
                title: const Text("作者"),
                trailing: Text(i.author),
              ),
              const Divider(),
              const ListTile(
                title: Text("支持阵营"),
              ),
              Column(
                children: i.child!.entries.map((e) {
                  return Column(
                    children: [
                      ListTile(
                        title: Text(FlutterI18n.translate(context, "basic.factions.${e.key}")),
                        subtitle: Text(e.value.toString()),
                      ),
                    ],
                  );
                }).toList(),
              )
            ],
          ),
        );
      },
    );
  }

  /// 添加配置
  void _addConfig(CalcProvider calcData) {
    String path = "";
    String title = "";
    String type = "0";

    add() {
      if (title.isEmpty || path.isEmpty) {
        Fluttertoast.showToast(msg: "请填写完整内容");
        return;
      }

      calcData.addNetworkCustom(
        title: title,
        path: path,
      );
    }

    showModalBottomSheet<void>(
        context: context,
        clipBehavior: Clip.hardEdge,
        useRootNavigator: true,
        builder: (context) {
          return Scaffold(
            appBar: AppBar(
              leading: const CloseButton(),
              actions: [
                IconButton(
                  onPressed: () {
                    add();
                  },
                  icon: const Icon(Icons.done),
                ),
              ],
            ),
            body: ListView(
              padding: const EdgeInsets.all(10),
              children: [
                DropdownButton(
                  value: type,
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(
                      value: "0",
                      child: Text("从网络"),
                    ),
                    DropdownMenuItem(
                      value: "1",
                      child: Text("从本地"),
                    ),
                  ],
                  onChanged: (v) {
                    setState(() {
                      type = v as String;
                    });
                  },
                ),
                TextField(
                  decoration: const InputDecoration(hintText: "标题"),
                  onChanged: (v) {
                    title = v;
                  },
                ),
                TextField(
                  decoration: const InputDecoration(hintText: "地址,例子:https://"),
                  minLines: 2,
                  maxLines: 10,
                  onChanged: (v) {
                    title = v;
                  },
                )
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CalcProvider>(builder: (context, calcData, widget) {
      return Scaffold(
        appBar: AppBar(
          title: Text(FlutterI18n.translate(context, "calculatingFunctionConfig.title")),
          actions: [
            IconButton(
              onPressed: () {
                _addConfig(calcData);
              },
              icon: const Icon(Icons.add),
            ),
            if (calcData.currentCalculatingFunctionName != _currentCalculatingFunctionName)
              IconButton(
                onPressed: () {
                  if (calcData.currentCalculatingFunctionName.isNotEmpty) {
                    calcData.selectCalculatingFunction(calcData.currentCalculatingFunctionName);

                    setState(() {
                      _currentCalculatingFunctionName = calcData.currentCalculatingFunctionName;
                    });
                  }
                },
                icon: const Icon(Icons.done),
              ),
          ],
        ),
        body: ListView.builder(
          itemBuilder: (context, index) {
            CalculatingFunction i = calcData.calcList[index];
            return ListTile(
              selected: i.name == calcData.currentCalculatingFunctionName,
              onTap: () {
                setState(() {
                  calcData.currentCalculatingFunctionName = i.name;
                });
              },
              title: Text(i.name),
              subtitle: Text(i.version.toString()),
              trailing: IconButton(
                icon: const Icon(Icons.more_horiz),
                onPressed: () {
                  _openConfigDetail(i);
                },
              ),
            );
          },
          itemCount: calcData.calcList.length,
        ),
      );
    });
  }
}
