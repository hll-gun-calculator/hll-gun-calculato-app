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
    Future.delayed(const Duration(seconds: 1)).then((value) => {
          if (mounted)
            setState(() {
              _size = 1.5;
            })
        });

    await providerUtil.ofApp(context).init();
    await providerUtil.ofCalc(context).init();
    await providerUtil.ofTheme(context).init();
    await providerUtil.ofCollect(context).init();
    await providerUtil.ofLang(context).init();
    await providerUtil.ofMap(context).init();

    onMain();
  }

  /// [Event]
  /// 进入主程序
  void onMain() async {
    // ignore: use_build_context_synchronously
    _urlUtil.opEnPage(
      context,
      "/",
      transition: TransitionType.none,
      clearStack: false,
      rootNavigator: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
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
                      child: const CircleAvatar(
                        radius: 30,
                        child: Icon(Icons.calculate),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              minHeight: 1,
              color: Theme.of(context).colorScheme.primary,
              backgroundColor: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
            ),
          ],
        ),
      ),
    );
  }
}
