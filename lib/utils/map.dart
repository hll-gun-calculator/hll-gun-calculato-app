import 'dart:ui';

import 'package:flutter/material.dart';

import '../data/index.dart';

class MapUtil {
  Widget _icon(dynamic mapItem) {
    if (mapItem.iconType == MapIconType.Url || mapItem.iconType == MapIconType.Assets) {
      return Text("${mapItem.iconType}需要path参数");
    }

    switch (mapItem.iconType) {
      // 自定义
      case MapIconType.Url:
        return Image.network(mapItem.iconPath!);
      case MapIconType.Assets:
        return Image.asset(mapItem.iconPath!);
      case MapIconType.None:
        return const Icon(Icons.help);
      // 内置
      default:
        return Image.asset(mapItem.iconType.path!);
    }
  }

  Widget mapInfoMarkerItemAsIcon(MapInfoMarkerItem mapItem) {
    return _icon(mapItem);
  }

  Widget mapInfoMarkerItem_FllAsIcon(MapInfoMarkerItem_Fll mapItem) {
    return _icon(mapItem);
  }

  /// 火炮位置
  Widget get putArtyIcon {
    return _icon(
      MapInfoMarkerItem(
        iconType: MapIconType.Arty,
      ),
    );
  }

  /// 炮击图标
  Widget get ArtyIcon {
    Color color = const Color(0xffe5b452);
    double opacity = .6;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          top: -12,
          left: 0,
          right: 0,
          child: Container(
            height: 12,
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(2),
                topRight: Radius.circular(2),
              ),
            ),
            child: const Wrap(
              runAlignment: WrapAlignment.center,
              alignment: WrapAlignment.center,
              children: [
                Icon(Icons.lock, size: 7),
                Icon(Icons.safety_check_outlined, size: 7)
              ],
            ),
          ),
        ),
        ClipPath(
          clipBehavior: Clip.hardEdge,
          child: Container(
            color: color.withOpacity(opacity),
            height: 20,
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          top: 20,
          child: ClipPath(
            clipBehavior: Clip.hardEdge,
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: const BorderSide(color: Colors.transparent, width: 10, style: BorderStyle.solid),
                  right: const BorderSide(color: Colors.transparent, width: 15, style: BorderStyle.solid),
                  left: const BorderSide(color: Colors.transparent, width: 15, style: BorderStyle.solid),
                  top: BorderSide(color: color.withOpacity(opacity), width: 10, style: BorderStyle.solid),
                ),
              ),
              child: const SizedBox(),
            ),
          ),
        ),
        Center(
          child: Container(
            margin: const EdgeInsets.only(top: 5, left: 5, right: 5, bottom: 8),
            child: _icon(
              MapInfoMarkerItem(
                iconType: MapIconType.Arty,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
