import 'dart:async';

import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

import '/utils/index.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  final UrlUtil _urlUtil = UrlUtil();

  final Storage _storage = Storage();

  // 状态机
  ProviderUtil _providerUtil = ProviderUtil();

  // 载入提示
  late String? loadTip = "";

  late double _size = 1;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _onReady();
    });
    super.initState();
  }

  /// [Event]
  /// 初始页面数据
  void _onReady() async {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          double boxWidth = MediaQuery.of(context).size.width;
          if (boxWidth > 800) {
            _size = 2.5;
            return;
          }

          _size = (boxWidth / 2) * .01;
        });
      }
    });

    Future.wait([
      _providerUtil.ofApp(context).init(),
      _providerUtil.ofCalc(context).init(),
      _providerUtil.ofTheme(context).init(),
      _providerUtil.ofCollect(context).init(),
      _providerUtil.ofLang(context).init(),
      _providerUtil.ofMap(context).init(),
      _providerUtil.ofHomeApp(context).init(),
      _providerUtil.ofGunTimer(context).init(),
      forcedAnimation(),
    ]).then((value) async {
      if (!await _onGuide()) return;

      onMain();
    });
  }

  Future forcedAnimation() async {
    await Future.delayed(const Duration(seconds: 2));
    return true;
  }

  /// [Event]
  /// 进入主程序
  void onMain() async {
    _urlUtil.opEnPage(
      context,
      "/",
      transition: TransitionType.none,
      // clearStack: false,
      // rootNavigator: true,
    );
  }

  /// [Event]
  /// 引导
  Future<bool> _onGuide() async {
    String guideName = "guide";

    StorageData guideData = await _storage.get(guideName);
    dynamic guide = guideData.value;

    if (guideData.code != 0 && guide == null) {
      await _urlUtil.opEnPage(context, "/guide", transition: TransitionType.fadeIn).then((value) async {
        onMain();
        await _storage.set(guideName, value: 1);
      });
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Title(
        title: FlutterI18n.translate(context, "splash.title"),
        color: Colors.black,
        child: Scaffold(
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Container(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedScale(
                        scale: _size,
                        curve: Curves.easeOutBack,
                        duration: const Duration(milliseconds: 300),
                        child: CircleAvatar(
                          radius: 30,
                          child: Image.asset("assets/splash/startup-icon.png"),
                        ),
                      ),
                      SizedBox(height: _size * 35),
                      const CircularProgressIndicator(),
                    ],
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
