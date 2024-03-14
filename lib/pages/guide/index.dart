/// 引导

import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:hll_gun_calculator/pages/guide/calculatingFunctionManagement.dart';
import 'package:hll_gun_calculator/pages/guide/keyboardManagement.dart';
import 'package:hll_gun_calculator/pages/guide/mapPackageManagement.dart';
import 'package:hll_gun_calculator/pages/guide/start.dart';

import '../../utils/index.dart';
import 'end.dart';
import 'homeAppSort.dart';


class GuidePage extends StatefulWidget {
  const GuidePage({Key? key}) : super(key: key);

  @override
  _GuidePageState createState() => _GuidePageState();
}

class _GuidePageState extends State<GuidePage> {
  final UrlUtil _urlUtil = UrlUtil();

  /// 引导下标
  int guideListPageIndex = 0;

  /// 引导页面列表
  late List<Widget> guideListPage = [
    const GuideStart(),
    const GuideCalculatingFunctionManagement(),
    const GuideMapPackageManagement(),
    const GuideKeyboardManagement(),
    GuideHomeAppSore(),
    GuideEnd(),
  ];

  /// 是否允许上一步
  bool disablePrev = false;

  /// 是否允许下一步
  bool disableNext = false;

  @override
  void initState() {
    for (var eventName in ['disable-prev', 'disable-next']) {
      eventUtil.on(eventName, (value) {
        setState(() {
          switch (eventName) {
            case 'disable-prev':
              disablePrev = value;
              break;
            case 'disable-next':
              disableNext = value;
              break;
          }
        });
      });
    }

    super.initState();
  }

  /// [Event]
  /// 上一步
  _onBacktrack() async {
    if (guideListPageIndex <= 0) return;

    setState(() {
      guideListPageIndex -= 1;
    });
  }

  /// [Event]
  /// 下一步
  _onNext() async {
    // 完成离开
    if (guideListPageIndex == guideListPage.length - 1) {
      await Storage().set("guide", value: "1");

      _urlUtil.popPage(context);
      return;
    }

    setState(() {
      if (guideListPageIndex <= guideListPage.length - 1) guideListPageIndex += 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: SafeArea(
        top: false,
        child: Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomRight,
                  colors: ProviderUtil().ofTheme(context).currentThemeName == "default" ? [Colors.transparent, Colors.black54] : [Colors.transparent, Colors.black12],
                ),
              ),
            ),
            backgroundColor: Colors.transparent,
          ),
          body: PageTransitionSwitcher(
            duration: const Duration(milliseconds: 150),
            transitionBuilder: (Widget child, Animation<double> primaryAnimation, Animation<double> secondaryAnimation) {
              return SharedAxisTransition(
                fillColor: Theme.of(context).scaffoldBackgroundColor,
                animation: primaryAnimation,
                secondaryAnimation: secondaryAnimation,
                transitionType: SharedAxisTransitionType.horizontal,
                child: child,
              );
            },
            child: guideListPage[guideListPageIndex],
          ),
          bottomNavigationBar: Container(
            color: Theme.of(context).bottomSheetTheme.backgroundColor,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AnimatedOpacity(
                  opacity: guideListPageIndex == 0 ? 0 : 1,
                  duration: const Duration(milliseconds: 300),
                  child: TextButton(
                    onPressed: disablePrev ? null : _onBacktrack,
                    child: Text(FlutterI18n.translate(context, "basic.button.prev")),
                  ),
                ),
                Text("${guideListPageIndex + 1} / ${guideListPage.length}"),
                ElevatedButton(
                  onPressed: disableNext ? null : _onNext,
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    disabledForegroundColor: Theme.of(context).colorScheme.primary.withOpacity(.5),
                    disabledBackgroundColor: Theme.of(context).colorScheme.primary.withOpacity(.2),
                  ),
                  child: guideListPageIndex + 1 < guideListPage.length
                      ? Text(FlutterI18n.translate(context, "basic.button.next"))
                      : Text(
                    FlutterI18n.translate(context, "basic.button.complete"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      onWillPop: () async {
        return false;
      },
    );
  }
}