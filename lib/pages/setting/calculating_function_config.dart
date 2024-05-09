import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hll_gun_calculator/component/_code/index.dart';
import 'package:provider/provider.dart';

import '/component/_empty/index.dart';
import '/component/_time/index.dart';
import '/constants/api.dart';
import '/constants/app.dart';
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
  Regular regular = Regular();

  String _currentCalculatingFunctionName = "";

  bool updataLoad = false;

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
    _currentCalculatingFunctionName = App.provider.ofCalc(context).currentCalculatingFunctionName;
    super.initState();
  }

  /// 更新配置
  void _updataConfigDetail(CalculatingFunction i, modalSetState) async {
    modalSetState(() {
      updataLoad = true;
    });

    List requestList = [];
    for (var i in i.updataFunction) {
      Response result = await Http.request(i.path, method: Http.GET, httpDioType: HttpDioType.none);
      requestList.add(jsonDecode(result.data));
    }

    modalSetState(() {
      CalculatingFunction newCalculatingFunction = CalculatingFunction.fromJson(requestList.first);
      newCalculatingFunction.type = CalculatingFunctionType.Custom;
      newCalculatingFunction.updateTime = DateTime.now();
      App.provider.ofCalc(context).updataCustomConfig(i.id, newCalculatingFunction);
      updataLoad = false;
    });
  }

  /// 查看配置详情
  void _openConfigDetail(CalculatingFunction i) {
    showModalBottomSheet<void>(
      context: context,
      clipBehavior: Clip.hardEdge,
      useRootNavigator: true,
      useSafeArea: true,
      scrollControlDisabledMaxHeightRatio: 1,
      builder: (context) {
        return StatefulBuilder(builder: (context, modalSetState) {
          return Scaffold(
            appBar: AppBar(
              leading: const CloseButton(),
              actions: [
                if (i.type == CalculatingFunctionType.Custom)
                  IconButton(
                    onPressed: () => _deleteConfig(i.name),
                    icon: const Icon(Icons.delete),
                  ),
              ],
            ),
            body: ListView(
              children: [
                ListTile(
                  title: Text(FlutterI18n.translate(context, "calculatingFunction.modalSheet.name")),
                  trailing: Text(i.name),
                ),
                ListTile(
                  title: Text(FlutterI18n.translate(context, "calculatingFunction.modalSheet.version")),
                  trailing: Text(i.version),
                ),
                ListTile(
                  title: Text(FlutterI18n.translate(context, "calculatingFunction.modalSheet.website")),
                  trailing: Text(i.website),
                ),
                ListTile(
                  title: Text(FlutterI18n.translate(context, "calculatingFunction.modalSheet.author")),
                  trailing: Text(i.author),
                ),
                if (i.type == CalculatingFunctionType.Custom && i.updataFunction.isNotEmpty)
                  ListTile(
                    title: Text(FlutterI18n.translate(context, "calculatingFunction.modalSheet.updataFunctionTitle")),
                    subtitle: Text(FlutterI18n.translate(context, "calculatingFunction.modalSheet.updataFunctionTitleDescription")),
                    trailing: updataLoad ? const CircularProgressIndicator() : const Icon(Icons.chevron_right),
                    onTap: () => _updataConfigDetail(i, modalSetState),
                  ),
                if (i.type == CalculatingFunctionType.Custom) const Divider(),
                if (i.type == CalculatingFunctionType.Custom)
                  ListTile(
                    title: Text(FlutterI18n.translate(context, "calculatingFunction.modalSheet.creationTime")),
                    trailing: TimeWidget(data: i.creationTime.toString()),
                  ),
                const Divider(),
                ListTile(
                  title: Text(FlutterI18n.translate(context, "calculatingFunction.modalSheet.factions")),
                ),
                if (i.child.isNotEmpty)
                  ...i.child.entries.map((e) {
                    return ListTile(
                      title: Text(FlutterI18n.translate(context, "basic.factions.${e.key.value}")),
                      subtitle: CodeConvertJsonView(
                        data: e.value,
                      ),
                    );
                  }).toList()
                else
                  const EmptyWidget(),
                const Divider(),
                ListTile(
                  title: const Text("id"),
                  trailing: Text(i.id ?? "none"),
                )
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
      Fluttertoast.showToast(msg: FlutterI18n.translate(context, "calculatingFunction.deletionFailure"));
      return;
    }

    App.provider.ofCalc(context).deleteLocalCustom(name);
    Navigator.pop(context);
  }

  /// 确定配置
  /// 保存添加
  void _onModalDone({bool use = false}) {
    if (titleController.text.isEmpty) {
      Fluttertoast.showToast(msg: FlutterI18n.translate(context, "calculatingFunction.failureMissingTitle"));
      return;
    }

    App.provider.ofCalc(context).addCustomConfig(
          title: titleController.text,
          data: jsonEncode(importCalculatingFunction.toJson()),
        );

    // 并立即使用
    if (use) {
      setState(() {
        _currentCalculatingFunctionName = titleController.text;
        App.provider.ofCalc(context).currentCalculatingFunctionName = titleController.text;
      });
    }

    Navigator.pop(context);
  }

  /// 函数重命名
  /// 列表重复时添加副本后缀
  String _hasCalcNameRename(String name) {
    String newName = "";
    CalcProvider calcData = App.provider.ofCalc(context);
    if (calcData.calcList.where((i) => i.name == name).isNotEmpty) {
      num length = calcData.calcList.where((i) => i.name == name).length;
      newName = "$name 副本$length";
    } else {
      newName = name;
    }
    return newName;
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
        titleController.text = _hasCalcNameRename(json["name"]);
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

    if (result != null && result.files.isNotEmpty) {
      Uint8List? fileBytes;
      String localImportResult = "";
      dynamic json;

      if (kIsWeb) {
        fileBytes = result.files.first.bytes;
        localImportResult = String.fromCharCodes(fileBytes!);
        json = jsonDecode(localImportResult);
      } else {
        PlatformFile file = result.files.first;
        localImportResult = await rootBundle.loadString(file.path!);
        json = jsonDecode(localImportResult);
      }

      setState(() {
        importCalculatingFunction = CalculatingFunction.fromJson(json);
        titleController.text = _hasCalcNameRename(json["name"]);
        pathController.text = "local://${titleController.text}";
      });
    }
  }

  /// 从本地创建配置文件
  Future _localCreateConfigType() async {
    App.url.opEnPage(context, "/calculatingFunctionCreate").then((value) {
      if (value is Map) {
        Map<String, dynamic> json = Map<String, dynamic>.from(value);
        setState(() {
          importCalculatingFunction = CalculatingFunction.fromJson(json);
          titleController.text = _hasCalcNameRename(json["name"]);
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
      if (Config.env == Env.PROD) pathController.text = "";
    });

    showModalBottomSheet<void>(
      context: context,
      clipBehavior: Clip.hardEdge,
      useRootNavigator: true,
      useSafeArea: true,
      scrollControlDisabledMaxHeightRatio: 1,
      builder: (context) {
        return StatefulBuilder(builder: (context, modalSetState) {
          return Scaffold(
            appBar: AppBar(
              leading: const CloseButton(),
              actions: [
                IconButton(
                  onPressed: () => _onModalDone(),
                  icon: const Icon(Icons.add),
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
                      items: ["0", "1", "2"]
                          .map((itemIndex) => DropdownMenuItem(
                                value: itemIndex,
                                child: Text(FlutterI18n.translate(context, "calculatingFunction.modalImport.type.$itemIndex.name")),
                              ))
                          .toList(),
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
                            labelText: FlutterI18n.translate(context, "calculatingFunction.modalImport.type.0.labelText"),
                            hintText: FlutterI18n.translate(context, "calculatingFunction.modalImport.type.0.hintText"),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                            suffix: importLoad
                                ? const SizedBox(
                                    width: 25,
                                    height: 25,
                                    child: CircularProgressIndicator(),
                                  )
                                : TextButton.icon(
                                    onPressed: () => _networkDownloadConfigType(calcData, pathController.text, modalSetState),
                                    icon: const Icon(Icons.download),
                                    label: Text(FlutterI18n.translate(context, "calculatingFunction.modalImport.type.0.suffix")),
                                  ),
                          ),
                          keyboardType: TextInputType.url,
                          controller: pathController,
                          onChanged: (v) {
                            pathController.text = v;
                          },
                          validator: (value) {
                            if (value!.isEmpty) return FlutterI18n.translate(context, "calculatingFunction.modalImport.type.0.validatorPathNull");
                            if (regular.check(RegularType.Link, value).code != 0) return FlutterI18n.translate(context, "calculatingFunction.modalImport.type.0.validatorNotLink");
                            return null;
                          },
                        ),
                      ],
                    )
                  else if (defaultType == "1")
                    TextField(
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: FlutterI18n.translate(context, "calculatingFunction.modalImport.type.1.labelText"),
                        hintText: FlutterI18n.translate(context, "calculatingFunction.modalImport.type.1.hintText"),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                        suffix: TextButton.icon(
                          onPressed: () => _localImportConfigType(),
                          icon: const Icon(Icons.file_download_rounded),
                          label: Text(FlutterI18n.translate(context, "calculatingFunction.modalImport.type.1.suffix")),
                        ),
                      ),
                      controller: pathController,
                    )
                  else if (defaultType == "2")
                    TextField(
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: FlutterI18n.translate(context, "calculatingFunction.modalImport.type.2.labelText"),
                        hintText: FlutterI18n.translate(context, "calculatingFunction.modalImport.type.2.hintText"),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                        suffix: TextButton.icon(
                          onPressed: () => _localCreateConfigType(),
                          icon: const Icon(Icons.edit),
                          label: Text(FlutterI18n.translate(context, "calculatingFunction.modalImport.type.2.suffix")),
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
                      if (calcData.calcList.where((element) => element.name == titleController.text).isNotEmpty) return FlutterI18n.translate(context, "calculatingFunction.titleExist");
                      if (value!.isEmpty) return FlutterI18n.translate(context, "calculatingFunction.failureMissingTitle");
                      return null;
                    },
                  ),
                ],
              ),
            ),
            bottomNavigationBar: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: ElevatedButton(
                      onPressed: () => _onModalDone(),
                      child: Text("创建"),
                    ),
                  ),
                  SizedBox(width: 5),
                  Expanded(
                    flex: 1,
                    child: ElevatedButton(
                      onPressed: () => _onModalDone(use: true),
                      child: Text("创建并使用"),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  /// 删除配置
  void _deleteMapConfig() {
    App.provider.ofCalc(context).deleteCustomMapCompilation();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CalcProvider>(builder: (context, calcData, widget) {
      return Scaffold(
        appBar: AppBar(
          title: Text(FlutterI18n.translate(context, "calculatingFunction.title")),
          actions: [
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
            PopupMenuButton(
              icon: const Icon(Icons.more_horiz),
              itemBuilder: (itemBuilder) => <PopupMenuEntry>[
                PopupMenuItem(
                  child: Wrap(
                    spacing: 5,
                    children: [
                      const Icon(Icons.add),
                      Text(FlutterI18n.translate(context, "calculatingFunction.createConfiguration")),
                    ],
                  ),
                  onTap: () => _openAddConfigModal(calcData),
                ),
                const PopupMenuDivider(),
                PopupMenuItem(
                  child: Wrap(
                    spacing: 5,
                    children: [
                      const Icon(Icons.delete),
                      Text(FlutterI18n.translate(context, "calculatingFunction.deleteConfiguration")),
                    ],
                  ),
                  onTap: () => _deleteMapConfig(),
                ),
              ],
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
