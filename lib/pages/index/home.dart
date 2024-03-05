import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:hll_emplacement_calculator/provider/package_provider.dart';
import 'package:provider/provider.dart';

import '/pages/index/calc.dart';
import '/pages/index/gunComparisonTable.dart';
import '/provider/calc_provider.dart';
import '/utils/index.dart';
import '/provider/history_provider.dart';
import 'landingTimer.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  late TabController _tabController;

  int tabIndex = 0;

  UrlUtil urlUtil = UrlUtil();

  @override
  void initState() {
    // 初始tab
    _tabController = TabController(
      vsync: this,
      length: 3,
      initialIndex: 0,
    )..addListener(() {
      setState(() {
        tabIndex = _tabController.index;
      });
    });
    super.initState();
  }

  /// 打开设置
  void _openSetting() async {
    Navigator.pop(context);
    urlUtil.opEnPage(context, "/setting/");
  }

  /// 打开计算历史
  void _openComputingHistory() {
    Navigator.pop(context);
    urlUtil.opEnPage(context, "/computingHistoryPage");
  }

  /// 打开计算配置
  void _openCalculatingFunctionConfig() {
    Navigator.pop(context);
    urlUtil.opEnPage(context, "/calculatingFunctionConfig");
  }

  /// 打开收藏
  void _openCollect() {
    Navigator.pop(context);
    urlUtil.opEnPage(context, "/collect");
  }

  /// 打开收藏
  void _openVersion() {
    Navigator.pop(context);
    urlUtil.opEnPage(context, "/setting/version");
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Consumer2<PackageProvider, HistoryProvider>(
        builder: (consumerContext, packageData, historyData, widget) {
          return DefaultTabController(
            length: 3,
            child: Scaffold(
              appBar: AppBar(
                title: Text(FlutterI18n.translate(context, "${['gunCalc', 'landingTimer','gunComparisonTable'][tabIndex]}.title")),
                leading: Builder(
                  builder: (BuildContext context) {
                    return IconButton(
                      icon: const Icon(Icons.menu),
                      onPressed: () {
                        Scaffold.of(context).openDrawer();
                      },
                      tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
                    );
                  },
                ),
              ),
              drawer: Drawer(
                backgroundColor: Theme.of(context).canvasColor,
                child: Column(
                  children: [
                    Expanded(
                      flex: 1,
                      child: ListView(
                        padding: EdgeInsets.zero,
                        children: [
                          DrawerHeader(
                            child: Text(packageData.package!.appName.toString()),
                          ),
                          ListTile(
                            title: Text(FlutterI18n.translate(context, "history.title")),
                            onTap: () => _openComputingHistory(),
                          ),
                          ListTile(
                            title: Text(FlutterI18n.translate(context, "calculatingFunctionConfig.title")),
                            onTap: () => _openCalculatingFunctionConfig(),
                          ),
                          ListTile(
                            title: Text(FlutterI18n.translate(context, "collect.title")),
                            onTap: () => _openCollect(),
                          ),
                          const Divider(),
                          ListTile(
                            title: const Text('设置'),
                            onTap: () {
                              _openSetting();
                            },
                          ),
                        ],
                      ),
                    ),
                    ListTile(
                      title: const Text('版本'),
                      trailing: const Text('v0.0.1'),
                      onTap: () {
                        _openVersion();
                      },
                    ),
                  ],
                ),
              ),
              body: TabBarView(
                controller: _tabController,
                children: const [
                  /// 计算机
                  calcPage(),

                  /// 落地时间计算
                  LandingTimerPage(),

                  /// 火炮表
                  GunComparisonTablePage(),
                ],
              ),
              bottomSheet: Container(
                margin: const EdgeInsets.only(bottom: 5),
                child: TabPageSelector(
                  controller: _tabController,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
