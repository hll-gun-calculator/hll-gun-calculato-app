import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:ui';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hll_gun_calculator/constants/api.dart';
import 'package:hll_gun_calculator/data/Gun.dart';
import 'package:hll_gun_calculator/provider/map_provider.dart';
import 'package:hll_gun_calculator/utils/calc.dart';
import 'package:hll_gun_calculator/utils/map.dart';
import 'package:provider/provider.dart';

import '../../constants/app.dart';
import '../../data/index.dart';
import '../../provider/calc_provider.dart';
import '../../widgets/map_card.dart';
import '../../widgets/wave_border.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _mapPageState();
}

class _mapPageState extends State<MapPage> {
  GlobalKey<MapCoreState> _mapCoreKey = GlobalKey<MapCoreState>();

  Factions inputFactions = Factions.None;

  MapGunResult mapGunResult = MapGunResult();

  bool _lock = false;

  Map<MapIconType, bool> _markerManagementSwitch = {};

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _mapCoreKey.currentState!.mapGunResult.addListener(() {
        setState(() {
          mapGunResult = _mapCoreKey.currentState!.mapGunResult.value;
        });
      });

      _mapCoreKey.currentState!.isLock.addListener(() {
        _lock = _mapCoreKey.currentState!.isLock.value;
      });

      _markerManagementSwitch = _mapCoreKey.currentState!.markerManagementSwitch.value;
      _mapCoreKey.currentState!.markerManagementSwitch.addListener(() {
        _markerManagementSwitch = _mapCoreKey.currentState!.markerManagementSwitch.value;
      });
    });
    super.initState();
  }

  /// 选择阵营
  void _openSelectFactions() {
    showModalBottomSheet<void>(
      context: context,
      clipBehavior: Clip.hardEdge,
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
    MapCompilation i = App.provider.ofMap(context).currentMapCompilation;
    MapInfo? newMapInfo;

    showModalBottomSheet<void>(
      context: context,
      clipBehavior: Clip.hardEdge,
      scrollControlDisabledMaxHeightRatio: .8,
      builder: (context) {
        return StatefulBuilder(builder: (context, modalSetState) {
          return Scaffold(
            appBar: AppBar(
              leading: const CloseButton(),
              actions: [
                IconButton(
                  onPressed: () {
                    modalSetState(() {
                      if (newMapInfo == null) {
                        Fluttertoast.showToast(msg: "请先选择一个地图");
                        return;
                      }
                      App.provider.ofMap(context).currentMapInfo = newMapInfo!;
                    });
                  },
                  icon: const Icon(Icons.done),
                ),
              ],
            ),
            body: ListView(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  child: const SearchBar(
                    hintText: "搜索地图",
                    elevation: MaterialStatePropertyAll(0),
                    leading: Icon(Icons.search),
                  ),
                ),
                const Divider(),
                ...i.data.asMap().entries.map((e) {
                  return MapCardWidget(
                    i: e.value,
                    selected: newMapInfo?.name ?? i.data.first.name,
                    onTap: () {
                      modalSetState(() {
                        newMapInfo = e.value;
                      });
                    },
                  );
                }).toList(),
                const Divider(),
                Align(
                  child: Text("by ${i.name}"),
                ),
              ],
            ),
          );
        });
      },
    );
  }

  /// 打开图层筛选器
  void _openMarkerModal() {
    bool all = _markerManagementSwitch.values.every((v) => v == true) ?? false;
    showModalBottomSheet<void>(
      context: context,
      clipBehavior: Clip.hardEdge,
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
                    title: Text(e.value),
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
    return Consumer2<CalcProvider, MapProvider>(
      builder: (context, calcData, mapData, widget) {
        return Column(
          children: [
            Expanded(
              flex: 1,
              child: Container(
                color: Theme.of(context).colorScheme.primary.withOpacity(.1),
                child: MapCore(key: _mapCoreKey, mapProvider: mapData),
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
                IconButton(
                  onPressed: () {
                    _mapCoreKey.currentState!.scale("+");
                  },
                  icon: const Icon(Icons.add),
                ),
                IconButton(
                  onPressed: () {
                    _mapCoreKey.currentState!.scale("-");
                  },
                  icon: const Icon(Icons.remove),
                ),
              ],
            ),

            const Divider(height: 1, thickness: 1),

            /// 控制器
            Container(
              height: 200,
              color: Theme.of(context).colorScheme.primary.withOpacity(.2),
              padding: const EdgeInsets.only(bottom: 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// 附件选项
                  Wrap(
                    children: [
                      const SizedBox(width: 48),
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
                      const SizedBox(width: 5),
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
                  const Divider(height: 1, thickness: 1),

                  /// 火炮列表
                  Flexible(
                    child: MediaQuery.removePadding(
                      context: context,
                      removeTop: true,
                      child: ListView(
                        children: mapData.currentMapInfo.gunPosition.asMap().entries.map((e) {
                          return GestureDetector(
                            child: Row(
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
                                        },
                                      ),
                                      IconButton(
                                        onPressed: () {},
                                        icon: Card(
                                          color: e.value.color.withOpacity((e.key + .5) * 0.2),
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
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Column(
                                          children: [
                                            Card(
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 15),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text(
                                                      mapGunResult.inputValue.toString(),
                                                      style: const TextStyle(
                                                        fontSize: 28,
                                                      ),
                                                    ),
                                                    const Icon(Icons.chevron_right),
                                                    Column(
                                                      crossAxisAlignment: CrossAxisAlignment.end,
                                                      children: [
                                                        Text(
                                                          mapGunResult.outputValue,
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            color: Theme.of(context).primaryColor,
                                                          ),
                                                        ),
                                                        Text(
                                                          "${mapGunResult.outputAngle.ceil()}",
                                                          style: const TextStyle(fontSize: 12),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                /// map button
                                IconButton.filledTonal(
                                  onPressed: () {},
                                  icon: const Icon(Icons.timer_outlined),
                                ),
                                IconButton.filledTonal(
                                  onPressed: () {},
                                  icon: const Icon(Icons.star_border),
                                ),
                                if (_lock)
                                  IconButton.filled(
                                    onPressed: () {
                                      _mapCoreKey.currentState!.unlock();
                                      setState(() {
                                        _lock = false;
                                      });
                                    },
                                    icon: const Icon(Icons.restart_alt),
                                  ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        );
      },
    );
  }
}

const mapUrl = 'assets/images/maps/Carentan.png';
const mapSize = [1000.0, 1000.0];
const mapOrigin = [.0, .0];
const markerSize = 32.0;

class MapCore extends StatefulWidget {
  final MapProvider mapProvider;

  const MapCore({
    super.key,
    required this.mapProvider,
  });

  @override
  State<MapCore> createState() => MapCoreState();
}

class MapCoreState extends State<MapCore> {
  final transformation = TransformationController();

  final StreamController<double> stream = StreamController.broadcast();

  CalcUtil _calcUtil = CalcUtil();

  GlobalKey _mapBoxKey = GlobalKey();

  late MapCompilation mapCompilation;

  double _scale = 1;

  ValueNotifier<bool> isLock = ValueNotifier(false);

  ValueNotifier<MapGunResult> mapGunResult = ValueNotifier<MapGunResult>(MapGunResult());

  List<MarkerPointItem> marker = [];

  Offset newMarker = const Offset(-1, -1);

  // 图层管理控制
  ValueNotifier<Map<MapIconType, bool>> markerManagementSwitch = ValueNotifier({
    MapIconType.Arty: true,
    MapIconType.PresupposeArty: true,
    MapIconType.CollectArty: true,
    MapIconType.PlainGrid: false,
    MapIconType.ArtyRadius: false,
  });

  @override
  void initState() {
    initMap();
    super.initState();
  }

  /// 初始地图
  initMap() async {
    // todo test
    mapCompilation = widget.mapProvider.currentMapCompilation;
    print(mapCompilation);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final size = MediaQuery.of(context).size;
      // 初始显示地图全貌
      transformation.value.scale(
        max(size.width / mapSize[0], size.height / mapSize[1]),
      );
      setState(() {});
    });

    transformation.addListener(() {
      stream.sink.add(transformation.value[0]);
    });
  }

  /// 地图缩放
  void scale(type) {
    switch (type) {
      case "+":
        _scale = 1.2;
        break;
      case "-":
        _scale = 0.8;
        break;
    }
    print(_scale.toStringAsFixed(1));
    setState(() {
      transformation.value.scale(_scale);
    });
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
    double? size = _mapBoxKey.currentContext?.findRenderObject()?.paintBounds.size.height;

    _setNewMapPosition(
      -(mapSize[0] / 2) - -(MediaQuery.of(context).size.width),
      -(mapSize[1] / 2) - -(size! / 2) - -(kToolbarHeight + 50),
    );
  }

  /// 设置地图位置
  void _setNewMapPosition(double x, double y) {
    transformation.value = Matrix4.identity()..translate(x, y);
  }

  /// 设置地图图层
  void setMapLayer(MapIconType key, bool value) {
    setState(() {
      markerManagementSwitch.value[key] = value;
    });
  }

  /// 地图标记计算
  void _onPositionCalcResult(TapDownDetails detail) {
    if (isLock.value) return;

    // 选中的火炮
    Offset gunPostionSelect = App.provider.ofMap(context).currentMapGun.offset;

    // 地图盒子高度
    double? size = _mapBoxKey.currentContext?.findRenderObject()?.paintBounds.size.height;

    // 对照标记居中
    _setNewMapPosition(
      -detail.localPosition.dx - -(MediaQuery.of(context).size.width / 2),
      -detail.localPosition.dy + (size! / 2),
    );

    setState(() {
      newMarker = detail.localPosition;
      double distance = (gunPostionSelect - newMarker).distance * 2.35;
      CalcResult result = _calcUtil.on(
        inputFactions: Factions.America,
        inputValue: distance.ceil(),
        calculatingFunctionInfo: App.provider.ofCalc(context).currentCalculatingFunction,
      );
      print(result.outputValue);
      // marker.add({"id": 0, "x": detail.localPosition.dx, "y": detail.localPosition.dy});
      // print(result.calculatingFunctionInfo.toJson());

      // 计算角度
      MapGunResult _mapGunResult = MapGunResult.fromJson(result.toJson());
      _mapGunResult.outputAngle = _calcUtil.onAngle(gunPostionSelect, newMarker).outputAngle;
      _mapGunResult.inputOffset = gunPostionSelect;
      _mapGunResult.targetOffset = newMarker;
      mapGunResult.value = _mapGunResult;
      print("角度:${_mapGunResult.outputAngle}");

      isLock.value = true;
    });
  }

  /// 打开火炮信息
  void _openGunDetailModal(Gun gunInfo) {
    showModalBottomSheet<void>(
      context: context,
      clipBehavior: Clip.hardEdge,
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
                    child: Container(
                      width: 50,
                      height: 50,
                      padding: const EdgeInsets.all(10),
                      child: MapUtil().putArtyIcon,
                    ),
                  ),
                  title: Text(gunInfo.name),
                ),
                const Divider(),
                ListTile(
                  title: const Text("坐标"),
                  trailing: Text("x:${gunInfo.offset.dx} y:${gunInfo.offset.dy}"),
                )
              ],
            ),
          );
        });
      },
    );
  }

  /// 打开图标信息
  void _openIconModal(MapInfoMarkerItem_Fll iconInfo) {
    showModalBottomSheet<void>(
      context: context,
      clipBehavior: Clip.hardEdge,
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
                  },
                  child: Text("Use"),
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

  /// 打开新坐标详情
  void _openNewGunPointModal() {
    showModalBottomSheet<void>(
      context: context,
      clipBehavior: Clip.hardEdge,
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
                    child: Container(
                      width: 50,
                      height: 50,
                      padding: EdgeInsets.all(10),
                      child: MapUtil().mapInfoMarkerItemAsIcon(MapInfoMarkerItem(iconType: MapIconType.Arty)),
                    ),
                  ),
                  title: Text("新标记"),
                ),
                const Divider(),
                ListTile(
                  title: const Text("x"),
                  trailing: Text("${newMarker.dx}"),
                ),
                ListTile(
                  title: const Text("y"),
                  trailing: Text("${newMarker.dy}"),
                )
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
      onHorizontalDragUpdate: (d) {
        // Prevent horizontal drag
        // You can customize this logic as needed
      },
      child: InteractiveViewer(
        boundaryMargin: const EdgeInsets.all(0),
        transformationController: transformation,
        constrained: false,
        maxScale: 1.5,
        minScale: 0.5,
        child: Container(
          width: mapSize[0],
          height: mapSize[1],
          padding: const EdgeInsets.only(top: kTextTabBarHeight + 50),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              /// 地图底层
              // FadeInImage(
              //   placeholder: const AssetImage('assets/images/maps/Carentan.png'),
              //   image: mapCompilation.data[0].assets!.image!,
              // ),

              GestureDetector(
                onTapDown: (TapDownDetails detail) => _onPositionCalcResult(detail),
                child: ExtendedImage(
                  image: mapCompilation.data[0].assets!.image!,
                  excludeFromSemantics: true,
                  loadStateChanged: (ExtendedImageState state) {
                    switch (state.extendedImageLoadState) {
                      case LoadState.completed:
                        return ExtendedRawImage(
                          image: state.extendedImageInfo?.image,
                        );
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
              ...mapCompilation.data[0].childs.where((e) {
                // 检查图层管理开关是否开启
                return markerManagementSwitch.value[e.type] == true;
              }).map((e) {
                return GestureDetector(
                  onTapDown: (TapDownDetails detail) => _onPositionCalcResult(detail),
                  child: ExtendedImage(image: e.image),
                );
              }).toList(),

              /// 新坐标连线
              if (newMarker.dy >= 0 && newMarker.dx >= 0)
                StreamBuilder(
                  stream: stream.stream,
                  builder: (context, snapshot) {
                    final scale = snapshot.data ?? transformation.value[0];
                    return LineWidget(
                      start: widget.mapProvider.currentMapGun.offset,
                      end: newMarker,
                      color: Theme.of(context).colorScheme.primary,
                      width: 2.5 / scale,
                    );
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

              /// 新坐标
              if (newMarker.dy >= 0 || newMarker.dx >= 0)
                Positioned(
                  left: newMarker.dx,
                  top: newMarker.dy,
                  width: markerSize,
                  height: markerSize,
                  child: StreamBuilder(
                    stream: stream.stream,
                    builder: (context, snapshot) {
                      final scale = snapshot.data ?? transformation.value[0];
                      const double boxSize = 33;
                      return Transform.translate(
                        offset: const Offset(-boxSize / 2, -boxSize - 5),
                        child: CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: () => _openNewGunPointModal(),
                          child: MapUtil().ArtyIcon,
                        ),
                      );
                    },
                  ),
                ),

              /// 火炮位置
              ...widget.mapProvider.currentMapInfo.gunPosition.map((i) {
                return Positioned(
                  left: i.offset.dx + mapOrigin[0] - markerSize / 2,
                  top: i.offset.dy + mapOrigin[1] - markerSize,
                  width: markerSize,
                  height: markerSize,
                  child: StreamBuilder(
                    stream: stream.stream,
                    builder: (context, snapshot) {
                      final scale = snapshot.data ?? transformation.value[0];

                      if (scale < 1.7) {
                        return Transform.translate(
                          offset: const Offset(0, 16),
                          child: CupertinoButton(
                            padding: EdgeInsets.zero,
                            onPressed: () {
                              setState(() {
                                widget.mapProvider.currentMapGun = i;
                              });
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
                  left: i.x + mapOrigin[0] - markerSize / 2,
                  top: i.y + mapOrigin[1] - markerSize,
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
      ..color = color! ?? Colors.red
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
