import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:provider/provider.dart';

import '/pages/index/calc.dart';
import '/pages/index/gunComparisonTable.dart';
import '/utils/index.dart';
import '/provider/history_provider.dart';
import '/constants/config.dart';
import '/provider/package_provider.dart';

import 'landingTimer.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> navs = [
    {
      "name": "gunCalc",
      "icon": const Icon(Icons.calculate_outlined, size: 30),
      "activeIcon": const Icon(Icons.calculate, size: 30),
    },
    {
      "name": "landingTimer",
      "icon": const Icon(Icons.timer_outlined, size: 30),
      "activeIcon": const Icon(Icons.timer, size: 30),
    },
    {
      "name": "gunComparisonTable",
      "icon": const Icon(Icons.table_chart_outlined, size: 30),
      "activeIcon": const Icon(Icons.table_chart, size: 30),
    },
  ];

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
              appBar: HomeAppBar(
                contentHeight: MediaQuery.of(context).size.width < AppSize.kRang ? kToolbarHeight : .0,
                tabIndex: tabIndex,
              ),
              drawer: Drawer(
                backgroundColor: Theme.of(context).canvasColor,
                child: SafeArea(
                  maintainBottomViewPadding: true,
                  child: Column(
                    children: [
                      Expanded(
                        flex: 1,
                        child: ListView(
                          padding: EdgeInsets.zero,
                          children: [
                            DrawerHeader(
                              curve: Curves.bounceIn,
                              child: Title(
                                color: Colors.black,
                                child: Text(
                                  packageData.package!.appName.toString(),
                                  style: TextStyle(
                                    fontSize: Theme.of(context).appBarTheme.titleTextStyle?.fontSize ?? 20,
                                  ),
                                ),
                              ),
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
                        trailing: Text(packageData.currentVersion),
                        onTap: () {
                          _openVersion();
                        },
                      ),
                    ],
                  ),
                ),
              ),
              body: HomeBody(
                tabIndex: tabIndex,
                tabController: _tabController,
                navs: navs,
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

class HomeAppBar extends StatefulWidget implements PreferredSizeWidget {
  final int tabIndex;
  late double contentHeight;

  HomeAppBar({
    required this.tabIndex,
    this.contentHeight = kToolbarHeight,
  });

  @override
  State<HomeAppBar> createState() => _HomeAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(contentHeight);
}

class _HomeAppBarState extends State<HomeAppBar> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
      if (constraints.maxWidth < AppSize.kRang) {
        widget.contentHeight = kToolbarHeight;

        return AppBar(
          forceMaterialTransparency: true,
          flexibleSpace: FlexibleSpaceBar(
            background: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: const SizedBox(),
            ),
          ),
          title: Text(FlutterI18n.translate(context, "${['gunCalc', 'landingTimer', 'gunComparisonTable'][widget.tabIndex]}.title")),
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
        );
      }

      widget.contentHeight = 0.0;

      return PreferredSize(
        preferredSize: const Size(0.0, 0.0),
        child: Container( ),
      );
    });
  }
}

class HomeBody extends StatefulWidget {
  final List navs;
  final int tabIndex;
  final TabController tabController;

  HomeBody({
    required this.navs,
    required this.tabIndex,
    required this.tabController,
  });

  @override
  State<HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<HomeBody> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
      return Center(
        child: OverflowBox(
          maxWidth: constraints.maxWidth > AppSize.kRang ? double.parse(AppSize.kRang.toString()) : null,
          child: Container(
            transformAlignment: Alignment.center,
            constraints: BoxConstraints(
              maxWidth: double.parse(AppSize.kRang.toString()),
              minWidth: 100,
            ),
            child: Row(
              children: [
                if (constraints.maxWidth >= AppSize.kRang)
                  NavigationRail(
                    onDestinationSelected: (value) {
                      setState(() {
                        widget.tabController.index = value;
                      });
                    },
                    leading: const DrawerButton(),
                    labelType: NavigationRailLabelType.all,
                    backgroundColor: Theme.of(context).bottomAppBarTheme.color,
                    destinations: widget.navs.map((nav) {
                      return NavigationRailDestination(
                        icon: nav!["icon"],
                        selectedIcon: nav!["activeIcon"],
                        label: Text(FlutterI18n.translate(context, "${nav["name"]}.title")),
                      );
                    }).toList(),
                    selectedIndex: widget.tabIndex,
                  ),
                Expanded(
                  flex: 1,
                  child: TabBarView(
                    controller: widget.tabController,
                    children: const [
                      /// 计算机
                      calcPage(),

                      /// 落地时间计算
                      LandingTimerPage(),

                      /// 火炮表
                      GunComparisonTablePage(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
