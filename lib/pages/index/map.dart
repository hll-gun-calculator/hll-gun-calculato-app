import 'dart:async';
import 'dart:math';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '/component/_empty/index.dart';
import '/provider/gun_timer_provider.dart';
import '/provider/map_provider.dart';
import '/utils/map.dart';
import 'package:provider/provider.dart';

import '/component/_color/index.dart';
import '/constants/app.dart';
import '/data/index.dart';
import '/provider/calc_provider.dart';
import '/utils/index.dart';
import '/widgets/map_card.dart';
import '/widgets/wave_border.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _mapPageState();
}

class _mapPageState extends State<MapPage> with AutomaticKeepAliveClientMixin {
  final GlobalKey<MapCoreState> _mapCoreKey = GlobalKey<MapCoreState>();

  I18nUtil i18nUtil = I18nUtil();

  Factions inputFactions = Factions.None;

  bool _lock = false;

  Map<MapIconType, bool> _markerManagementSwitch = {};

  // 火炮下标
  List listTimerIndex = [];

  @override
  void initState() {
    CalculatingFunction currentCalculatingFunction = App.provider.ofCalc(context).currentCalculatingFunction;
    Factions firstName = Factions.None;

    firstName = currentCalculatingFunction.child.keys.first;

    setState(() {
      // 初始所支持的阵营
      if (Factions.values.where((e) => e == firstName).isNotEmpty) inputFactions = Factions.values.where((e) => e == firstName).first;
    });

    // 依照地图火炮创建下标列表
    // 更新id
    listTimerIndex = List.generate(App.provider.ofMap(context).currentMapInfo.gunPositions.length, (index) {
      int gunTimerIndex = 1;
      Gun gunItem = App.provider.ofMap(context).currentMapInfo.gunPositions[index];
      String id = "${gunItem.name}-${gunItem.id}-$gunTimerIndex";

      return {
        'id': id,
        'index': gunTimerIndex,
        'faction': gunItem.factions!.value,
      };
    });

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (mounted) {
        // 地图标记锁定
        _mapCoreKey.currentState!.isLock.addListener(() {
          _lock = _mapCoreKey.currentState!.isLock.value;
        });

        // 图层管理
        _markerManagementSwitch = _mapCoreKey.currentState!.markerManagementSwitch.value;
        _mapCoreKey.currentState!.markerManagementSwitch.addListener(() {
          _markerManagementSwitch = _mapCoreKey.currentState!.markerManagementSwitch.value;
        });
      }
    });
    super.initState();
  }

  /// 切换火炮列表
  /// 重新计算结果
  void _calcResult() {
    _mapCoreKey.currentState!.calc();
  }

  /// 火炮落地时间计时
  void _putGunTimer(gunTimerData, querId, e, id) {
    if (gunTimerData.getItem(querId).isTimerActive) {
      Fluttertoast.showToast(msg: "计时还在继续，需停止后重计时，详情可以前往计时器管理");
      return;
    }
    setState(() {
      Map currerGun = listTimerIndex.where((element) => element["id"] == id).first;

      // 添加
      gunTimerData.add(
        id: currerGun['id'],
        type: LandingType.MapGun,
        isAutoShow: true,
        endCallback: (l) {
          // 添加后更新
          currerGun['index'] = currerGun['index'] = currerGun['index'] + 1;
          currerGun['id'] = "${e.value.name}-${e.value.id}-${currerGun['index']}";
        },
      );
    });
  }

  /// 收藏
  void _collect(Gun gun) {
    App.provider.ofCollect(context).add(gun.result, gun.name);
    Fluttertoast.showToast(msg: "收藏添加");
  }

  /// 选择阵营
  void _openSelectFactions() {
    showModalBottomSheet<void>(
      context: context,
      clipBehavior: Clip.hardEdge,
      useSafeArea: true,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, modalSetState) {
          return Consumer<CalcProvider>(
            builder: (context, calcData, widget) {
              return Scaffold(
                appBar: AppBar(
                  leading: const CloseButton(),
                ),
                body: ListView(
                  children: Factions.values.where((i) => i != Factions.None).map((i) {
                    return ListTile(
                      selected: inputFactions.value == i.value,
                      enabled: calcData.currentCalculatingFunction.hasChildValue(i),
                      title: Text(FlutterI18n.translate(context, "basic.factions.${i.value}")),
                      trailing: Text(calcData.currentCalculatingFunction.hasChildValue(i) ? "" : "不支持"),
                      onTap: () {
                        if (!calcData.currentCalculatingFunction.hasChildValue(i)) {
                          return;
                        }

                        setState(() {
                          inputFactions = i;
                        });
                        modalSetState(() {});

                        Future.delayed(const Duration(milliseconds: 500)).then((value) {
                          Navigator.pop(context);
                        });
                      },
                    );
                  }).toList(),
                ),
              );
            },
          );
        });
      },
    );
  }

  /// 打开地图选择
  void _openMapsModal() {
    TextEditingController mapSearchTextEditingController = TextEditingController();
    MapCompilation currentMapCompilation = App.provider.ofMap(context).currentMapCompilation;
    MapInfo currentMapInfo = App.provider.ofMap(context).currentMapInfo;
    late MapInfo newMapInfo = currentMapInfo;

    showModalBottomSheet<void>(
      context: context,
      clipBehavior: Clip.hardEdge,
      scrollControlDisabledMaxHeightRatio: .8,
      useSafeArea: true,
      builder: (context) {
        return StatefulBuilder(builder: (context, modalSetState) {
          return Scaffold(
            appBar: AppBar(
              leading: const CloseButton(),
              actions: [
                IconButton(
                  onPressed: () {
                    modalSetState(() {
                      if (newMapInfo.name == App.provider.ofMap(context).currentMapInfo) {
                        Fluttertoast.showToast(msg: "请选择一个新地图");
                        return;
                      }
                    });

                    Navigator.of(context).pop();
                    App.provider.ofMap(context).currentMapInfo = newMapInfo;

                    _mapCoreKey.currentState!.unlock();
                    _mapCoreKey.currentState!.setState(() {});
                  },
                  icon: const Icon(Icons.done),
                ),
              ],
            ),
            body: Column(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  child: SearchBar(
                    hintText: FlutterI18n.translate(context, "map.searchMapTip"),
                    elevation: const MaterialStatePropertyAll(0),
                    leading: const Icon(Icons.search),
                    controller: mapSearchTextEditingController,
                  ),
                ),
                ListTile(
                  title: Text(i18nUtil.as(context, currentMapCompilation.name)),
                  subtitle: Text(i18nUtil.as(context, currentMapCompilation.description)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    App.url.opEnPage(context, "/setting/mapPackage");
                  },
                ),
                const Divider(),
                Expanded(
                  flex: 1,
                  child: ListView(
                    children: [
                      if (currentMapCompilation.data.isNotEmpty)
                        ...currentMapCompilation.data.where((i) => i.name.indexOf(mapSearchTextEditingController.text) >= 0).toList().asMap().entries.map((e) {
                          return MapCardWidget(
                            i: e.value,
                            selected: newMapInfo.name,
                            onTap: () {
                              modalSetState(() {
                                newMapInfo = e.value;
                              });
                            },
                          );
                        }).toList()
                      else
                        const EmptyWidget(),
                      const Divider(),
                      Align(
                        child: Text("by ${currentMapCompilation.name}"),
                      ),
                    ],
                  ),
                )
              ],
            ),
          );
        });
      },
    );
  }

  /// 打开图层筛选器
  void _openMarkerModal() {
    bool all = _markerManagementSwitch.values.every((v) => v == true);
    showModalBottomSheet<void>(
      context: context,
      clipBehavior: Clip.hardEdge,
      useSafeArea: true,
      builder: (context) {
        return StatefulBuilder(builder: (context, modalSetState) {
          return Scaffold(
            appBar: AppBar(
              leading: const CloseButton(),
              actions: [
                Switch(
                  value: all,
                  onChanged: (switchValue) {
                    modalSetState(() {
                      all = switchValue;
                      _markerManagementSwitch = _markerManagementSwitch.map((key, value) {
                        _mapCoreKey.currentState!.setMapLayer(key, !value);
                        return MapEntry(key, switchValue);
                      });
                    });
                  },
                ),
                const SizedBox(width: 25),
              ],
            ),
            body: ListView(
              children: [
                ...MapIconType.values.skipWhile((e) => e == MapIconType.None || e == MapIconType.Url || e == MapIconType.Assets).map((e) {
                  return SwitchListTile(
                    value: _markerManagementSwitch[e] ?? false,
                    title: Text(FlutterI18n.translate(context, "map.layers.${e.value}")),
                    subtitle: Text(e.value),
                    secondary: Icon(_markerManagementSwitch[e] ?? false ? Icons.layers : Icons.layers_outlined),
                    onChanged: (value) {
                      modalSetState(() {
                        _markerManagementSwitch[e] = value;
                        _mapCoreKey.currentState!.setMapLayer(e, value);
                        all = _markerManagementSwitch.values.every((v) => v == true);
                      });
                      setState(() {
                        // up widget
                        _markerManagementSwitch;
                      });
                    },
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
  Widget build(BuildContext context) {
    super.build(context);
    return Consumer2<CalcProvider, MapProvider>(
      builder: (context, calcData, mapData, widget) {
        return Column(
          children: [
            Expanded(
              flex: 1,
              child: mapData.hasMapCompilation
                  ? const Center(
                      child: Text("请选择地图合集"),
                    )
                  : Container(
                      color: Theme.of(context).colorScheme.primary.withOpacity(.1),
                      child: MapCore(key: _mapCoreKey, mapProvider: mapData, inputFactions: inputFactions),
                    ),
            ),

            /// tool
            Row(
              children: [
                IconButton(
                  onPressed: () => _openMapsModal(),
                  icon: const Icon(Icons.map),
                ),
                IconButton(
                  onPressed: () => _openMarkerModal(),
                  icon: Icon(_markerManagementSwitch.values.where((v) => v == true).isNotEmpty ? Icons.layers : Icons.layers_outlined),
                ),
                const Expanded(child: SizedBox()),
                IconButton(
                  onPressed: () {
                    _mapCoreKey.currentState!.onResetMapPosition();
                  },
                  icon: const Icon(Icons.restart_alt),
                ),
                // IconButton(
                //   onPressed: () {
                //     _mapCoreKey.currentState!.scale("+");
                //   },
                //   icon: const Icon(Icons.add),
                // ),
                // IconButton(
                //   onPressed: () {
                //     _mapCoreKey.currentState!.scale("-");
                //   },
                //   icon: const Icon(Icons.remove),
                // ),
                if (_lock)
                  IconButton.filled(
                    onPressed: () {
                      _mapCoreKey.currentState!.unlock();
                      setState(() {
                        _lock = false;
                      });
                    },
                    icon: const Icon(Icons.location_off_sharp),
                  ),
              ],
            ),

            const Divider(height: 1, thickness: 1),

            /// 控制器
            Container(
              height: 250,
              color: Theme.of(context).colorScheme.primary.withOpacity(.2),
              padding: const EdgeInsets.only(bottom: 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// 火炮列表
                  Flexible(
                    child: Consumer<GunTimerProvider>(
                      builder: (context, GunTimerProvider gunTimerData, widget) {
                        return MediaQuery.removePadding(
                          context: context,
                          removeTop: true,
                          child: ListView(
                            children: mapData.currentMapInfo.gunPositions.isNotEmpty
                                ? mapData.currentMapInfo.gunPositions.asMap().entries.map((e) {
                                    String id = listTimerIndex[e.key]['id'];
                                    String querId = "$id-${LandingType.MapGun.name}"; // 查询id，与生成的id缺少类型
                                    return Stack(
                                      children: [
                                        // Text(id),
                                        if (gunTimerData.hasItemId(querId))
                                          Positioned.fill(
                                            child: Opacity(
                                              opacity: .3,
                                              child: LinearProgressIndicator(
                                                value: gunTimerData.getItem(querId).countdownTimeSeconds / gunTimerData.getItem(querId).duration.inSeconds * 1,
                                                backgroundColor: Colors.transparent,
                                              ),
                                            ),
                                          ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              margin: const EdgeInsets.only(left: 55, top: 5),
                                              child: Wrap(
                                                spacing: 10,
                                                children: [
                                                  Text(e.value.name),
                                                  Text(FlutterI18n.translate(context, "basic.factions.${e.value.factions!.value}")),
                                                  Text(e.value.direction.name),
                                                ],
                                              ),
                                            ),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  flex: 1,
                                                  child: Row(
                                                    children: [
                                                      Radio(
                                                        value: e.value,
                                                        toggleable: true,
                                                        groupValue: mapData.currentMapGun,
                                                        onChanged: (value) {
                                                          setState(() {
                                                            mapData.currentMapGun = e.value;
                                                          });
                                                          _calcResult();
                                                        },
                                                      ),
                                                      Expanded(
                                                        flex: 1,
                                                        child: Card(
                                                          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 0),
                                                          child: Padding(
                                                            padding: const EdgeInsets.only(right: 10, top: 5, bottom: 5, left: 5),
                                                            child: Row(
                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                              children: [
                                                                Card(
                                                                  color: e.value.name == mapData.currentMapGun.name ? e.value.color : Colors.transparent,
                                                                  margin: EdgeInsets.zero,
                                                                  child: SizedBox(
                                                                    width: 44,
                                                                    height: 44,
                                                                    child: Center(
                                                                      child: Padding(
                                                                        padding: const EdgeInsets.all(10),
                                                                        child: MapUtil().mapInfoMarkerItemAsIcon(MapInfoMarkerItem(iconType: MapIconType.Arty)),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                Text(
                                                                  "${e.value.result?.inputValue ?? 0}",
                                                                  style: const TextStyle(
                                                                    fontSize: 28,
                                                                  ),
                                                                ),
                                                                const Icon(Icons.chevron_right),
                                                                Column(
                                                                  crossAxisAlignment: CrossAxisAlignment.end,
                                                                  children: [
                                                                    Text(
                                                                      "${e.value.result?.outputValue ?? 0}",
                                                                      style: TextStyle(
                                                                        fontSize: 16,
                                                                        color: Theme.of(context).primaryColor,
                                                                      ),
                                                                    ),
                                                                    Text(
                                                                      "${e.value.result?.outputAngle.ceil() ?? 0}",
                                                                      style: const TextStyle(fontSize: 12),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),

                                                IconButton(
                                                  onPressed: () {
                                                    _putGunTimer(gunTimerData, querId, e, id);
                                                  },
                                                  icon: Column(
                                                    children: [
                                                      Stack(
                                                        children: [
                                                          if (gunTimerData.getItem(querId).isTimerActive) const Icon(Icons.timer) else const Icon(Icons.timer_outlined),
                                                        ],
                                                      ),
                                                      if (gunTimerData.getItem(querId).isTimerActive) Text(gunTimerData.getItem(querId).countdownTimeSeconds.toString()) else const Text("0")
                                                    ],
                                                  ),
                                                ),

                                                /// map button
                                                PopupMenuButton(
                                                  icon: Icon(
                                                    Icons.adaptive.more,
                                                    color: Theme.of(context).iconTheme.color,
                                                  ),
                                                  itemBuilder: (context) {
                                                    return <PopupMenuEntry>[
                                                      const PopupMenuItem(
                                                        value: "gunDescription",
                                                        child: Row(
                                                          children: [Icon(Icons.text_fields), Text("火炮描述")],
                                                        ),
                                                      ),
                                                      const PopupMenuDivider(),
                                                      const PopupMenuItem(
                                                        value: "timer",
                                                        child: Row(
                                                          children: [Icon(Icons.timer_outlined), Text("定时器")],
                                                        ),
                                                      ),
                                                      if (e.value.result != null)
                                                        const PopupMenuItem(
                                                          value: "collect",
                                                          child: Row(
                                                            children: [Icon(Icons.star_border), Text("收藏")],
                                                          ),
                                                        )
                                                    ];
                                                  },
                                                  onSelected: (v) {
                                                    switch (v) {
                                                      case "gunDescription":
                                                        _mapCoreKey.currentState!._openGunDetailModal(
                                                          e.value,
                                                          onEvent: (value) => setState(() {
                                                            e.value.color = value;
                                                          }),
                                                        );
                                                        break;
                                                      case "timer":
                                                        _putGunTimer(gunTimerData, querId, e, id);
                                                        break;
                                                      case "collect":
                                                        _collect(e.value);
                                                        break;
                                                    }
                                                  },
                                                ),
                                              ],
                                            ),
                                          ],
                                        )
                                      ],
                                    );
                                  }).toList()
                                : [
                                    const Center(
                                      child: EmptyWidget(),
                                    )
                                  ],
                          ),
                        );
                      },
                    ),
                  ),
                  const Divider(height: 1, thickness: 1),

                  /// 附件选项
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                    child: Row(
                      children: [
                        GestureDetector(
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              child: Wrap(
                                runAlignment: WrapAlignment.center,
                                children: [
                                  Text(FlutterI18n.translate(context, "basic.factions.${inputFactions.value}")),
                                  const Icon(Icons.arrow_drop_down),
                                ],
                              ),
                            ),
                          ),
                          onTap: () => _openSelectFactions(),
                        ),
                        const Expanded(flex: 1, child: SizedBox(width: 5)),
                        GestureDetector(
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              child: Wrap(
                                runAlignment: WrapAlignment.center,
                                children: [
                                  Text(calcData.currentCalculatingFunctionName),
                                  const Icon(Icons.arrow_drop_down),
                                ],
                              ),
                            ),
                          ),
                          onTap: () => {
                            App.url.opEnPage(context, "/calculatingFunctionConfig").then((value) {
                              setState(() {
                                inputFactions = App.provider.ofCalc(context).currentCalculatingFunction.child.keys.first;
                              });
                            }),
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Container(
              height: MediaQuery.of(context).viewPadding.bottom,
              color: Theme.of(context).primaryColor.withOpacity(.2),
            ),
          ],
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}

const markerSize = 32.0;

class MapCore extends StatefulWidget {
  final MapProvider mapProvider;
  final Factions inputFactions;

  const MapCore({
    super.key,
    required this.mapProvider,
    required this.inputFactions,
  });

  @override
  State<MapCore> createState() => MapCoreState();
}

class MapCoreState extends State<MapCore> {
  final transformation = TransformationController();

  final StreamController<double> stream = StreamController.broadcast();

  final CalcUtil _calcUtil = CalcUtil();

  final I18nUtil i18nUtil = I18nUtil();

  final GlobalKey _mapBoxKey = GlobalKey();

  late MapCompilation mapCompilation;

  double _scale = 1;
  double _scaleMax = 1.1;
  double _scaleMin = .1;

  ValueNotifier<bool> isLock = ValueNotifier(false);

  ValueNotifier<MapGunResult> mapGunResult = ValueNotifier<MapGunResult>(MapGunResult());

  List<MarkerPointItem> marker = [];

  Offset newMarker = const Offset(-1, -1);

  // 地图加载状态
  bool mapLoading = true;

  // 图层管理控制
  ValueNotifier<Map<MapIconType, bool>> markerManagementSwitch = ValueNotifier({
    MapIconType.Arty: true,
    MapIconType.PresupposeArty: true,
    MapIconType.CollectArty: true,
    MapIconType.PlainGrid: false,
    MapIconType.ArtyRadius: false,
    MapIconType.Landmark: true,
  });

  // 地图盒子高度
  double mapBoxHeight = 0;

  @override
  void initState() {
    initMap();
    super.initState();
  }

  /// 初始地图
  initMap() async {
    mapCompilation = widget.mapProvider.currentMapCompilation;

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (mounted) {
        setState(() {
          mapBoxHeight = _mapBoxKey.currentContext?.findRenderObject()!.paintBounds.size.height ?? 0;
        });
        _resetMap();
      }
    });

    transformation.addListener(() {
      stream.sink.add(transformation.value[0]);
    });

    setState(() {
      mapLoading = false;
    });
  }

  /// 地图缩放
  void scale(type) {
    switch (type) {
      case "+":
        setState(() {
          _scale += 0.1;
          var screenCenter = MediaQuery.of(context).size.width / 2;
          transformation.value = Matrix4.identity()
            ..translate(screenCenter, screenCenter)
            ..scale(_scale)
            ..translate(-screenCenter, -screenCenter);
        });

        break;
      case "-":
        setState(() {
          _scale -= 0.1;
          var screenCenter = MediaQuery.of(context).size.width / 2;
          transformation.value = Matrix4.identity()
            ..translate(screenCenter, screenCenter)
            ..scale(_scale)
            ..translate(-screenCenter, -screenCenter);
        });
        break;
    }
  }

  /// 解锁
  void unlock() {
    setState(() {
      isLock.value = false;
      newMarker = const Offset(-1, -1);
    });
  }

  /// 地图坐标重置
  void onResetMapPosition() {
    _resetMap();
    _scale = 1;
  }

  /// 重置地图
  void _resetMap() {
    final size = MediaQuery.of(context).size;
    setState(() {
      // 初始显示地图全貌
      _scale = max(
        size.width / App.provider.ofMap(context).currentMapInfo.size.dx,
        size.height / App.provider.ofMap(context).currentMapInfo.size.dy,
      );
      _scaleMax = _scale + .4;
      _scaleMin = .1;
      transformation.value = Matrix4.identity()
        ..scale(_scale)
        ..translate(
          -(App.provider.ofMap(context).currentMapInfo.size.dx / 2) - -(MediaQuery.of(context).size.width / 2),
          -(mapBoxHeight) - -(kToolbarHeight + kTextTabBarHeight),
        );

      _scale = transformation.value.getMaxScaleOnAxis();
    });
  }

  /// 设置地图图层
  void setMapLayer(MapIconType key, bool value) {
    setState(() {
      markerManagementSwitch.value[key] = value;
    });
  }

  /// 计算结果
  /// 火炮角度、方向
  void calc() {
    if (newMarker.dx < 0 || newMarker.dy < 0) return; // 未选择标记

    // 选中的火炮
    Offset gunPostionSelect = App.provider.ofMap(context).currentMapGun.offset;

    setState(() {
      double distance = (gunPostionSelect - newMarker).distance;
      double gridOnePx = (200 * 10) / App.provider.ofMap(context).currentMapInfo.size.dy;

      // 计算mil
      CalcResult result = _calcUtil.on(
        inputFactions: Factions.America,
        inputValue: (distance * gridOnePx).ceil(),
        calculatingFunctionInfo: App.provider.ofCalc(context).currentCalculatingFunction,
      );

      // 添加计算会话历史
      App.provider.ofHistory(context).add(result);

      // 计算角度
      MapGunResult _mapGunResult = MapGunResult.fromJson(result.toJson());
      _mapGunResult.outputAngle = _calcUtil.onAngle(gunPostionSelect, newMarker).outputAngle;
      _mapGunResult.outputValue = result.outputValue;
      _mapGunResult.inputOffset = gunPostionSelect;
      _mapGunResult.targetOffset = newMarker;
      App.provider.ofMap(context).setCurrentMapGunResult(_mapGunResult);

      isLock.value = true;
    });
  }

  /// 地图标记计算
  void _onPositionCalcResult(dynamic detail) {
    if (isLock.value) return;

    setState(() {
      newMarker = detail.localPosition;

      calc();
    });
  }

  /// 地图标记 擦除选择
  void _onPositionDelete() {
    Navigator.of(context).pop();
    setState(() {
      newMarker = const Offset(-1, -1);
    });
  }

  /// 打开图标信息
  void _openIconModal(MapInfoMarkerItem_Fll iconInfo) {
    showModalBottomSheet<void>(
      context: context,
      clipBehavior: Clip.hardEdge,
      useSafeArea: true,
      builder: (context) {
        return StatefulBuilder(builder: (context, modalSetState) {
          return Scaffold(
            appBar: AppBar(
              leading: const CloseButton(),
              actions: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      newMarker = Offset(iconInfo.x, iconInfo.y);
                      isLock.value = true;
                    });
                    Navigator.of(context).pop();
                  },
                  child: const Text("使用"),
                ),
              ],
            ),
            body: ListView(
              children: [
                ListTile(
                  leading: Card(
                    child: Container(
                      width: 50,
                      height: 50,
                      padding: const EdgeInsets.all(10),
                      child: MapUtil().mapInfoMarkerItem_FllAsIcon(iconInfo),
                    ),
                  ),
                  title: Text(iconInfo.upLevelName),
                  subtitle: Text(iconInfo.name),
                ),
                const Divider(),
                ListTile(
                  title: const Text("x"),
                  trailing: Text("${iconInfo.x}"),
                ),
                ListTile(
                  title: const Text("y"),
                  trailing: Text("${iconInfo.y}"),
                )
              ],
            ),
          );
        });
      },
    );
  }

  /// 打开火炮信息
  void _openGunDetailModal(Gun gunInfo, {Function(Color color)? onEvent}) async {
    Future<void> gunDetailModal = showModalBottomSheet<void>(
      context: context,
      clipBehavior: Clip.hardEdge,
      useSafeArea: true,
      builder: (context) {
        return StatefulBuilder(builder: (context, modalSetState) {
          return Scaffold(
            appBar: AppBar(
              leading: const CloseButton(),
            ),
            body: ListView(
              children: [
                ListTile(
                  leading: Card(
                    color: gunInfo.color,
                    child: Container(
                      width: 50,
                      height: 50,
                      padding: const EdgeInsets.all(10),
                      child: MapUtil().putArtyIcon,
                    ),
                  ),
                  title: Text(i18nUtil.as(context, gunInfo.name)),
                ),
                const Divider(),
                ListTile(
                  title: const Text("火炮描述"),
                  subtitle: Text(i18nUtil.as(context, gunInfo.description)),
                ),
                ListTile(
                  title: const Text("阵营"),
                  subtitle: Text(FlutterI18n.translate(context, "basic.factions.${gunInfo.factions!.value}")),
                ),
                ListTile(
                  title: const Text("坐标"),
                  trailing: Text("x:${gunInfo.offset.dx} y:${gunInfo.offset.dy}"),
                ),
                ListTile(
                  title: const Text("颜色"),
                  trailing: ColorWidget(
                    initializeColor: gunInfo.color,
                    onEvent: (value) => modalSetState(() {
                      gunInfo.color = value;
                    }),
                  ),
                ),
                ListTile(
                  title: const Text("id"),
                  trailing: Text(gunInfo.id),
                ),
              ],
            ),
          );
        });
      },
    );

    gunDetailModal.then((void value) {
      onEvent != null ? onEvent(gunInfo.color) : null;
    });
  }

  /// 打开新坐标详情
  void _openNewGunPointModal() {
    showModalBottomSheet<void>(
      context: context,
      clipBehavior: Clip.hardEdge,
      scrollControlDisabledMaxHeightRatio: .8,
      useSafeArea: true,
      builder: (context) {
        return StatefulBuilder(builder: (context, modalSetState) {
          return Scaffold(
            appBar: AppBar(
              leading: const CloseButton(),
              actions: [
                IconButton(
                  onPressed: () => _onPositionDelete(),
                  icon: const Icon(Icons.delete),
                ),
              ],
            ),
            body: ListView(
              children: [
                ListTile(
                  leading: Card(
                    child: Container(
                      width: 50,
                      height: 50,
                      padding: const EdgeInsets.all(10),
                      child: MapUtil().mapInfoMarkerItemAsIcon(MapInfoMarkerItem(iconType: MapIconType.Arty)),
                    ),
                  ),
                  title: const Text("新标记"),
                ),
                const Divider(),
                const ListTile(
                  title: Text("x"),
                ),
                TextField(
                  readOnly: true,
                  decoration: const InputDecoration(
                    hintText: "0",
                    contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                  ),
                  controller: TextEditingController(text: newMarker.dx.toString()),
                ),
                const ListTile(
                  title: Text("y"),
                ),
                TextField(
                  readOnly: true,
                  decoration: const InputDecoration(
                    hintText: "0",
                    contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                  ),
                  controller: TextEditingController(text: newMarker.dy.toString()),
                ),
                const Divider(),
                ListTile(
                  title: const Text("发射源"),
                  subtitle: const Text("发射火炮信息"),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _openGunDetailModal(
                    App.provider.ofMap(context).currentMapGun,
                    onEvent: (value) {
                      modalSetState(() {});
                    },
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: _mapBoxKey,
      onHorizontalDragUpdate: (details) {
        setState(() {
          transformation.value = transformation.value..translate(details.delta.dx * 3, 0, 0);
        });
      },
      child: InteractiveViewer(
        boundaryMargin: const EdgeInsets.only(),
        transformationController: transformation,
        maxScale: _scaleMax,
        minScale: _scaleMin,
        constrained: false,
        child: Container(
          padding: const EdgeInsets.only(top: kToolbarHeight + 290 + 500, left: 500, right: 500, bottom: 500),
          decoration: const BoxDecoration(
            image: DecorationImage(image: AssetImage("assets/images/maps/map-backdrop.png"), fit: BoxFit.scaleDown, repeat: ImageRepeat.repeat, opacity: .1, scale: .2),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              /// 地图底层
              GestureDetector(
                onTapUp: (detail) => _onPositionCalcResult(detail),
                // onLongPressDown: (LongPressDownDetails detail) => _onPositionCalcResult(detail),
                child: ExtendedImage(
                  image: widget.mapProvider.currentMapInfo.assets!.image!,
                  width: widget.mapProvider.currentMapInfo.size.dx,
                  height: widget.mapProvider.currentMapInfo.size.dy,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                  enableMemoryCache: false,
                  loadStateChanged: (ExtendedImageState state) {
                    switch (state.extendedImageLoadState) {
                      case LoadState.completed:
                        return ExtendedRawImage(
                          image: state.extendedImageInfo?.image,
                        );
                      case LoadState.loading:
                        return const SizedBox();
                      case LoadState.failed:
                      default:
                        return Center(
                          child: Column(
                            children: [
                              const Text("未能加载地图"),
                              Text(state.extendedImageLoadState.name),
                            ],
                          ),
                        );
                    }
                  },
                ),
              ),

              /// 地图图层
              ...widget.mapProvider.currentMapInfo.childs.where((e) {
                // 检查图层管理开关是否开启
                return markerManagementSwitch.value[e.type] == true;
              }).map((e) {
                return GestureDetector(
                  onTapUp: (detail) => _onPositionCalcResult(detail),
                  child: RotatedBox(
                    quarterTurns: e.type == MapIconType.ArtyRadius
                        ? {
                              MapInfoFactionInfoDirection.Left: 0,
                              MapInfoFactionInfoDirection.Top: 1,
                              MapInfoFactionInfoDirection.Right: 2,
                              MapInfoFactionInfoDirection.Bottom: 3,
                            }[App.provider.ofMap(context).currentMapGun.direction] ??
                            0
                        : 0,
                    child: ExtendedImage(
                      image: e.image,
                      width: widget.mapProvider.currentMapInfo.size.dx,
                      height: widget.mapProvider.currentMapInfo.size.dy,
                      fit: BoxFit.contain,
                      enableMemoryCache: false,
                      filterQuality: FilterQuality.high,
                    ),
                  ),
                );
              }).toList(),

              /// 新坐标连线
              if (newMarker.dy >= 0 && newMarker.dx >= 0)
                StreamBuilder(
                  stream: stream.stream,
                  builder: (context, snapshot) {
                    final scale = snapshot.data ?? transformation.value[0];
                    return Consumer<CalcProvider>(builder: (calcContext, calcData, calcWidget) {
                      Factions factions = widget.inputFactions;
                      bool isCalcExceed = (num.parse(widget.mapProvider.currentMapGun.result!.inputValue) > calcData.currentCalculatingFunction.child[factions]!.maximumRange) || (num.parse(widget.mapProvider.currentMapGun.result!.inputValue) < calcData.currentCalculatingFunction.child[factions]!.minimumRange);

                      return LineWidget(
                        start: widget.mapProvider.currentMapGun.offset,
                        end: newMarker,
                        color: !isCalcExceed ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.error,
                        width: 2.5 / scale,
                      );
                    });
                  },
                ),
              if (newMarker.dy >= 0 && newMarker.dx >= 0)
                Positioned(
                  top: newMarker.dy - 1.5,
                  left: newMarker.dx - 1.5,
                  child: WaveBorder(
                    count: 3,
                    width: 3,
                    maxWidth: 50,
                    borderColor: Theme.of(context).colorScheme.primary.withOpacity(.5),
                    child: const SizedBox(),
                  ),
                ),

              /// 选择坐标
              if (newMarker.dy >= 0 || newMarker.dx >= 0)
                Positioned(
                  left: newMarker.dx,
                  top: newMarker.dy,
                  width: markerSize,
                  height: markerSize,
                  child: StreamBuilder(
                    stream: stream.stream,
                    builder: (context, snapshot) {
                      double scale = snapshot.data ?? transformation.value[0];
                      return Transform.translate(
                        offset: const Offset(-markerSize / 2, (-markerSize / 2)),
                        child: AnimatedScale(
                          scale: 1 / scale,
                          duration: const Duration(milliseconds: 300),
                          child: ArtyIconWidget(
                            onPressed: () => _openNewGunPointModal(),
                            resultNumber: App.provider.ofMap(context).currentMapGun.result!.outputValue,
                          ),
                        ),
                      );
                    },
                  ),
                ),

              /// 火炮位置
              ...widget.mapProvider.currentMapInfo.gunPositions.map((i) {
                return Positioned(
                  left: i.offset.dx,
                  top: i.offset.dy,
                  child: StreamBuilder(
                    stream: stream.stream,
                    builder: (context, snapshot) {
                      final scale = snapshot.data ?? transformation.value[0];

                      if (_scale < 1.7) {
                        return Transform.translate(
                          offset: const Offset(-20, -20),
                          child: AnimatedScale(
                            duration: const Duration(milliseconds: 300),
                            scale: 1 / scale,
                            child: CupertinoButton(
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                setState(() {
                                  widget.mapProvider.currentMapGun = i;
                                });

                                _openGunDetailModal(i, onEvent: (value) => setState(() {}));
                              },
                              child: Container(
                                width: 5,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: i.name == widget.mapProvider.currentMapGun.name ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.primary.withOpacity(.5),
                                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                                ),
                              ),
                            ),
                          ),
                        );
                      }

                      return AnimatedScale(
                        duration: const Duration(milliseconds: 350),
                        scale: 1 / scale,
                        alignment: Alignment.bottomCenter,
                        child: Transform.translate(
                          offset: Offset(scale * .3, 12),
                          child: IconButton.filled(
                            isSelected: i.name == widget.mapProvider.currentMapGun.name,
                            visualDensity: const VisualDensity(horizontal: -1, vertical: -1),
                            color: Theme.of(context).colorScheme.primary,
                            onPressed: () => _openNewGunPointModal(),
                            icon: MapUtil().putArtyIcon,
                          ),
                        ),
                      );
                    },
                  ),
                );
              }).toList(),

              /// 坐标
              ...widget.mapProvider.currentMapInfo.markerPointAll.where((e) {
                // 检查图层管理开关是否开启
                return markerManagementSwitch.value[e.iconType] == true;
              }).map(
                (i) => Positioned(
                  left: i.x - markerSize / 2,
                  top: i.y - -markerSize,
                  width: markerSize,
                  height: markerSize,
                  child: StreamBuilder(
                    stream: stream.stream,
                    builder: (context, snapshot) {
                      final scale = snapshot.data ?? transformation.value[0];
                      return AnimatedScale(
                        duration: const Duration(milliseconds: 350),
                        scale: 1 / scale,
                        alignment: Alignment.bottomCenter,
                        child: CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: () => {},
                          child: IconButton.filledTonal(
                            onPressed: () => _openIconModal(i),
                            icon: MapUtil().mapInfoMarkerItem_FllAsIcon(i),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LinePainter extends CustomPainter {
  late Paint _paint;
  Offset start, end;
  Color? color;
  double? width;

  LinePainter(
    this.start,
    this.end, {
    this.color,
    this.width,
  }) {
    _paint = Paint()
      ..color = color!
      ..strokeWidth = width ?? 2.5
      ..strokeCap = StrokeCap.square;
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawLine(start, end, _paint);
  }

  @override
  bool shouldRepaint(LinePainter oldDelegate) {
    return oldDelegate.start != start || oldDelegate.end != end;
  }
}

class LineWidget extends StatelessWidget {
  final Offset start, end;
  final Color? color;
  final double? width;

  const LineWidget({
    super.key,
    required this.start,
    required this.end,
    this.color,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: LinePainter(start, end, color: color, width: width),
    );
  }
}

class ArtyIconWidget extends StatelessWidget {
  final VoidCallback? onPressed;
  final String resultNumber;
  final Color headerColor = const Color(0xffffd27c);
  final Color color = const Color(0xffe5b452);
  final double opacity = .9;

  const ArtyIconWidget({
    super.key,
    this.onPressed,
    this.resultNumber = "0",
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      pressedOpacity: .8,
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: -12,
            left: 0,
            right: 0,
            child: Container(
              height: 14,
              decoration: BoxDecoration(
                color: headerColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(2),
                  topRight: Radius.circular(2),
                ),
              ),
              child: Wrap(
                runAlignment: WrapAlignment.center,
                alignment: WrapAlignment.center,
                children: [
                  if (resultNumber.isEmpty)
                    const Icon(Icons.layers, size: 12)
                  else
                    Text(
                      resultNumber.toString(),
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                    ),
                ],
              ),
            ),
          ),
          ClipPath(
            clipBehavior: Clip.hardEdge,
            child: Container(
              color: color.withOpacity(opacity),
              height: 24,
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 24,
            child: ClipPath(
              clipBehavior: Clip.hardEdge,
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: const BorderSide(color: Colors.transparent, width: 10, style: BorderStyle.solid),
                    right: const BorderSide(color: Colors.transparent, width: 15, style: BorderStyle.solid),
                    left: const BorderSide(color: Colors.transparent, width: 15, style: BorderStyle.solid),
                    top: BorderSide(color: color.withOpacity(opacity), width: 10, style: BorderStyle.solid),
                  ),
                ),
                child: const SizedBox(),
              ),
            ),
          ),
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 5, left: 5, right: 5, bottom: 8),
              child: MapUtil().icon(
                MapInfoMarkerItem(
                  iconType: MapIconType.Arty,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
