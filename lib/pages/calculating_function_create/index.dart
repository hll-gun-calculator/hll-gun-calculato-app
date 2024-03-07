import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hll_gun_calculator/utils/index.dart';
import 'package:uuid/uuid.dart';

import '../../component/_time/index.dart';
import '../../data/index.dart';

class CalculatingFunctionChildTextController extends CalculatingFunction {
  late TextEditingController maximumRangeController = TextEditingController(text: "");
  late TextEditingController minimumRangeController = TextEditingController(text: "");
  late List<TextEditingController> envsController = [];
  late TextEditingController funController = TextEditingController(text: "");

  late ValueNotifier<Factions> faction = ValueNotifier<Factions>(Factions.None);
  late num maximumRange = 1600;
  late num minimumRange = 100;
  late List<CalculatingFunctionEnvController> envs = [];
  late String fun = "";

  @override
  late Map<String, dynamic>? child = {};

  String factionName = "";

  CalculatingFunctionChildTextController({
    required this.faction,
    required this.maximumRange,
    required this.minimumRange,
    required this.envs,
    required this.fun,
  }) {
    factionName = faction.value.value;
    maximumRangeController.text = maximumRange.toString();
    minimumRangeController.text = minimumRange.toString();
    funController.text = fun;

    // 初始
    Map envs = {};
    for (final map in this.envs.map((e) => e.toJson)) {
      map.forEach((key, value) {
        envs[key] = value;
      });
    }
    child!.addAll({
      factionName: {
        'maximumRange': maximumRangeController.text,
        'minimumRange': minimumRangeController.text,
        'envs': envs,
        'fun': funController.text,
      },
    });

    // 变动
    faction.addListener(() {
      String newFaction = faction.value.value;
      // 当阵营配置内没有，创建新的Map
      child![newFaction] = child![factionName];
      child!.removeWhere((key, value) => key == factionName);
      factionName = newFaction;
    });
    maximumRangeController.addListener(() {
      child![factionName]['maximumRange'] = maximumRangeController.text;
    });
    minimumRangeController.addListener(() {
      child![factionName]['minimumRange'] = minimumRangeController.text;
    });
    funController.addListener(() {
      child![factionName]['fun'] = funController.text;
    });
  }

  /// 添加变量
  envAdd(String key, dynamic value) {
    envs.add(CalculatingFunctionEnvController(key: key, value: value));
  }
}

class CalculatingFunctionEnvController {
  late TextEditingController keyController = TextEditingController(text: "");
  late TextEditingController valueController = TextEditingController(text: "");

  String key;
  dynamic value;

  CalculatingFunctionEnvController({
    required this.key,
    this.value,
  }) {
    keyController.text = key.toString();
    valueController.text = value.toString();

    keyController.addListener(() {
      key = keyController.text;
    });
    valueController.addListener(() {
      value = valueController.text;
    });
  }

  Map get toJson => {key: value};
}

class CalculatingFunctionCreatePage extends StatefulWidget {
  const CalculatingFunctionCreatePage({super.key});

  @override
  State<CalculatingFunctionCreatePage> createState() => _calculatingFunctionCreatePageState();
}

class _calculatingFunctionCreatePageState extends State<CalculatingFunctionCreatePage> {
  CalcUtil calcUtil = CalcUtil();

  TextEditingController nameController = TextEditingController(text: "");
  TextEditingController versionController = TextEditingController(text: "");
  TextEditingController websiteController = TextEditingController(text: "");
  TextEditingController authorController = TextEditingController(text: "");
  List<CalculatingFunctionChildTextController> child = [];

  /// 执行测试结果
  CalcResult _runTestResult(CalculatingFunctionChildTextController e, inputValue) {
    CalcResult calcResult = calcUtil.on(
      inputFactions: e.faction.value,
      inputValue: inputValue,
      calculatingFunctionInfo: CalculatingFunction(
        child: e.toJson()["child"],
      ),
    );

    if (calcResult.result!.code != 0) {
      Fluttertoast.showToast(msg: "${calcResult.result!.message!} (${calcResult.result!.code})");
    } else {
      Fluttertoast.showToast(msg: "${calcResult.result!.message!}");
    }

    return calcResult;
  }

  /// 打开Modal测试
  void _runTestModal(CalculatingFunctionChildTextController e) {
    TextEditingController inputValueController = TextEditingController(text: "10");
    List<CalcResult> results = []; // 结果列表

    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, modalSetState) {
          return Scaffold(
            appBar: AppBar(
              leading: const CloseButton(),
              title: Text(
                FlutterI18n.translate(context, "basic.factions.${e.faction.value.value}"),
              ),
              centerTitle: true,
              actions: [
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      results.add(_runTestResult(e, inputValueController.text));
                    });
                    modalSetState(() {});
                  },
                  icon: const Icon(Icons.play_arrow),
                  label: const Text("测试"),
                ),
              ],
            ),
            body: Scrollbar(
              child: ListView(
                children: [
                  TextField(
                    decoration: const InputDecoration(
                      hintText: "0",
                      contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                      label: Text("测试值"),
                    ),
                    controller: inputValueController,
                  ),
                  const Divider(),
                  Column(
                    children: results.map((i) {
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
                                    FlutterI18n.translate(context, "basic.factions.${i.inputFactions.value}"),
                                    style: const TextStyle(fontWeight: FontWeight.normal),
                                  ),
                                  TimeWidget(data: i.creationTime.toString()),
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
                                      i.inputValue,
                                      style: const TextStyle(
                                        fontSize: 20,
                                      ),
                                    ),
                                    const Icon(Icons.chevron_right),
                                    Text(
                                      i.outputValue.toString(),
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
                            if (i.result!.code != 0) Text(i.result!.message.toString()),
                          ],
                        ),
                      );
                    }).toList(),
                  )
                ],
              ),
            ),
          );
        });
      },
    );
  }

  /// 添加阵营配置
  void _addChildConfig() {
    setState(() {
      child.add(
        CalculatingFunctionChildTextController(
          faction: ValueNotifier<Factions>(Factions.None),
          maximumRange: 1600,
          minimumRange: 100,
          envs: [
            CalculatingFunctionEnvController(key: "a", value: 1),
            CalculatingFunctionEnvController(key: "b", value: 2),
          ],
          fun: "({a}+{b})/{inputValue}",
        ),
      );
    });
  }

  Map _getForm() {
    Map child = Map.fromIterable(this.child, key: (v) => v.faction.value.value, value: (v) => v.toJson()["child"]);
    return {
      "name": nameController.text,
      "version": versionController.text,
      "website": websiteController.text,
      "author": authorController.text,
      "child": child,
    };
  }

  String get valueAsString {
    return jsonEncode(_getForm());
  }

  Map get valueAsMap => _getForm();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("创建函数"),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pop(context, valueAsMap);
            },
            icon: const Icon(
              Icons.done,
            ),
          )
        ],
      ),
      body: Scrollbar(
        child: ListView(
          children: [
            /// 基本信息
            TextField(
              decoration: const InputDecoration(
                hintText: "",
                contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                label: Text("名称"),
              ),
              controller: nameController,
            ),
            TextField(
              decoration: const InputDecoration(
                labelText: "版本",
                hintText: "0.0.1",
                contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              ),
              controller: versionController,
            ),
            TextField(
              decoration: const InputDecoration(
                labelText: "网站",
                hintText: "http://",
                contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              ),
              controller: websiteController,
            ),
            TextField(
              decoration: const InputDecoration(
                labelText: "作者",
                hintText: "",
                contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              ),
              controller: authorController,
            ),

            const SizedBox(height: 10),

            /// 阵营配置
            Column(
              children: child.asMap().keys.map((index) {
                CalculatingFunctionChildTextController e = child[index];
                return Card(
                  margin: const EdgeInsets.only(left: 5, right: 5, bottom: 5),
                  semanticContainer: false,
                  borderOnForeground: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton(
                                padding: const EdgeInsets.symmetric(horizontal: 15),
                                value: e.faction.value,
                                isExpanded: true,
                                items: Factions.values.map((factionItem) {
                                  return DropdownMenuItem(
                                    value: factionItem,
                                    child: Text(FlutterI18n.translate(context, "basic.factions.${factionItem.value}")),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    e.faction.value = value as Factions;
                                  });
                                },
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                child.removeAt(index);
                              });
                            },
                            icon: const Icon(Icons.delete),
                          ),
                          IconButton(
                            onPressed: () => _runTestModal(e),
                            icon: const Icon(Icons.play_arrow),
                          ),
                        ],
                      ),

                      const Divider(height: 1, thickness: 1),

                      /// 阵营基本变量
                      Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: TextField(
                              decoration: const InputDecoration(
                                hintText: "0",
                                contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                                label: Text("最小角度"),
                              ),
                              controller: e.minimumRangeController,
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: TextField(
                              decoration: const InputDecoration(
                                hintText: "0",
                                contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                                label: Text("最大角度"),
                              ),
                              controller: e.maximumRangeController,
                            ),
                          ),
                        ],
                      ),

                      /// 阵营变量
                      if (e.envs.isNotEmpty)
                        Column(
                          children: e.envs.asMap().keys.map((envItemIndex) {
                            CalculatingFunctionEnvController envItem = e.envs[envItemIndex];
                            return Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: TextField(
                                    decoration: const InputDecoration(
                                      hintText: "",
                                      contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                                      label: Text("变量名"),
                                    ),
                                    controller: envItem.keyController,
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: TextField(
                                    decoration: const InputDecoration(
                                      hintText: "",
                                      contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                                      label: Text("值"),
                                    ),
                                    controller: envItem.valueController,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      e.envs.removeAt(index);
                                    });
                                  },
                                  icon: const Icon(Icons.delete),
                                ),
                                if (envItemIndex >= e.envs.length - 1)
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        e.envAdd("key", "value");
                                      });
                                    },
                                    icon: const Icon(Icons.add),
                                  ),
                              ],
                            );
                          }).toList(),
                        )
                      else
                        Center(
                          child: TextButton.icon(
                            onPressed: () {
                              setState(() {
                                e.envAdd("key", "value");
                              });
                            },
                            icon: const Icon(Icons.add),
                            label: const Text("创建变量"),
                          ),
                        ),

                      /// 函数
                      TextField(
                        decoration: const InputDecoration(
                          hintText: "",
                          contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                          label: Text("函数"),
                        ),
                        minLines: 2,
                        maxLines: 4,
                        controller: e.funController,
                      ),

                      const Divider(height: 1, thickness: 1),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                        child: Row(
                          children: [
                            Opacity(
                              opacity: .2,
                              child: Text(const Uuid().v4()),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                );
              }).toList(),
            ),

            if (child.isEmpty || child.length < Factions.values.length - 1)
              TextButton.icon(
                onPressed: () {
                  _addChildConfig();
                },
                icon: const Icon(Icons.add),
                label: const Text("创建阵营"),
              ),
          ],
        ),
      ),
    );
  }
}
