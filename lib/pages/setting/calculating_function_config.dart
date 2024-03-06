import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hll_gun_calculator/component/_time/index.dart';
import 'package:provider/provider.dart';

import '/provider/calc_provider.dart';
import '/utils/index.dart';
import '/data/index.dart';

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

  ProviderUtil providerUtil = ProviderUtil();

  String _currentCalculatingFunctionName = "";

  @override
  void initState() {
    _currentCalculatingFunctionName = providerUtil.ofCalc(context).currentCalculatingFunctionName;
    super.initState();
  }

  /// 删除配置
  void _deleteConfig (String name) {
    if (_currentCalculatingFunctionName == name) {
      Fluttertoast.showToast(msg: "选择中无法删除，请切换函数");
      return;
    }

    ProviderUtil().ofCalc(context).deleteLocalCustom(name);
    Navigator.pop(context);
  }

  /// 查看配置详情
  void _openConfigDetail(CalculatingFunction i) {
    showModalBottomSheet<void>(
      context: context,
      clipBehavior: Clip.hardEdge,
      useRootNavigator: true,
      builder: (context) {
        return StatefulBuilder(builder: (context, modalSetState) {
          return Scaffold(
            appBar: AppBar(
              leading: const CloseButton(),
              actions: [
                if (i.isCustom)
                  IconButton(
                    onPressed: () => _deleteConfig(i.name),
                    icon: const Icon(Icons.delete),
                  ),
              ],
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
                if (i.isCustom) const Divider(),
                if (i.isCustom)
                  ListTile(
                    title: const Text("创建时间"),
                    trailing: TimeWidget(data: i.creationTime.toString()),
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
        });
      },
    );
  }

  Future _localAddConfig(calcData, title, path) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      print(result.files.single.path!);
      // File file = File(result.files.single.path!);
      // calcData.addNetworkCustom(
      //   title: title,
      //   path: path,
      // );
    } else {
      // User canceled the picker
    }
  }

  Future _networkAddConfig(CalcProvider calcData, title, path) async {
    Response result = await calcData.addNetworkCustom(
      title: title,
      path: path,
    );

    return result;
  }

  /// 添加配置
  void _addConfigModal(CalcProvider calcData) {
    TextEditingController pathController = TextEditingController(text: "https://raw.githubusercontent.com/hell-gun-calculator/document/main/config/calcFunction/example.json");
    TextEditingController titleController = TextEditingController(text: "");
    TextEditingController versionController = TextEditingController(text: "");
    String type = "0";

    showModalBottomSheet<void>(
      context: context,
      clipBehavior: Clip.hardEdge,
      useRootNavigator: true,
      builder: (context) {
        return StatefulBuilder(builder: (context, modalSetState) {
          return Scaffold(
            appBar: AppBar(
              leading: const CloseButton(),
              actions: [
                IconButton(
                  onPressed: () {
                    // switch (type) {
                    //   case "0":
                    //     _networkAddConfig(calcData, title, path);
                    //     break;
                    //   case "1":
                    //     _localAddConfig(calcData, title, path);
                    //     break;
                    // }
                  },
                  icon: const Icon(Icons.done),
                ),
              ],
            ),
            body: ListView(
              children: [
                DropdownButton(
                  value: type,
                  isExpanded: true,
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                  items: const [
                    DropdownMenuItem(
                      value: "0",
                      child: Text("从网络导入"),
                    ),
                    DropdownMenuItem(
                      value: "1",
                      child: Text("从本地导入"),
                    ),
                    DropdownMenuItem(
                      value: "2",
                      child: Text("从本地创建"),
                    ),
                  ],
                  onChanged: (v) {
                    setState(() {
                      type = v as String;
                    });
                    modalSetState(() {});
                  },
                ),
                if (type == "0")
                  Column(
                    children: [
                      TextField(
                        decoration: InputDecoration(
                          hintText: "地址,例子:https://",
                          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                          suffix: IconButton(
                            onPressed: () async {
                              Response result = await _networkAddConfig(calcData, titleController.text, pathController.text);
                              dynamic json = jsonDecode(result.data);

                              // 将下载的配置，同步到输入框内
                              setState(() {
                                titleController.text = json["name"];
                                versionController.text = json["version"];
                              });
                            },
                            icon: const Icon(Icons.download),
                          ),
                        ),
                        controller: pathController,
                        minLines: 2,
                        maxLines: 10,
                        onChanged: (v) {
                          pathController.text = v;
                        },
                      ),
                      TextField(
                        decoration: const InputDecoration(
                          hintText: "标题",
                          contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                        ),
                        controller: titleController,
                        onChanged: (v) {
                          titleController.text = v;
                        },
                      ),
                      TextField(
                        decoration: const InputDecoration(
                          hintText: "版本",
                          contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                        ),
                        controller: versionController,
                        onChanged: (v) {
                          setState(() {
                            versionController.text = v;
                          });
                        },
                      ),
                    ],
                  )
                else if (type == "1")
                  const TextField(
                    readOnly: true,
                    decoration:  InputDecoration(
                      hintText: "path://",
                      contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                    ),
                    minLines: 2,
                    maxLines: 10,
                  )
                else if (type == "2")
                  Column(
                    children: [
                      TextField(
                        readOnly: true,
                        decoration:  InputDecoration(
                          hintText: ".json",
                          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                          suffix: IconButton(
                            onPressed: () {
                              UrlUtil().opEnPage(context, "/calculatingFunctionCreate").then((value) {
                                // calcData.addLocalCustom(title: "???", data: value);
                              });
                              // _localAddConfig(calcData, titleController.text, pathController.text);
                            },
                            icon: const Icon(Icons.edit),
                          ),
                        ),
                        minLines: 2,
                        maxLines: 10,
                      )
                    ],
                  ),
              ],
            ),
          );
        });
      },
    );
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
                _addConfigModal(calcData);
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
        body: ListView(
          children: calcData.sort().calcList.map((i) {
            return RadioListTile<String>(
              value: i.name,
              groupValue: calcData.currentCalculatingFunctionName,
              onChanged: (v) {
                setState(() {
                  calcData.currentCalculatingFunctionName = i.name;
                });
              },
              title: Text(i.name),
              subtitle: Text(i.version.toString()),
              secondary: IconButton(
                icon: const Icon(Icons.more_horiz),
                onPressed: () {
                  _openConfigDetail(i);
                },
              ),
            );
          }).toList(),
        ),
      );
    });
  }
}
