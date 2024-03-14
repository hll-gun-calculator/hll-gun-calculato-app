import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:hll_gun_calculator/data/HomeApp.dart';
import 'package:hll_gun_calculator/provider/home_app_provider.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../constants/app.dart';

class HomeAppConfigPage extends StatefulWidget {
  const HomeAppConfigPage({super.key});

  @override
  State<HomeAppConfigPage> createState() => _HomeAppConfigPageState();
}

class _HomeAppConfigPageState extends State<HomeAppConfigPage> {
  List<HomeAppData> activeList = [];

  @override
  void initState() {
    activeList = App.provider.ofHomeApp(context).activeList;

    super.initState();
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      /// 按照拖拽排序的结果重新排序数据源，并重新渲染
      var item = activeList.removeAt(oldIndex);
      if (newIndex > oldIndex) {
        activeList.insert(newIndex - 1, item);
      } else {
        activeList.insert(newIndex, item);
      }

      App.provider.ofHomeApp(context).activeList = activeList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeAppProvider>(builder: (context, homeAppData, widget) {
      return Scaffold(
        appBar: AppBar(),
        body: Column(
          children: [
            Expanded(
              flex: 1,
              child: ReorderableListView(
                itemExtent: 70,
                shrinkWrap: true,
                onReorder: _onReorder,
                buildDefaultDragHandles: false,
                footer: Column(
                  children: [
                    const Divider(),
                    ...homeAppData.unactivatedList.map((e) {
                      return ListTile(
                        leading: e.icon,
                        title: Text(FlutterI18n.translate(context, "${e.name}.title")),
                        subtitle: Text(FlutterI18n.translate(context, "${e.name}.describe")),
                        trailing: IconButton.filledTonal(
                          onPressed: () {
                            homeAppData.add(e);
                          },
                          icon: const Icon(Icons.add),
                        ),
                      );
                    }).toList()
                  ],
                ),
                proxyDecorator: (Widget child, int index, Animation<double> animation) {
                  return Material(
                    child: Container(
                      color: Theme.of(context).colorScheme.primary.withOpacity(.5),
                      child: child,
                    ),
                  );
                },
                children: [
                  for (int index = 0; index < activeList.length; index++)
                    ReorderableDragStartListener(
                      key: ValueKey(const Uuid().v4()),
                      index: index,
                      child: ListTile(
                        leading: activeList[index].icon,
                        title: Text(FlutterI18n.translate(context, "${activeList[index].name}.title")),
                        subtitle: Text(FlutterI18n.translate(context, "${activeList[index].name}.describe")),
                        trailing: activeList.length > 1
                            ? IconButton.filledTonal(
                                onPressed: () {
                                  homeAppData.remove(activeList[index]);
                                },
                                icon: const Icon(Icons.delete_outline),
                              )
                            : null,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}
