import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/constants/api.dart';
import '/constants/app.dart';
import '/provider/map_provider.dart';
import '/data/index.dart';
import '/utils/index.dart';

class GuideMapPackageManagement extends StatefulWidget {
  const GuideMapPackageManagement({super.key});

  @override
  State<GuideMapPackageManagement> createState() => _GuideMapPackageManagementState();
}

class _GuideMapPackageManagementState extends State<GuideMapPackageManagement> {
  late GuideRecommendedMap guideRecommendedMap = GuideRecommendedMap();

  bool load = false;

  @override
  void initState() {
    _getRecommendedList();
    super.initState();
  }

  /// 获取推荐列表
  void _getRecommendedList() async {
    GuideRecommendedCalcFunction;

    setState(() {
      load = true;
    });

    Response result = await Http.request(
      "config/map/recommendeds.json",
      httpDioValue: "app_web_site",
      method: Http.GET,
    );

    if (result.data is Map && result.data.toString().isNotEmpty) {
      guideRecommendedMap = GuideRecommendedMap.fromJson(result.data);
    }

    setState(() {
      load = false;
    });
  }

  /// 下载配置
  Future<MapCompilation> _downloadConfig(GuideRecommendedBaseItem guideRecommendedBaseItem) async {
    List requestList = [];

    setState(() {
      guideRecommendedBaseItem.load = true;
    });

    for (var i in guideRecommendedBaseItem.updataFunction) {
      Response result = await Http.request(i.path, method: Http.GET, httpDioType: HttpDioType.none);
      if (result.data is Map && Map.from(result.data).isNotEmpty) {
        requestList.add(result.data);
      }
    }

    // 下载失败或无
    if (requestList.isEmpty) return MapCompilation.empty();

    MapCompilation newMapCompilation = MapCompilation.fromJson(requestList.first);
    newMapCompilation.type = MapCompilationType.Custom;
    App.provider.ofMap(context).addCustomConfig(title: newMapCompilation.name, data: newMapCompilation.toJson());

    setState(() {
      guideRecommendedBaseItem.load = false;
    });

    return newMapCompilation;
  }

  /// 下载并使用
  void _downloadAndUse(GuideRecommendedBaseItem guideRecommendedBaseItem) async {
    MapCompilation newMapCompilation = await _downloadConfig(guideRecommendedBaseItem);
    App.provider.ofMap(context).currentMapCompilationName = newMapCompilation.name;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MapProvider>(
      builder: (context, mapData, widget) {
        return ListView(
          children: [
            const ListTile(
              title: Text(
                "地图包",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                ),
              ),
              subtitle: Text("作为’地图测量‘所加载地图数据，这包含地图本身、额外图层、坐标"),
            ),
            ListTile(
              title: Text(mapData.currentMapCompilationName),
              subtitle: const Text("当前选择"),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                App.url.opEnPage(context, "/setting/mapPackage");
              },
            ),
            const Divider(),
            ListTile(
              leading: RawChip(
                label: const Text("推荐"),
                color: MaterialStatePropertyAll(Theme.of(context).colorScheme.primary.withOpacity(.2)),
              ),
              title: Text("来自第三方"),
              subtitle: Text("我们陈列出一些社区提供’地图包‘选择"),
              trailing: Icon(Icons.open_in_new),
              onTap: () {
                App.url.onPeUrl("${Config.apis["app_web_site"]!.url}/page/map/mapRecommendedList.html");
              },
            ),
            if (load)
              Center(
                child: Container(
                  width: 50,
                  height: 50,
                  margin: const EdgeInsets.symmetric(vertical: 50),
                  child: const CircularProgressIndicator(),
                ),
              ),
            ...guideRecommendedMap.child.map((e) {
              return ListTile(
                title: Text(e.name),
                trailing: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (e.load)
                      Container(
                        width: 18,
                        height: 18,
                        margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 15),
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    else if (!e.load && mapData.list.where((element) => element.name == e.name).isEmpty)
                      IconButton(
                        onPressed: () => _downloadConfig(e),
                        icon: const Icon(Icons.downloading),
                      )
                    else if (!e.load && mapData.list.where((element) => element.name == e.name).isNotEmpty)
                      const IconButton(
                        onPressed: null,
                        icon: Icon(Icons.done),
                      ),
                    if (!e.load && mapData.list.where((i) => i.name == e.name).isEmpty)
                      TextButton.icon(
                      onPressed: () => _downloadAndUse(e),
                      icon: const Icon(Icons.add_circle_outline),
                      label: const Text("添加并作为默认"),
                    )
                  ],
                ),
              );
            }).toList()
          ],
        );
      },
    );
  }
}
