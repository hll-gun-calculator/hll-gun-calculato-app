import 'package:flutter/material.dart';
import 'package:hll_gun_calculator/data/index.dart';
import 'package:hll_gun_calculator/provider/map_provider.dart';
import 'package:provider/provider.dart';

import '../../widgets/map_card.dart';

class MapPackagePage extends StatefulWidget {
  const MapPackagePage({super.key});

  @override
  State<MapPackagePage> createState() => _MapPackagePageState();
}

class _MapPackagePageState extends State<MapPackagePage> {
  /// 查看配置详情
  void _openConfigDetail(MapCompilation i) {
    showModalBottomSheet<void>(
      context: context,
      clipBehavior: Clip.hardEdge,
      useRootNavigator: true,
      builder: (context) {
        return StatefulBuilder(builder: (context, modalSetState) {
          return Scaffold(
            appBar: AppBar(
              leading: const CloseButton(),
              actions: [],
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
                const Divider(),
                const ListTile(
                  title: Text("地图"),
                ),
                ...i.data.asMap().entries.map((e) {
                  return MapCardWidget(i: e.value);
                }).toList()
              ],
            ),
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MapProvider>(
      builder: (context, data, widget) {
        return Scaffold(
          appBar: AppBar(),
          body: ListView(
            children: data.list.map((i) {
              return ListTile(
                title: Text(i.name),
                subtitle: Text(i.author),
                trailing: IconButton(
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
