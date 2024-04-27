import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/utils/index.dart';
import '/constants/app.dart';
import '/widgets/map_card.dart';
import '/data/index.dart';
import '/provider/map_provider.dart';

class MapPackagePage extends StatefulWidget {
  const MapPackagePage({super.key});

  @override
  State<MapPackagePage> createState() => _MapPackagePageState();
}

class _MapPackagePageState extends State<MapPackagePage> {
  late MapCompilation selectMapCompilation;

  bool updataLoad = false;

  /// 更新配置
  void _updataConfigDetail(MapCompilation i, modalSetState) async {
    modalSetState(() {
      updataLoad = true;
    });

    List requestList = [];
    for (var i in i.updataFunction) {
      Response result = await Http.request(i.path, method: Http.GET, httpDioType: HttpDioType.none);
      requestList.add(jsonDecode(result.data));
    }

    modalSetState(() {
      MapCompilation newMapCompilation = MapCompilation.fromJson(requestList.first);
      newMapCompilation.type = MapCompilationType.Custom;
      App.provider.ofMap(context).updataCustomConfig(i.id, newMapCompilation);
      updataLoad = false;
    });
  }

  /// 查看配置详情
  void _openConfigDetail(MapCompilation i) {
    showModalBottomSheet<void>(
      context: context,
      clipBehavior: Clip.hardEdge,
      useRootNavigator: true,
      useSafeArea: true,
      builder: (context) {
        return StatefulBuilder(builder: (context, modalSetState) {
          return Scaffold(
            appBar: AppBar(
              leading: const CloseButton(),
              actions: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      App.provider.ofMap(context).deleteMapCompilation(i);
                    });
                  },
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
                  title: const Text("作者"),
                  trailing: Text(i.author),
                ),
                if (i.type == MapCompilationType.Custom && i.updataFunction.isNotEmpty)
                  ListTile(
                    title: const Text("更新"),
                    subtitle: const Text("更新此配置文件"),
                    trailing: updataLoad ? const CircularProgressIndicator() : const Icon(Icons.chevron_right),
                    onTap: () => _updataConfigDetail(i, modalSetState),
                  ),
                const Divider(),
                const ListTile(
                  title: Text("地图"),
                ),
                ...i.data.asMap().entries.map((e) {
                  return MapCardWidget(
                    i: e.value,
                  );
                }).toList()
              ],
            ),
          );
        });
      },
    );
  }

  /// 删除配置
  void _deleteMapConfig() {
    App.provider.ofMap(context).deleteCustomMapCompilation();
  }

  @override
  void initState() {
    selectMapCompilation = App.provider.ofMap(context).currentMapCompilation;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MapProvider>(
      builder: (context, mapData, widget) {
        return Scaffold(
          appBar: AppBar(
            actions: [
              if (mapData.currentMapCompilation.name != selectMapCompilation.name)
                IconButton(
                  onPressed: () {
                    App.provider.ofMap(context).currentMapCompilation = selectMapCompilation;
                  },
                  icon: const Icon(Icons.done),
                ),
              IconButton(
                onPressed: () {
                  _deleteMapConfig();
                },
                icon: Icon(Icons.delete),
              )
            ],
          ),
          body: ListView(
            children: mapData.list.map((i) {
              return RadioListTile(
                value: i.name,
                groupValue: selectMapCompilation.name,
                title: Text(i.name),
                subtitle: Text(i.author),
                onChanged: (String? value) {
                  setState(() {
                    selectMapCompilation = i;
                  });
                },
                secondary: IconButton(
                  onPressed: () => _openConfigDetail(i),
                  icon: const Icon(Icons.more_horiz),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
