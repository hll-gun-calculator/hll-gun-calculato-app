import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hll_gun_calculator/component/_empty/index.dart';
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

  UrlUtil urlUtil = UrlUtil();

  ProviderUtil providerUtil = ProviderUtil();

  Regular regular = Regular();

  String _currentCalculatingFunctionName = "";

  /// 导入 S
  /// 导入实例
  CalculatingFunction importCalculatingFunction = CalculatingFunction();

  /// 导入加载状态
  bool importLoad = false;

  /// 导入地址
  TextEditingController pathController = TextEditingController(text: "https://raw.githubusercontent.com/hell-gun-calculator/document/main/config/calcFunction/example.json");

  /// 导入标题
  TextEditingController titleController = TextEditingController(text: "");

  /// 导入 E

  @override
  void initState() {
    _currentCalculatingFunctionName = providerUtil.ofCalc(context).currentCalculatingFunctionName;
    super.initState();
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
                if (i.child != null && i.child!.isNotEmpty)
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
                else
                  const EmptyWidget(),
              ],
            ),
          );
        });
      },
    );
  }

  /// 删除配置
  void _deleteConfig(String name) {
    if (_currentCalculatingFunctionName == name) {
      Fluttertoast.showToast(msg: "选择中无法删除，请切换函数");
      return;
    }

    providerUtil.ofCalc(context).deleteLocalCustom(name);
    Navigator.pop(context);
  }

  /// 确定配置
  /// 保存添加
  void _onModalDone() {
    if (titleController.text.isEmpty) {
      Fluttertoast.showToast(msg: "缺少标题");
      return;
    }

    providerUtil.ofCalc(context).addCustomConfig(
          title: titleController.text,
          data: jsonEncode(importCalculatingFunction.toJson()),
        );
    Navigator.pop(context);
  }

  /// 从远程网络下载配置文件
  Future _networkDownloadConfigType(CalcProvider calcData, String path, modalSetState) async {
    if (path.isEmpty) {
      Fluttertoast.showToast(msg: "请填写导入配置具体地址");
      return;
    }

    modalSetState(() {
      importLoad = true;
    });

    Response cloudNetworkResult = await calcData.cloudNetworkLoadCalc(path);

    if (cloudNetworkResult.data != null) {
      dynamic json = jsonDecode(cloudNetworkResult.data);

      // 将下载的配置，同步到输入框内
      setState(() {
        importCalculatingFunction = CalculatingFunction.fromJson(json);

        if (calcData.calcList.where((i) => i.name == json["name"]).isNotEmpty) {
          num length = calcData.calcList.where((i) => i.name == json["name"]).length;
          titleController.text = "${json["name"]} 副本$length";
        } else {
          titleController.text = json["name"];
        }
      });
    }

    modalSetState(() {
      importLoad = false;
    });

    return cloudNetworkResult;
  }

  /// 从本地添加配置文件
  Future _localImportConfigType() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result != null) {
      PlatformFile file = result.files.first;
      String localImportResult = await rootBundle.loadString(file.path!);
      dynamic json = jsonDecode(localImportResult);

      setState(() {
        importCalculatingFunction = CalculatingFunction.fromJson(json);

        if (providerUtil.ofCalc(context).calcList.where((i) => i.name == json["name"]).isNotEmpty) {
          num length = providerUtil.ofCalc(context).calcList.where((i) => i.name == json["name"]).length;
          titleController.text = "${json["name"]} 副本$length";
        } else {
          titleController.text = json["name"];
        }
        pathController.text = "local://${titleController.text}";
      });
    }
  }

  /// 从本地创建配置文件
  Future _localCreateConfigType() async {
    urlUtil.opEnPage(context, "/calculatingFunctionCreate").then((value) {
      if (value is Map) {
        Map<String, dynamic> json = Map<String, dynamic>.from(value);
        setState(() {
          print(json);
          // importCalculatingFunction = CalculatingFunction.fromJson(json);

          if (providerUtil.ofCalc(context).calcList.where((i) => i.name == json["name"]).isNotEmpty) {
            num length = providerUtil.ofCalc(context).calcList.where((i) => i.name == json["name"]).length;
            titleController.text = "${json["name"]} 副本$length";
          } else {
            titleController.text = json["name"];
          }
          pathController.text = "local://${json["name"]}";
        });
      }
    });
  }

  /// 打开添加配置Modal
  void _openAddConfigModal(CalcProvider calcData) {
    String defaultType = "0";

    setState(() {
      // 重置
      importCalculatingFunction = CalculatingFunction();
      pathController.text = "";
    });

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
                  onPressed: () => _onModalDone(),
                  icon: const Icon(Icons.add_circle),
                ),
              ],
            ),
            body: Form(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: ListView(
                children: [
                  /// 导入方式
                  DropdownButtonHideUnderline(
                    child: DropdownButton(
                      value: defaultType,
                      isExpanded: true,
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
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
                          defaultType = v as String;
                        });
                        modalSetState(() {});
                      },
                    ),
                  ),
                  const Divider(height: 1, thickness: 1),

                  /// 导入方式Widget
                  if (defaultType == "0")
                    Column(
                      children: [
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: "地址",
                            hintText: "https://",
                            contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                            suffix: importLoad
                                ? const SizedBox(
                                    width: 10,
                                    height: 10,
                                    child: CircularProgressIndicator(),
                                  )
                                : TextButton.icon(
                                    onPressed: () => _networkDownloadConfigType(calcData, pathController.text, modalSetState),
                                    icon: const Icon(Icons.download),
                                    label: const Text("下载"),
                                  ),
                          ),
                          keyboardType: TextInputType.url,
                          controller: pathController,
                          onChanged: (v) {
                            pathController.text = v;
                          },
                          validator: (value) {
                            if (value!.isEmpty) return "地址不可空";
                            if (regular.check(RegularType.Link, value).code != 0) return "并非正确的地址";
                            return null;
                          },
                        ),
                      ],
                    )
                  else if (defaultType == "1")
                    TextField(
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: "地址",
                        hintText: "local://",
                        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                        suffix: TextButton.icon(
                          onPressed: () => _localImportConfigType(),
                          icon: const Icon(Icons.file_download_rounded),
                          label: const Text("导入文件"),
                        ),
                      ),
                      controller: pathController,
                    )
                  else if (defaultType == "2")
                    TextField(
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: "地址",
                        hintText: "local://",
                        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                        suffix: TextButton.icon(
                          onPressed: () => _localCreateConfigType(),
                          icon: const Icon(Icons.edit),
                          label: const Text("创建"),
                        ),
                      ),
                      controller: pathController,
                    ),

                  /// 导入的信息
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: "函数标题",
                      hintText: "标题",
                      contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                    ),
                    controller: titleController,
                    maxLength: 20,
                    onChanged: (v) {
                      titleController.text = v;
                    },
                    validator: (value) {
                      if (value!.isEmpty) return "缺少标题";
                      return null;
                    },
                  ),
                ],
              ),
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
              onPressed: () => _openAddConfigModal(calcData),
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
              subtitle: Row(
                children: [
                  Text(i.author.toString()),
                  const VerticalDivider(),
                  Text(i.version.toString()),
                ],
              ),
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
