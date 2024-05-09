/// 清理数据

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '/utils/index.dart';
import '/component/_empty/index.dart';

class DestockPage extends StatefulWidget {
  const DestockPage({Key? key}) : super(key: key);

  @override
  _DestockPageState createState() => _DestockPageState();
}

class _DestockPageState extends State<DestockPage> {
  final FileManagement _fileManagement = FileManagement();

  String destockEnvValue = "all";

  String destockByteValue = "0";

  String destockKeyValue = "";

  final DestockStatus _destockStatus = DestockStatus(list: []);

  Storage storage = Storage();

  bool selectAll = false;

  @override
  void initState() {
    super.initState();

    _getLocalAll();
  }

  /// [Event]
  /// 获取所有持久数据
  Future _getLocalAll() async {
    List<DestockItemData> list = [];

    storage.getAll().then((storageAll) {
      storageAll.forEach((i) {
        DestockItemData destockItemData = DestockItemData();
        destockItemData.setName(i["key"]);
        destockItemData.setValue(i["value"]);
        list.add(destockItemData);
      });

      setState(() {
        _destockStatus.list = list;
      });
    });
  }

  /// [Event]
  /// 删除记录
  _removeLocal(DestockItemData e) async {
    String key = e.fullName.split(":")[1];
    await storage.remove(key);
    _getLocalAll();
  }

  /// [Event]
  /// 删除勾选记录
  _removeSelectLocal() {
    // 全选
    if (_destockStatus.list!.length == _destockStatus.list!.where((element) => element.check).length) _removeAllLocal();

    // 单独
    for (var i in _destockStatus.list!) {
      setState(() {
        if (i.check) _removeLocal(i);
      });
    }

    _getLocalAll();
  }

  /// [Event]
  /// 删除所有
  _removeAllLocal() {
    storage.removeAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.restart_alt_outlined),
            onPressed: () => _getLocalAll(),
          ),
          if (_destockStatus.list!.where((i) => i.check).isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _removeSelectLocal(),
            ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 0),
            child: Row(
              children: [
                Checkbox(
                  value: selectAll,
                  onChanged: (value) {
                    setState(() {
                      selectAll = value!;
                      for (var i in _destockStatus.list!) {
                        i.check = value;
                      }
                    });
                  },
                ),
                const SizedBox(width: 5, child: VerticalDivider()),
                Flexible(
                  flex: 1,
                  child: DropdownButton(
                    isExpanded: true,
                    dropdownColor: Theme.of(context).bottomAppBarTheme.color,
                    style: Theme.of(context).dropdownMenuTheme.textStyle,
                    onChanged: (value) {
                      setState(() {
                        destockEnvValue = value.toString();
                      });
                    },
                    value: destockEnvValue,
                    items: ['all', 'development', 'production'].map<DropdownMenuItem<String>>((i) {
                      return DropdownMenuItem(
                        value: i.toString(),
                        child: Text(i.toString()),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(width: 10, child: VerticalDivider()),
                Flexible(
                  flex: 1,
                  child: DropdownButton(
                    isExpanded: true,
                    dropdownColor: Theme.of(context).bottomAppBarTheme.color,
                    style: Theme.of(context).dropdownMenuTheme.textStyle,
                    onChanged: (value) {
                      setState(() {
                        destockByteValue = value.toString();
                      });
                    },
                    value: destockByteValue,
                    items: [0, 10.0, 600.0, 1000.0].map<DropdownMenuItem<String>>((i) {
                      return DropdownMenuItem(
                        value: i.toString(),
                        child: Text(_fileManagement.onUnitConversion(i).toString()),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(width: 10, child: VerticalDivider()),
                Flexible(
                  flex: 2,
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: "input key",
                      icon: Icon(Icons.search_rounded),
                      contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                    ),
                    onChanged: (value) {
                      setState(() {
                        destockKeyValue = value;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          if (_destockStatus.list!.isNotEmpty)
            Flexible(
              flex: 1,
              child: ListView(
                children: _destockStatus.list!
                    .where((element) {
                      if (destockByteValue == '0') return true;
                      return destockByteValue.isNotEmpty && double.parse(destockByteValue) > element.value.toString().length;
                    })
                    .where((element) {
                      if (destockKeyValue.isEmpty) return true;
                      return destockKeyValue.isNotEmpty && element.key!.contains(destockKeyValue);
                    })
                    .where((element) => destockEnvValue == 'all' ? true : destockEnvValue.isNotEmpty && element.env!.contains(destockEnvValue))
                    .map((e) {
                      return Column(
                        children: [
                          Row(
                            children: [
                              Checkbox(
                                value: e.check,
                                onChanged: (value) {
                                  setState(() {
                                    e.check = value!;
                                  });
                                },
                              ),
                              Expanded(
                                flex: 1,
                                child: SelectionArea(
                                  child: ListTile(
                                    title: Text("${e.key}"),
                                    subtitle: Text(e.fullName),
                                  ),
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.symmetric(vertical: 5),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    ClipPath(
                                      child: Text(e.byes),
                                    ),
                                    const SizedBox(height: 5),
                                    ClipPath(
                                      child: Text("${e.env}"),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 5),
                              TextButton(
                                onPressed: () => _removeLocal(e),
                                child: const Icon(Icons.delete),
                              ),
                              const SizedBox(width: 5),
                            ],
                          ),
                          const Divider(height: 1),
                        ],
                      );
                    })
                    .toList(),
              ),
            )
          else
            const Expanded(
              flex: 1,
              child: EmptyWidget(),
            )
        ],
      ),
    );
  }
}

class DestockStatus {
  List<DestockItemData>? list;

  DestockStatus({this.list});
}

class DestockItemData {
  final FileManagement _fileManagement = FileManagement();

  bool check;
  String? env;
  String? key;
  dynamic value;
  String byes;
  String fullName = "";

  DestockItemData({
    this.check = false,
    this.env,
    this.key,
    this.value,
    this.byes = "-",
  });

  setName(String value) {
    List<String> a = value.split(":");
    List envAndAppName = a[0].split(".");
    String key = a[1];

    this.fullName = value;
    this.env = envAndAppName[0];
    this.key = key.replaceAll(".", " ").toUpperCase();
  }

  setValue(dynamic value) {
    this.value = value;
    this.byes = _fileManagement.onUnitConversion(this.value.toString().length);
  }
}
