import 'package:flutter/material.dart';

import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:provider/provider.dart';

import '/constants/app.dart';
import '/data/HomeApp.dart';
import '/provider/home_app_provider.dart';

class GuideHomeAppSore extends StatefulWidget {
  const GuideHomeAppSore({super.key});

  @override
  State<GuideHomeAppSore> createState() => _GuideHomeAppSoreState();
}

class _GuideHomeAppSoreState extends State<GuideHomeAppSore> {
  List<HomeAppData> activeList = [];

  @override
  void initState() {
    activeList = App.provider.ofHomeApp(context).activeList;
    super.initState();
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      var item = activeList.removeAt(oldIndex);
      if (newIndex > oldIndex) {
        activeList.insert(newIndex - 1, item);
      } else {
        activeList.insert(newIndex, item);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeAppProvider>(builder: (context, homeAppData, widget) {
      return ReorderableListView(
        itemExtent: 70,
        onReorder: _onReorder,
        buildDefaultDragHandles: false,
        proxyDecorator: (Widget child, int index, Animation<double> animation) {
          return Material(
            child: Container(
              color: Theme.of(context).colorScheme.primary.withOpacity(.5),
              child: child,
            ),
          );
        },
        header: const SafeArea(
          child: Column(
            children: [
              ListTile(
                title: Text(
                  "面板应用",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                  ),
                ),
                subtitle: Text("勾选你需要的面板或排行，它们会在应用首页等着你"),
              ),
              Divider(),
            ],
          ),
        ),
        footer: Column(
          children: [
            const Divider(),
            ...homeAppData.unactivatedList.map((e) {
              return ListTile(
                leading: e.icon,
                title: Text(FlutterI18n.translate(context, "${e.name}.title")),
                subtitle: Text(FlutterI18n.translate(context, "${e.name}.describe")),
                trailing: IconButton.filledTonal(
                  onPressed: homeAppData.activeList.length <= homeAppData.appMaxLength ? () => homeAppData.add(e) : null,
                  icon: const Icon(Icons.add),
                ),
              );
            }).toList()
          ],
        ),
        children: [
          for (int index = 0; index < activeList.length; index++)
            ReorderableDragStartListener(
              key: ValueKey(activeList[index].name),
              index: index,
              child: ListTile(
                leading: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const Icon(Icons.dehaze_sharp),
                    Container(
                      width: 1,
                      height: 35,
                      margin: const EdgeInsets.symmetric(horizontal: 15),
                      color: Theme.of(context).dividerTheme.color,
                    ),
                    activeList[index].activeIcon,
                  ],
                ),
                title: Text(FlutterI18n.translate(context, "${activeList[index].name}.title")),
                subtitle: Text(FlutterI18n.translate(context, "${activeList[index].name}.describe")),
                trailing: IconButton.filledTonal(
                  onPressed: homeAppData.activeList.length > homeAppData.appMinLength ? () => homeAppData.remove(activeList[index]) : null,
                  icon: const Icon(Icons.delete_outline),
                ),
              ),
            ),
        ],
      );
    });
  }
}

class ReorderableListViewDemo extends StatefulWidget {
  const ReorderableListViewDemo({Key? key}) : super(key: key);

  @override
  _ReorderableListViewDemoState createState() => _ReorderableListViewDemoState();
}

class _ReorderableListViewDemoState extends State<ReorderableListViewDemo> {
  List<String> _dataList = [];

  @override
  void initState() {
    super.initState();
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      /// 按照拖拽排序的结果重新排序数据源，并重新渲染
      var item = _dataList.removeAt(oldIndex);
      if (newIndex > oldIndex) {
        _dataList.insert(newIndex - 1, item);
      } else {
        _dataList.insert(newIndex, item);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("title"),
      ),
      backgroundColor: Colors.orange,
      body: Column(
        children: [
          /// 本例用于演示如何自定义拖拽行为，以及如何自定义拖拽中的项的样式
          /// 默认 android/ios 长按项后可拖拽，本例可以实现 android/ios 点击项后可拖拽
          Expanded(
            child: ReorderableListView(
              itemExtent: 40,
              onReorder: _onReorder,

              /// 禁用默认的拖拽行为
              buildDefaultDragHandles: false,

              /// 构造 ReorderableListView 中的每一项，并自定义其拖拽行为
              children: [
                for (int index = 0; index < _dataList.length; index++)

                  /// ReorderableDelayedDragStartListener - 长按项后即可拖拽
                  /// ReorderableDragStartListener - 点击项后即可拖拽
                  ReorderableDragStartListener(
                    key: ValueKey(_dataList[index]),
                    index: index,
                    child: Container(
                      alignment: Alignment.center,
                      margin: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.blue,
                      ),
                      child: MyTextSmall(_dataList[index]),
                    ),
                  ),
              ],

              /// 用于定义拖拽中的项的样式
              ///   child - 拖拽中的项
              ///   index - 拖拽中的项的索引位置
              proxyDecorator: (Widget child, int index, Animation<double> animation) {
                return Material(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.red,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(5),
                      child: child,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class MyText extends StatefulWidget {
  const MyText(String title, {super.key});

  @override
  State<MyText> createState() => _MyTextState();
}

class _MyTextState extends State<MyText> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class MyTextSmall extends StatefulWidget {
  const MyTextSmall(String title, {super.key});

  @override
  State<MyTextSmall> createState() => _MyTextSmallState();
}

class _MyTextSmallState extends State<MyTextSmall> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
