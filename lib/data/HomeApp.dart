import 'package:flutter/material.dart';

enum HomeAppType {
  Calc(name: "Calc"),
  GunComparisonTable(name: "GunComparisonTable"),
  LandingTimer(name: "LandingTimer"),
  Map(name: "Map");

  final String name;

  const HomeAppType({
    required this.name,
  });
}

class HomeAppData {
  // 面板名称
  late String name;
  // 图标
  Icon icon;
  // 激活图标
  Icon activeIcon;
  // widget
  Widget widget;
  // 类型
  HomeAppType type = HomeAppType.Calc;
  // 是否显示appbar
  bool isShowAppBar;

  HomeAppData({
    required this.name,
    required this.icon,
    required this.activeIcon,
    required this.widget,
    required this.type,
    this.isShowAppBar = true,
  });
}
