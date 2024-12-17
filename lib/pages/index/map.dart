import 'dart:async';
import 'dart:math';
import 'dart:ui';


import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hll_gun_calculator/constants/api.dart';
import 'package:hll_gun_calculator/widgets/map_image.dart';
import 'package:provider/provider.dart';

import '/component/_color/index.dart';
import '/component/_empty/index.dart';
import '/provider/gun_timer_provider.dart';
import '/provider/map_provider.dart';
import '/utils/map.dart';
import '/constants/app.dart';
import '/data/index.dart';
import '/provider/calc_provider.dart';
import '/utils/index.dart';
import '/widgets/map_card.dart';
import '/widgets/wave_border.dart';

class MapPage extends HomeAppWidget {
  MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> with AutomaticKeepAliveClientMixin {
  final GlobalKey<MapCoreState> _mapCoreKey = GlobalKey<MapCoreState>();

  I18nUtil i18nUtil = I18nUtil();

  bool _lock = false;

  Map<MapIconType, bool> _markerManagementSwitch = {};

  // 火炮下标
  List listTimerIndex = [];

  @override
  void initState() {
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
      Map currentGun = listTimerIndex.where((element) => element["id"] == id).first;

      // 添加
      gunTimerData.add(
        id: currentGun['id'],
        type: LandingType.MapGun,
        isAutoShow: true,
        endCallback: (l) {
          // 添加后更新
          currentGun['index'] = currentGun['index'] = currentGun['index'] + 1;
          currentGun['id'] = "${e.value.name}-${e.value.id}-${currentGun['index']}";
        },
      );
    });
  }

  /// 收藏
  void _collect(Gun gun) {
    App.provider.ofCollect(context).add(gun.result, gun.name);
    Fluttertoast.showToast(msg: "收藏添加");
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
                    App.url.opEnPage(context, "/setting/mapPackage").then((value) => modalSetState(() {
                          print(currentMapCompilation.name);
                        }));
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
                ...MapIconType.values.where((e) => e != MapIconType.Url || e != MapIconType.Assets || e != MapIconType.Arty).map((e) {
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
              child: Stack(
                children: [
                  mapData.hasMapCompilation
                      ? const Center(
                          child: Text("请选择地图合集"),
                        )
                      : Container(
                          color: Theme.of(context).colorScheme.primary.withOpacity(.1),
                          child: MapCore(
                            key: _mapCoreKey,
                            mapProvider: mapData,
                            inputFactions: App.provider.ofMap(context).currentMapGun.factions!,
                          ),
                        ),

                  /// tool
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: ClipRRect(
                      clipBehavior: Clip.antiAlias,
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaY: 10, sigmaX: 10),
                        child: Container(
                          color: Theme.of(context).colorScheme.background.withOpacity(.9),
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: () => _openMapsModal(),
                                icon: const Icon(Icons.map),
                              ),
                              IconButton(
                                onPressed: () => _openMarkerModal(),
                                icon: Icon(_markerManagementSwitch.values.where((v) => v == true).isNotEmpty ? Icons.layers : Icons.layers_outlined),
                              ),
                              PopupMenuButton(
                                icon: const Wrap(
                                  children: [
                                    Icon(Icons.center_focus_strong_rounded),
                                    Icon(Icons.arrow_drop_down),
                                  ],
                                ),
                                itemBuilder: (itemBuilder) => [
                                  PopupMenuItem(
                                    child: const Text("地图居中"),
                                    onTap: () {
                                      _mapCoreKey.currentState!.onResetMapPosition();
                                    },
                                  ),
                                  PopupMenuItem(
                                    child: const Text("定位火炮标居中"),
                                    onTap: () {
                                      _mapCoreKey.currentState!.onResetGunPosition();
                                    },
                                  ),
                                ],
                              ),
                              const Spacer(),
                              if (_lock)
                                IconButton(
                                  icon: const Icon(Icons.location_off_sharp),
                                  onPressed: () {
                                    setState(() {
                                      _mapCoreKey.currentState!.unlock();
                                      _lock = false;
                                    });
                                  },
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
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
                                    String inquireId = "$id-${LandingType.MapGun.name}"; // 查询id，与生成的id缺少类型
                                    return Stack(
                                      children: [
                                        if (gunTimerData.hasItemId(inquireId))
                                          Positioned.fill(
                                            child: Opacity(
                                              opacity: .3,
                                              child: LinearProgressIndicator(
                                                value: gunTimerData.getItem(inquireId).countdownTimeSeconds / gunTimerData.getItem(inquireId).duration.inSeconds * 1,
                                                backgroundColor: Colors.transparent,
                                              ),
                                            ),
                                          ),

                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            SelectionArea(
                                              child: Container(
                                                margin: const EdgeInsets.only(left: 55, top: 5),
                                                child: Wrap(
                                                  spacing: 10,
                                                  children: [
                                                    Text(i18nUtil.as(context, e.value.name)),
                                                    Text(FlutterI18n.translate(context, "basic.factions.${e.value.factions!.value}")),
                                                    Text(FlutterI18n.translate(context, "map.direction.${e.value.direction.name}")),
                                                  ],
                                                ),
                                              ),
                                            ),

                                            /// 火炮row
                                            Opacity(
                                              opacity: calcData.currentCalculatingFunction.hasChildValue(e.value.factions!) ? 1 : .5,
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: [
                                                  Expanded(
                                                    flex: 1,
                                                    child: Row(
                                                      children: [
                                                        Radio(
                                                          value: e.value,
                                                          toggleable: calcData.currentCalculatingFunction.hasChildValue(e.value.factions!),
                                                          groupValue: mapData.currentMapGun,
                                                          onChanged: (value) {
                                                            // 检查计算函数内对应阵营函数是否可用
                                                            if (!calcData.currentCalculatingFunction.hasChildValue(e.value.factions!)) return;

                                                            setState(() {
                                                              mapData.currentMapGun = e.value;
                                                              _calcResult();
                                                            });
                                                          },
                                                        ),
                                                        Expanded(
                                                          flex: 1,
                                                          child: Card(
                                                            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
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
                                                    onPressed: () => _putGunTimer(gunTimerData, inquireId, e, id),
                                                    icon: Column(
                                                      children: [
                                                        Stack(
                                                          children: [
                                                            if (gunTimerData.getItem(inquireId).isTimerActive) const Icon(Icons.timer) else const Icon(Icons.timer_outlined),
                                                          ],
                                                        ),
                                                        if (gunTimerData.getItem(inquireId).isTimerActive) Text(gunTimerData.getItem(inquireId).countdownTimeSeconds.toString()) else const Text("0")
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
                                                          _putGunTimer(gunTimerData, inquireId, e, id);
                                                          break;
                                                        case "collect":
                                                          _collect(e.value);
                                                          break;
                                                      }
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),

                                        /// tip 阵营不支持
                                        if (!calcData.currentCalculatingFunction.hasChildValue(e.value.factions!))
                                          Positioned.fill(
                                            child: ClipRRect(
                                              clipBehavior: Clip.hardEdge,
                                              child: Stack(
                                                children: [
                                                  BackdropFilter(
                                                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                                    child: const SizedBox(),
                                                  ),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 20),
                                                    color: Theme.of(context).colorScheme.error.withOpacity(.2),
                                                    child: Center(
                                                      child: Row(
                                                        children: [
                                                          Flexible(
                                                            flex: 1,
                                                            child: Text.rich(
                                                              TextSpan(
                                                                style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 15),
                                                                children: [
                                                                  WidgetSpan(child: Icon(Icons.error, color: Theme.of(context).colorScheme.error, size: 20)),
                                                                  const WidgetSpan(child: SizedBox(width: 5)),
                                                                  TextSpan(text: "此${FlutterI18n.translate(context, "basic.factions.${e.value.factions!.value}")}阵营所支持的${App.provider.ofCalc(context).currentCalculatingFunction.name}计算函数不支持，你可以更换其他函数"),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                          const SizedBox(width: 10),
                                                          OutlinedButton.icon(
                                                            icon: const Icon(Icons.help),
                                                            label: const Text("帮助", style: TextStyle(fontWeight: FontWeight.bold)),
                                                            onPressed: () => App.url.onPeUrl("${Config.apis["app_web_site"]!.url}/docs/map/help.html"),
                                                            style: ButtonStyle(
                                                              visualDensity: VisualDensity.compact,
                                                              foregroundColor: MaterialStatePropertyAll(Theme.of(context).colorScheme.error.withOpacity(.8)),
                                                              textStyle: MaterialStatePropertyAll(TextStyle(color: Theme.of(context).colorScheme.error.withOpacity(.8))),
                                                              side: MaterialStatePropertyAll(BorderSide(color: Theme.of(context).colorScheme.error.withOpacity(.2))),
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
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
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                    child: Row(
                      children: [
                        const Spacer(),
                        RawChip(
                          onPressed: () => App.url.opEnPage(context, "/calculatingFunctionConfig"),
                          padding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                          backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(.2),
                          avatar: const Icon(Icons.functions),
                          label: Row(
                            children: [
                              Text(calcData.currentCalculatingFunctionName),
                              const Icon(Icons.keyboard_arrow_down_outlined, size: 18),
                            ],
                          ),
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

  bool isMagnifying = false;

  // 地图加载状态
  bool mapLoading = true;

  // 图层管理控制
  ValueNotifier<Map<MapIconType, bool>> markerManagementSwitch = ValueNotifier({
    MapIconType.Arty: true,
    MapIconType.PresupposeArty: true,
    MapIconType.CollectArty: true,
    MapIconType.PlainGrid: false,
    MapIconType.ArtyRadius: true,
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

  /// 定位地图中心坐标
  void onResetMapPosition() {
    _resetMap();
    _scale = 1;
  }

  /// 定位火炮中心坐标
  void onResetGunPosition() {
    final size = MediaQuery.of(context).size;

    if (newMarker.dy < 0 && newMarker.dx < 0) return;

    // 初始显示地图全貌
    _scale = max(
      size.width / App.provider.ofMap(context).currentMapInfo.size.dx,
      size.height / App.provider.ofMap(context).currentMapInfo.size.dy,
    );
    transformation.value = Matrix4.identity()
      ..scale(_scale)
      ..translate(
        -(newMarker.dx / 2) - -(MediaQuery.of(context).size.width / 2),
        -(newMarker.dy + kToolbarHeight + 290 + 580),
      );
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
          -(mapBoxHeight + kToolbarHeight + 290 + 580),
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
    Gun gunInfo = App.provider.ofMap(context).currentMapGun;
    Offset gunOffsetSelect = gunInfo.offset;
    Factions? gunFactions = gunInfo.factions;

    setState(() {
      double distance = (gunOffsetSelect - newMarker).distance;
      double gridOnePx = (200 * 10) / App.provider.ofMap(context).currentMapInfo.size.dy;

      // 计算mil
      CalcResult result = _calcUtil.on(
        inputFactions: gunFactions!,
        inputValue: (distance * gridOnePx).ceil(),
        calculatingFunctionInfo: App.provider.ofCalc(context).currentCalculatingFunction,
      );

      // 添加计算会话历史
      App.provider.ofHistory(context).add(result);

      // 计算角度
      MapGunResult _mapGunResult = MapGunResult.fromJson(result.toJson());
      _mapGunResult.outputAngle = _calcUtil.onAngle(gunOffsetSelect, newMarker).outputAngle;
      _mapGunResult.outputValue = result.outputValue;
      _mapGunResult.inputOffset = gunOffsetSelect;
      _mapGunResult.targetOffset = newMarker;
      App.provider.ofMap(context).setCurrentMapGunResult(_mapGunResult);

      isLock.value = true;
    });
  }

  /// 地图标记计算
  void _onPositionCalcResult(dynamic detail) {
    if (isLock.value) return;

    if (App.provider.ofMap(context).currentMapGun == null) {
      Fluttertoast.showToast(msg: "请选择火炮后再标记");
      return;
    }

    if (!App.provider.ofCalc(context).currentCalculatingFunction.hasChildValue(App.provider.ofMap(context).currentMapGun.factions!)) {
      Fluttertoast.showToast(msg: "当前阵营或计算函数不支持");
      return;
    }

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
    return Consumer<CalcProvider>(
      builder: (consumerContext, calcData, consumerWidget) {
        return GestureDetector(
          key: _mapBoxKey,
          onHorizontalDragUpdate: (details) {
            setState(() {
              transformation.value = transformation.value..translate(details.delta.dx * 3, 0, 0);
            });
          },
          onTapUp: (d) {
            setState(() {
              isMagnifying = true;
            });
          },
          onTapCancel: () {
            setState(() {
              isMagnifying = false;
            });
          },
          onTapDown: (d) {
            setState(() {
              isMagnifying = true;
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
                    child: MapImageWidget(
                      assets: widget.mapProvider.currentMapInfo.assets!,
                      width: widget.mapProvider.currentMapInfo.size.dx,
                      height: widget.mapProvider.currentMapInfo.size.dy,
                    ),
                  ),

                  /// 其他孩子-地图图层
                  ...widget.mapProvider.currentMapInfo.childs.where((e) {
                    // 检查图层管理开关是否开启
                    return markerManagementSwitch.value[e.type] == true;
                  }).map((e) {
                    return IgnorePointer(
                      ignoring: true,
                      child: MapImageWidget(
                        assets: e,
                        width: widget.mapProvider.currentMapInfo.size.dx,
                        height: widget.mapProvider.currentMapInfo.size.dy,
                      ),
                    );
                  }).toList(),

                  /// 火炮范围-地图图层
                  if (widget.mapProvider.currentMapInfo.gunRangeChilds.isNotEmpty && widget.mapProvider.currentMapInfo.gunRangeChilds[App.provider.ofMap(context).currentMapGun.direction] != null && markerManagementSwitch.value[MapIconType.ArtyRadius]!)
                    StreamBuilder(
                      stream: stream.stream,
                      builder: (context, snapshot) {
                        MapInfoAssets? currentGunAssets = widget.mapProvider.currentMapInfo.gunRangeChilds[App.provider.ofMap(context).currentMapGun.direction];

                        return IgnorePointer(
                          ignoring: true,
                          child: MapImageWidget(
                            assets: currentGunAssets ?? widget.mapProvider.currentMapInfo.gunRangeChilds.values.first,
                            width: widget.mapProvider.currentMapInfo.size.dx,
                            height: widget.mapProvider.currentMapInfo.size.dy,
                          ),
                        );
                      },
                    ),

                  /// 坐标
                  ...widget.mapProvider.currentMapInfo.markerPointAll.where((e) {
                    // 检查图层管理开关是否开启
                    return markerManagementSwitch.value[e.iconType] == true;
                  }).map((i) => Positioned(
                        left: i.x - markerSize / 2,
                        top: i.y - -markerSize,
                        width: markerSize,
                        height: markerSize,
                        child: StreamBuilder(
                          stream: stream.stream,
                          builder: (context, snapshot) {
                            final scale = snapshot.data ?? transformation.value[0];
                            // Convert actual distance
                            double gridOnePx = (200 * 10) / App.provider.ofMap(context).currentMapInfo.size.dy;
                            // Current mark and mark distance
                            double targetDistance = (Offset(i.x, i.y) - newMarker).distance * gridOnePx;
                            double minimumHiddenIconDistance = 100;

                            return AnimatedScale(
                              duration: const Duration(microseconds: 250),
                              scale: 1 / scale,
                              alignment: Alignment.bottomCenter,
                              child: MapPrefabricateGunMarkersIcon(
                                isShowUpIcon: targetDistance > minimumHiddenIconDistance && Offset(i.x, i.y) != newMarker,
                                onPressed: () => _openIconModal(i),
                              ),
                            );
                          },
                        ),
                      )),

                  /// 新坐标连线
                  if (newMarker.dy >= 0 && newMarker.dx >= 0)
                    StreamBuilder(
                      stream: stream.stream,
                      builder: (context, snapshot) {
                        final scale = snapshot.data ?? transformation.value[0];
                        Factions factions = widget.inputFactions;
                        bool isCalcExceed = (num.parse(widget.mapProvider.currentMapGun.result!.inputValue) > calcData.currentCalculatingFunction.child[factions]!.maximumRange) || (num.parse(widget.mapProvider.currentMapGun.result!.inputValue) < calcData.currentCalculatingFunction.child[factions]!.minimumRange);

                        return LineWidget(
                          start: widget.mapProvider.currentMapGun.offset,
                          end: newMarker,
                          color: !isCalcExceed ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.error,
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
                          Factions factions = widget.inputFactions;
                          bool isCalcExceed = (num.parse(widget.mapProvider.currentMapGun.result!.inputValue) > calcData.currentCalculatingFunction.child[factions]!.maximumRange) || (num.parse(widget.mapProvider.currentMapGun.result!.inputValue) < calcData.currentCalculatingFunction.child[factions]!.minimumRange);

                          return Transform.translate(
                            offset: const Offset(-markerSize / 2, (-markerSize / 2)),
                            child: AnimatedScale(
                              scale: 1 / scale,
                              duration: const Duration(microseconds: 250),
                              child: MapGunMarkersIcon(
                                headerColor: !isCalcExceed ? null : Theme.of(context).colorScheme.error,
                                color: !isCalcExceed ? null : Theme.of(context).colorScheme.error,
                                onPressed: () => _openNewGunPointModal(),
                                resultNumber: isCalcExceed ? 'N/A' : App.provider.ofMap(context).currentMapGun.result!.outputValue,
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                  /// 放大镜
                  if (isMagnifying && (newMarker.dy >= 0 || newMarker.dx >= 0))
                    Positioned(
                      left: newMarker.dx - 200,
                      top: newMarker.dy - 200,
                      child: StreamBuilder(
                        stream: stream.stream,
                        builder: (context, snapshot) {
                          double scale = snapshot.data ?? transformation.value[0];

                          return Transform.translate(
                            offset: const Offset(-0, -400),
                            child: RawMagnifier(
                              decoration: MagnifierDecoration(
                                shape: CircleBorder(
                                  side: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2 / scale),
                                ),
                                shadows: [
                                  BoxShadow(color: Colors.black.withOpacity(.2), blurRadius: 10, spreadRadius: 10),
                                ],
                              ),
                              size: const Size(400, 400),
                              focalPointOffset: const Offset(0, 400),
                              magnificationScale: 1.3,
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
                              offset: const Offset(-2.5, -2.5),
                              child: AnimatedScale(
                                duration: const Duration(microseconds: 250),
                                scale: 1 / scale,
                                child: GestureDetector(
                                  onTap: () {
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
                ],
              ),
            ),
          ),
        );
      },
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
  });

  @override
  void paint(Canvas canvas, Size size) {
    _paint = Paint()
      ..color = color!
      ..strokeWidth = width ?? 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;

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
