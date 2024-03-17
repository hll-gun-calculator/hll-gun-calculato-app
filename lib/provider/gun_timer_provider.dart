import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '/data/Landing.dart';
import '/data/index.dart';

class GunTimerProvider with ChangeNotifier {
  AudioPlayer audioPlayer = AudioPlayer();

  num _maxLength = 30;

  // 是否播放声音
  bool isPlayAudio = true;

  // 下标
  int _index = 1;

  // 炮弹
  List<Landing> landings = [];

  // 是否数量最大
  bool get isLengthMax {
    return landings.where((element) => element.show).length > _maxLength;
  }

  // 声音高低
  double? volumeValue;

  Future init() async {
    audioPlayer.audioCache = AudioCache(prefix: "assets/audio/");
    audioPlayer.audioCache.loadAll(['coins.wav']);
    return true;
  }

  bool hasItemId(String id) {
    return landings.where((i) => i.id == id).isNotEmpty;
  }

  /// 设置播放声音高度
  GunTimerProvider setVolume (double volume) {
    volumeValue = volume;
    return this;
  }

  /// 添加计时
  GunTimerProvider add({
    String? id,
    Duration autoHiddenDuration = const Duration(seconds: 10),
    Duration duration = const Duration(seconds: 14),
    LandingType type = LandingType.None,
    bool isAutoShow = true,
    double? volume,
    Function(Landing l)? vanishCallback,
    Function(Landing l)? endCallback,
  }) {
    String _id;

    if (id == null) {
      _id = "$_index-${type.name}";
    } else {
      _id = "$id-${type.name}";
    }

    if (hasItemId(_id)) {
      throw "id已存在";
    }

    Landing l = Landing(
      id: _id,
      type: type,
      duration: duration,
      isTimerActive: true,
      countdownTime: duration,
    );

    landings.add(l);
    startCountdownTimer(
      l,
      autoHiddenDuration: autoHiddenDuration,
      vanishCallback: vanishCallback,
      endCallback: endCallback,
    );
    _index++;

    notifyListeners();
    return this;
  }

  /// 查询
  Landing getItem(String id, {LandingType type = LandingType.None}) {
    if (landings.isEmpty || landings.where((i) => i.id == id).isEmpty) {
      return Landing(id: id, type: type);
    }
    return landings.where((i) => i.id == id).first;
  }

  /// 计时
  void startCountdownTimer(
    Landing landing, {
    Duration autoHiddenDuration = const Duration(seconds: 10),
    Function(Landing l)? vanishCallback,
    Function(Landing l)? endCallback,
    bool isAutoShow = true,
  }) {
    Duration oneSec = const Duration(seconds: 1);

    landing.isTimerActive = true;
    landing.timer = Timer.periodic(oneSec, (timer) {
      if (landing.countdownTimeSeconds < 1) {
        _playAudio();
        landing.timer!.cancel();
        landing.isTimerActive = false;
        if (endCallback != null) endCallback(landing);

        Timer.periodic(autoHiddenDuration, (timer) {
          if (isAutoShow) landing.show = false;

          if (vanishCallback != null) vanishCallback(landing);
          notifyListeners();
        });
      } else {
        landing.countdownTimeSeconds = landing.countdownTimeSeconds - 1;
      }

      notifyListeners();
    });
  }

  /// 停止计时
  void stopTimer(Landing landing) {
    landing.timer!.cancel();
    landing.isTimerActive = false;
    notifyListeners();
  }

  /// 删除计时
  void deleteTimer(Landing landing) {
    stopTimer(landing);
    landings.removeWhere((i) => i.id == landing.id);
    notifyListeners();
  }

  void clearLandings() {
    if (landings.isEmpty) return;
    landings.clear();
    _index = 1;
    notifyListeners();
  }

  /// 播放声音
  void _playAudio({double? volume}) async {
    if (landings.isNotEmpty && isPlayAudio) {
      await audioPlayer.play(AssetSource("coins.wav"), volume: volume ?? this.volumeValue);
    }
  }
}
