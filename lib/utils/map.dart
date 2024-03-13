
import 'package:flutter/material.dart';

import '../data/index.dart';

class MapUtil {
  Widget icon(dynamic mapItem) {
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
    return icon(mapItem);
  }

  Widget mapInfoMarkerItem_FllAsIcon(MapInfoMarkerItem_Fll mapItem) {
    return icon(mapItem);
  }

  /// 火炮位置
  Widget get putArtyIcon {
    return icon(
      MapInfoMarkerItem(
        iconType: MapIconType.Arty,
      ),
    );
  }
}
