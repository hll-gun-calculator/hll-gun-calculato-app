import 'dart:async';

import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';

import '/utils/index.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  final UrlUtil _urlUtil = UrlUtil();

  final Storage storage = Storage();

  // 状态机
  ProviderUtil providerUtil = ProviderUtil();

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
    Future.delayed(const Duration(seconds: 1)).then((value) =>
    {
      if (mounted)
        setState(() {
          _size = (MediaQuery
              .of(context)
              .size
              .width / 2) * .01;
        })
    });

    Future.wait([
      providerUtil.ofApp(context).init(),
      providerUtil.ofCalc(context).init(),
      providerUtil.ofTheme(context).init(),
      providerUtil.ofCollect(context).init(),
      providerUtil.ofLang(context).init(),
      providerUtil.ofMap(context).init(),
      providerUtil.ofHomeApp(context).init(),
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
    // ignore: use_build_context_synchronously
    _urlUtil.opEnPage(
      context,
      "/",
      transition: TransitionType.none,
      // clearStack: false,
      rootNavigator: true,
    );
  }

  /// [Event]
  /// 引导
  Future<bool> _onGuide() async {
    String guideName = "guide";

    StorageData guideData = await storage.get(guideName);
    dynamic guide = guideData.value;

    await _urlUtil.opEnPage(context, "/guide", transition: TransitionType.fadeIn).then((value) async {
      onMain();
      await storage.set(guideName, value: 1);
    });

    if (guideData.code != 0 && guide == null) {
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                color: Theme
                    .of(context)
                    .scaffoldBackgroundColor,
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
    );
  }
}
