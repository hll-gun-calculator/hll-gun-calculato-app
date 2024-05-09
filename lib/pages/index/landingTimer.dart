import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import '/constants/app.dart';
import '/data/index.dart';
import '/provider/gun_timer_provider.dart';

class LandingTimerPage extends HomeAppWidget {
  LandingTimerPage({super.key});

  @override
  State<LandingTimerPage> createState() => _LandingTimerPageState();
}

class _LandingTimerPageState extends State<LandingTimerPage> with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();

  // 总计倒计时
  final TextEditingController _textEditingController = TextEditingController(text: "14");

  // 计时结束后，多少秒隐藏
  final TextEditingController _textEditingControllerTimedRemovalValue = TextEditingController(text: "10");

  // 声音高度
  late double _volumeValue = .3;

  // 自动滚动底部
  bool isAutoScrollFooter = true;

  @override
  void initState() {
    ready();
    super.initState();
  }

  ready() async {
    var volume = await App.config.getAttr("landingTimer.volume");
    if (volume is double && volume != null) {
      _volumeValue = volume;
    }
  }

  /// 炮弹
  void _putLanding() async {
    GunTimerProvider gunTimerProvider = App.provider.ofGunTimer(context);

    if (gunTimerProvider.isLengthMax) {
      Fluttertoast.showToast(
        msg: "过多炮弹，请清理炮弹列表或等待炮弹自动取消",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
      );
      return;
    }

    gunTimerProvider
      ..setVolume(_volumeValue)
      ..add(duration: Duration(seconds: int.parse(_textEditingController.text)));

    _scrollFooter();
  }

  /// 滚动底部
  void _scrollFooter() {
    GunTimerProvider gunTimerProvider = App.provider.ofGunTimer(context);

    if (_scrollController.positions.isNotEmpty && gunTimerProvider.landings.isNotEmpty && isAutoScrollFooter) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

  /// 打开设置
  void _openSettingModal() {
    bool timedRemoval = true;
    bool keepRollingBottom = isAutoScrollFooter;
    bool isSoundValue = App.provider.ofGunTimer(context).isPlayAudio;

    showModalBottomSheet<void>(
      context: context,
      clipBehavior: Clip.hardEdge,
      useSafeArea: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (modalContext, modalSetState) {
            return Scaffold(
              appBar: AppBar(
                leading: const CloseButton(),
              ),
              body: ListView(
                children: [
                  CheckboxListTile(
                    value: timedRemoval,
                    title: Text(FlutterI18n.translate(context, "landingTimer.settings.autoRemovalComplete")),
                    onChanged: (v) {
                      modalSetState(() {
                        timedRemoval = v as bool;
                      });
                      App.config.updateAttr("landing_timer.timed_removal", timedRemoval);
                    },
                  ),
                  if (timedRemoval)
                    TextFormField(
                      decoration: InputDecoration(
                        hintText: "0",
                        helperText: FlutterI18n.translate(context, "landingTimer.settings.inputAutoRemovalCompleteHelperText"),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 15),
                        border: InputBorder.none,
                      ),
                      maxLength: 2,
                      controller: _textEditingControllerTimedRemovalValue,
                      onChanged: (v) {
                        modalSetState(() {
                          _textEditingControllerTimedRemovalValue.text = v;
                        });
                        App.config.updateAttr("landing_timer.timed_removal.time_value", _textEditingControllerTimedRemovalValue.text);
                      },
                    ),
                  const Divider(),
                  CheckboxListTile(
                    value: keepRollingBottom,
                    title: Text(FlutterI18n.translate(context, "landingTimer.settings.autoScrollFooter")),
                    subtitle: Text(FlutterI18n.translate(context, "landingTimer.settings.autoScrollFooterDescription")),
                    onChanged: (v) {
                      modalSetState(() {
                        keepRollingBottom = v as bool;
                      });
                      setState(() {
                        isAutoScrollFooter = v as bool;
                      });
                      App.config.updateAttr("landing_timer.keep_rolling_bottom", keepRollingBottom);
                    },
                  ),
                  CheckboxListTile(
                    value: isSoundValue,
                    title: Text(FlutterI18n.translate(context, "landingTimer.settings.soundValue")),
                    subtitle: Text(FlutterI18n.translate(context, "landingTimer.settings.soundValueDescription")),
                    onChanged: (v) {
                      modalSetState(() {
                        isSoundValue = v as bool;
                      });
                      setState(() {
                        App.provider.ofGunTimer(context).isPlayAudio = !(v as bool);
                      });
                      App.config.updateAttr("landing_timer.is_sound_value", isSoundValue);
                    },
                  ),
                  ListTile(
                    title: Text(FlutterI18n.translate(context, "landingTimer.settings.volume")),
                    subtitle: Text(FlutterI18n.translate(context, "landingTimer.settings.volumeDescription")),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 15),
                    child: Row(
                      children: [
                        const Icon(Icons.volume_mute),
                        Expanded(
                          flex: 1,
                          child: Slider(
                            label: (_volumeValue * 100).toStringAsFixed(0),
                            max: 1,
                            min: 0,
                            divisions: 50,
                            value: _volumeValue,
                            onChanged: (value) {
                              modalSetState(() {
                                _volumeValue = value;
                              });
                              App.config.updateAttr("landingTimer.volume", _volumeValue);
                            },
                          ),
                        ),
                        const Icon(Icons.volume_up),
                      ],
                    ),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// 炮弹状态Widget
  Widget _landingsSubtitleWidget(Landing landing) {
    if (landing.countdownTimeSeconds > 1 && landing.countdownTimeSeconds < 5) {
      return Text(FlutterI18n.translate(context, "landingTimer.landingCloseCompletion"));
    } else if (landing.countdownTimeSeconds <= 1) return Text(FlutterI18n.translate(context, "landingTimer.landingComplete"));
    return Text(FlutterI18n.translate(context, "landingTimer.landingInExecution"));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Consumer<GunTimerProvider>(
      builder: (BuildContext context, GunTimerProvider data, Widget? child) {
        return Column(
          children: [
            /// 炮弹推
            Expanded(
              child: data.landings.isNotEmpty || data.landings.where((i) => i.show).isNotEmpty
                  ? MediaQuery.removePadding(
                      context: context,
                      removeBottom: true,
                      child: ListView(
                        controller: _scrollController,
                        children: data.landings.where((element) => element.show).map((e) {
                          return Stack(
                            children: [
                              Positioned.fill(
                                child: Opacity(
                                  opacity: .1,
                                  child: LinearProgressIndicator(
                                    value: e.countdownTimeSeconds / e.duration.inSeconds * 1,
                                  ),
                                ),
                              ),
                              ListTile(
                                leading: Text("${e.countdownTimeSeconds}s"),
                                title: Text(e.id),
                                subtitle: _landingsSubtitleWidget(e),
                                trailing: Wrap(
                                  children: [
                                    IconButton.filled(
                                      color: Theme.of(context).colorScheme.primaryContainer,
                                      icon: e.isTimerActive ? const Icon(Icons.stop) : const Icon(Icons.play_arrow),
                                      onPressed: e.countdownTimeSeconds > 0 ? () {
                                        if (e.isTimerActive) {
                                          data.stopTimer(e);
                                          return;
                                        }

                                        data.startCountdownTimer(e, vanishCallback: (l) {
                                          _scrollFooter();
                                        });
                                      } : null,
                                    ),
                                    if (!e.isTimerActive)
                                      IconButton.filled(
                                        color: Theme.of(context).colorScheme.primaryContainer,
                                        icon: const Icon(Icons.delete),
                                        onPressed: () => data.deleteTimer(e),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    )
                  : Center(
                      child: Opacity(
                        opacity: .3,
                        child: Text(
                          FlutterI18n.translate(context, "landingTimer.nullPrompt"),
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
            ),

            /// tool
            Row(
              children: [
                Opacity(
                  opacity: data.landings.isEmpty ? .5 : 1,
                  child: IconButton(
                    tooltip: "清空列表",
                    onPressed: () {
                      data.clearLandings();
                    },
                    icon: const Icon(Icons.delete),
                  ),
                ),
                IconButton(
                  tooltip: "自动滚动底部",
                  onPressed: () {
                    setState(() {
                      isAutoScrollFooter = !isAutoScrollFooter;
                    });
                  },
                  icon: Icon(
                    isAutoScrollFooter ? Icons.swipe_down : Icons.stop_sharp,
                  ),
                ),
                const Expanded(child: SizedBox()),
                IconButton(
                  tooltip: "设置",
                  onPressed: () {
                    _openSettingModal();
                  },
                  icon: const Icon(Icons.settings),
                ),
              ],
            ),

            /// 计时面板
            const Divider(height: 1, thickness: 1),
            Container(
              color: Theme.of(context).primaryColor.withOpacity(.2),
              height: 200,
              padding: const EdgeInsets.only(
                bottom: kBottomNavigationBarHeight,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  SizedBox(
                    width: 80,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Card(
                          margin: const EdgeInsets.only(bottom: 3),
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: TextFormField(
                              readOnly: true,
                              controller: _textEditingController,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 20),
                              decoration: const InputDecoration.collapsed(hintText: "0"),
                              validator: (value) {
                                if (value is num && value as int > 0 && value as int < 30) return "0-30范围";
                                return null;
                              },
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton.outlined(
                              padding: EdgeInsets.zero,
                              visualDensity: const VisualDensity(vertical: -4, horizontal: -4),
                              onPressed: () {
                                setState(() {
                                  _textEditingController.text = (int.parse(_textEditingController.text) - 1).toString();
                                });
                              },
                              icon: const Icon(Icons.remove),
                            ),
                            IconButton.outlined(
                              padding: EdgeInsets.zero,
                              visualDensity: const VisualDensity(vertical: -4, horizontal: -4),
                              onPressed: () {
                                setState(() {
                                  _textEditingController.text = (int.parse(_textEditingController.text) + 1).toString();
                                });
                              },
                              icon: const Icon(Icons.add),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton.filled(
                    icon: const Icon(Icons.add, size: 80),
                    onPressed: () {
                      _putLanding();
                    },
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 80,
                    child: IconButton.filledTonal(
                      onPressed: () {
                        setState(() {
                          data.isPlayAudio = !data.isPlayAudio;
                        });
                      },
                      icon: Stack(
                        children: [
                          const Icon(
                            Icons.audiotrack,
                            size: 40,
                          ),
                          if (!data.isPlayAudio)
                            Positioned(
                              top: 10,
                              left: 6,
                              child: Transform(
                                transform: Matrix4.rotationZ(-.8),
                                child: Container(
                                  width: 4,
                                  height: 35,
                                  color: Theme.of(context).iconTheme.color,
                                ),
                              ),
                            )
                        ],
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

  @override
  bool get wantKeepAlive => true;
}

typedef RemovedItemBuilder<T> = Widget Function(T item, BuildContext context, Animation<double> animation);

class ListModel<E> {
  ListModel({
    required this.listKey,
    required this.removedItemBuilder,
    Iterable<E>? initialItems,
  }) : _items = List<E>.from(initialItems ?? <E>[]);

  final GlobalKey<AnimatedListState> listKey;
  final RemovedItemBuilder<E> removedItemBuilder;
  final List<E> _items;

  AnimatedListState? get _animatedList => listKey.currentState;

  void insert(int index, E item) {
    _items.insert(index, item);
    _animatedList!.insertItem(index);
  }

  E removeAt(int index) {
    final E removedItem = _items.removeAt(index);
    if (removedItem != null) {
      _animatedList!.removeItem(
        index,
        (BuildContext context, Animation<double> animation) {
          return removedItemBuilder(removedItem, context, animation);
        },
      );
    }
    return removedItem;
  }

  int get length => _items.length;

  E operator [](int index) => _items[index];

  int indexOf(E item) => _items.indexOf(item);
}
