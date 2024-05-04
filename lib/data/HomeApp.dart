import 'package:flutter/material.dart';

enum HomeAppType {
  None(name: "none"),
  Test(name: "test"),
  Calc(name: "gunCalc"),
  GunComparisonTable(name: "gunComparisonTable"),
  LandingTimer(name: "landingTimer"),
  Map(name: "map");

  final String name;

  const HomeAppType({
    required this.name,
  });
}

abstract class HomeAppWidget extends StatefulWidget {
  late String _name;

  HomeAppWidget({super.key});

  String get name => _name;
}

class HomeAppData {
  // 图标
  Icon icon;

  // 激活图标
  Icon activeIcon;

  // widget
  HomeAppWidget widget;

  // 类型
  HomeAppType type = HomeAppType.Calc;

  // 是否显示appbar
  bool isShowAppBar;

  HomeAppData({
    required this.icon,
    required this.activeIcon,
    required this.widget,
    required this.type,
    this.isShowAppBar = true,
  }) {
    widget._name = type.name;
  }
}
