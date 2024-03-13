import 'dart:async';

class Landing {
  // id
  String id;

  // 倒计时间
  late Duration _duration;

  // 计时值
  late int _countdownTime;

  // 定时器
  Timer? timer;

  // 是否显示
  bool show;

  // 定时状态
  bool isTimerActive;

  // 类型
  LandingType? _type;

  Duration get duration => _duration;

  int get countdownTimeSeconds => _countdownTime;

  set countdownTimeSeconds(int seconds) => _countdownTime = seconds;

  LandingType? get type => _type;

  Landing({
    this.id = "0",
    Duration? duration,
    Duration? countdownTime,
    this.timer,
    this.show = true,
    this.isTimerActive = false,
    LandingType type = LandingType.None,
  }) {
    _duration = duration ?? const Duration(seconds: 14);
    _countdownTime = countdownTime?.inSeconds ?? 14;
    _type = type;
    if (timer != null) isTimerActive = timer!.isActive;
  }
}

enum LandingType {
  None,
  MapGun,
}
