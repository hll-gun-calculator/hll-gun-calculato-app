import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class LandingTimerPage extends StatefulWidget {
  const LandingTimerPage({super.key});

  @override
  State<LandingTimerPage> createState() => _LandingTimerPageState();
}

class _LandingTimerPageState extends State<LandingTimerPage> with AutomaticKeepAliveClientMixin {

  // 炮弹
  List<Landing> landings = [];

  int index = 1;

  ScrollController _scrollController = ScrollController();

  AudioPlayer audioPlayer = AudioPlayer();

  TextEditingController textEditingController = TextEditingController(text: "14");

  // 自动滚动底部
  bool isAutoScrollFooter = true;

  // 是否播放声音
  bool isPlayAudio = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // for (var element in landings) {
    //   element.timer!.cancel();
    // }
    super.dispose();
  }

  /// 炮弹
  void _putLanding() async {
    if (landings.where((element) => element.show).length > 30) {
      Fluttertoast.showToast(
        msg: "过多炮弹，请清理炮弹列表或等待炮弹自动取消",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
      );
      return;
    }

    setState(() {
      Landing l = Landing(
        id: index.toString(),
        duration: Duration(seconds: int.parse(textEditingController.text)),
        countdownTime: Duration(seconds: int.parse(textEditingController.text)),
      );

      landings.add(l);
      startCountdownTimer(l);
      index++;
    });

    scrollFooter();
  }

  /// 播放声音
  void _playAudio() async {
    if (landings.isNotEmpty && isPlayAudio) {
      await audioPlayer.play(AssetSource("audio/coins.wav"));
    }
  }

  /// 滚动底部
  void scrollFooter() {
    if (_scrollController.positions.isNotEmpty && landings.isNotEmpty && isAutoScrollFooter) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

  /// 计时
  void startCountdownTimer(Landing landing) {
    Duration oneSec = const Duration(seconds: 1);

    landing.timer = Timer.periodic(oneSec, (timer) {
      setState(() {
        if (landing.countdownTime < 1) {
          landing.timer!.cancel();
          _playAudio();

          Timer.periodic(const Duration(seconds: 10), (timer) {
            if (mounted) {
              setState(() {
                landing.show = false;
              });
            }

            scrollFooter();
          });
        } else {
          landing.countdownTime = landing.countdownTime - 1;
        }
      });
    });
  }

  /// 停止计时
  void stopTimer(Landing landing) {
    landing.timer!.cancel();
  }

  /// 删除计时
  void deleteTimer (Landing landing) {
    stopTimer(landing);
    landings.removeWhere((i) => i.id == landing.id);
  }

  /// 清空计时堆
  void clearLandings() {
    if (landings.isEmpty) return;
    setState(() {
      landings.clear();
      index = 1;
    });
  }

  /// 打开设置
  void _openSettingModal() {
    showModalBottomSheet<void>(
      context: context,
      clipBehavior: Clip.hardEdge,
      builder: (context) {
        return Scaffold(
          appBar: AppBar(
            leading: const CloseButton(),
          ),
          body: ListView(
            children: [
              CheckboxListTile(
                value: true,
                title: const Text("是否开启自动消息"),
                onChanged: (v) {},
              ),
              TextFormField(
                decoration: const InputDecoration(
                  hintText: "自动消失秒，范围0-50",
                  contentPadding: EdgeInsets.symmetric(horizontal: 15),
                  border: InputBorder.none,
                ),
                controller: TextEditingController(text: ""),
              ),
              const Divider(),
              CheckboxListTile(
                value: true,
                title: const Text("是否一直滚动底部"),
                subtitle: const Text("实时查看最新炮弹"),
                onChanged: (v) {},
              ),
              CheckboxListTile(
                value: true,
                title: const Text("落地声音"),
                subtitle: const Text("计时结束播放声音"),
                onChanged: (v) {},
              ),
            ],
          ),
        );
      },
    );
  }

  /// 炮弹状态widget
  Widget landingsSubtitleWidget(Landing landing) {
    if (landing.countdownTime > 1 && landing.countdownTime < 5) {
      return const Text("注意炮弹即将落地");
    } else if (landing.countdownTime <= 1) return const Text("已落地");
    return const Text("炮弹飞行中..");
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      children: [
        /// 炮弹推
        Expanded(
          child: landings.isNotEmpty || landings.where((i) => i.show).isNotEmpty
              ? Scrollbar(
                  child: ListView(
                    controller: _scrollController,
                    children: landings.where((element) => element.show).map((e) {
                      return Stack(
                        children: [
                          Positioned.fill(
                            child: Opacity(
                              opacity: .1,
                              child: LinearProgressIndicator(
                                value: e.countdownTime / e.duration.inSeconds * 1,
                              ),
                            ),
                          ),
                          ListTile(
                            leading: Text("${e.countdownTime}s"),
                            title: Text(e.id),
                            subtitle: landingsSubtitleWidget(e),
                            trailing: Wrap(
                              children: [
                                IconButton.filled(
                                  color: Theme.of(context).colorScheme.primaryContainer,
                                  icon: e.timer!.isActive ? const Icon(Icons.stop) : const Icon(Icons.play_arrow),
                                  onPressed: () {
                                    if (e.timer!.isActive) {
                                      stopTimer(e);
                                    } else {
                                      startCountdownTimer(e);
                                    }
                                  },
                                ),
                                if (!e.timer!.isActive)
                                  IconButton.filled(
                                    color: Theme.of(context).colorScheme.primaryContainer,
                                    icon: const Icon(Icons.delete),
                                    onPressed: () => deleteTimer(e),
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
              opacity: landings.isEmpty ? .5 : 1,
              child: IconButton(
                onPressed: () {
                  clearLandings();
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
                  controller: textEditingController,
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
                              textEditingController.text = (int.parse(textEditingController.text) - 1).toString();
                            });
                          },
                          icon: const Icon(Icons.remove),
                        ),
                        IconButton.outlined(
                          padding: EdgeInsets.zero,
                          visualDensity: const VisualDensity(vertical: -4, horizontal: -4),
                          onPressed: () {
                            setState(() {
                              textEditingController.text = (int.parse(textEditingController.text) + 1).toString();
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
                      isPlayAudio = !isPlayAudio;
                    });
                  },
                  icon: Stack(
                    children: [
                      const Icon(
                        Icons.audiotrack,
                        size: 40,
                      ),
                      if (!isPlayAudio)
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

class Landing {
  String id;
  late Duration duration;
  late int countdownTime;
  Timer? timer;
  bool show;

  Landing({
    this.id = "0",
    Duration? duration,
    Duration? countdownTime,
    this.timer,
    this.show = true,
  }) {
    this.duration = duration ?? const Duration(seconds: 14);
    this.countdownTime = countdownTime?.inSeconds ?? 14;
  }
}
