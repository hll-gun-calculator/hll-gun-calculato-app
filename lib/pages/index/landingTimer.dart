import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hll_gun_calculator/provider/gun_timer_provider.dart';
import 'package:provider/provider.dart';

import '../../constants/app.dart';
import '../../data/index.dart';

class LandingTimerPage extends StatefulWidget {
  const LandingTimerPage({super.key});

  @override
  State<LandingTimerPage> createState() => _LandingTimerPageState();
}

class _LandingTimerPageState extends State<LandingTimerPage> with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();

  final TextEditingController _textEditingController = TextEditingController(text: "14");

  // 自动滚动底部
  bool isAutoScrollFooter = true;

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

    gunTimerProvider.add(duration: Duration(seconds: int.parse(_textEditingController.text)));
    scrollFooter();
  }

  /// 滚动底部
  void scrollFooter() {
    GunTimerProvider gunTimerProvider = App.provider.ofGunTimer(context);

    if (_scrollController.positions.isNotEmpty && gunTimerProvider.landings.isNotEmpty && isAutoScrollFooter) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

  /// 打开设置
  void _openSettingModal() {
    bool timed_removal = true;
    String timed_removal_value = "5";
    bool keep_rolling_bottom = isAutoScrollFooter;
    bool is_sound_value = App.provider.ofGunTimer(context).isPlayAudio;

    showModalBottomSheet<void>(
      context: context,
      clipBehavior: Clip.hardEdge,
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
                    value: timed_removal,
                    title: const Text("是否开启自动移除"),
                    onChanged: (v) {
                      modalSetState(() {
                        timed_removal = v as bool;
                      });
                      App.config.updateAttr("landing_timer.timed_removal", timed_removal);
                    },
                  ),
                  if (timed_removal)
                    TextFormField(
                      decoration: const InputDecoration(
                        hintText: "0",
                        helperText: "自动消失秒，范围0-50",
                        contentPadding: EdgeInsets.symmetric(horizontal: 15),
                        border: InputBorder.none,
                      ),
                      controller: TextEditingController(text: timed_removal_value),
                      onChanged: (v) {
                        modalSetState(() {
                          timed_removal_value = v;
                        });
                        App.config.updateAttr("landing_timer.timed_removal.time_value", timed_removal_value);
                      },
                    ),
                  const Divider(),
                  CheckboxListTile(
                    value: keep_rolling_bottom,
                    title: const Text("是否一直滚动底部"),
                    subtitle: const Text("实时查看最新炮弹"),
                    onChanged: (v) {
                      modalSetState(() {
                        keep_rolling_bottom = v as bool;
                      });
                      setState(() {
                        isAutoScrollFooter = v as bool;
                      });
                      App.config.updateAttr("landing_timer.keep_rolling_bottom", keep_rolling_bottom);
                    },
                  ),
                  CheckboxListTile(
                    value: is_sound_value,
                    title: const Text("落地声音"),
                    subtitle: const Text("计时结束播放声音"),
                    onChanged: (v) {
                      modalSetState(() {
                        is_sound_value = v as bool;
                      });
                      setState(() {
                        App.provider.ofGunTimer(context).isPlayAudio = !(v as bool);
                      });
                      App.config.updateAttr("landing_timer.is_sound_value", is_sound_value);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// 炮弹状态widget
  Widget landingsSubtitleWidget(Landing landing) {
    if (landing.countdownTimeSeconds > 1 && landing.countdownTimeSeconds < 5) {
      return const Text("注意炮弹即将落地");
    } else if (landing.countdownTimeSeconds <= 1) return const Text("已落地");
    return const Text("炮弹飞行中..");
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
                  ? Scrollbar(
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
                                subtitle: landingsSubtitleWidget(e),
                                trailing: Wrap(
                                  children: [
                                    IconButton.filled(
                                      color: Theme.of(context).colorScheme.primaryContainer,
                                      icon: e.isTimerActive ? const Icon(Icons.stop) : const Icon(Icons.play_arrow),
                                      onPressed: () {
                                        if (e.isTimerActive) {
                                          data.stopTimer(e);
                                          return;
                                        }

                                        data.startCountdownTimer(e, vanishCallback: (l) {
                                          scrollFooter();
                                        });
                                      },
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
                  : const Center(
                      child: Opacity(
                        opacity: .3,
                        child: Text(
                          "请点击下方的 + 号,来模拟炮弹落地计时",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
            ),

            Row(
              children: [
                Opacity(
                  opacity: data.landings.isEmpty ? .5 : 1,
                  child: IconButton(
                    onPressed: () {
                      data.clearLandings();
                    },
                    icon: const Icon(Icons.delete),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      isAutoScrollFooter = !isAutoScrollFooter;
                    });
                  },
                  icon: Icon(
                    isAutoScrollFooter ? Icons.file_download_rounded : Icons.file_download_off_sharp,
                  ),
                ),
                const Expanded(child: SizedBox()),
                IconButton(
                  onPressed: () {
                    _openSettingModal();
                  },
                  icon: const Icon(Icons.settings),
                ),
              ],
            ),

            /// 计算
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
                    child: TextFormField(
                      readOnly: true,
                      controller: _textEditingController,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        counter: Row(
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
                      ),
                      validator: (value) {
                        if (value is num && value as int > 0 && value as int < 30) return "0-30范围";
                        return null;
                      },
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
                          if (data.isPlayAudio)
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
