import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
              actions: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      App.provider.ofMap(context).deleteMapCompilation(i);
                    });
                  },
                  icon: Icon(Icons.delete),
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

  @override
  void initState() {
    selectMapCompilation = App.provider.ofMap(context).currentMapCompilation;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MapProvider>(
      builder: (context, data, widget) {
        return Scaffold(
          appBar: AppBar(
            actions: [
              IconButton(
                onPressed: () {
                  App.provider.ofMap(context).currentMapCompilation = selectMapCompilation;
                },
                icon: Icon(Icons.done),
              ),
            ],
          ),
          body: ListView(
            children: data.list.map((i) {
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
