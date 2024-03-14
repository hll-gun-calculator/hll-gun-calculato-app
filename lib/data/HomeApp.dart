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
  late String name;
  Icon icon;
  Icon activeIcon;
  Widget widget;
  HomeAppType type = HomeAppType.Calc;

  HomeAppData({
    required this.name,
    required this.icon,
    required this.activeIcon,
    required this.widget,
    required this.type,
  });
}
